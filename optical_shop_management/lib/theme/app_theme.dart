import 'package:flutter/material.dart';

/// AppTheme class containing all theme configuration for the Optical Shop Management app
/// Includes color palette, typography, spacing, and border radius constants
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Color Constants
  static const primaryColor = Color(0xFF1a365d); // Deep navy blue
  static const accentColor = Color(0xFFf59e0b); // Warm amber/gold
  static const backgroundColor = Color(0xFFfaf9f6); // Soft cream
  static const textColor = Color(0xFF2d3748); // Charcoal gray
  static const successColor = Color(0xFF14b8a6); // Teal green
  static const errorColor = Color(0xFFef4444); // Red

  // Typography
  static const headingFont = 'Poppins';
  static const bodyFont = 'Inter';

  // Spacing Constants
  static const spacing4 = 4.0;
  static const spacing8 = 8.0;
  static const spacing12 = 12.0;
  static const spacing16 = 16.0;
  static const spacing24 = 24.0;
  static const spacing32 = 32.0;

  // Border Radius Constants
  static const radiusSmall = 8.0;
  static const radiusMedium = 16.0;
  static const radiusLarge = 24.0;

  /// Light theme configuration for the app
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: Colors.white,
        error: errorColor,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: headingFont,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        displayMedium: TextStyle(
          fontFamily: headingFont,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        bodyLarge: TextStyle(
          fontFamily: bodyFont,
          fontSize: 16,
          color: textColor,
        ),
        bodyMedium: TextStyle(
          fontFamily: bodyFont,
          fontSize: 14,
          color: textColor,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
