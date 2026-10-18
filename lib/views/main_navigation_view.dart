import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import 'traffic/traffic_list_view.dart';
import 'vpn/vpn_dashboard_view.dart';

/// الشاشة الحاوية للتنقل السفلي بين المحلل الداخلي ومراقب شبكة الجهاز
class MainNavigationView extends StatelessWidget {
  const MainNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = NavigationController.to;

    final screens = const [
      TrafficListView(),
      VpnDashboardView(),
    ];

    return Scaffold(
      body: Obx(() => IndexedStack(
            index: navController.currentIndex.value,
            children: screens,
          )),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: navController.currentIndex.value,
          onDestinationSelected: (index) => navController.changeIndex(index),
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
      ),
    );
  }
}
