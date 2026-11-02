import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/icons.dart';

/// Controller managing application settings such as theme, locale,
/// and future configurable settings.
class SettingsController extends GetxController {
  static SettingsController get to => Get.find<SettingsController>();

  /// Currently active theme mode
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  /// Currently active locale
  final Rx<Locale> currentLocale = (Get.locale ?? const Locale('en', 'US')).obs;

  @override
  void onInit() {
    super.onInit();
    // Synchronize initial locale with Get's device/configured locale
    if (Get.locale != null) {
      currentLocale.value = Get.locale!;
    }
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
