import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What came of a purchase or restore.
enum PurchaseOutcome {
  /// Ads are gone.
  unlocked,

  /// The person closed the store's payment sheet.
  cancelled,

  /// The store accepted the order but the payment isn't through yet, as
  /// with some carrier billing and bank transfers.
  pending,

  /// A restore found nothing to restore.
  nothingToRestore,
}

/// The paid "no ads" unlock, sold through RevenueCat as a monthly or yearly
/// subscription or a one-time lifetime purchase. All three grant the same
/// [entitlementId].
class Premium {
  Premium._();

  /// The RevenueCat entitlement every plan grants.
  static const String entitlementId = 'ad_free';

  // Public SDK keys for the RevenueCat project "Baptist Hymnal"
  // (proj9d531b86): safe to ship in the app.
  static const String _appleKey = 'appl_OvlsuZMlMyhIzWDYPmQQetskmIV';
  static const String _googleKey = 'goog_guYJdhBxqRCgoztIWjnxsrXCocK';

  // RevenueCat's Test Store sells the same plans with no App Store or Google
  // Play behind it. Debug builds use it when run with
  // --dart-define=REVENUECAT_TEST_STORE=true; release builds never do, as
  // RevenueCat refuses its key there.
  static const String _testStoreKey = 'test_SYgMmRLIznMfyZtoNcdNXTRKQBh';
  static const bool _useTestStore = bool.fromEnvironment(
    'REVENUECAT_TEST_STORE',
  );

  // The last answer, so someone who paid sees no ads at launch, even offline.
  static const String _cacheKey = 'premium/adFree';

  /// Whether ads are removed.
  static final ValueNotifier<bool> isActive = ValueNotifier(false);

  /// The latest purchase details, once RevenueCat has answered.
  static final ValueNotifier<CustomerInfo?> customerInfo = ValueNotifier(null);

  /// Whether the store has plans to sell. Until it does (offline, or the
  /// products aren't live in the stores yet), the app offers nothing.
  static final ValueNotifier<bool> hasPlans = ValueNotifier(false);

  static bool _isConfigured = false;
  static Future<void>? _checkingPlans;
  static SharedPreferences? _prefs;

  static String get _apiKey {
    if (!kReleaseMode && _useTestStore) return _testStoreKey;
    if (Platform.isIOS) return _appleKey;
    if (Platform.isAndroid) return _googleKey;
    return '';
  }

  /// Reads the saved answer, then starts RevenueCat. Doesn't wait for the
  /// network: [isActive] updates when the purchase details arrive.
  static Future<void> initialize() async {
    final prefs = _prefs = await SharedPreferences.getInstance();
    isActive.value = prefs.getBool(_cacheKey) ?? false;

    final apiKey = _apiKey;
    if (apiKey.isEmpty || _isConfigured) return;
    try {
      if (kDebugMode) await Purchases.setLogLevel(LogLevel.debug);
      await Purchases.configure(PurchasesConfiguration(apiKey));
      _isConfigured = true;
      Purchases.addCustomerInfoUpdateListener(_update);
      unawaited(refresh());
      unawaited(checkPlans());
    } on PlatformException catch (e) {
      debugPrint('RevenueCat setup failed: ${e.message}');
    }
  }

  /// Looks for plans to sell, unless some were already found. Safe to call
  /// often, for example each time Settings is shown.
  static Future<void> checkPlans() {
    if (!_isConfigured || hasPlans.value) return Future.value();
    return _checkingPlans ??= () async {
      try {
        final offering = await currentOffering();
        hasPlans.value = offering?.availablePackages.isNotEmpty ?? false;
      } on PlatformException catch (e) {
        debugPrint('Fetching plans failed: ${e.message}');
      } finally {
        _checkingPlans = null;
      }
    }();
  }

  /// Asks RevenueCat again, for example after coming back online.
  static Future<void> refresh() async {
    if (!_isConfigured) return;
    try {
      _update(await Purchases.getCustomerInfo());
    } on PlatformException catch (e) {
      debugPrint('Fetching purchases failed: ${e.message}');
    }
  }

  /// The plans on sale, as set in the RevenueCat dashboard. Null when there
  /// are none, or the store can't be reached.
  static Future<Offering?> currentOffering() async {
    if (!_isConfigured) return null;
    final offerings = await Purchases.getOfferings();
    return offerings.current;
  }

  /// Of [productIds], the ones whose free trial this person can still take.
  /// Apple allows one trial per subscription group, so on iOS this asks the
  /// App Store. Google Play only offers trials to people who can take them,
  /// so on Android every trial counts.
  static Future<Set<String>> trialEligible(List<String> productIds) async {
    if (!_isConfigured || !Platform.isIOS) return productIds.toSet();
    try {
      final eligibility =
          await Purchases.checkTrialOrIntroductoryPriceEligibility(productIds);
      return {
        for (final MapEntry(:key, :value) in eligibility.entries)
          if (value.status ==
              IntroEligibilityStatus.introEligibilityStatusEligible)
            key,
      };
    } on PlatformException catch (e) {
      debugPrint('Checking trial eligibility failed: ${e.message}');
      return {};
    }
  }

  /// Tells RevenueCat the plans were shown, for its conversion charts.
  static void trackPaywallShown(Offering offering) {
    Purchases.trackCustomPaywallImpression(
      params: CustomPaywallImpressionParams(
        paywallId: 'remove_ads',
        offering: offering,
      ),
    ).catchError((Object e) => debugPrint('Paywall tracking failed: $e'));
  }

  /// The store page where a subscriber can cancel or change plans.
  static Uri get manageSubscriptionsUrl {
    final url = customerInfo.value?.managementURL;
    if (url != null) return Uri.parse(url);
    return Platform.isIOS
        ? Uri.parse('https://apps.apple.com/account/subscriptions')
        : Uri.parse('https://play.google.com/store/account/subscriptions');
  }

  /// Buys [package]. Throws a [PlatformException] for errors other than the
  /// ones [PurchaseOutcome] covers.
  static Future<PurchaseOutcome> purchase(Package package) async {
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      _update(result.customerInfo);
      return isActive.value
          ? PurchaseOutcome.unlocked
          : PurchaseOutcome.pending;
    } on PlatformException catch (e) {
      switch (PurchasesErrorHelper.getErrorCode(e)) {
        case PurchasesErrorCode.purchaseCancelledError:
          return PurchaseOutcome.cancelled;
        case PurchasesErrorCode.paymentPendingError:
          return PurchaseOutcome.pending;
        default:
          rethrow;
      }
    }
  }

  /// Finds earlier purchases made with this Apple ID or Google account.
  static Future<PurchaseOutcome> restore() async {
    _update(await Purchases.restorePurchases());
    return isActive.value
        ? PurchaseOutcome.unlocked
        : PurchaseOutcome.nothingToRestore;
  }

  /// The active purchase's entitlement, if any.
  static EntitlementInfo? get activeEntitlement =>
      customerInfo.value?.entitlements.active[entitlementId];

  /// "Monthly", "Yearly" or "Lifetime", for the active purchase.
  static String? get activePlanName {
    final entitlement = activeEntitlement;
    if (entitlement == null) return null;
    if (entitlement.expirationDate == null) return 'Lifetime';
    // App Store: bh_ad_free_yearly. Google Play: bh_ad_free, plan yearly.
    final id =
        '${entitlement.productIdentifier}:${entitlement.productPlanIdentifier}';
    if (id.contains('year') || id.contains('annual')) return 'Yearly';
    if (id.contains('month')) return 'Monthly';
    return null;
  }

  static void _update(CustomerInfo info) {
    customerInfo.value = info;
    final active = info.entitlements.active.containsKey(entitlementId);
    if (active == isActive.value) return;
    isActive.value = active;
    unawaited(_prefs?.setBool(_cacheKey, active));
  }
}
