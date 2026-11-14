import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../constants/icons.dart';
import '../../../constants/spacing.dart';
import '../../../controllers/vpn_controller.dart';
import 'package:traffic_tracker_app/shared_views/widgets/app_buttons.dart';
import 'build_metric.dart';

/// Status and metrics card at the top of the VPN Dashboard.
class VpnStatusCard extends StatelessWidget {
  final VpnController controller;
  final VoidCallback? onOpenAppFilter;

  const VpnStatusCard({
    super.key,
    required this.controller,
    this.onOpenAppFilter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final isRunning = controller.isVpnRunning.value;
      final selectedCount = controller.selectedPackages.length;
      final filteredList = controller.filteredConnections;

      return Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.base,
          AppSpacing.md,
          AppSpacing.base,
          AppSpacing.sm,
        ),
        padding: AppSpacing.paddingCard,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: AppSpacing.borderRadiusXl,
          border: Border.all(
            color: isRunning
                ? AppColors.statusSuccess.withValues(alpha: 0.6)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: isRunning ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            // Status and Target Apps Row
            Row(
              children: [
                Container(
                  width: AppSpacing.md,
                  height: AppSpacing.md,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isRunning
                        ? AppColors.statusSuccess
                        : AppColors.textMuted(context),
                  ),
                ),
                AppSpacing.horizontalSm,
                Expanded(
                  child: Text(
                    isRunning ? 'vpn_active'.tr : 'vpn_stopped'.tr,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isRunning
                          ? AppColors.statusSuccess
                          : AppColors.textSecondary(context),
                    ),
                  ),
                ),
                AppSpacing.horizontalSm,
                // Target Apps Pill button
                Flexible(
                  child: InkWell(
                    onTap: onOpenAppFilter,
                    borderRadius: AppSpacing.borderRadiusXxl,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space10,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: AppSpacing.borderRadiusXxl,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.apps,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          AppSpacing.horizontalXs,
                          Flexible(
                            child: Text(
                              selectedCount == 0
                                  ? 'all_apps'.tr
                                  : 'target_apps_selected'.trParams({
                                      'count': '$selectedCount',
                                    }),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.vertical14,

            // Metrics Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: BuildMetric(
                    title: 'packets_captured'.tr,
                    value: '${controller.totalPackets.value}',
                    icon: AppIcons.layers,
                  ),
                ),
                Expanded(
                  child: BuildMetric(
                    title: 'data_volume'.tr,
                    value: controller.formattedTotalBytes,
                    icon: AppIcons.dataUsage,
                  ),
                ),
                Expanded(
                  child: BuildMetric(
                    title: 'live_connections'.tr,
                    value: '${filteredList.length}',
                    icon: AppIcons.connections,
                  ),
                ),
              ],
            ),
            AppSpacing.vertical14,

            // Big Unified Primary Toggle Button
            AppPrimaryButton(
              text: isRunning ? 'stop_inspection'.tr : 'start_inspection'.tr,
              icon: isRunning ? AppIcons.stop : AppIcons.play,
              backgroundColor: isRunning
                  ? AppColors.statusServerError
                  : theme.colorScheme.primary,
              foregroundColor: isRunning ? Colors.white : theme.colorScheme.onPrimary,
              onPressed: () => controller.toggleVpn(),
            ),
          ],
        ),
      );
    });
  }
}
