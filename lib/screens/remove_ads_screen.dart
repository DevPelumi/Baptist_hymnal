import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../purchases/premium.dart';
import '../utils/analytics_tracker.dart';
import '../utils/platform_icons.dart';

const String privacyPolicyUrl =
    'https://baptisthymnal-website.vercel.app/privacy-policy';

// Apple's standard licence on iOS; the app's own terms on Android.
const String _appleTermsUrl =
    'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';
const String _androidTermsUrl =
    'https://baptisthymnal-website.vercel.app/terms-and-conditions';

/// Opens the page that sells the "no ads" plans. [source] says where it was
/// opened from, for analytics.
Future<void> showRemoveAds(BuildContext context, {required String source}) {
  AnalyticsTracker.logRemoveAdsViewed(source: source).catchError(
    (Object e) => debugPrint('Logging the remove ads page failed: $e'),
  );
  final Route<void> route = PlatformInfo.isIOS
      ? CupertinoPageRoute(
          fullscreenDialog: true,
          builder: (_) => const RemoveAdsScreen(),
        )
      : MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const RemoveAdsScreen(),
        );
  return Navigator.of(context, rootNavigator: true).push(route);
}

/// Finds an earlier purchase and says what came of it.
Future<void> restorePurchases(BuildContext context) async {
  try {
    final outcome = await Premium.restore();
    _logResult('restore', outcome.name);
    if (!context.mounted) return;
    await _showOutcome(context, outcome);
  } on PlatformException catch (e) {
    _logResult('restore', 'error');
    if (context.mounted) await _showError(context, e);
  }
}

/// The plans for removing ads, with their prices from the store.
class RemoveAdsScreen extends StatefulWidget {
  const RemoveAdsScreen({super.key, this.loadOffering});

  /// Stands in for the store in tests and previews.
  @visibleForTesting
  final Future<Offering?> Function()? loadOffering;

  @override
  State<RemoveAdsScreen> createState() => _RemoveAdsScreenState();
}

class _RemoveAdsScreenState extends State<RemoveAdsScreen> {
  late Future<Offering?> _offering = _loadOffering();
  Package? _selected;
  bool _busy = false;

  Future<Offering?> _loadOffering() async {
    final load = widget.loadOffering;
    final offering = await (load ?? Premium.currentOffering)();
    if (offering != null) {
      _selected ??= offering.annual ?? offering.monthly ?? offering.lifetime;
      if (load == null) Premium.trackPaywallShown(offering);
    }
    return offering;
  }

  Future<void> _buy(Package package) async {
    setState(() => _busy = true);
    try {
      final outcome = await Premium.purchase(package);
      _logResult(_planName(package), outcome.name);
      if (!mounted || outcome == PurchaseOutcome.cancelled) return;
      final navigator = Navigator.of(context);
      if (outcome == PurchaseOutcome.unlocked) navigator.pop();
      await _showOutcome(navigator.context, outcome);
    } on PlatformException catch (e) {
      _logResult(_planName(package), 'error');
      if (mounted) await _showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _busy = true);
    final navigator = Navigator.of(context);
    await restorePurchases(context);
    if (Premium.isActive.value && mounted) navigator.pop();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = _PaywallColors.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Stack(
          children: [
            FutureBuilder<Offering?>(
              future: _offering,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }
                final offering = snapshot.data;
                if (offering == null || paywallPlans(offering).isEmpty) {
                  return _Unavailable(
                    onRetry: () => setState(() => _offering = _loadOffering()),
                  );
                }
                return _content(context, offering, colors);
              },
            ),
            Align(
              alignment: PlatformInfo.isIOS
                  ? Alignment.topRight
                  : Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    platformIconData(
                      cupertino: CupertinoIcons.xmark_circle_fill,
                      material: Icons.close,
                    ),
                    size: PlatformInfo.isIOS ? 30 : 24,
                    color: PlatformInfo.isIOS
                        ? CupertinoColors.systemGrey3.resolveFrom(context)
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    Offering offering,
    _PaywallColors colors,
  ) {
    final plans = paywallPlans(offering);
    final selected = plans.contains(_selected) ? _selected! : plans.first;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  'assets/images/splash_logo.png',
                  width: 96,
                  height: 96,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Remove Ads',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: colors.label,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sing without interruptions, and help keep Baptist Hymnal going.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, color: colors.secondaryLabel),
            ),
            const SizedBox(height: 24),
            for (final benefit in const [
              'No banner ads under the words',
              'No full-screen ads between hymns',
              'Everything else stays the same',
            ])
              _Benefit(text: benefit, colors: colors),
            const SizedBox(height: 20),
            for (final plan in plans)
              _PlanTile(
                package: plan,
                badge: identical(plan, offering.annual)
                    ? yearlySavingsBadge(offering)
                    : null,
                selected: identical(plan, selected),
                colors: colors,
                onTap: _busy ? null : () => setState(() => _selected = plan),
              ),
            const SizedBox(height: 12),
            _ContinueButton(
              busy: _busy,
              onPressed: _busy ? null : () => _buy(selected),
            ),
            const SizedBox(height: 12),
            Text(
              planTerms(selected, ios: PlatformInfo.isIOS),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: colors.secondaryLabel),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                _LinkButton(
                  label: 'Restore Purchases',
                  onPressed: _busy ? null : _restore,
                ),
                _LinkButton(
                  label: 'Terms of Use',
                  onPressed: () => _open(
                    PlatformInfo.isIOS ? _appleTermsUrl : _androidTermsUrl,
                  ),
                ),
                _LinkButton(
                  label: 'Privacy Policy',
                  onPressed: () => _open(privacyPolicyUrl),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _open(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      debugPrint('Could not open $url');
    }
  }
}

/// The plans to show, yearly first as the one most people want.
@visibleForTesting
List<Package> paywallPlans(Offering offering) => [
  offering.annual,
  offering.monthly,
  offering.lifetime,
].whereType<Package>().toList();

/// "Save 40%" on the yearly plan, against twelve months of the monthly one.
/// Null when there's no monthly plan to compare with, or it saves little.
@visibleForTesting
String? yearlySavingsBadge(Offering offering) {
  final yearly = offering.annual?.storeProduct.price;
  final monthly = offering.monthly?.storeProduct.price;
  if (yearly == null || monthly == null || monthly <= 0) return null;
  // The small nudge stops 40% coming out as 39.999…, then 39.
  final percent = ((1 - yearly / (monthly * 12)) * 100 + 1e-9).floor();
  return percent >= 5 ? 'Save $percent%' : null;
}

/// What the store will charge and when, as both stores require.
@visibleForTesting
String planTerms(Package package, {required bool ios}) {
  final price = package.storeProduct.priceString;
  final store = ios ? 'Apple ID' : 'Google Play';
  final period = switch (package.packageType) {
    PackageType.annual => 'year',
    PackageType.monthly => 'month',
    _ => null,
  };
  if (period == null) return 'One payment of $price. No subscription.';
  return '$price a $period, charged to your $store account. It renews '
      'automatically unless you cancel at least 24 hours before the end of '
      'the $period. Cancel any time in your $store subscriptions.';
}

String _planName(Package package) => switch (package.packageType) {
  PackageType.annual => 'yearly',
  PackageType.monthly => 'monthly',
  PackageType.lifetime => 'lifetime',
  _ => package.identifier,
};

void _logResult(String plan, String outcome) {
  AnalyticsTracker.logRemoveAdsResult(plan: plan, outcome: outcome).catchError(
    (Object e) => debugPrint('Logging the remove ads result failed: $e'),
  );
}

Future<void> _showOutcome(BuildContext context, PurchaseOutcome outcome) {
  final account = PlatformInfo.isIOS ? 'Apple ID' : 'Google account';
  final (title, message) = switch (outcome) {
    PurchaseOutcome.unlocked => (
      'Thank You',
      'Ads are gone. Thank you for supporting Baptist Hymnal.',
    ),
    PurchaseOutcome.pending => (
      'Payment Pending',
      'Your payment is still going through. Ads will go as soon as it’s '
          'confirmed.',
    ),
    PurchaseOutcome.nothingToRestore => (
      'No Purchases Found',
      'There’s no earlier purchase to restore for this $account.',
    ),
    PurchaseOutcome.cancelled => ('', ''),
  };
  if (title.isEmpty) return Future.value();
  return AdaptiveAlertDialog.show(
    context: context,
    title: title,
    message: message,
    actions: [AlertAction(title: 'OK', onPressed: () {})],
  );
}

Future<void> _showError(BuildContext context, PlatformException error) {
  final message = switch (PurchasesErrorHelper.getErrorCode(error)) {
    PurchasesErrorCode.networkError ||
    PurchasesErrorCode.offlineConnectionError =>
      'Check your internet connection and try again.',
    PurchasesErrorCode.purchaseNotAllowedError =>
      'Purchases aren’t allowed on this device.',
    PurchasesErrorCode.productAlreadyPurchasedError =>
      'You’ve already bought this. Tap Restore Purchases to remove ads.',
    PurchasesErrorCode.storeProblemError =>
      'The store had a problem. Please try again later.',
    _ => 'Something went wrong. Please try again.',
  };
  debugPrint('Purchase failed: ${error.code} ${error.message}');
  return AdaptiveAlertDialog.show(
    context: context,
    title: 'Purchase Didn’t Go Through',
    message: message,
    actions: [AlertAction(title: 'OK', onPressed: () {})],
  );
}

class _PaywallColors {
  const _PaywallColors({
    required this.background,
    required this.card,
    required this.accent,
    required this.label,
    required this.secondaryLabel,
  });

  final Color background;
  final Color card;
  final Color accent;
  final Color label;
  final Color secondaryLabel;

  static _PaywallColors of(BuildContext context) {
    if (PlatformInfo.isIOS) {
      return _PaywallColors(
        background: CupertinoColors.systemGroupedBackground.resolveFrom(
          context,
        ),
        card: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(
          context,
        ),
        accent: CupertinoColors.systemGreen.resolveFrom(context),
        label: CupertinoColors.label.resolveFrom(context),
        secondaryLabel: CupertinoColors.secondaryLabel.resolveFrom(context),
      );
    }
    final scheme = Theme.of(context).colorScheme;
    return _PaywallColors(
      background: scheme.surface,
      card: scheme.surfaceContainerHigh,
      accent: scheme.primary,
      label: scheme.onSurface,
      secondaryLabel: scheme.onSurfaceVariant,
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.text, required this.colors});

  final String text;
  final _PaywallColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        children: [
          Icon(
            platformIconData(
              cupertino: CupertinoIcons.checkmark_circle_fill,
              material: Icons.check_circle,
            ),
            color: colors.accent,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 17, color: colors.label),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.package,
    required this.badge,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  final Package package;
  final String? badge;
  final bool selected;
  final _PaywallColors colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final product = package.storeProduct;
    final (title, price, detail) = switch (package.packageType) {
      PackageType.annual => (
        'Yearly',
        '${product.priceString} / year',
        product.pricePerMonthString == null
            ? null
            : '${product.pricePerMonthString} a month',
      ),
      PackageType.monthly => (
        'Monthly',
        '${product.priceString} / month',
        null,
      ),
      PackageType.lifetime => (
        'Lifetime',
        product.priceString,
        'Pay once, no subscription',
      ),
      _ => (product.title, product.priceString, null),
    };
    final radius = BorderRadius.circular(PlatformInfo.isIOS ? 14 : 16);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        selected: selected,
        button: true,
        child: Material(
          color: colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(
              color: selected ? colors.accent : Colors.transparent,
              width: 2,
            ),
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? platformIconData(
                            cupertino: CupertinoIcons.checkmark_circle_fill,
                            material: Icons.radio_button_checked,
                          )
                        : platformIconData(
                            cupertino: CupertinoIcons.circle,
                            material: Icons.radio_button_unchecked,
                          ),
                    color: selected ? colors.accent : colors.secondaryLabel,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: colors.label,
                              ),
                            ),
                            if (badge != null) ...[
                              const SizedBox(width: 8),
                              _Badge(text: badge!, colors: colors),
                            ],
                          ],
                        ),
                        if (detail != null)
                          Text(
                            detail,
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.secondaryLabel,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.label,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.colors});

  final String text;
  final _PaywallColors colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.accent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.busy, required this.onPressed});

  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final child = busy
        ? const SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator.adaptive(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          )
        : const Text(
            'Continue',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          );
    if (PlatformInfo.isIOS) {
      return SizedBox(
        height: 52,
        child: CupertinoButton.filled(
          borderRadius: BorderRadius.circular(26),
          onPressed: onPressed,
          // Keep the green while the purchase sheet is up.
          disabledColor: busy
              ? CupertinoColors.systemGreen.resolveFrom(context)
              : CupertinoColors.quaternarySystemFill.resolveFrom(context),
          color: CupertinoColors.systemGreen.resolveFrom(context),
          child: child,
        ),
      );
    }
    return SizedBox(
      height: 52,
      child: FilledButton(onPressed: busy ? () {} : onPressed, child: child),
    );
  }
}

class _LinkButton extends StatelessWidget {
  const _LinkButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 13,
      color: _PaywallColors.of(context).accent,
    );
    if (PlatformInfo.isIOS) {
      return CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(44, 44),
        onPressed: onPressed,
        child: Text(label, style: style),
      );
    }
    return TextButton(
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = _PaywallColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              platformIconData(
                cupertino: CupertinoIcons.wifi_exclamationmark,
                material: Icons.wifi_off,
              ),
              size: 44,
              color: colors.secondaryLabel,
            ),
            const SizedBox(height: 12),
            Text(
              'Can’t Load the Plans',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colors.label,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: colors.secondaryLabel),
            ),
            const SizedBox(height: 16),
            PlatformInfo.isIOS
                ? CupertinoButton(
                    onPressed: onRetry,
                    child: const Text('Try Again'),
                  )
                : TextButton(
                    onPressed: onRetry,
                    child: const Text('Try Again'),
                  ),
          ],
        ),
      ),
    );
  }
}
