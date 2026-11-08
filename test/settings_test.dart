import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:traffic_tracker_app/views/settings/widgets/pcap_location_selector_sheet.dart';
import 'package:traffic_tracker_app/views/settings/widgets/theme_selector_sheet.dart';

void main() {
  group('SettingsController Tests', () {
    late SettingsController controller;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      Get.reset();
      Get.addTranslations(AppTranslations().keys);
      Get.locale = const Locale('en', 'US');
      controller = Get.put(SettingsController());
    });

    test('Initial settings values default correctly', () {
      expect(controller.themeMode.value, ThemeMode.system);
      expect(controller.useDynamicColor.value, isTrue);
      expect(controller.selectedPaletteId.value, 'forest_green');
      expect(controller.isIgnoringBatteryOptimizations.value, isFalse);
      expect(controller.pcapLocationType.value, 'downloads');
      expect(controller.pcapLocationDisplayName, 'Downloads Folder');
    });

    test('PCAP location updates correctly', () {
      controller.setPcapLocationType('documents');
      expect(controller.pcapLocationType.value, 'documents');
      expect(controller.pcapLocationDisplayName, 'Documents Folder');

      controller.setPcapLocationType('app_storage');
      expect(controller.pcapLocationType.value, 'app_storage');
      expect(controller.pcapLocationDisplayName, 'App Storage Folder');

      controller.setCustomPcapLocation('content://tree/custom', 'Captures');
      expect(controller.pcapLocationType.value, 'custom');
      expect(controller.customPcapUri.value, 'content://tree/custom');
      expect(controller.pcapLocationDisplayName, 'Captures');
    });

    test('Battery optimization state changes reactively', () {
      expect(controller.isIgnoringBatteryOptimizations.value, isFalse);
      controller.isIgnoringBatteryOptimizations.value = true;
      expect(controller.isIgnoringBatteryOptimizations.value, isTrue);
      controller.isIgnoringBatteryOptimizations.value = false;
      expect(controller.isIgnoringBatteryOptimizations.value, isFalse);
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

    test('User preferences persist to and load from SharedPreferences', () async {
      // Modify several settings
      controller.setThemeMode(ThemeMode.dark);
      controller.setPalette('crimson_red');
      controller.setPcapLocationType('documents');
      controller.setLocale(const Locale('ar', 'SA'));

      // Verify immediate reactive state
      expect(controller.themeMode.value, ThemeMode.dark);
      expect(controller.selectedPaletteId.value, 'crimson_red');
      expect(controller.pcapLocationType.value, 'documents');
      expect(controller.isArabic, isTrue);

      // Verify stored values in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(SettingsController.keyThemeMode), 'dark');
      expect(prefs.getString(SettingsController.keySelectedPaletteId), 'crimson_red');
      expect(prefs.getString(SettingsController.keyPcapLocationType), 'documents');
      expect(prefs.getString(SettingsController.keyLocaleLanguage), 'ar');
      expect(prefs.getString(SettingsController.keyLocaleCountry), 'SA');

      // Create a fresh new controller to simulate app restart
      Get.reset();
      Get.addTranslations(AppTranslations().keys);
      final reloadedController = Get.put(SettingsController());
      await reloadedController.loadPersistedSettings();

      // Verify that values are restored from SharedPreferences
      expect(reloadedController.themeMode.value, ThemeMode.dark);
      expect(reloadedController.selectedPaletteId.value, 'crimson_red');
      expect(reloadedController.pcapLocationType.value, 'documents');
      expect(reloadedController.currentLocale.value.languageCode, 'ar');
    });
  });

  group('SettingsView Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      Get.reset();
      Get.put(SettingsController());
    });

    testWidgets('SettingsView renders all requested options properly', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

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

      // Verify Sections
      expect(find.text('General Preferences'), findsOneWidget);
      expect(find.text('Application Preferences'), findsOneWidget);
      expect(find.text('Application Info'), findsOneWidget);

      // Verify requested options: Language, Theme, Color Scheme, Battery Optimization, About App
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Appearance & Theme'), findsOneWidget);
      expect(find.text('App Color & Theme Scheme'), findsOneWidget);
      expect(find.text('Battery Optimization'), findsOneWidget);
      expect(find.text('About App'), findsOneWidget);

      // Verify default state has circle with horizontal line (minusCircle)
      expect(find.byIcon(AppIcons.minusCircle), findsOneWidget);
      expect(find.byIcon(AppIcons.checkCircle), findsNothing);

      // Verify tapping on Battery Optimization tile
      await tester.tap(find.text('Battery Optimization'));
      await tester.pumpAndSettle();

      // Update state to ignored/unrestricted
      final controller = SettingsController.to;
      controller.isIgnoringBatteryOptimizations.value = true;
      await tester.pumpAndSettle();

      // Verify trailing icon transforms into green checkmark
      expect(find.byIcon(AppIcons.minusCircle), findsNothing);
      expect(find.byIcon(AppIcons.checkCircle), findsOneWidget);
      final checkIcon = tester.widget<Icon>(find.byIcon(AppIcons.checkCircle));
      expect(checkIcon.color, AppColors.statusSuccess);

      // Reset for subsequent sheet tests
      controller.isIgnoringBatteryOptimizations.value = false;
      await tester.pumpAndSettle();

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

      // 4. Open PCAP Location bottom sheet
      await tester.tap(find.text('PCAP Save Location'));
      await tester.pumpAndSettle();
      expect(find.byType(PcapLocationSelectorSheet), findsOneWidget);
      expect(find.text('Select PCAP Save Location'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(PcapLocationSelectorSheet),
          matching: find.text('Downloads Folder'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(PcapLocationSelectorSheet),
          matching: find.text('Documents Folder'),
        ),
        findsOneWidget,
      );
      expect(find.text('App Storage Folder'), findsOneWidget);
      expect(find.text('Custom Folder...'), findsOneWidget);

      // Select Documents Folder
      await tester.tap(
        find.descendant(
          of: find.byType(PcapLocationSelectorSheet),
          matching: find.text('Documents Folder'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PcapLocationSelectorSheet), findsNothing);
      expect(controller.pcapLocationType.value, 'documents');

      // 5. Open About App bottom sheet
      await tester.tap(find.text('About App'));
      await tester.pumpAndSettle();
      expect(find.byType(AboutAppSheet), findsOneWidget);
      expect(find.text('About Traffic Tracker'), findsOneWidget);

      // Close About App sheet
      await tester.tap(find.byIcon(AppIcons.close));
      await tester.pumpAndSettle();
    });

    testWidgets('SettingsView renders Battery Optimization and PCAP location in Arabic correctly', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('ar', 'SA'),
          home: const SettingsView(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('التفضيلات العامة'), findsOneWidget);
      expect(find.text('تفضيلات التطبيق'), findsOneWidget);
      expect(find.text('معلومات التطبيق'), findsOneWidget);
      expect(find.text('تحسين استهلاك البطارية'), findsOneWidget);
      expect(find.text('إيقاف التحسين للسماح للتطبيق بالعمل في الخلفية دون قيود'), findsOneWidget);
      expect(find.text('مكان حفظ ملفات PCAP'), findsOneWidget);
      expect(find.text('مجلد التنزيلات (Downloads)'), findsOneWidget);
      expect(find.byIcon(AppIcons.minusCircle), findsOneWidget);

      final controller = SettingsController.to;
      controller.isIgnoringBatteryOptimizations.value = true;
      await tester.pumpAndSettle();

      expect(find.byIcon(AppIcons.checkCircle), findsOneWidget);
      final checkIcon = tester.widget<Icon>(find.byIcon(AppIcons.checkCircle));
      expect(checkIcon.color, AppColors.statusSuccess);
    });
  });

  group('AppTranslations Parity & Completeness Tests', () {
    test('enUS and arAR have 100% key parity with no missing or empty translations', () {
      final enKeys = AppTranslations.enUS.keys.toSet();
      final arKeys = AppTranslations.arAR.keys.toSet();

      final missingInAr = enKeys.difference(arKeys);
      final missingInEn = arKeys.difference(enKeys);

      expect(missingInAr, isEmpty, reason: 'Keys present in English but missing in Arabic: $missingInAr');
      expect(missingInEn, isEmpty, reason: 'Keys present in Arabic but missing in English: $missingInEn');

      for (final entry in AppTranslations.enUS.entries) {
        expect(entry.value.trim(), isNotEmpty, reason: 'Empty en translation for key: ${entry.key}');
      }
      for (final entry in AppTranslations.arAR.entries) {
        expect(entry.value.trim(), isNotEmpty, reason: 'Empty ar translation for key: ${entry.key}');
      }
    });
  });
}
