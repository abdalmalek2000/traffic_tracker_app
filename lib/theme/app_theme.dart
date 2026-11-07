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
    final Color seed = dynamicSeedColor ?? palette.primaryColor;
    final ColorScheme baseScheme = dynamicScheme ??
        ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
          primary: dynamicSeedColor != null ? null : palette.primaryColor,
          secondary: dynamicSeedColor != null ? null : palette.secondaryColor,
          surface: AppColors.lightSurface,
          error: AppColors.statusServerError,
        );

    final Color primaryColor = baseScheme.primary;
    final Color onPrimaryColor = AppColors.getContrastingColor(primaryColor);
    final Color primContainer = baseScheme.primaryContainer;
    final Color onPrimContainer = AppColors.getContrastingColor(primContainer);
    final Color secContainer = baseScheme.secondaryContainer;
    final Color onSecContainer = AppColors.getContrastingColor(secContainer);

    final ColorScheme colorScheme = baseScheme.copyWith(
      primary: primaryColor,
      onPrimary: onPrimaryColor,
      primaryContainer: primContainer,
      onPrimaryContainer: onPrimContainer,
      secondaryContainer: secContainer,
      onSecondaryContainer: onSecContainer,
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
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusBase,
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusBase,
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.6)),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusBase,
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLg,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusBase,
        ),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 60,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer.withValues(alpha: 0.7),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 21,
            color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          );
        }),
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
    final Color seed = dynamicSeedColor ?? palette.primaryColor;
    final ColorScheme baseScheme = dynamicScheme ??
        ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
          // In Material 3 dark mode with dynamic accent color, allow ColorScheme.fromSeed
          // to generate the optimal Tone 80 dynamic primary for proper contrast.
          // For static palettes, use darkPrimaryColor.
          primary: dynamicSeedColor != null ? null : palette.darkPrimaryColor,
          surface: AppColors.darkSurface,
          error: AppColors.statusServerError,
        );

    final Color primaryColor = baseScheme.primary;
    final Color onPrimaryColor = AppColors.getContrastingColor(primaryColor);
    final Color primContainer = baseScheme.primaryContainer;
    final Color onPrimContainer = AppColors.getContrastingColor(primContainer);
    final Color secContainer = baseScheme.secondaryContainer;
    final Color onSecContainer = AppColors.getContrastingColor(secContainer);

    final ColorScheme colorScheme = baseScheme.copyWith(
      primary: primaryColor,
      onPrimary: onPrimaryColor,
      primaryContainer: primContainer,
      onPrimaryContainer: onPrimContainer,
      secondaryContainer: secContainer,
      onSecondaryContainer: onSecContainer,
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
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusBase,
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusBase,
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.6)),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusBase,
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLg,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusBase,
        ),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 60,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.25),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 21,
            color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          );
        }),
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
