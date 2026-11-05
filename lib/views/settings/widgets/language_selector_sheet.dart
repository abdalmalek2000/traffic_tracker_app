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

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: const BorderRadius.vertical(
        top: AppSpacing.radiusCircularXxl,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.lg,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
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
              // Header
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
              AppSpacing.verticalSm,
              Obx(() {
                final activeLocale = controller.currentLocale.value;
                return Column(
                  children: languages.map((lang) {
                    final locale = lang['locale'] as Locale;
                    final isSelected = activeLocale.languageCode == locale.languageCode;

                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.08)
                            : Colors.transparent,
                        borderRadius: AppSpacing.borderRadiusLg,
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: AppSpacing.borderRadiusLg,
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderRadiusLg,
                          ),
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
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
            ],
          ),
        ),
      ),
    );
  }
}
