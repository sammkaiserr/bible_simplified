
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryLight = Color(0xFF3D5A80);
  static const Color primaryDark = Color(0xFF98C1D9);
  static const Color accent = Color(0xFFE8A838);
  static const Color accentDark = Color(0xFFFFD166);

  static const Color navy950 = Color(0xFF0A0C16);
  static const Color navy900 = Color(0xFF0F1123);
  static const Color navy850 = Color(0xFF14182E);
  static const Color navy800 = Color(0xFF1A1D35);
  static const Color navy700 = Color(0xFF252845);
  static const Color navy600 = Color(0xFF3D5A80);

  static const Color ivory50  = Color(0xFFFAF9F6);
  static const Color ivory100 = Color(0xFFF8F6F2);
  static const Color ivory200 = Color(0xFFF0EDE8);

  static const Color gold300 = Color(0xFFF4C56D);
  static const Color gold500 = Color(0xFFE8A838);

  static const Color amber700 = Color(0xFFD97706);
  static const Color amber800 = Color(0xFFB45309);

  static const Color lightBg = Color(0xFFF8F6F2);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0EDE8);
  static const Color lightOnBg = Color(0xFF1A1A2E);
  static const Color lightOnSurface = Color(0xFF2D2D3A);
  static const Color lightOnSurfaceVariant = Color(0xFF6B6B7B);
  static const Color lightOutline = Color(0xFFD4D0CA);

  static const Color darkBg = Color(0xFF0F1123);
  static const Color darkSurface = Color(0xFF1A1D35);
  static const Color darkSurfaceVariant = Color(0xFF252845);
  static const Color darkOnBg = Color(0xFFE8E6E1);
  static const Color darkOnSurface = Color(0xFFD4D2CD);
  static const Color darkOnSurfaceVariant = Color(0xFF9A98A3);
  static const Color darkOutline = Color(0xFF3A3D55);

  static const Color error = Color(0xFFCF6679);
  static const Color success = Color(0xFF4CAF50);

  static const List<Color> highlightColors = [
    Color(0xFFFFF9C4),
    Color(0xFFB2DFDB),
    Color(0xFFBBDEFB),
    Color(0xFFF8BBD0),
    Color(0xFFE1BEE7),
    Color(0xFFFFCCBC),
  ];

  static const List<Color> highlightColorsDark = [
    Color(0xFF4A4520),
    Color(0xFF1A3B35),
    Color(0xFF1A2F45),
    Color(0xFF3B1A28),
    Color(0xFF2D1A35),
    Color(0xFF3B2218),
  ];

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3D5A80), Color(0xFF5C7FA8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1D35), Color(0xFF252845)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFE8A838), Color(0xFFF4C56D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF1A1D35), Color(0xFF3D5A80), Color(0xFF5C7FA8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
