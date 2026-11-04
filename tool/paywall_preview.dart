// Preview-only entry point: the Remove Ads page with the real prices and no
// store behind it. Run with `flutter run -t tool/paywall_preview.dart`, adding
// --dart-define=USD=true for US prices or DARK=true for dark mode.
// Never use this target for a release build.
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:baptist_hymnal/screens/remove_ads_screen.dart';
import 'package:baptist_hymnal/utils/platform_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

const _dark = bool.fromEnvironment('DARK');

// US prices instead of Nigerian ones, as Apple's reviewers see them.
const _usd = bool.fromEnvironment('USD');

Package _package(
  PackageType type,
  double price,
  String priceString, {
  String? perMonth,
  int trialDays = 0,
}) => Package(
  type.name,
  type,
  StoreProduct(
    'bh_ad_free_${type.name}',
    '',
    '',
    price,
    priceString,
    _usd ? 'USD' : 'NGN',
    pricePerMonthString: perMonth,
    introductoryPrice: trialDays == 0
        ? null
        : IntroductoryPrice(
            0,
            'Free',
            'P${trialDays}D',
            1,
            PeriodUnit.day,
            trialDays,
          ),
  ),
  const PresentedOfferingContext('default', null, null),
);

// The live prices and trials, as set in App Store Connect on 2026-11-04.
Future<Offering?> _sampleOffering() async {
  final monthly = _usd
      ? _package(PackageType.monthly, 0.99, r'$0.99', trialDays: 3)
      : _package(PackageType.monthly, 500, '₦500', trialDays: 3);
  final annual = _usd
      ? _package(
          PackageType.annual,
          4.99,
          r'$4.99',
          perMonth: r'$0.41',
          trialDays: 7,
        )
      : _package(
          PackageType.annual,
          3000,
          '₦3,000',
          perMonth: '₦250',
          trialDays: 7,
        );
  final lifetime = _usd
      ? _package(PackageType.lifetime, 9.99, r'$9.99')
      : _package(PackageType.lifetime, 6000, '₦6,000');
  return Offering(
    'default',
    '',
    const {},
    [monthly, annual, lifetime],
    monthly: monthly,
    annual: annual,
    lifetime: lifetime,
  );
}

void main() {
  if (kReleaseMode) throw StateError('Preview entry point, not for release.');
  final light = ThemeData(colorSchemeSeed: brandGreen);
  final dark = ThemeData(
    colorSchemeSeed: brandGreen,
    brightness: Brightness.dark,
  );
  runApp(
    AdaptiveApp(
      title: 'Paywall preview',
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      materialLightTheme: light,
      materialDarkTheme: dark,
      cupertinoLightTheme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: CupertinoColors.systemGreen,
      ),
      cupertinoDarkTheme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: CupertinoColors.systemGreen,
      ),
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      builder: (context, child) => PlatformInfo.isIOS
          ? Theme(data: _dark ? dark : light, child: child!)
          : child!,
      // ignore: invalid_use_of_visible_for_testing_member
      home: const RemoveAdsScreen(loadOffering: _sampleOffering),
    ),
  );
}
