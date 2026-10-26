class Settings {
  Language language;
  int textSize;
  bool darkMode;
  Settings(
      {this.language = defaultLanguage,
      this.darkMode = false,
      this.textSize = defaulTextSize});

  static const Language defaultLanguage = Language.english;
  static const int defaulTextSize = 20;
}

enum Language { english }

extension LanguageFunctions on Language {
  String get label => switch (this) {
        Language.english => 'English',
      };


  Language languageFromString(String string) {
    switch (string) {
      default:
        return Language.english;
    }
  }
}
