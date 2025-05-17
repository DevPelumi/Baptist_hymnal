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

  Future<Settings> fetchSettings() async {
    await assertNotNullSharedPrefs();
    return Settings(
        language: _sharedPreferences.containsKey(_languageKey)
            ? Language.English.languageFromString(
                _sharedPreferences.getString(_languageKey) ?? '')
            : Language.English,
        darkMode: _sharedPreferences.getBool(_darkModeKey) ?? false,
        textSize: _sharedPreferences.getInt(_fontSizeKey) ?? 20);
  }

  Future<void> assertNotNullSharedPrefs() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static const String _languageKey = 'settings/language';
  static const String _darkModeKey = 'settings/darkMode';
  static const String _fontSizeKey = 'settings/fontSize';
}
