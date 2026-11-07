import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/icons.dart';
import '../../../constants/spacing.dart';
import '../../../controllers/settings_controller.dart';

/// Modal bottom sheet allowing users to select the app theme (System, Light, Dark).
class ThemeSelectorSheet extends StatelessWidget {
  const ThemeSelectorSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ThemeSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = SettingsController.to;
    final screenHeight = MediaQuery.sizeOf(context).height;

    final themeOptions = [
      {
        'mode': ThemeMode.system,
        'title': 'theme_system'.tr,
        'icon': AppIcons.theme,
      },
      {
        'mode': ThemeMode.light,
        'title': 'theme_light'.tr,
        'icon': AppIcons.sun,
      },
      {
        'mode': ThemeMode.dark,
        'title': 'theme_dark'.tr,
        'icon': AppIcons.moon,
      },
    ];

    final isCompact = screenHeight < 500;
    final initialFraction = isCompact ? 0.85 : 0.50;
    final maxFraction = isCompact ? 0.95 : 0.70;
    final minFraction = isCompact ? 0.40 : 0.25;

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
              // Drag handle & Pinned Header
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.base,
                  right: AppSpacing.base,
                  top: AppSpacing.md,
                  bottom: AppSpacing.xs,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outlineVariant,
                          borderRadius: AppSpacing.borderRadiusRound,
                        ),
                      ),
                    ),
                    AppSpacing.verticalBase,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'select_theme'.tr,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(AppIcons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 0.5),
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
                      final icon = opt['icon'] as IconData;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Material(
                          color: isSelected
                              ? theme.colorScheme.primary.withValues(alpha: 0.08)
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderRadiusLg,
                            side: BorderSide(
                              color: isSelected
                                  ? theme.colorScheme.primary
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
                                color: (isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.surfaceContainerHighest)
                                    .withValues(alpha: 0.15),
                                borderRadius: AppSpacing.borderRadiusBase,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                icon,
                                size: AppSpacing.iconSm,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            title: Text(
                              opt['title'] as String,
                              style: TextStyle(
                                fontWeight:
                                    isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    AppIcons.checkCircle,
                                    color: theme.colorScheme.primary,
                                  )
                                : null,
                            onTap: () {
                              controller.setThemeMode(mode);
                              Navigator.of(context).pop();
                            },
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
