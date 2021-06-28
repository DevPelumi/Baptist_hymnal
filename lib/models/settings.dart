class Settings {
  Language language;
  int textSize;
  bool darkMode;
  Settings({this.language, this.darkMode, this.textSize});

  static const Language defaultLanguage = Language.English;
  static const int defaulTextSize = 20;
}

enum Language { English }

extension LanguageFunctions on Language {
  String get stringValue => this.toString().split('.')[1];
  Language languageFromString(String string) {
    switch (string) {
      default:
        return Language.English;
    }
  }
}
