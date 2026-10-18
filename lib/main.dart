import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/navigation_controller.dart';
import 'controllers/traffic_controller.dart';
import 'controllers/vpn_controller.dart';
import 'views/main_navigation_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // حقن المتحكمات المركزية (MVC Controllers)
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
      title: 'مراقب حركة الشبكة - Traffic Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF2563EB),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Color(0xFFFFFFFF),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF3B82F6),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Color(0xFF1E293B),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const MainNavigationView(),
    );
  }
}
