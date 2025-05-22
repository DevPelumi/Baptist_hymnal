import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class AdHelper {
  static bool adsEnabled = true;
  static BannerAd? myBanner;
  static InterstitialAd? _interstitialAd;
  static int _hymnViewCount = 0;

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

  static void toggleAds(bool enabled) {
    adsEnabled = enabled;
    if (!enabled) {
      disposeBannerAd();
      disposeInterstitialAd();
    }
  }

  static void loadBannerAd() {
    if (!adsEnabled) return;
    myBanner = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Ad loaded.');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Ad failed to load: $error');
          ad.dispose();
        },
      ),
    );

    myBanner?.load();
  }

  static void disposeBannerAd() {
    myBanner?.dispose();
    myBanner = null;
  }

  static void loadInterstitialAd() {
    if (!adsEnabled) return;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  static void incrementHymnViewCount() {
    if (!adsEnabled) return;
    _hymnViewCount++;
    if (_hymnViewCount >= 2) {
      _hymnViewCount = 0;
      showInterstitialAd();
    }
  }

  static void showInterstitialAd() {
    if (!adsEnabled || _interstitialAd == null) return;
    _interstitialAd!.show();
    _interstitialAd = null;
    loadInterstitialAd();
  }

  static void disposeInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
