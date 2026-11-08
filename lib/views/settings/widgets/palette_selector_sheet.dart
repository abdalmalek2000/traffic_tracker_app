import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_palettes.dart';
import '../../../constants/icons.dart';
import '../../../constants/spacing.dart';
import '../../../controllers/settings_controller.dart';
import '../../widgets/app_bottom_sheet.dart';

/// Modal bottom sheet allowing users to select between Android Material You
/// dynamic wallpaper-derived colors and various rich static palettes.
class PaletteSelectorSheet extends StatelessWidget {
  const PaletteSelectorSheet({super.key});

  static void show(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      child: const PaletteSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = SettingsController.to;
    final screenHeight = MediaQuery.sizeOf(context).height;

    final isCompact = screenHeight < 500;
    final initialFraction = isCompact ? 0.92 : 0.72;
    final maxFraction = 0.95;
    final minFraction = isCompact ? 0.40 : 0.30;

    return DraggableScrollableSheet(
      initialChildSize: initialFraction,
      minChildSize: minFraction,
      maxChildSize: maxFraction,
      expand: false,
      builder: (context, scrollController) {
        return Material(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: AppSpacing.radiusCircularXxl,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBottomSheetHeader(
                title: 'select_color_scheme'.tr,
              ),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Material You dynamic option
                      Obx(() {
                        final isDynamicSelected = controller.useDynamicColor.value;

                        return Material(
                          color: isDynamicSelected
                              ? theme.colorScheme.primary.withValues(alpha: 0.08)
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderRadiusLg,
                            side: BorderSide(
                              color: isDynamicSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant
                                      .withValues(alpha: 0.3),
                              width: isDynamicSelected ? 1.5 : 1.0,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            leading: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4285F4),
                                    Color(0xFFEA4335),
                                    Color(0xFFFBBC05),
                                    Color(0xFF34A853),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: AppSpacing.borderRadiusBase,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                AppIcons.palette,
                                size: AppSpacing.iconSm,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              'color_dynamic_system'.tr,
                              style: TextStyle(
                                fontWeight: isDynamicSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: isDynamicSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              'color_dynamic_system_desc'.tr,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            trailing: isDynamicSelected
                                ? Icon(
                                    AppIcons.checkCircle,
                                    color: theme.colorScheme.primary,
                                  )
                                : null,
                            onTap: () {
                              controller.setUseDynamicColor(true);
                              Navigator.of(context).pop();
                            },
                          ),
                        );
                      }),
                      AppSpacing.verticalBase,

                      // Static color heading
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                        child: Text(
                          'static_colors_heading'.tr,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      AppSpacing.verticalSm,

                      // Palettes List
                      Obx(() {
                        final isDynamicSelected = controller.useDynamicColor.value;
                        final currentPaletteId = controller.selectedPaletteId.value;

                        return Column(
                          children: AppPalettes.all.map((palette) {
                            final isSelected = !isDynamicSelected &&
                                currentPaletteId == palette.id;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: Material(
                                color: isSelected
                                    ? palette.primaryColor.withValues(alpha: 0.08)
                                    : Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppSpacing.borderRadiusLg,
                                  side: BorderSide(
                                    color: isSelected
                                        ? palette.primaryColor
                                        : theme.colorScheme.outlineVariant
                                            .withValues(alpha: 0.3),
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: ListTile(
                                  leading: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: palette.primaryColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: palette.primaryColor
                                              .withValues(alpha: 0.35),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  title: Text(
                                    palette.localizedName,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? palette.primaryColor
                                          : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? Icon(
                                          AppIcons.checkCircle,
                                          color: palette.primaryColor,
                                        )
                                      : null,
                                  onTap: () {
                                    controller.setPalette(palette.id);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
