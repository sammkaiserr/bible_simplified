/// Complete Material 3 theme definitions for Bible Simplified.
///
/// Both light and dark themes with consistent styling across
/// all Material components.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  // ─── Light Theme ──────────────────────────────────────────────
  static ThemeData get light {
    final textTheme = AppTypography.textTheme(Brightness.light);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryLight,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightOnSurface,
        surfaceContainerHighest: AppColors.lightSurfaceVariant,
        onSurfaceVariant: AppColors.lightOnSurfaceVariant,
        outline: AppColors.lightOutline,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.lightBg,
      textTheme: textTheme,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBg,
        foregroundColor: AppColors.lightOnBg,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.lightOutline.withValues(alpha: 0.3)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.lightOnSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSurfaceVariant,
        selectedColor: AppColors.primaryLight.withValues(alpha: 0.15),
        labelStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide.none,
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.lightOnSurfaceVariant.withValues(alpha: 0.6),
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.lightOutline.withValues(alpha: 0.3),
        thickness: 1,
      ),

      // Slider
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.primaryLight,
        thumbColor: AppColors.primaryLight,
        inactiveTrackColor: AppColors.lightOutline,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primaryLight;
          return AppColors.lightOnSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight.withValues(alpha: 0.3);
          }
          return AppColors.lightOutline;
        }),
      ),
    );
  }

  // ─── Dark Theme ───────────────────────────────────────────────
  static ThemeData get dark {
    final textTheme = AppTypography.textTheme(Brightness.dark);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        onPrimary: AppColors.darkBg,
        secondary: AppColors.accentDark,
        onSecondary: AppColors.darkBg,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        surfaceContainerHighest: AppColors.darkSurfaceVariant,
        onSurfaceVariant: AppColors.darkOnSurfaceVariant,
        outline: AppColors.darkOutline,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.darkBg,
      textTheme: textTheme,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBg,
        foregroundColor: AppColors.darkOnBg,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.darkOutline.withValues(alpha: 0.3)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.darkOnSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        selectedColor: AppColors.primaryDark.withValues(alpha: 0.15),
        labelStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide.none,
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.darkBg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.darkOnSurfaceVariant.withValues(alpha: 0.6),
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.darkOutline.withValues(alpha: 0.3),
        thickness: 1,
      ),

      // Slider
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.primaryDark,
        thumbColor: AppColors.primaryDark,
        inactiveTrackColor: AppColors.darkOutline,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primaryDark;
          return AppColors.darkOnSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryDark.withValues(alpha: 0.3);
          }
          return AppColors.darkOutline;
        }),
      ),
    );
  }
}
