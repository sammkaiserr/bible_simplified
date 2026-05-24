import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class AppSettings {
  final ThemeMode themeMode;
  final double fontSize;
  final String readingMode;
  final String languageCode; // 'te' for Telugu, 'en' for English

  AppSettings({
    required this.themeMode,
    required this.fontSize,
    required this.readingMode,
    required this.languageCode,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    double? fontSize,
    String? readingMode,
    String? languageCode,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      readingMode: readingMode ?? this.readingMode,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier()
      : super(AppSettings(
          themeMode: ThemeMode.system,
          fontSize: AppConstants.defaultFontSize,
          readingMode: AppConstants.readingModeSimple,
          languageCode: 'te',
        )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Theme Mode
    final themeIndex = prefs.getInt(AppConstants.keyThemeMode);
    final themeMode = themeIndex != null 
        ? ThemeMode.values[themeIndex] 
        : ThemeMode.system;

    // Font Size
    final fontSize = prefs.getDouble(AppConstants.keyFontSize) ?? AppConstants.defaultFontSize;

    // Reading Mode
    final readingMode = prefs.getString(AppConstants.keyReadingMode) ?? AppConstants.readingModeSimple;

    // Language Code
    final languageCode = prefs.getString(AppConstants.keyLanguage) ?? 'te';

    state = AppSettings(
      themeMode: themeMode,
      fontSize: fontSize,
      readingMode: readingMode,
      languageCode: languageCode,
    );
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyThemeMode, themeMode.index);
    state = state.copyWith(themeMode: themeMode);
  }

  Future<void> setFontSize(double size) async {
    if (size < AppConstants.minFontSize || size > AppConstants.maxFontSize) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.keyFontSize, size);
    state = state.copyWith(fontSize: size);
  }

  Future<void> setReadingMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyReadingMode, mode);
    state = state.copyWith(readingMode: mode);
  }

  Future<void> setLanguageCode(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLanguage, languageCode);
    state = state.copyWith(languageCode: languageCode);
  }
}

final settingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier();
});
