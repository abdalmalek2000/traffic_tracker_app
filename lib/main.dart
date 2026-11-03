import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/navigation_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/traffic_controller.dart';
import 'controllers/vpn_controller.dart';
import 'localization/app_translations.dart';
import 'theme/app_theme.dart';
import 'views/main_navigation_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Centralized MVC Controllers injection
  Get.put(NavigationController());
  Get.put(SettingsController());
  Get.put(TrafficController());
  Get.put(VpnController());

  runApp(const TrafficTrackerApp());
}

class TrafficTrackerApp extends StatelessWidget {
  const TrafficTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final settingsController = SettingsController.to;
      final themeMode = settingsController.themeMode.value;
      final isDynamic = settingsController.useDynamicColor.value;
      final dynamicColor =
          isDynamic ? settingsController.systemAccentColor.value : null;
      final palette = settingsController.activePalette;

      return GetMaterialApp(
        title: 'Traffic Tracker',
        debugShowCheckedModeBanner: false,
        themeMode: themeMode,
        theme: AppTheme.buildLightTheme(
          dynamicSeedColor: dynamicColor,
          palette: palette,
        ),
        darkTheme: AppTheme.buildDarkTheme(
          dynamicSeedColor: dynamicColor,
          palette: palette,
        ),
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        fallbackLocale: const Locale('en', 'US'),
        home: const MainNavigationView(),
      );
    });
  }
}
