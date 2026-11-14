// ==========================================
// THEME MODE CARD (3 Horizontal Cards)
// ==========================================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:traffic_tracker_app/constants/colors.dart';
import 'package:traffic_tracker_app/constants/icons.dart';
import 'package:traffic_tracker_app/constants/spacing.dart';
import 'package:traffic_tracker_app/controllers/settings_controller.dart';

Widget buildThemeModeCard(BuildContext context, SettingsController controller) {
  final theme = Theme.of(context);

  return Obx(() {
    final currentMode = controller.themeMode.value;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(controller.themeModeIcon, color: theme.colorScheme.primary),
              AppSpacing.horizontalSm,
              Text(
                'theme_option'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          AppSpacing.verticalXxs,
          Text(
            'theme_subtitle'.tr,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
          ),
          AppSpacing.verticalMd,
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildThemeModeItem(
                    context,
                    title: 'theme_light'.tr,
                    desc: 'theme_light_desc'.tr,
                    icon: AppIcons.sun,
                    isSelected: currentMode == ThemeMode.light,
                    onTap: () => controller.setThemeMode(ThemeMode.light),
                  ),
                ),
                AppSpacing.horizontalMd,
                Expanded(
                  child: _buildThemeModeItem(
                    context,
                    title: 'theme_dark'.tr,
                    desc: 'theme_dark_desc'.tr,
                    icon: AppIcons.moon,
                    isSelected: currentMode == ThemeMode.dark,
                    onTap: () => controller.setThemeMode(ThemeMode.dark),
                  ),
                ),
                AppSpacing.horizontalMd,
                Expanded(
                  child: _buildThemeModeItem(
                    context,
                    title: 'theme_system'.tr,
                    desc: 'theme_system_desc'.tr,
                    icon: AppIcons.theme,
                    isSelected: currentMode == ThemeMode.system,
                    onTap: () => controller.setThemeMode(ThemeMode.system),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  });
}

Widget _buildThemeModeItem(
  BuildContext context, {
  required String title,
  required String desc,
  required IconData icon,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  final theme = Theme.of(context);

  return InkWell(
    onTap: onTap,
    borderRadius: AppSpacing.borderRadiusMd,
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.12)
            : theme.colorScheme.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
          width: isSelected ? 1.8 : 0.8,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 28,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          AppSpacing.verticalSm,
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isSelected ? theme.colorScheme.primary : null,
            ),
          ),
          AppSpacing.verticalXxs,
          Text(
            desc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              height: 1.35,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    ),
  );
}
