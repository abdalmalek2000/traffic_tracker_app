import 'package:flutter/material.dart';

/// Centralized application typography configurations.
/// Manages font families, fallbacks, and bilingual font resolution.
class AppTypography {
  AppTypography._();

  /// Primary application font family (Readex Pro)
  /// Modern, world-class geometric font designed specifically for Arabic & Latin harmony.
  static const String primaryFont = 'ReadexPro';

  /// Optional secondary font for English/Latin if distinct styling is desired
  static const String? englishFont = null; // Set to custom family if English needs a separate font

  /// Font family fallbacks
  static const List<String> fontFallback = [
    'ReadexPro',
    'Roboto',
    'sans-serif',
  ];

  /// Resolves the appropriate font family based on active language
  static String resolveFontFamily({bool isArabic = true}) {
    if (!isArabic && englishFont != null) {
      return englishFont!;
    }
    return primaryFont;
  }

  /// Builds a cohesive, unified Material 3 TextTheme using the configured font family
  static TextTheme buildTextTheme({
    required Color primaryColor,
    required Color secondaryColor,
    required Color mutedColor,
    String fontFamily = primaryFont,
  }) {
    return TextTheme(
      // Display
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),

      // Headline
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),

      // Title
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: primaryColor,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 15,
        color: primaryColor,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 13.5,
        color: primaryColor,
      ),

      // Body
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 14.5,
        color: primaryColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.normal,
        fontSize: 13,
        color: primaryColor,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.normal,
        fontSize: 11.5,
        color: secondaryColor,
      ),

      // Label
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: primaryColor,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 11.5,
        color: secondaryColor,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.normal,
        fontSize: 10.5,
        color: mutedColor,
      ),
    );
  }
}
