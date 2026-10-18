import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/navigation_controller.dart';
import 'controllers/traffic_controller.dart';
import 'controllers/vpn_controller.dart';
import 'localization/app_translations.dart';
import 'theme/app_theme.dart';
import 'views/main_navigation_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Centralized MVC Controllers injection
  Get.put(NavigationController());
  Get.put(TrafficController());
  Get.put(VpnController());

  runApp(const TrafficTrackerApp());
}

class TrafficTrackerApp extends StatelessWidget {
  const TrafficTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Traffic Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      translations: AppTranslations(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      home: const MainNavigationView(),
    );
  }
}
