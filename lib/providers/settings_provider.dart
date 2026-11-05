import 'package:flutter/material.dart';

import '../models/settings.dart';
import '../repositories/settings_repository.dart';
import '../utils/analytics_tracker.dart';
import '../utils/hymn_of_the_day.dart';

class SettingsProvider extends ChangeNotifier {
  Settings? _settings;
  bool _notificationsAllowed = false;
  late SettingsRepository _repo;
  SettingsProvider() {
    _repo = SettingsRepository();
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    _settings = await _repo.fetchSettings();
    _notificationsAllowed = await HymnOfTheDay.isAllowed();
    notifyListeners();
  }

  bool isDarkMode(bool userDefault) => _settings?.darkMode ?? userDefault;

  Language getLanguage({Language userDefault = Language.english}) =>
      _settings?.language ?? userDefault;

  int getFontSize({int defaultFontSize = 20}) =>
      _settings?.textSize ?? defaultFontSize;

  /// Whether the hymn of the day is on: wanted, which it is unless turned
  /// off, and allowed by the phone.
  bool get hymnOfTheDay =>
      (_settings?.hymnOfTheDay ?? true) && _notificationsAllowed;

  /// Whether the user turned the hymn of the day off.
  bool get hymnOfTheDayTurnedOff => !(_settings?.hymnOfTheDay ?? true);

  TimeOfDay get hymnOfTheDayTime {
    final minute =
        _settings?.hymnOfTheDayMinute ?? Settings.defaultHymnOfTheDayMinute;
    return TimeOfDay(hour: minute ~/ 60, minute: minute % 60);
  }

  Future<void> setDarkMode(bool value) async {
    if (_settings != null) {
      _settings!.darkMode = value;
      notifyListeners();
      await _repo.updateDarkMode(value);
    }
  }

  Future<void> setLanguage(Language language) async {
    if (_settings != null) {
      _settings!.language = language;
      notifyListeners();
      await _repo.updateLanguage(language);
    }
  }

  Future<void> setFontSize(int fontSize) async {
    if (_settings != null) {
      _settings!.textSize = fontSize;
      notifyListeners();
      await _repo.updateFontSize(fontSize);
    }
  }

  /// Turns the hymn of the day on or off. Turning it on first asks to send
  /// notifications, and leaves it off if the phone doesn't allow them.
  /// [source] is 'settings' or 'prompt'. Returns whether it's on.
  Future<bool> setHymnOfTheDay(bool value, {required String source}) async {
    final settings = _settings;
    if (settings == null) return false;
    if (value) {
      _notificationsAllowed = await HymnOfTheDay.requestPermission();
    }
    if (!value || _notificationsAllowed) {
      settings.hymnOfTheDay = value;
      await _repo.updateHymnOfTheDay(value);
      await scheduleHymnOfTheDay();
    }
    notifyListeners();
    try {
      await AnalyticsTracker.logHymnOfTheDayChanged(
        enabled: hymnOfTheDay,
        source: source,
      );
    } catch (e) {
      debugPrint('Logging the hymn of the day change failed: $e');
    }
    return hymnOfTheDay;
  }

  Future<void> setHymnOfTheDayTime(TimeOfDay time) async {
    final settings = _settings;
    if (settings == null) return;
    settings.hymnOfTheDayMinute = time.hour * 60 + time.minute;
    notifyListeners();
    await _repo.updateHymnOfTheDayMinute(settings.hymnOfTheDayMinute);
    await scheduleHymnOfTheDay();
  }

  /// Schedules the coming days' hymns, or clears them when it's off. Call at
  /// launch, after [fetchSettings], to keep them topped up.
  Future<void> scheduleHymnOfTheDay() => HymnOfTheDay.schedule(
    enabled: !hymnOfTheDayTurnedOff,
    minuteOfDay:
        _settings?.hymnOfTheDayMinute ?? Settings.defaultHymnOfTheDayMinute,
  );
}
