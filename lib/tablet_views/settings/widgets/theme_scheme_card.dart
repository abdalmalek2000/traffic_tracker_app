// ==========================================
// THEME SCHEME CARD (Material You + Palettes)
// ==========================================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:traffic_tracker_app/constants/app_palettes.dart';
import 'package:traffic_tracker_app/constants/colors.dart';
import 'package:traffic_tracker_app/constants/icons.dart';
import 'package:traffic_tracker_app/constants/spacing.dart';
import 'package:traffic_tracker_app/controllers/settings_controller.dart';

Widget buildThemeSchemeCard(BuildContext context, SettingsController controller) {
  final theme = Theme.of(context);

  return Obx(() {
    final isDynamic = controller.useDynamicColor.value;
    final selectedPaletteId = controller.selectedPaletteId.value;

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
              Icon(AppIcons.palette, color: theme.colorScheme.primary),
              AppSpacing.horizontalSm,
              Text(
                'color_scheme_option'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          AppSpacing.verticalXxs,
          Text(
            'color_scheme_subtitle'.tr,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
          ),
          AppSpacing.verticalMd,
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Side: Material You Card
                Expanded(
                  flex: 4,
                  child: InkWell(
                    onTap: () => controller.setUseDynamicColor(!isDynamic),
                    borderRadius: AppSpacing.borderRadiusMd,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isDynamic
                            ? theme.colorScheme.primary.withValues(alpha: 0.12)
                            : theme.colorScheme.surface,
                        borderRadius: AppSpacing.borderRadiusMd,
                        border: Border.all(
                          color: isDynamic
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
                          width: isDynamic ? 1.8 : 0.8,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Icon(
                                AppIcons.palette,
                                size: 22,
                                color: isDynamic
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              AppSpacing.horizontalSm,
                              Expanded(
                                child: Text(
                                  'material_you_title'.tr,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isDynamic
                                        ? theme.colorScheme.primary
                                        : null,
                                  ),
                                ),
                              ),
                              if (isDynamic)
                                Icon(
                                  AppIcons.checkCircle,
                                  size: 18,
                                  color: theme.colorScheme.primary,
                                ),
                            ],
                          ),
                          AppSpacing.verticalSm,
                          Text(
                            'material_you_desc'.tr,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary(context),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                AppSpacing.horizontalLg,

                // Right Side: Color Circles with Underline Indicator
                Expanded(
                  flex: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Text(
                            'static_palettes_title'.tr,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDynamic
                                  ? AppColors.textMuted(context)
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 16,
                          runSpacing: 14,
                          children: AppPalettes.all.map((palette) {
                            final isSelected =
                                !isDynamic && selectedPaletteId == palette.id;

                            return InkWell(
                              onTap: () {
                                controller.setPalette(palette.id);
                              },
                              borderRadius: BorderRadius.circular(24),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 2,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: palette.seedColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.8),
                                          width: isSelected ? 3 : 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: palette.seedColor.withValues(alpha: 0.4),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: isSelected
                                          ? const Center(
                                              child: Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 22,
                                              ),
                                            )
                                          : null,
                                    ),
                                    AppSpacing.verticalXxs,
                                    Container(
                                      width: 28,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? palette.seedColor
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
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
