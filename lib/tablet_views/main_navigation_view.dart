import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/colors.dart';
import '../constants/icons.dart';
import '../constants/spacing.dart';
import '../controllers/navigation_controller.dart';
import 'settings/settings_view.dart';
import 'traffic/traffic_list_view.dart';
import 'vpn/vpn_dashboard_view.dart';

/// Tablet Main Navigation View with responsive NavigationRail.
class TabletMainNavigationView extends StatelessWidget {
  const TabletMainNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = NavigationController.to;
    final theme = Theme.of(context);

    final screens = const [
      TabletVpnDashboardView(),
      TabletTrafficListView(),
      TabletSettingsView(),
    ];

    return Scaffold(
      body: Row(
        children: [
          Obx(() {
            final selectedIndex = navController.currentIndex.value;
            // NavigationRail native items handle index 0 and 1
            final railSelectedIndex = selectedIndex <= 1 ? selectedIndex : null;
            final isSettingsSelected = selectedIndex == 2;

            return NavigationRail(
              selectedIndex: railSelectedIndex,
              onDestinationSelected: navController.changeIndex,
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: ClipRRect(
                  borderRadius: AppSpacing.borderRadiusSm,
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    width: AppSpacing.appLogoSize,
                    height: AppSpacing.appLogoSize,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.base),
                    child: InkWell(
                      borderRadius: AppSpacing.borderRadiusLg,
                      onTap: () => navController.changeIndex(2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isSettingsSelected
                              ? theme.colorScheme.primary.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: AppSpacing.borderRadiusLg,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              AppIcons.settings,
                              color: isSettingsSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            AppSpacing.verticalXxs,
                            Text(
                              'settings_title'.tr,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSettingsSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSettingsSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              backgroundColor: theme.colorScheme.surface,
              indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.15),
              selectedIconTheme: IconThemeData(
                color: theme.colorScheme.primary,
              ),
              unselectedIconTheme: IconThemeData(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              selectedLabelTextStyle: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(AppIcons.vpnSecurity),
                  selectedIcon: Icon(
                    AppIcons.vpnSecurity,
                    color: AppColors.protocolTcp,
                  ),
                  label: Text('tab_system_vpn'.tr),
                ),
                NavigationRailDestination(
                  icon: const Icon(AppIcons.http),
                  selectedIcon: Icon(
                    AppIcons.http,
                    color: AppColors.protocolHttp,
                  ),
                  label: Text('tab_api_inspector'.tr),
                ),
              ],
            );
          }),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Obx(
              () => IndexedStack(
                index: navController.currentIndex.value.clamp(0, screens.length - 1),
                children: screens,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
