import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_10y.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../data/english_hymns.dart';
import '../data/hymn_audio.dart';
import '../providers/settings_provider.dart';
import 'hymn_helper_functions.dart';
import 'platform_icons.dart';

/// A notification each day with an English hymn that has a tune. Each phone
/// schedules its own, so it needs no server and arrives offline. It's on
/// unless the user turns it off in Settings, wherever the phone allows
/// notifications.
class HymnOfTheDay {
  /// Hymn pages closed before the app asks to send notifications.
  static const int hymnsClosedBeforeAsking = 2;

  /// Days of notifications scheduled ahead. Each launch tops them up, so they
  /// stop only for someone who hasn't opened the app in this long. iOS keeps
  /// at most 64.
  static const int daysAhead = 30;

  static const String _hymnsClosedKey = 'hymnOfTheDay/hymnsClosed';
  static const String _askedKey = 'hymnOfTheDay/asked';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static Future<void>? _timeZone;

  /// The notification last opened. Android can report the one that started
  /// the app twice.
  static int? _openedId;

  /// The hymn for [date]'s day. Every phone picks the same hymn on the same
  /// date, and every tuned hymn comes round once before any repeats.
  static int hymnFor(DateTime date) => _order[_dayNumber(date) % _order.length];

  static final DateTime _firstDay = DateTime.utc(2026);

  static int _dayNumber(DateTime date) => DateTime.utc(
    date.year,
    date.month,
    date.day,
  ).difference(_firstDay).inDays;

  /// The tuned hymns in a fixed shuffled order. It shuffles with its own
  /// generator (Park–Miller), because dart:math's Random may give the same
  /// seed a different sequence in a later Dart.
  static final List<int> _order = () {
    final ids = englishHymnsWithAudio.toList()..sort();
    var seed = 20261102;
    for (var i = ids.length - 1; i > 0; i--) {
      seed = seed * 48271 % 2147483647;
      final j = seed % (i + 1);
      final swap = ids[i];
      ids[i] = ids[j];
      ids[j] = swap;
    }
    return ids;
  }();

  /// Call once at launch. [onOpen] gets the hymn number when someone taps a
  /// hymn of the day while the app is running. Returns the hymn number when
  /// tapping one opened the app.
  static Future<int?> initialize({
    required void Function(int hymnId) onOpen,
  }) async {
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_notification'),
          // Permission is asked for after a couple of hymns, not at launch.
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestSoundPermission: false,
            requestBadgePermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (response) {
          final hymnId = _hymnToOpen(response);
          if (hymnId != null) onOpen(hymnId);
        },
      );
      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch == null || !launch.didNotificationLaunchApp) return null;
      return _hymnToOpen(launch.notificationResponse);
    } catch (e) {
      debugPrint('Hymn of the day setup failed: $e');
      return null;
    }
  }

  /// The hymn to open for a tapped notification, or null when it's open
  /// already.
  static int? _hymnToOpen(NotificationResponse? response) {
    if (response == null || response.id == _openedId) return null;
    _openedId = response.id;
    return int.tryParse(response.payload ?? '');
  }

  /// Whether the phone lets the app post notifications. Android before 13
  /// allows them without asking.
  static Future<bool> isAllowed() async {
    try {
      return await _checkAllowed();
    } catch (e) {
      debugPrint('Checking notification permission failed: $e');
      return false;
    }
  }

  static Future<bool> _checkAllowed() async {
    if (PlatformInfo.isIOS) {
      final permissions = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.checkPermissions();
      return permissions?.isEnabled ?? false;
    }
    return await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.areNotificationsEnabled() ??
        false;
  }

  /// Asks to send notifications. Returns whether they're allowed.
  static Future<bool> requestPermission() async {
    try {
      final granted = PlatformInfo.isIOS
          ? await _plugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, sound: true)
          : await _plugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >()
                ?.requestNotificationsPermission();
      return granted ?? false;
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
      return false;
    }
  }

  /// Replaces the scheduled hymns with the next [daysAhead] days' at
  /// [minuteOfDay] (minutes after midnight), when [enabled] and the phone
  /// allows notifications. Hymns already in the notification list stay.
  static Future<void> schedule({
    required bool enabled,
    required int minuteOfDay,
  }) async {
    try {
      await _plugin.cancelAllPendingNotifications();
      if (!enabled || !await isAllowed()) return;
      await (_timeZone ??= _setLocalTimeZone());

      final now = tz.TZDateTime.now(tz.local);
      // Today's, unless its time has passed.
      final first = now.hour * 60 + now.minute < minuteOfDay ? 0 : 1;
      for (var day = first; day < first + daysAhead; day++) {
        final when = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day + day,
          minuteOfDay ~/ 60,
          minuteOfDay % 60,
        );
        final hymnId = hymnFor(when);
        final hymn = englishHymnData.firstWhere((h) => h.id == hymnId);
        final body =
            '$hymnId. ${hymn.title}\n'
            '${HymnHelperFunctions.openingLine(hymn)}';
        await _plugin.zonedSchedule(
          // One per date, so a new day's never replaces one still showing.
          id: _dayNumber(when),
          scheduledDate: when,
          title: 'Hymn of the Day',
          body: body,
          payload: '$hymnId',
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              'hymn_of_the_day',
              'Hymn of the Day',
              channelDescription: 'A hymn and its tune each day',
              color: brandGreen,
              styleInformation: BigTextStyleInformation(body),
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          // Android may send it up to an hour after the time. Exact alarms
          // need a permission Google Play restricts to alarm-clock apps.
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } catch (e) {
      debugPrint('Scheduling the hymn of the day failed: $e');
    }
  }

  static Future<void> _setLocalTimeZone() async {
    tz.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (e) {
      // Stays on UTC: an hour out in Nigeria, but still once a day.
      debugPrint('Finding the time zone failed: $e');
    }
  }

  /// Call when the user leaves a hymn page and no full-screen ad is showing.
  /// On the [hymnsClosedBeforeAsking]th, asks once to send the hymn of the
  /// day, unless the phone already allows it. [context] has to outlive the
  /// hymn page, so pass the navigator's.
  static Future<void> onHymnClosed(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_askedKey) ?? false) return;
      final closed = (prefs.getInt(_hymnsClosedKey) ?? 0) + 1;
      await prefs.setInt(_hymnsClosedKey, closed);
      if (closed < hymnsClosedBeforeAsking) return;
      await prefs.setBool(_askedKey, true);

      if (!context.mounted) return;
      final settings = context.read<SettingsProvider>();
      if (settings.hymnOfTheDay || settings.hymnOfTheDayTurnedOff) return;
      final time = settings.hymnOfTheDayTime.format(context);
      await AdaptiveAlertDialog.show(
        context: context,
        title: 'Hymn of the Day',
        message:
            'Get a hymn and its tune every day at $time. You can '
            'change the time or turn it off in Settings.',
        actions: [
          AlertAction(
            title: 'Not Now',
            style: AlertActionStyle.cancel,
            onPressed: () {},
          ),
          AlertAction(
            title: 'Turn On',
            style: AlertActionStyle.primary,
            onPressed: () => settings.setHymnOfTheDay(true, source: 'prompt'),
          ),
        ],
      );
    } catch (e) {
      debugPrint('Hymn of the day prompt failed: $e');
    }
  }
}
