import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chainy_colors.dart';

/// Chainy theme configuration with iOS-optimized styling
class ChainyTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: ChainyColors.lightAccentBlue,
        secondary: ChainyColors.lightOrange,
        surface: ChainyColors.lightCard,
        onPrimary: ChainyColors.lightPrimaryText,
        onSecondary: ChainyColors.lightBackground,
        onSurface: ChainyColors.lightPrimaryText,
        error: ChainyColors.error,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: ChainyColors.lightBackground,
      
      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: ChainyColors.lightBackground,
        foregroundColor: ChainyColors.lightPrimaryText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: ChainyColors.lightPrimaryText,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Card
      cardTheme: CardThemeData(
        color: ChainyColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Text Theme
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          color: ChainyColors.lightPrimaryText,
          fontSize: 34,
          fontWeight: FontWeight.w400,
        ),
        displayMedium: GoogleFonts.inter(
          color: ChainyColors.lightPrimaryText,
          fontSize: 28,
          fontWeight: FontWeight.w400,
        ),
        displaySmall: GoogleFonts.inter(
          color: ChainyColors.lightPrimaryText,
          fontSize: 22,
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: GoogleFonts.inter(
          color: ChainyColors.lightPrimaryText,
          fontSize: 22,
          fontWeight: FontWeight.w400,
        ),
        headlineMedium: GoogleFonts.inter(
          color: ChainyColors.lightPrimaryText,
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
        headlineSmall: GoogleFonts.inter(
          color: ChainyColors.lightPrimaryText,
          fontSize: 17,
          fontWeight: FontWeight.w400,
        ),
        titleLarge: GoogleFonts.inter(
          color: ChainyColors.lightPrimaryText,
          fontSize: 22,
          fontWeight: FontWeight.w400,
        ),
        titleMedium: GoogleFonts.inter(
          color: ChainyColors.lightPrimaryText,
          fontSize: 17,
          fontWeight: FontWeight.w400,
        ),
        titleSmall: GoogleFonts.inter(
          color: ChainyColors.lightPrimaryText,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        bodyLarge: GoogleFonts.inter(
          color: ChainyColors.lightPrimaryText,
          fontSize: 17,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.inter(
          color: ChainyColors.lightPrimaryText,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: GoogleFonts.inter(
          color: ChainyColors.lightSecondaryText,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: GoogleFonts.inter(
          color: ChainyColors.lightPrimaryText,
          fontSize: 17,
          fontWeight: FontWeight.w400,
        ),
        labelMedium: GoogleFonts.inter(
          color: ChainyColors.lightPrimaryText,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        labelSmall: GoogleFonts.inter(
          color: ChainyColors.lightSecondaryText,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ChainyColors.lightAccentBlue,
          foregroundColor: ChainyColors.lightPrimaryText,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ChainyColors.lightAccentBlue,
          side: const BorderSide(color: ChainyColors.lightAccentBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ChainyColors.lightAccentBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ChainyColors.lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ChainyColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ChainyColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ChainyColors.lightAccentBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ChainyColors.error),
        ),
        labelStyle: const TextStyle(color: ChainyColors.lightSecondaryText),
        hintStyle: const TextStyle(color: ChainyColors.lightSecondaryText),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ChainyColors.lightCard,
        selectedItemColor: ChainyColors.lightAccentBlue,
        unselectedItemColor: ChainyColors.lightSecondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      
      // Tab Bar
      tabBarTheme: const TabBarThemeData(
        labelColor: ChainyColors.lightAccentBlue,
        unselectedLabelColor: ChainyColors.lightSecondaryText,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: ChainyColors.lightAccentBlue, width: 2),
        ),
      ),
    );
  }
  
  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: ChainyColors.darkAccentBlue,
        secondary: ChainyColors.darkOrange,
        surface: ChainyColors.darkCard,
        onPrimary: ChainyColors.darkPrimaryText,
        onSecondary: ChainyColors.darkBackground,
        onSurface: ChainyColors.darkPrimaryText,
        error: ChainyColors.error,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: ChainyColors.darkBackground,
      
      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: ChainyColors.darkBackground,
        foregroundColor: ChainyColors.darkPrimaryText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: ChainyColors.darkPrimaryText,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Card
      cardTheme: CardThemeData(
        color: ChainyColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Text Theme (same as light for this black-based theme)
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          color: ChainyColors.darkPrimaryText,
          fontSize: 34,
          fontWeight: FontWeight.w400,
        ),
        displayMedium: GoogleFonts.inter(
          color: ChainyColors.darkPrimaryText,
          fontSize: 28,
          fontWeight: FontWeight.w400,
        ),
        displaySmall: GoogleFonts.inter(
          color: ChainyColors.darkPrimaryText,
          fontSize: 22,
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: GoogleFonts.inter(
          color: ChainyColors.darkPrimaryText,
          fontSize: 22,
          fontWeight: FontWeight.w400,
        ),
        headlineMedium: GoogleFonts.inter(
          color: ChainyColors.darkPrimaryText,
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
        headlineSmall: GoogleFonts.inter(
          color: ChainyColors.darkPrimaryText,
          fontSize: 17,
          fontWeight: FontWeight.w400,
        ),
        titleLarge: GoogleFonts.inter(
          color: ChainyColors.darkPrimaryText,
          fontSize: 22,
          fontWeight: FontWeight.w400,
        ),
        titleMedium: GoogleFonts.inter(
          color: ChainyColors.darkPrimaryText,
          fontSize: 17,
          fontWeight: FontWeight.w400,
        ),
        titleSmall: GoogleFonts.inter(
          color: ChainyColors.darkPrimaryText,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        bodyLarge: GoogleFonts.inter(
          color: ChainyColors.darkPrimaryText,
          fontSize: 17,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.inter(
          color: ChainyColors.darkPrimaryText,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: GoogleFonts.inter(
          color: ChainyColors.darkSecondaryText,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: GoogleFonts.inter(
          color: ChainyColors.darkPrimaryText,
          fontSize: 17,
          fontWeight: FontWeight.w400,
        ),
        labelMedium: GoogleFonts.inter(
          color: ChainyColors.darkPrimaryText,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        labelSmall: GoogleFonts.inter(
          color: ChainyColors.darkSecondaryText,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ChainyColors.darkAccentBlue,
          foregroundColor: ChainyColors.darkPrimaryText,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ChainyColors.darkAccentBlue,
          side: const BorderSide(color: ChainyColors.darkAccentBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ChainyColors.darkAccentBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ChainyColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ChainyColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ChainyColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ChainyColors.darkAccentBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ChainyColors.error),
        ),
        labelStyle: const TextStyle(color: ChainyColors.darkSecondaryText),
        hintStyle: const TextStyle(color: ChainyColors.darkSecondaryText),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ChainyColors.darkCard,
        selectedItemColor: ChainyColors.darkAccentBlue,
        unselectedItemColor: ChainyColors.darkSecondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      
      // Tab Bar
      tabBarTheme: const TabBarThemeData(
        labelColor: ChainyColors.darkAccentBlue,
        unselectedLabelColor: ChainyColors.darkSecondaryText,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: ChainyColors.darkAccentBlue, width: 2),
        ),
      ),
    );
  }
}
