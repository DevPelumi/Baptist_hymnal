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
      expect(terms, startsWith('₦7,200 a year, renewing until you cancel.'));
      expect(terms, contains('Cancel any time in your Apple ID subscriptions'));
      expect(
        planTerms(monthly, ios: false),
        contains('a day before it renews'),
      );
      expect(planTerms(monthly, ios: false), contains('Google Play'));
    });

    test('says nothing for lifetime, whose row says it all', () {
      expect(planTerms(lifetime, ios: true), isEmpty);
    });
  });

  group('freeTrialLength', () {
    Package withIntro(PeriodUnit unit, int count, {double price = 0}) =>
        Package(
          'monthly',
          PackageType.monthly,
          StoreProduct(
            'bh_ad_free_monthly',
            '',
            '',
            1000,
            '₦1,000',
            'NGN',
            introductoryPrice: IntroductoryPrice(
              price,
              price == 0 ? 'Free' : '₦$price',
              'P$count${unit.name[0].toUpperCase()}',
              1,
              unit,
              count,
            ),
          ),
          const PresentedOfferingContext('default', null, null),
        );

    test('reads an App Store free trial', () {
      expect(freeTrialLength(withIntro(PeriodUnit.day, 3)), '3 days');
      expect(freeTrialLength(withIntro(PeriodUnit.week, 1)), 'a week');
      expect(freeTrialLength(withIntro(PeriodUnit.month, 2)), '2 months');
    });

    test('calls whole weeks of days weeks', () {
      expect(freeTrialLength(withIntro(PeriodUnit.day, 7)), 'a week');
      expect(freeTrialLength(withIntro(PeriodUnit.day, 14)), '2 weeks');
    });

    test('ignores a paid introductory price', () {
      expect(freeTrialLength(withIntro(PeriodUnit.week, 1, price: 99)), isNull);
    });

    test('reads a Google Play free phase', () {
      const week = Period(PeriodUnit.week, 1, 'P1W');
      const phase = PricingPhase(
        week,
        RecurrenceMode.finiteRecurring,
        1,
        Price('Free', 0, 'NGN'),
        OfferPaymentMode.freeTrial,
      );
      final package = Package(
        'annual',
        PackageType.annual,
        StoreProduct(
          'bh_ad_free:yearly',
          '',
          '',
          3000,
          '₦3,000',
          'NGN',
          defaultOption: const SubscriptionOption(
            'yearly-trial',
            'bh_ad_free:yearly',
            'bh_ad_free',
            [phase],
            [],
            false,
            Period(PeriodUnit.year, 1, 'P1Y'),
            false,
            null,
            phase,
            null,
            null,
            null,
          ),
        ),
        const PresentedOfferingContext('default', null, null),
      );
      expect(freeTrialLength(package), 'a week');
    });

    test('is null with no trial', () {
      expect(freeTrialLength(monthly), isNull);
      expect(freeTrialLength(lifetime), isNull);
    });
  });

  test('planTerms states the trial, then the price', () {
    final terms = planTerms(monthly, ios: true, trial: '3 days');
    expect(terms, startsWith('Free for 3 days, then ₦1,000 a month'));
    expect(terms, endsWith('at least a day before the trial ends.'));
    expect(planTerms(lifetime, ios: true, trial: '3 days'), isEmpty);
  });
}
