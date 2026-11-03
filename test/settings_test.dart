import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:traffic_tracker_app/constants/app_palettes.dart';
import 'package:traffic_tracker_app/constants/colors.dart';
import 'package:traffic_tracker_app/constants/icons.dart';
import 'package:traffic_tracker_app/constants/typography.dart';
import 'package:traffic_tracker_app/controllers/settings_controller.dart';
import 'package:traffic_tracker_app/localization/app_translations.dart';
import 'package:traffic_tracker_app/views/settings/settings_view.dart';
import 'package:traffic_tracker_app/views/settings/widgets/about_app_sheet.dart';
import 'package:traffic_tracker_app/views/settings/widgets/language_selector_sheet.dart';
import 'package:traffic_tracker_app/views/settings/widgets/palette_selector_sheet.dart';
import 'package:traffic_tracker_app/views/settings/widgets/theme_selector_sheet.dart';

void main() {
  group('SettingsController Tests', () {
    late SettingsController controller;

    setUp(() {
      Get.reset();
      controller = Get.put(SettingsController());
    });

    test('Initial settings values default correctly', () {
      expect(controller.themeMode.value, ThemeMode.system);
      expect(controller.useDynamicColor.value, isTrue);
      expect(controller.selectedPaletteId.value, 'forest_green');
    });

    test('Changing theme mode updates reactive state', () {
      controller.setThemeMode(ThemeMode.dark);
      expect(controller.themeMode.value, ThemeMode.dark);

      controller.setThemeMode(ThemeMode.light);
      expect(controller.themeMode.value, ThemeMode.light);

      controller.setThemeMode(ThemeMode.system);
      expect(controller.themeMode.value, ThemeMode.system);
    });

    test('Changing dynamic color and palette updates reactive state', () {
      controller.setUseDynamicColor(false);
      expect(controller.useDynamicColor.value, isFalse);

      controller.setPalette('crimson_red');
      expect(controller.selectedPaletteId.value, 'crimson_red');
      expect(controller.activePalette.seedColor, AppPalettes.crimsonRed.primaryColor);

      controller.setUseDynamicColor(true);
      expect(controller.useDynamicColor.value, isTrue);
    });

    test('RTL flag reflects active locale', () {
      controller.currentLocale.value = const Locale('ar', 'SA');
      expect(controller.isArabic, isTrue);

      controller.currentLocale.value = const Locale('en', 'US');
      expect(controller.isArabic, isFalse);
    });

    test('AppPalettes findById returns correct palette or fallback', () {
      final blue = AppPalettes.findById('ocean_blue');
      expect(blue.id, 'ocean_blue');

      final unknown = AppPalettes.findById('non_existent');
      expect(unknown.id, AppPalettes.defaultPaletteId);
    });

    test('AppTypography resolves fonts correctly', () {
      expect(AppTypography.primaryFont, 'ReadexPro');
      expect(AppTypography.resolveFontFamily(isArabic: true), 'ReadexPro');
      expect(AppTypography.resolveFontFamily(isArabic: false), 'ReadexPro');

      final textTheme = AppTypography.buildTextTheme(
        primaryColor: AppColors.lightTextPrimary,
        secondaryColor: AppColors.lightTextSecondary,
        mutedColor: AppColors.lightTextMuted,
      );
      expect(textTheme.bodyLarge?.fontFamily, 'ReadexPro');
      expect(textTheme.bodySmall?.color, AppColors.lightTextSecondary);
    });
  });

  group('SettingsView Widget Tests', () {
    setUp(() {
      Get.reset();
      Get.put(SettingsController());
    });

    testWidgets('SettingsView renders all requested options properly', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en', 'US'),
          home: const SettingsView(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Settings'), findsOneWidget);

      // Verify requested options: Language, Theme, Color Scheme, About App
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Appearance & Theme'), findsOneWidget);
      expect(find.text('App Color & Theme Scheme'), findsOneWidget);
      expect(find.text('About App'), findsOneWidget);

      // 1. Open Language bottom sheet
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();
      expect(find.byType(LanguageSelectorSheet), findsOneWidget);
      expect(find.text('Select Language'), findsOneWidget);

      // Close Language sheet
      await tester.tap(find.byIcon(AppIcons.close));
      await tester.pumpAndSettle();

      // 2. Open Theme bottom sheet
      await tester.tap(find.text('Appearance & Theme'));
      await tester.pumpAndSettle();
      expect(find.byType(ThemeSelectorSheet), findsOneWidget);
      expect(find.text('Select Theme Mode'), findsOneWidget);

      // Close Theme sheet
      await tester.tap(find.byIcon(AppIcons.close));
      await tester.pumpAndSettle();

      // 3. Open Color Scheme bottom sheet
      await tester.tap(find.text('App Color & Theme Scheme'));
      await tester.pumpAndSettle();
      expect(find.byType(PaletteSelectorSheet), findsOneWidget);
      expect(find.text('Select Color Scheme'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(PaletteSelectorSheet),
          matching: find.text('Material You (System Dynamic)'),
        ),
        findsOneWidget,
      );

      // Close Color Scheme sheet
      await tester.tap(find.byIcon(AppIcons.close));
      await tester.pumpAndSettle();

      // 4. Open About App bottom sheet
      await tester.tap(find.text('About App'));
      await tester.pumpAndSettle();
      expect(find.byType(AboutAppSheet), findsOneWidget);
      expect(find.text('About Traffic Tracker'), findsOneWidget);

      // Close About App sheet
      await tester.tap(find.byIcon(AppIcons.close));
      await tester.pumpAndSettle();
    });
  });
}
