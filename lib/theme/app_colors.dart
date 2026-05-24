/// App-wide color palette for Bible Simplified.
///
/// Curated spiritual palette: deep indigo primary with warm golden accents.
/// Distinct light and dark schemes for comfortable reading.
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Brand Colors ─────────────────────────────────────────────
  static const Color primaryLight = Color(0xFF3D5A80);   // Deep steel blue
  static const Color primaryDark = Color(0xFF98C1D9);    // Soft sky blue
  static const Color accent = Color(0xFFE8A838);         // Warm gold
  static const Color accentDark = Color(0xFFFFD166);     // Bright gold

  // ─── Numeric Colors for M3 spiritual theme ───────────────────
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


  // ─── Light Theme ──────────────────────────────────────────────
  static const Color lightBg = Color(0xFFF8F6F2);        // Warm ivory
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0EDE8);
  static const Color lightOnBg = Color(0xFF1A1A2E);      // Near black
  static const Color lightOnSurface = Color(0xFF2D2D3A);
  static const Color lightOnSurfaceVariant = Color(0xFF6B6B7B);
  static const Color lightOutline = Color(0xFFD4D0CA);

  // ─── Dark Theme ───────────────────────────────────────────────
  static const Color darkBg = Color(0xFF0F1123);          // Deep navy
  static const Color darkSurface = Color(0xFF1A1D35);
  static const Color darkSurfaceVariant = Color(0xFF252845);
  static const Color darkOnBg = Color(0xFFE8E6E1);
  static const Color darkOnSurface = Color(0xFFD4D2CD);
  static const Color darkOnSurfaceVariant = Color(0xFF9A98A3);
  static const Color darkOutline = Color(0xFF3A3D55);

  // ─── Semantic Colors ──────────────────────────────────────────
  static const Color error = Color(0xFFCF6679);
  static const Color success = Color(0xFF4CAF50);

  // ─── Highlight Colors ─────────────────────────────────────────
  static const List<Color> highlightColors = [
    Color(0xFFFFF9C4), // Soft yellow
    Color(0xFFB2DFDB), // Mint green
    Color(0xFFBBDEFB), // Light blue
    Color(0xFFF8BBD0), // Soft pink
    Color(0xFFE1BEE7), // Lavender
    Color(0xFFFFCCBC), // Peach
  ];

  static const List<Color> highlightColorsDark = [
    Color(0xFF4A4520), // Muted yellow
    Color(0xFF1A3B35), // Deep mint
    Color(0xFF1A2F45), // Deep blue
    Color(0xFF3B1A28), // Deep pink
    Color(0xFF2D1A35), // Deep lavender
    Color(0xFF3B2218), // Deep peach
  ];

  // ─── Gradients ────────────────────────────────────────────────
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
