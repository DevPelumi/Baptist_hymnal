import 'dart:async';
import 'dart:io' show Platform;

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'purchases/premium.dart';

class AdHelper {
  /// False once someone has paid to remove ads, or [toggleAds] turned them
  /// off.
  static bool get adsEnabled => !_turnedOff && !Premium.isActive.value;

  static bool _turnedOff = false;

  /// Turns ads off for this run whatever was bought, as the store screenshot
  /// tool does.
  static void toggleAds(bool enabled) {
    _turnedOff = !enabled;
    if (!enabled) _disposeInterstitialAd();
  }

  /// Becomes true once consent has been gathered and the Mobile Ads SDK is
  /// initialized. Banners listen to this so they can load as soon as allowed.
  static final ValueNotifier<bool> canRequestAds = ValueNotifier(false);

  /// Show a full-screen ad at most once per this many hymn closes...
  static const int hymnsClosedPerInterstitial = 2;

  /// ...and never more often than this.
  static const Duration minTimeBetweenInterstitials = Duration(minutes: 3);

  // Loaded interstitials expire after an hour, so refresh them before that.
  static const Duration _interstitialMaxAge = Duration(minutes: 55);

  static Future<void>? _initialization;
  static bool _listeningToPremium = false;
  static InterstitialAd? _interstitialAd;
  static DateTime? _interstitialLoadedAt;
  static bool _isLoadingInterstitial = false;
  static DateTime? _lastInterstitialShownAt;
  static int _hymnsClosedSinceLastInterstitial = 0;

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3742689910893242/9895203713';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3742689910893242/9782688924';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3742689910893242/2910434444';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3742689910893242/6302884542';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// Gathers GDPR consent (UMP), asks for iOS tracking permission, then starts
  /// the Mobile Ads SDK. Safe to call more than once; if consent could not be
  /// checked (usually no connection), the next call tries again.
  /// Does nothing while ads are removed, so a paying user is never asked
  /// about ad consent or tracking; if their purchase lapses, the next call
  /// sets ads up.
  static Future<void> initialize() {
    if (!adsEnabled) return Future.value();
    return _initialization ??= _initialize();
  }

  static Future<void> _initialize() async {
    if (!_listeningToPremium) {
      _listeningToPremium = true;
      Premium.isActive.addListener(() {
        if (!adsEnabled) _disposeInterstitialAd();
      });
    }
    final consentChecked = await _gatherConsent();
    if (Platform.isIOS) {
      await _requestTrackingAuthorization();
    }
    if (await ConsentInformation.instance.canRequestAds()) {
      await MobileAds.instance.initialize();
      canRequestAds.value = true;
    } else if (!consentChecked) {
      _initialization = null;
    }
  }

  /// Completes with whether the consent status could be checked.
  static Future<bool> _gatherConsent() {
    final completer = Completer<bool>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () {
        ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) {
          if (error != null) {
            debugPrint('Consent form error: ${error.message}');
          }
          completer.complete(true);
        });
      },
      (FormError error) {
        debugPrint('Consent info update failed: ${error.message}');
        completer.complete(false);
      },
    );
    return completer.future;
  }

  static Future<void> _requestTrackingAuthorization() async {
    try {
      // The UMP IDFA explainer, if configured in AdMob, may already have asked.
      if (await AppTrackingTransparency.trackingAuthorizationStatus ==
          TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (e) {
      debugPrint('Tracking authorization failed: $e');
    }
  }

  /// Whether the user must be offered a way to change their consent choices.
  static Future<bool> isPrivacyOptionsRequired() async {
    return await ConsentInformation.instance
            .getPrivacyOptionsRequirementStatus() ==
        PrivacyOptionsRequirementStatus.required;
  }

  static void showPrivacyOptionsForm() {
    ConsentForm.showPrivacyOptionsForm((FormError? error) {
      if (error != null) {
        debugPrint('Privacy options form error: ${error.message}');
      }
    });
  }

  /// Loads a full-screen ad if one isn't already loaded or loading. The ad is
  /// kept app-wide, so leaving or replacing a hymn page doesn't discard it.
  static void preloadInterstitialAd() {
    if (!adsEnabled || !canRequestAds.value || _isLoadingInterstitial) return;
    if (_interstitialAd != null && !_isInterstitialExpired) return;
    _disposeInterstitialAd();

    _isLoadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _isLoadingInterstitial = false;
          if (!adsEnabled) {
            ad.dispose();
            return;
          }
          ad.setImmersiveMode(true);
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) => ad.dispose(),
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('InterstitialAd failed to show: $error');
              ad.dispose();
            },
          );
          _interstitialAd = ad;
          _interstitialLoadedAt = DateTime.now();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isLoadingInterstitial = false;
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  /// Call when the user leaves a hymn page. Shows the full-screen ad every
  /// [hymnsClosedPerInterstitial] closes, but no sooner than
  /// [minTimeBetweenInterstitials] after the previous one. Returns whether it
  /// showed one.
  static bool onHymnClosed() {
    if (!adsEnabled) return false;
    _hymnsClosedSinceLastInterstitial++;
    if (_hymnsClosedSinceLastInterstitial < hymnsClosedPerInterstitial) {
      return false;
    }

    final lastShown = _lastInterstitialShownAt;
    if (lastShown != null &&
        DateTime.now().difference(lastShown) < minTimeBetweenInterstitials) {
      return false;
    }

    final ad = _interstitialAd;
    if (ad == null || _isInterstitialExpired) return false;

    _interstitialAd = null;
    _interstitialLoadedAt = null;
    _hymnsClosedSinceLastInterstitial = 0;
    _lastInterstitialShownAt = DateTime.now();
    ad.show();
    return true;
  }

  static bool get _isInterstitialExpired {
    final loadedAt = _interstitialLoadedAt;
    return loadedAt == null ||
        DateTime.now().difference(loadedAt) > _interstitialMaxAge;
  }

  static void _disposeInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _interstitialLoadedAt = null;
  }
}
