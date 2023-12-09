import 'package:flutter/foundation.dart';

import '../models/settings.dart';
import '../repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  Settings _settings = Settings(darkMode: true, language: Language.English, textSize: 20); // Initialize with default values
  final SettingsRepository _repo = SettingsRepository(); // Initialize _repo directly

  SettingsProvider() {
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    try {
      _settings = await _repo.fetchSettings() ?? Settings(darkMode: true, language: Language.English, textSize: 20); // Use default if fetch fails
    } catch (e) {
      print("Error fetching settings: $e");
    }
    notifyListeners();
  }

  bool isDarkMode(bool userDefault) => _settings?.darkMode ?? userDefault;

  Language getLanguage({Language userDefault = Language.English}) =>
      _settings?.language ?? userDefault;

  int getFontSize({int defaultFontSize = 20}) =>
      _settings?.textSize ?? defaultFontSize;

  Future<void> setDarkMode(bool value) async {
    _settings?.darkMode = value;
    notifyListeners();
    await _repo.updateDarkMode(value);
  }

  Future<void> setLanguage(Language language) async {
    _settings.language = language;
    notifyListeners();
    await _repo.updateLanguage(language);
  }

  Future<void> setFontSize(int fontSize) async {
    _settings.textSize = fontSize;
    notifyListeners();
    await _repo.updateFontSize(fontSize);
  }
}
