// Preview-only entry point: the Remove Ads page with sample Naira prices and
// no store behind it. Run with `flutter run -t tool/paywall_preview.dart`.
// Never use this target for a release build.
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:baptist_hymnal/screens/remove_ads_screen.dart';
import 'package:baptist_hymnal/utils/platform_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

const _dark = bool.fromEnvironment('DARK');

Package _package(
  PackageType type,
  double price,
  String priceString, {
  String? perMonth,
}) => Package(
  type.name,
  type,
  StoreProduct(
    'ad_free_${type.name}',
    '',
    '',
    price,
    priceString,
    'NGN',
    pricePerMonthString: perMonth,
  ),
  const PresentedOfferingContext('default', null, null),
);

Future<Offering?> _sampleOffering() async {
  final monthly = _package(PackageType.monthly, 500, '₦500');
  final annual = _package(
    PackageType.annual,
    3500,
    '₦3,500',
    perMonth: '₦291.67',
  );
  final lifetime = _package(PackageType.lifetime, 9000, '₦9,000');
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
