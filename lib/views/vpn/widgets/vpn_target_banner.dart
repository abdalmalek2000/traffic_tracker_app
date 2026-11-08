import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../constants/icons.dart';
import '../../../constants/spacing.dart';
import '../app_filter_view.dart';

/// Banner shown when target apps filter is active in VPN monitoring.
class VpnTargetBanner extends StatelessWidget {
  final int selectedCount;

  const VpnTargetBanner({
    super.key,
    required this.selectedCount,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedCount <= 0) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space14,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.statusSuccess.withValues(alpha: 0.12),
        borderRadius: AppSpacing.borderRadiusBase,
        border: Border.all(
          color: AppColors.statusSuccess.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            AppIcons.filterActive,
            size: AppSpacing.iconSm,
            color: AppColors.statusSuccess,
          ),
          AppSpacing.horizontalSm,
          Expanded(
            child: Text(
              'target_mode_active_banner'.trParams({'count': '$selectedCount'}),
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: AppColors.statusSuccess,
              ),
            ),
          ),
          InkWell(
            onTap: () => Get.to(() => const AppFilterView()),
            child: Text(
              'edit'.tr,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
