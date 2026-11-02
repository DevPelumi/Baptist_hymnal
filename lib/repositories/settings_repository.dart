import 'package:shared_preferences/shared_preferences.dart';

import '../models/settings.dart';

class SettingsRepository {
  late SharedPreferences _sharedPreferences;

  Future<void> updateLanguage(Language language) async {
    await assertNotNullSharedPrefs();
    await _sharedPreferences.setString(_languageKey, language.name);
  }

  Future<void> updateDarkMode(bool isDarkMode) async {
    await assertNotNullSharedPrefs();
    await _sharedPreferences.setBool(_darkModeKey, isDarkMode);
  }

  Future<void> updateFontSize(int fontSize) async {
    await assertNotNullSharedPrefs();
    await _sharedPreferences.setInt(_fontSizeKey, fontSize);
  }

  Future<void> updateHymnOfTheDay(bool isOn) async {
    await assertNotNullSharedPrefs();
    await _sharedPreferences.setBool(_hymnOfTheDayKey, isOn);
  }

  Future<void> updateHymnOfTheDayMinute(int minute) async {
    await assertNotNullSharedPrefs();
    await _sharedPreferences.setInt(_hymnOfTheDayMinuteKey, minute);
  }

  Future<Settings> fetchSettings() async {
    await assertNotNullSharedPrefs();
    return Settings(
        language: _sharedPreferences.containsKey(_languageKey)
            ? Language.english.languageFromString(
                _sharedPreferences.getString(_languageKey) ?? '')
            : Language.english,
        darkMode: _sharedPreferences.getBool(_darkModeKey) ?? false,
        textSize: _sharedPreferences.getInt(_fontSizeKey) ?? 20,
        hymnOfTheDay: _sharedPreferences.getBool(_hymnOfTheDayKey) ?? true,
        hymnOfTheDayMinute: _sharedPreferences.getInt(_hymnOfTheDayMinuteKey) ??
            Settings.defaultHymnOfTheDayMinute);
  }

  Future<void> assertNotNullSharedPrefs() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static const String _languageKey = 'settings/language';
  static const String _darkModeKey = 'settings/darkMode';
  static const String _fontSizeKey = 'settings/fontSize';
  static const String _hymnOfTheDayKey = 'settings/hymnOfTheDay';
  static const String _hymnOfTheDayMinuteKey = 'settings/hymnOfTheDayMinute';
}
