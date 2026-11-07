import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/icons.dart';
import '../../../constants/spacing.dart';
import '../../../controllers/settings_controller.dart';

/// Modal bottom sheet allowing users to select the app display language.
class LanguageSelectorSheet extends StatelessWidget {
  const LanguageSelectorSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LanguageSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = SettingsController.to;
    final screenHeight = MediaQuery.sizeOf(context).height;

    final languages = [
      {
        'title': 'العربية',
        'subtitle': 'Arabic (Saudi Arabia)',
        'locale': const Locale('ar', 'SA'),
        'code': 'ar',
      },
      {
        'title': 'English',
        'subtitle': 'English (United States)',
        'locale': const Locale('en', 'US'),
        'code': 'en',
      },
    ];

    final isCompact = screenHeight < 500;
    final initialFraction = isCompact ? 0.85 : 0.45;
    final maxFraction = isCompact ? 0.95 : 0.65;
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
                            'select_language'.tr,
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
                  final activeLocale = controller.currentLocale.value;
                  return ListView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.base),
                    children: languages.map((lang) {
                      final locale = lang['locale'] as Locale;
                      final isSelected =
                          activeLocale.languageCode == locale.languageCode;

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
                                AppIcons.language,
                                size: AppSpacing.iconSm,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            title: Text(
                              lang['title'] as String,
                              style: TextStyle(
                                fontWeight:
                                    isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              lang['subtitle'] as String,
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: isSelected
                                ? Icon(
                                    AppIcons.checkCircle,
                                    color: theme.colorScheme.primary,
                                  )
                                : null,
                            onTap: () {
                              controller.setLocale(locale);
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
