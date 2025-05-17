class Settings {
  Language language;
  int textSize;
  bool darkMode;
  Settings(
      {this.language = defaultLanguage,
      this.darkMode = false,
      this.textSize = defaulTextSize});

  static const Language defaultLanguage = Language.English;
  static const int defaulTextSize = 20;
}

enum Language { English }

extension LanguageFunctions on Language {
  Language languageFromString(String string) {
    switch (string) {
      default:
        return Language.English;
    }
  }
}
