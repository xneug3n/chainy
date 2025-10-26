import 'package:flutter/material.dart';

/// Chainy color palette with light and dark mode support
class ChainyColors {
  // Light Mode Colors
  static const Color lightBackground = Color(0xFF000000);
  static const Color lightCard = Color(0xFF1C1C1E);
  static const Color lightPrimaryText = Color(0xFFFFFFFF);
  static const Color lightSecondaryText = Color(0xFF8E8E93);
  static const Color lightAccentBlue = Color(0xFF007AFF);
  static const Color lightOrange = Color(0xFFFCA311);
  static const Color lightGray = Color(0xFF2C2C2E);
  static const Color lightBorder = Color(0xFF3A3A3C);
  
  // Dark Mode Colors (same as light for this black-based theme)
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkCard = Color(0xFF1C1C1E);
  static const Color darkPrimaryText = Color(0xFFFFFFFF);
  static const Color darkSecondaryText = Color(0xFF8E8E93);
  static const Color darkAccentBlue = Color(0xFF007AFF);
  static const Color darkOrange = Color(0xFFFCA311);
  static const Color darkGray = Color(0xFF2C2C2E);
  static const Color darkBorder = Color(0xFF3A3A3C);
  
  // Status Colors
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
  
  // Get colors based on brightness
  static Color getBackground(Brightness brightness) {
    return brightness == Brightness.light ? lightBackground : darkBackground;
  }
  
  static Color getCard(Brightness brightness) {
    return brightness == Brightness.light ? lightCard : darkCard;
  }
  
  static Color getPrimaryText(Brightness brightness) {
    return brightness == Brightness.light ? lightPrimaryText : darkPrimaryText;
  }
  
  static Color getSecondaryText(Brightness brightness) {
    return brightness == Brightness.light ? lightSecondaryText : darkSecondaryText;
  }
  
  static Color getAccentBlue(Brightness brightness) {
    return brightness == Brightness.light ? lightAccentBlue : darkAccentBlue;
  }
  
  static Color getOrange(Brightness brightness) {
    return brightness == Brightness.light ? lightOrange : darkOrange;
  }
  
  static Color getGray(Brightness brightness) {
    return brightness == Brightness.light ? lightGray : darkGray;
  }
  
  static Color getBorder(Brightness brightness) {
    return brightness == Brightness.light ? lightBorder : darkBorder;
  }
}

