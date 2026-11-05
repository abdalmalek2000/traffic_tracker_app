import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'constants/typography.dart';
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
      final fontFamily = AppTypography.resolveFontFamily(
        isArabic: settingsController.isArabic,
      );

      return GetMaterialApp(
        title: 'Traffic Tracker',
        debugShowCheckedModeBanner: false,
        themeMode: themeMode,
        theme: AppTheme.buildLightTheme(
          dynamicSeedColor: dynamicColor,
          palette: palette,
          fontFamily: fontFamily,
        ),
        darkTheme: AppTheme.buildDarkTheme(
          dynamicSeedColor: dynamicColor,
          palette: palette,
          fontFamily: fontFamily,
        ),
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        fallbackLocale: const Locale('en', 'US'),
        home: const MainNavigationView(),
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          final fluidScale = AppTypography.getResponsiveFontScale(
            mediaQuery.size.width,
          );
          // Combine dynamic fluid scale with device accessibility text scale within safe clamp
          final systemFactor = mediaQuery.textScaler.scale(1.0);
          final combinedScale = (fluidScale * systemFactor).clamp(0.82, 1.22);

          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: TextScaler.linear(combinedScale),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      );
    });
  }
}
