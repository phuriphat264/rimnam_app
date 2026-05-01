import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Dark Luxury Palette
  static const Color ink = Color(0xFF1C1208);
  static const Color espresso = Color(0xFF2E1A0A);
  static const Color mahogany = Color(0xFF5C3218);
  
  // Gold & Highlight Palette
  static const Color gold = Color(0xFFC8942C);
  static const Color honey = Color(0xFFD4A55A);
  static const Color amber = Color(0xFFE8C878);
  
  // Light Text & Elements
  static const Color cream = Color(0xFFF8F0DC);
  static const Color parchment = Color(0xFFEDE0C0);
  
  // Nature & Accent Palette
  static const Color sage = Color(0xFF5C6B4A);
  static const Color teal = Color(0xFF3A6B6B);
  
  // Glassmorphism
  static Color glassBackground = Colors.white.withOpacity(0.05);
  static Color glassBorder = Colors.white.withOpacity(0.15);

  // Gradient
  static LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      gold,
      honey,
    ],
  );
  
  // Text Colors
  static const Color textLight = cream;
  static const Color textDark = ink;
}