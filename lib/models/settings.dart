class Settings {
  Language language;
  int textSize;
  bool darkMode;

  /// Whether the hymn of the day is wanted. It still needs the phone to allow
  /// notifications.
  bool hymnOfTheDay;

  /// When the hymn of the day arrives, in minutes after midnight.
  int hymnOfTheDayMinute;
  Settings(
      {this.language = defaultLanguage,
      this.darkMode = false,
      this.textSize = defaulTextSize,
      this.hymnOfTheDay = true,
      this.hymnOfTheDayMinute = defaultHymnOfTheDayMinute});

  static const Language defaultLanguage = Language.english;
  static const int defaulTextSize = 20;
  static const int defaultHymnOfTheDayMinute = 7 * 60 + 30;
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
