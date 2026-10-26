import 'package:baptist_hymnal/ad_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A screen-wide large anchored adaptive banner. Each instance owns its own ad, so
/// pages being replaced or popped never dispose another page's banner.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  BannerAd? _pendingAd;
  int? _requestedWidth;

  @override
  void initState() {
    super.initState();
    AdHelper.canRequestAds.addListener(_loadAd);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Also reruns when the screen width changes, e.g. on rotation.
    _loadAd();
  }

  Future<void> _loadAd() async {
    if (!mounted || !AdHelper.adsEnabled || !AdHelper.canRequestAds.value) {
      return;
    }
    final width = MediaQuery.sizeOf(context).width.truncate();
    if (width == _requestedWidth) return;
    _requestedWidth = width;

    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
    if (!mounted || size == null || width != _requestedWidth) return;

    _pendingAd?.dispose();
    _pendingAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted || ad != _pendingAd) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd?.dispose();
            _bannerAd = ad as BannerAd;
            _pendingAd = null;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: $error');
          ad.dispose();
          if (ad == _pendingAd) _pendingAd = null;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    AdHelper.canRequestAds.removeListener(_loadAd);
    _pendingAd?.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _bannerAd;
    if (ad == null) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
