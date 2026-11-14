import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/colors.dart';
import '../constants/icons.dart';
import '../controllers/navigation_controller.dart';
import 'traffic/traffic_list_view.dart';
import 'vpn/vpn_dashboard_view.dart';
import 'package:traffic_tracker_app/shared_views/widgets/app_nav_bar.dart';

/// Main navigation view hosting the bottom navigation bar.
class MainNavigationView extends StatelessWidget {
  const MainNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = NavigationController.to;
    const screens = [VpnDashboardView(), TrafficListView()];

    final navItems = [
      AppNavBarItem(
        icon: AppIcons.vpnSecurity,
        selectedColor: AppColors.protocolTcp,
        label: 'tab_system_vpn'.tr,
      ),
      AppNavBarItem(
        icon: AppIcons.http,
        selectedColor: AppColors.protocolHttp,
        label: 'tab_api_inspector'.tr,
      ),
    ];

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: navController.currentIndex.value,
          children: screens,
        ),
      ),
      bottomNavigationBar: Obx(
        () => AppNavBar(
          selectedIndex: navController.currentIndex.value,
          onDestinationSelected: navController.changeIndex,
          items: navItems,
        ),
      ),
    );
  }
}
