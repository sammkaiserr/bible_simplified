/// Typography system for Bible Simplified.
///
/// Uses Noto Sans Telugu from Google Fonts for excellent Telugu script
/// rendering. Defines a scaled type system optimized for readability.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  /// Base Telugu font family
  static String get _teluguFamily => GoogleFonts.notoSansTelugu().fontFamily!;

  /// Get the text theme for the given brightness
  static TextTheme textTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color onBg = isDark ? AppColors.darkOnBg : AppColors.lightOnBg;
    final Color onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final Color onSurfaceVariant = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;

    return TextTheme(
      // ─── Display ──────────────────────────────────
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

      // ─── Headline ─────────────────────────────────
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

      // ─── Title ────────────────────────────────────
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

      // ─── Body (main reading text) ─────────────────
      bodyLarge: TextStyle(
        fontFamily: _teluguFamily,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: onSurface,
        height: 1.8, // Extra height for Telugu readability
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

      // ─── Label ────────────────────────────────────
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

  /// Special verse text style — used for Bible verse display
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

  /// Simple Telugu explanation style
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

  /// Verse number badge style
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

  /// Custom original Telugu text style (reading screen)
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

  /// Custom simple Telugu explanation style (reading screen)
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
