import 'package:flutter/material.dart';
import 'ui/screens/traffic_list_screen.dart';
import 'ui/screens/vpn_dashboard_screen.dart';

void main() {
  runApp(const TrafficTrackerApp());
}

class TrafficTrackerApp extends StatelessWidget {
  const TrafficTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مراقب حركة الشبكة - Traffic Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF2563EB), // Modern Blue
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
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TrafficListScreen(),
    VpnDashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.http_rounded),
            selectedIcon: Icon(Icons.http_rounded, color: Colors.blue),
            label: 'فحص API (In-App)',
          ),
          NavigationDestination(
            icon: Icon(Icons.security_rounded),
            selectedIcon: Icon(Icons.security_rounded, color: Colors.green),
            label: 'فحص تطبيقات الجهاز (VPN)',
          ),
        ],
      ),
    );
  }
}
