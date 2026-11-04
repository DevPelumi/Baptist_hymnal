import 'package:baptist_hymnal/screens/remove_ads_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

Package _package(PackageType type, double price, String priceString) => Package(
  type.name,
  type,
  StoreProduct('bh_${type.name}', '', '', price, priceString, 'NGN'),
  const PresentedOfferingContext('default', null, null),
);

Offering _offering({Package? annual, Package? monthly, Package? lifetime}) =>
    Offering(
      'default',
      '',
      const {},
      [?monthly, ?annual, ?lifetime],
      annual: annual,
      monthly: monthly,
      lifetime: lifetime,
    );

void main() {
  final monthly = _package(PackageType.monthly, 1000, '₦1,000');
  final yearly = _package(PackageType.annual, 7200, '₦7,200');
  final lifetime = _package(PackageType.lifetime, 15000, '₦15,000');

  group('paywallPlans', () {
    test('puts yearly first, then monthly, then lifetime', () {
      final offering = _offering(
        monthly: monthly,
        annual: yearly,
        lifetime: lifetime,
      );
      expect(paywallPlans(offering), [yearly, monthly, lifetime]);
    });

    test('leaves out plans the offering lacks', () {
      expect(paywallPlans(_offering(lifetime: lifetime)), [lifetime]);
      expect(paywallPlans(_offering()), isEmpty);
    });
  });

  group('yearlySavingsBadge', () {
    test('compares the year with twelve months', () {
      final offering = _offering(monthly: monthly, annual: yearly);
      expect(yearlySavingsBadge(offering), 'Save 40%');
    });

    test('rounds down', () {
      final offering = _offering(
        monthly: monthly,
        annual: _package(PackageType.annual, 8050, '₦8,050'),
      );
      expect(yearlySavingsBadge(offering), 'Save 32%');
    });

    test('is left off without a monthly plan or a real saving', () {
      expect(yearlySavingsBadge(_offering(annual: yearly)), isNull);
      final noSaving = _offering(
        monthly: monthly,
        annual: _package(PackageType.annual, 11900, '₦11,900'),
      );
      expect(yearlySavingsBadge(noSaving), isNull);
    });
  });

  group('planTerms', () {
    test('says a subscription renews, and where to cancel', () {
      final terms = planTerms(yearly, ios: true);
      expect(terms, startsWith('₦7,200 a year, charged to your Apple ID'));
      expect(terms, contains('Cancel any time in your Apple ID subscriptions'));
      expect(planTerms(monthly, ios: false), contains('end of the month'));
      expect(planTerms(monthly, ios: false), contains('Google Play'));
    });

    test('says lifetime is a single payment', () {
      expect(
        planTerms(lifetime, ios: true),
        'One payment of ₦15,000. No subscription.',
      );
    });
  });
}
