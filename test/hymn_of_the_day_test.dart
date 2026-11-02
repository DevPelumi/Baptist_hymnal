import 'package:baptist_hymnal/data/hymn_audio.dart';
import 'package:baptist_hymnal/providers/settings_provider.dart';
import 'package:baptist_hymnal/utils/hymn_of_the_day.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('hymnFor', () {
    test('gives the same hymn all day', () {
      expect(
        HymnOfTheDay.hymnFor(DateTime(2026, 11, 3, 0, 1)),
        HymnOfTheDay.hymnFor(DateTime(2026, 11, 3, 23, 59)),
      );
    });

    test('goes through every tuned hymn before repeating', () {
      final start = DateTime(2026, 11, 3);
      final hymns = [
        for (var day = 0; day < englishHymnsWithAudio.length; day++)
          HymnOfTheDay.hymnFor(DateTime(start.year, start.month, day + 3)),
      ];
      expect(hymns.toSet(), englishHymnsWithAudio);
      expect(
        HymnOfTheDay.hymnFor(
          DateTime(start.year, start.month, 3 + englishHymnsWithAudio.length),
        ),
        hymns.first,
      );
    });

    test('is not in hymn-number order', () {
      final week = [
        for (var day = 1; day <= 7; day++)
          HymnOfTheDay.hymnFor(DateTime(2026, 11, day)),
      ];
      expect(week, isNot(orderedEquals([...week]..sort())));
    });

    // Phones on different app versions should agree on the day's hymn, so the
    // order may only change when the set of tuned hymns does.
    test('keeps its order between versions', () {
      expect([
        for (var day = 1; day <= 5; day++)
          HymnOfTheDay.hymnFor(DateTime(2026, 11, day)),
      ], _pinnedNovemberHymns);
    });
  });

  group('notifications', () {
    const channel = MethodChannel('dexterous.com/flutter/local_notifications');
    late List<MethodCall> calls;
    late bool allowed;

    setUp(() {
      AndroidFlutterLocalNotificationsPlugin.registerWith();
      SharedPreferences.setMockInitialValues({});
      calls = [];
      allowed = true;
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return call.method == 'areNotificationsEnabled' ? allowed : null;
      });
      messenger.setMockMethodCallHandler(
        const MethodChannel('flutter_timezone'),
        (call) async => 'Africa/Lagos',
      );
    });

    List<Map<Object?, Object?>> scheduled() => [
      for (final call in calls)
        if (call.method == 'zonedSchedule')
          call.arguments as Map<Object?, Object?>,
    ];

    Future<void> schedule({bool enabled = true}) =>
        HymnOfTheDay.schedule(enabled: enabled, minuteOfDay: 7 * 60 + 30);

    test('schedules the next 30 days at the chosen time', () async {
      await schedule();

      expect(calls.first.method, 'cancelAllPendingNotifications');
      final days = scheduled();
      expect(days, hasLength(HymnOfTheDay.daysAhead));

      final times = [
        for (final day in days)
          DateTime.parse(day['scheduledDateTime']! as String),
      ];
      final lagosNow = DateTime.now().toUtc().add(const Duration(hours: 1));
      final today = DateTime(lagosNow.year, lagosNow.month, lagosNow.day);
      final firstDay = lagosNow.hour * 60 + lagosNow.minute < 7 * 60 + 30
          ? today
          : DateTime(today.year, today.month, today.day + 1);
      for (var i = 0; i < times.length; i++) {
        expect(
          times[i],
          DateTime(firstDay.year, firstDay.month, firstDay.day + i, 7, 30),
        );
        expect(days[i]['timeZoneName'], 'Africa/Lagos');
        expect(days[i]['payload'], '${HymnOfTheDay.hymnFor(times[i])}');
      }
      expect(days.map((d) => d['id']).toSet(), hasLength(days.length));
    });

    test('names the hymn and its opening words', () async {
      await schedule();

      final day = scheduled().first;
      expect(day['title'], 'Hymn of the Day');
      final hymnId = day['payload'];
      expect(day['body'], startsWith('$hymnId. '));
      expect((day['body']! as String).split('\n'), hasLength(2));
    });

    test('schedules nothing when the phone blocks notifications', () async {
      allowed = false;
      await schedule();

      expect(calls.map((c) => c.method), [
        'cancelAllPendingNotifications',
        'areNotificationsEnabled',
      ]);
    });

    test('only clears them when turned off', () async {
      await schedule(enabled: false);

      expect(calls.map((c) => c.method), ['cancelAllPendingNotifications']);
    });

    Future<BuildContext> pumpApp(WidgetTester tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(),
          // Loads the settings now, as the app does at launch.
          lazy: false,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: const SizedBox.shrink(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return navigatorKey.currentContext!;
    }

    // Not awaited: while the question shows, it waits for an answer.
    Future<void> closeHymn(WidgetTester tester, BuildContext context) async {
      HymnOfTheDay.onHymnClosed(context);
      await tester.pumpAndSettle();
    }

    testWidgets('asks once, on the second hymn closed', (tester) async {
      allowed = false;
      final context = await pumpApp(tester);

      await closeHymn(tester, context);
      expect(find.text('Hymn of the Day'), findsNothing);

      await closeHymn(tester, context);
      expect(find.text('Hymn of the Day'), findsOneWidget);
      expect(find.textContaining('every day at 7:30 AM'), findsOneWidget);
      await tester.tap(find.text('Not Now'));
      await tester.pumpAndSettle();
      expect(find.text('Hymn of the Day'), findsNothing);

      await closeHymn(tester, context);
      expect(find.text('Hymn of the Day'), findsNothing);
    });

    testWidgets("is on by default where the phone allows it, so doesn't ask", (
      tester,
    ) async {
      final context = await pumpApp(tester);
      final settings = context.read<SettingsProvider>();
      expect(settings.hymnOfTheDay, isTrue);
      expect(settings.hymnOfTheDayTime, const TimeOfDay(hour: 7, minute: 30));

      await closeHymn(tester, context);
      await closeHymn(tester, context);
      expect(find.text('Hymn of the Day'), findsNothing);
    });
  });
}

/// The hymns for 1 to 5 November 2026. Update these only when a tune is
/// added or removed.
const List<int> _pinnedNovemberHymns = [42, 511, 424, 267, 136];
