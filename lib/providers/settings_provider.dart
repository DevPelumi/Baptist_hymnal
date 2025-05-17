import 'package:flutter/foundation.dart';

import '../models/settings.dart';
import '../repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  late Settings _settings;
  late SettingsRepository _repo;
  SettingsProvider() {
    _repo = SettingsRepository();
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    _settings = await _repo.fetchSettings();
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
