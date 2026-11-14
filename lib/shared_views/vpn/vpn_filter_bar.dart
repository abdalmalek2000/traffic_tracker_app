import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../constants/icons.dart';
import '../../../constants/spacing.dart';
import '../../../controllers/vpn_controller.dart';
import 'package:traffic_tracker_app/shared_views/widgets/app_filter_chip.dart';

/// Horizontal filter chips bar for traffic classification in VPN Dashboard.
class VpnFilterBar extends StatelessWidget {
  final VpnController controller;

  const VpnFilterBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.activeTrafficFilter.value;
      final selectedCount = controller.selectedPackages.length;
      final targetOnly = controller.filterBySelectedAppsOnly.value;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            AppSpacing.horizontalBase,
            AppFilterChip(
              label: 'filter_traffic_all'.tr,
              isSelected: active == VpnTrafficFilter.all,
              onSelected: () => controller.setTrafficFilter(VpnTrafficFilter.all),
            ),
            AppSpacing.horizontalXs,
            AppFilterChip(
              label: 'filter_traffic_apps_only'.tr,
              icon: AppIcons.device,
              isSelected: active == VpnTrafficFilter.appsOnly,
              onSelected: () => controller.setTrafficFilter(VpnTrafficFilter.appsOnly),
            ),
            AppSpacing.horizontalXs,
            AppFilterChip(
              label: 'filter_traffic_system'.tr,
              icon: AppIcons.settings,
              isSelected: active == VpnTrafficFilter.systemOnly,
              onSelected: () => controller.setTrafficFilter(VpnTrafficFilter.systemOnly),
            ),
            if (selectedCount > 0) ...[
              AppSpacing.horizontalXs,
              AppFilterChip(
                label: 'mode_target_only'.tr,
                isSelected: targetOnly,
                color: AppColors.statusSuccess,
                onSelected: () => controller.setFilterBySelectedAppsOnly(!targetOnly),
              ),
            ],
            AppSpacing.horizontalBase,
          ],
        ),
      );
    });
  }
}
