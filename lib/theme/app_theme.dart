import 'package:flutter/material.dart';
import '../constants/app_palettes.dart';
import '../constants/colors.dart';
import '../constants/spacing.dart';
import '../constants/typography.dart';

/// App theme configurations for Light and Dark modes.
/// Supports both Android 12+ Material You Dynamic Color schemes
/// and custom static color palettes.
class AppTheme {
  AppTheme._();

  /// Build Light ThemeData using either dynamic Material You seed color or custom palette
  static ThemeData buildLightTheme({
    Color? dynamicSeedColor,
    ColorScheme? dynamicScheme,
    AppColorPalette palette = AppPalettes.forestGreen,
    String fontFamily = AppTypography.primaryFont,
  }) {
    final ColorScheme baseScheme = dynamicScheme ??
        ColorScheme.fromSeed(
          seedColor: dynamicSeedColor ?? palette.primaryColor,
          brightness: Brightness.light,
          primary: dynamicSeedColor ?? palette.primaryColor,
          secondary: dynamicSeedColor != null ? null : palette.secondaryColor,
          surface: AppColors.lightSurface,
          error: AppColors.statusServerError,
        );

    final ColorScheme colorScheme = baseScheme.copyWith(
      onSurface: AppColors.lightTextPrimary,
      onSurfaceVariant: AppColors.lightTextSecondary,
      surface: AppColors.lightSurface,
      error: AppColors.statusServerError,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      fontFamily: fontFamily,
      textTheme: AppTypography.buildTextTheme(
        primaryColor: AppColors.lightTextPrimary,
        secondaryColor: AppColors.lightTextSecondary,
        mutedColor: AppColors.lightTextMuted,
        fontFamily: fontFamily,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer.withValues(alpha: 0.7),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLg,
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  /// Build Dark ThemeData using either dynamic Material You seed color or custom palette
  static ThemeData buildDarkTheme({
    Color? dynamicSeedColor,
    ColorScheme? dynamicScheme,
    AppColorPalette palette = AppPalettes.forestGreen,
    String fontFamily = AppTypography.primaryFont,
  }) {
    final ColorScheme baseScheme = dynamicScheme ??
        ColorScheme.fromSeed(
          seedColor: dynamicSeedColor ?? palette.darkPrimaryColor,
          brightness: Brightness.dark,
          primary: dynamicSeedColor ?? palette.darkPrimaryColor,
          surface: AppColors.darkSurface,
          error: AppColors.statusServerError,
        );

    final ColorScheme colorScheme = baseScheme.copyWith(
      onSurface: AppColors.darkTextPrimary,
      onSurfaceVariant: AppColors.darkTextSecondary,
      surface: AppColors.darkSurface,
      error: AppColors.statusServerError,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      fontFamily: fontFamily,
      textTheme: AppTypography.buildTextTheme(
        primaryColor: AppColors.darkTextPrimary,
        secondaryColor: AppColors.darkTextSecondary,
        mutedColor: AppColors.darkTextMuted,
        fontFamily: fontFamily,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.25),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLg,
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  /// Backward-compatible default light theme
  static ThemeData get lightTheme => buildLightTheme();

  /// Backward-compatible default dark theme
  static ThemeData get darkTheme => buildDarkTheme();
}
