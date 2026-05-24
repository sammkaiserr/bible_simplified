/// App-wide constants for Bible Simplified.
class AppConstants {
  AppConstants._();

  static const String appName = 'Bible Simplified';
  static const String appVersion = '1.0.0';

  // Database
  static const String dbName = 'bible_simplified.db';
  static const int dbVersion = 4;

  // SharedPreferences keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyFontSize = 'font_size';
  static const String keyReadingMode = 'reading_mode';
  static const String keyLastBookId = 'last_book_id';
  static const String keyLastChapter = 'last_chapter';
  static const String keyDailyVerseDate = 'daily_verse_date';
  static const String keyDailyVerseId = 'daily_verse_id';
  static const String keyLanguage = 'language_code';

  // Default values
  static const double defaultFontSize = 20.0;
  static const double minFontSize = 14.0;
  static const double maxFontSize = 32.0;

  // Reading modes
  static const String readingModeOriginal = 'original';
  static const String readingModeSimple = 'simple';
  static const String readingModeBoth = 'both';

  // AI
  static const String geminiApiBase = 'https://generativelanguage.googleapis.com/v1beta';
  static const String geminiModel = 'gemini-2.0-flash';
}
