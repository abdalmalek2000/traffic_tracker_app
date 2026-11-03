import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_palettes.dart';
import '../constants/icons.dart';
import '../services/system_theme_service.dart';

/// Controller managing application settings such as theme, locale,
/// dynamic Material You colors, and static color palettes.
class SettingsController extends GetxController {
  static SettingsController get to => Get.find<SettingsController>();

  /// Currently active theme mode
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  /// Currently active locale
  final Rx<Locale> currentLocale = (Get.locale ?? const Locale('en', 'US')).obs;

  /// Whether Material You dynamic system colors are enabled (Android 12+)
  final RxBool useDynamicColor = true.obs;

  /// Selected static color palette ID (used when dynamic colors are off or unavailable)
  final RxString selectedPaletteId = AppPalettes.forestGreen.id.obs;

  /// System dynamic accent color extracted from Android 12+ (Material You)
  final Rx<Color?> systemAccentColor = Rx<Color?>(null);

  @override
  void onInit() {
    super.onInit();
    // Synchronize initial locale with Get's device/configured locale
    if (Get.locale != null) {
      currentLocale.value = Get.locale!;
    }
    loadSystemAccentColor();
  }

  /// Query native Android 12+ dynamic accent color
  Future<void> loadSystemAccentColor() async {
    systemAccentColor.value = await SystemThemeService.getDynamicAccentColor();
  }

  /// Change theme mode dynamically across the entire app
  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
  }

  /// Change application language dynamically
  void setLocale(Locale locale) {
    currentLocale.value = locale;
    Get.updateLocale(locale);
  }

  /// Toggle or set whether dynamic color is enabled
  void setUseDynamicColor(bool value) {
    useDynamicColor.value = value;
  }

  /// Select a static color palette and turn off dynamic color override
  void setPalette(String paletteId) {
    selectedPaletteId.value = paletteId;
    useDynamicColor.value = false;
  }

  /// Get the currently active static palette
  AppColorPalette get activePalette => AppPalettes.findById(selectedPaletteId.value);

  /// Human-readable label for current theme
  String get themeModeName {
    switch (themeMode.value) {
      case ThemeMode.light:
        return 'theme_light'.tr;
      case ThemeMode.dark:
        return 'theme_dark'.tr;
      case ThemeMode.system:
        return 'theme_system'.tr;
    }
  }

  /// Icon corresponding to current theme
  IconData get themeModeIcon {
    switch (themeMode.value) {
      case ThemeMode.light:
        return AppIcons.sun;
      case ThemeMode.dark:
        return AppIcons.moon;
      case ThemeMode.system:
        return AppIcons.theme;
    }
  }

  /// Human-readable summary for current color scheme in settings
  String get colorSchemeSummaryName {
    if (useDynamicColor.value) {
      return 'color_dynamic_system'.tr;
    }
    return activePalette.localizedName;
  }

  /// Human-readable label for current language
  String get currentLanguageName {
    if (currentLocale.value.languageCode.startsWith('ar')) {
      return 'lang_arabic'.tr;
    }
    return 'lang_english'.tr;
  }

  /// Check whether the active language is RTL (Arabic)
  bool get isArabic => currentLocale.value.languageCode.startsWith('ar');
}
