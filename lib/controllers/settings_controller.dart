import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_palettes.dart';
import '../constants/icons.dart';
import '../services/battery_optimization_service.dart';
import '../services/system_theme_service.dart';
import '../services/vpn_native_bridge.dart';

/// Controller managing application settings such as theme, locale,
/// dynamic Material You colors, static color palettes, battery optimization,
/// and PCAP capture save location.
///
/// Automatically persists all user choices via [SharedPreferences].
class SettingsController extends GetxController with WidgetsBindingObserver {
  static SettingsController get to => Get.find<SettingsController>();

  // Storage keys for persisting user choices
  static const String keyThemeMode = 'settings_theme_mode';
  static const String keyUseDynamicColor = 'settings_use_dynamic_color';
  static const String keySelectedPaletteId = 'settings_selected_palette_id';
  static const String keyLocaleLanguage = 'settings_locale_language';
  static const String keyLocaleCountry = 'settings_locale_country';
  static const String keyPcapLocationType = 'settings_pcap_location_type';
  static const String keyCustomPcapUri = 'settings_custom_pcap_uri';
  static const String keyCustomPcapPath = 'settings_custom_pcap_path';

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

  /// Whether battery optimization is ignored (unrestricted background execution)
  final RxBool isIgnoringBatteryOptimizations = false.obs;

  /// Selected PCAP save location: 'downloads' (default), 'documents', 'app_storage', 'custom'
  final RxString pcapLocationType = 'downloads'.obs;

  /// Custom SAF directory Uri when 'custom' is active
  final RxnString customPcapUri = RxnString();

  /// Display name / relative path for custom chosen folder
  final RxnString customPcapPath = RxnString();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    // Synchronize initial locale with Get's device/configured locale
    if (Get.locale != null) {
      currentLocale.value = Get.locale!;
    }
    loadPersistedSettings();
    loadSystemAccentColor();
    checkBatteryOptimization();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkBatteryOptimization();
    }
  }

  /// Load user choices from persistent storage
  Future<void> loadPersistedSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Restore Theme mode
      final savedTheme = prefs.getString(keyThemeMode);
      if (savedTheme != null) {
        if (savedTheme == 'light') {
          themeMode.value = ThemeMode.light;
        } else if (savedTheme == 'dark') {
          themeMode.value = ThemeMode.dark;
        } else {
          themeMode.value = ThemeMode.system;
        }
      }

      // Restore Dynamic Color toggle
      final savedDynamic = prefs.getBool(keyUseDynamicColor);
      if (savedDynamic != null) {
        useDynamicColor.value = savedDynamic;
      }

      // Restore Palette
      final savedPalette = prefs.getString(keySelectedPaletteId);
      if (savedPalette != null && savedPalette.isNotEmpty) {
        selectedPaletteId.value = savedPalette;
      }

      // Restore Locale
      final lang = prefs.getString(keyLocaleLanguage);
      if (lang != null && lang.isNotEmpty) {
        final country = prefs.getString(keyLocaleCountry);
        final loc = Locale(lang, country);
        currentLocale.value = loc;
        if (Get.context != null) {
          Get.updateLocale(loc);
        }
      }

      // Restore PCAP save location
      final savedLocation = prefs.getString(keyPcapLocationType);
      if (savedLocation != null && savedLocation.isNotEmpty) {
        pcapLocationType.value = savedLocation;
      }

      final savedUri = prefs.getString(keyCustomPcapUri);
      if (savedUri != null && savedUri.isNotEmpty) {
        customPcapUri.value = savedUri;
      }

      final savedPath = prefs.getString(keyCustomPcapPath);
      if (savedPath != null && savedPath.isNotEmpty) {
        customPcapPath.value = savedPath;
      }
    } catch (e) {
      debugPrint('Failed to load persisted settings: $e');
    }
  }

  Future<void> _saveString(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (e) {
      debugPrint('Failed to persist $key: $e');
    }
  }

  Future<void> _saveBool(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      debugPrint('Failed to persist $key: $e');
    }
  }

  /// Query native Android 12+ dynamic accent color
  Future<void> loadSystemAccentColor() async {
    systemAccentColor.value = await SystemThemeService.getDynamicAccentColor();
  }

  /// Check current battery optimization status from native platform
  Future<void> checkBatteryOptimization() async {
    isIgnoringBatteryOptimizations.value =
        await BatteryOptimizationService.isIgnoringBatteryOptimizations();
  }

  /// Request battery optimization exemption or open system settings
  Future<void> requestIgnoreBatteryOptimization() async {
    await BatteryOptimizationService.requestIgnoreBatteryOptimization();
    await checkBatteryOptimization();
  }

  /// Change theme mode dynamically across the entire app
  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    if (Get.context != null) {
      Get.changeThemeMode(mode);
    }
    final str = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    _saveString(keyThemeMode, str);
  }

  /// Change application language dynamically
  void setLocale(Locale locale) {
    currentLocale.value = locale;
    if (Get.context != null) {
      Get.updateLocale(locale);
    }
    _saveString(keyLocaleLanguage, locale.languageCode);
    if (locale.countryCode != null) {
      _saveString(keyLocaleCountry, locale.countryCode!);
    }
  }

  /// Toggle or set whether dynamic color is enabled
  void setUseDynamicColor(bool value) {
    useDynamicColor.value = value;
    _saveBool(keyUseDynamicColor, value);
  }

  /// Select a static color palette and turn off dynamic color override
  void setPalette(String paletteId) {
    selectedPaletteId.value = paletteId;
    useDynamicColor.value = false;
    _saveString(keySelectedPaletteId, paletteId);
    _saveBool(keyUseDynamicColor, false);
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

  /// Set predefined PCAP save location ('downloads', 'documents', 'app_storage')
  void setPcapLocationType(String type) {
    pcapLocationType.value = type;
    _saveString(keyPcapLocationType, type);
  }

  /// Set custom SAF location chosen by user
  void setCustomPcapLocation(String uri, String displayPath) {
    pcapLocationType.value = 'custom';
    customPcapUri.value = uri;
    customPcapPath.value = displayPath;
    _saveString(keyPcapLocationType, 'custom');
    _saveString(keyCustomPcapUri, uri);
    _saveString(keyCustomPcapPath, displayPath);
  }

  /// Launch Android system directory picker to choose a custom folder
  Future<bool> pickCustomPcapDirectory() async {
    final result = await VpnNativeBridge.pickDirectory();
    if (result != null && result['uri'] != null) {
      final uri = result['uri'] as String;
      final display = (result['displayPath'] as String?) ?? 'Custom Folder';
      setCustomPcapLocation(uri, display);
      return true;
    }
    return false;
  }

  /// Human-readable label for currently selected PCAP directory
  String get pcapLocationDisplayName {
    switch (pcapLocationType.value) {
      case 'downloads':
        return 'pcap_dir_downloads'.tr;
      case 'documents':
        return 'pcap_dir_documents'.tr;
      case 'app_storage':
        return 'pcap_dir_app_storage'.tr;
      case 'custom':
        return customPcapPath.value ?? 'pcap_dir_custom'.tr;
      default:
        return 'pcap_dir_downloads'.tr;
    }
  }
}
