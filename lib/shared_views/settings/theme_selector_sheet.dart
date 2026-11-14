import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/icons.dart';
import '../../../constants/spacing.dart';
import '../../../controllers/settings_controller.dart';
import 'package:traffic_tracker_app/shared_views/widgets/app_bottom_sheet.dart';

/// Modal bottom sheet allowing users to select the app brightness mode.
class ThemeSelectorSheet extends StatelessWidget {
  const ThemeSelectorSheet({super.key});

  static void show(BuildContext context) {
    AppBottomSheet.show(context: context, child: const ThemeSelectorSheet());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = SettingsController.to;
    final screenHeight = MediaQuery.sizeOf(context).height;

    final themeOptions = [
      {
        'title': 'theme_system'.tr,
        'subtitle': 'theme_system_desc'.tr,
        'icon': AppIcons.theme,
        'mode': ThemeMode.system,
      },
      {
        'title': 'theme_light'.tr,
        'subtitle': 'theme_light_desc'.tr,
        'icon': AppIcons.sun,
        'mode': ThemeMode.light,
      },
      {
        'title': 'theme_dark'.tr,
        'subtitle': 'theme_dark_desc'.tr,
        'icon': AppIcons.moon,
        'mode': ThemeMode.dark,
      },
    ];

    final isCompact = screenHeight < 500;
    final initialFraction = isCompact ? 0.90 : 0.52;
    final maxFraction = isCompact ? 0.95 : 0.70;
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
              AppBottomSheetHeader(title: 'select_theme'.tr),
              // Scrollable Options List
              Expanded(
                child: Obx(() {
                  final activeMode = controller.themeMode.value;
                  return ListView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.base),
                    children: themeOptions.map((opt) {
                      final mode = opt['mode'] as ThemeMode;
                      final isSelected = activeMode == mode;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Material(
                          color: isSelected
                              ? theme.colorScheme.primary.withValues(
                                  alpha: 0.08,
                                )
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderRadiusLg,
                            side: BorderSide(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant.withValues(
                                      alpha: 0.3,
                                    ),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: AppSpacing.borderRadiusBase,
                            onTap: () {
                              controller.setThemeMode(mode);
                              Navigator.of(context).pop();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.base,
                                vertical: AppSpacing.md,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    opt['icon'] as IconData,
                                    size: AppSpacing.iconMd,
                                    color: isSelected
                                        ? theme.colorScheme.onPrimaryContainer
                                        : theme.colorScheme.primary,
                                  ),
                                  AppSpacing.horizontalBase,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          opt['title'] as String,
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                                color: isSelected
                                                    ? theme.colorScheme.primary
                                                    : theme
                                                          .colorScheme
                                                          .onSurface,
                                              ),
                                        ),
                                        AppSpacing.verticalXxs,
                                        Text(
                                          opt['subtitle'] as String,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: isSelected
                                                    ? theme
                                                          .colorScheme
                                                          .onPrimaryContainer
                                                          .withValues(
                                                            alpha: 0.8,
                                                          )
                                                    : theme
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      AppIcons.checkCircle,
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                      size: AppSpacing.iconMd,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
