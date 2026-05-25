
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static String get _teluguFamily => GoogleFonts.notoSansTelugu().fontFamily!;

  static TextTheme textTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color onBg = isDark ? AppColors.darkOnBg : AppColors.lightOnBg;
    final Color onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final Color onSurfaceVariant = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;

    return TextTheme(

      displayLarge: TextStyle(
        fontFamily: _teluguFamily,
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: onBg,
        height: 1.5,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontFamily: _teluguFamily,
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: onBg,
        height: 1.5,
      ),
      displaySmall: TextStyle(
        fontFamily: _teluguFamily,
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: onBg,
        height: 1.4,
      ),

      headlineLarge: TextStyle(
        fontFamily: _teluguFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: onBg,
        height: 1.5,
      ),
      headlineMedium: TextStyle(
        fontFamily: _teluguFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: onBg,
        height: 1.5,
      ),
      headlineSmall: TextStyle(
        fontFamily: _teluguFamily,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: onBg,
        height: 1.5,
      ),

      titleLarge: TextStyle(
        fontFamily: _teluguFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: onSurface,
        height: 1.5,
      ),
      titleMedium: TextStyle(
        fontFamily: _teluguFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: onSurface,
        height: 1.5,
      ),
      titleSmall: TextStyle(
        fontFamily: _teluguFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: onSurface,
        height: 1.4,
      ),

      bodyLarge: TextStyle(
        fontFamily: _teluguFamily,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: onSurface,
        height: 1.8,
      ),
      bodyMedium: TextStyle(
        fontFamily: _teluguFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: onSurface,
        height: 1.7,
      ),
      bodySmall: TextStyle(
        fontFamily: _teluguFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: onSurfaceVariant,
        height: 1.6,
      ),

      labelLarge: TextStyle(
        fontFamily: _teluguFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: onSurface,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontFamily: _teluguFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: onSurfaceVariant,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontFamily: _teluguFamily,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: onSurfaceVariant,
        height: 1.3,
      ),
    );
  }

  static TextStyle verseStyle({
    required Brightness brightness,
    double fontSize = 20,
  }) {
    final bool isDark = brightness == Brightness.dark;
    return TextStyle(
      fontFamily: _teluguFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
      height: 1.9,
      letterSpacing: 0.2,
    );
  }

  static TextStyle simpleVerseStyle({
    required Brightness brightness,
    double fontSize = 17,
  }) {
    final bool isDark = brightness == Brightness.dark;
    return TextStyle(
      fontFamily: _teluguFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant,
      height: 1.8,
      fontStyle: FontStyle.italic,
    );
  }

  static TextStyle verseNumberStyle({required Brightness brightness}) {
    final bool isDark = brightness == Brightness.dark;
    return TextStyle(
      fontFamily: _teluguFamily,
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: isDark ? AppColors.accentDark : AppColors.accent,
      height: 1.0,
    );
  }

  static TextStyle teluguOriginal({
    required double fontSize,
    required bool isDark,
  }) {
    return TextStyle(
      fontFamily: _teluguFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
      height: 1.8,
      letterSpacing: 0.1,
    );
  }

  static TextStyle teluguSimple({
    required double fontSize,
    required bool isDark,
  }) {
    return TextStyle(
      fontFamily: _teluguFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant,
      height: 1.8,
      fontStyle: FontStyle.italic,
    );
  }
}
