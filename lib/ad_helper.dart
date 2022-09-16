import 'package:google_mobile_ads/google_mobile_ads.dart';


class AdHelper {
  static BannerAd myBanner = BannerAd(
    adUnitId: 'ca-app-pub-3940256099942544/6300978111',
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(),
  );
}

// class AdHelper {
//   static String get bannerAdUnitId {
//     if (Platform.isAndroid) {
//       return 'ca-app-pub-8428392278159227/2118367384';
//     } else if (Platform.isIOS) {
//       return 'ca-app-pub-8428392278159227/6380150175';
//     } else {
//       throw new UnsupportedError('Unsupported platform');
//     }
//   }
// }