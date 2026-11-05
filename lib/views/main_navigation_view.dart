import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/colors.dart';
import '../constants/icons.dart';
import '../controllers/navigation_controller.dart';
import 'traffic/traffic_list_view.dart';
import 'vpn/vpn_dashboard_view.dart';

/// Main navigation view hosting the bottom navigation bar.
class MainNavigationView extends StatelessWidget {
  const MainNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = NavigationController.to;

    final screens = const [VpnDashboardView(), TrafficListView()];

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: navController.currentIndex.value,
          children: screens,
        ),
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 60,
          selectedIndex: navController.currentIndex.value,
          onDestinationSelected: (index) => navController.changeIndex(index),
          destinations: [
            NavigationDestination(
              icon: const Icon(AppIcons.vpnSecurity),
              selectedIcon: const Icon(
                AppIcons.vpnSecurity,
                color: AppColors.protocolTcp,
              ),
              label: 'tab_system_vpn'.tr,
            ),
            NavigationDestination(
              icon: const Icon(AppIcons.http),
              selectedIcon: const Icon(
                AppIcons.http,
                color: AppColors.protocolHttp,
              ),
              label: 'tab_api_inspector'.tr,
            ),
          ],
        ),
      ),
    );
  }
}
