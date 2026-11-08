import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/icons.dart';
import '../../../constants/spacing.dart';
import '../../../controllers/settings_controller.dart';
import '../../widgets/app_bottom_sheet.dart';

/// Modal bottom sheet allowing users to select the app display language.
class LanguageSelectorSheet extends StatelessWidget {
  const LanguageSelectorSheet({super.key});

  static void show(BuildContext context) {
    AppBottomSheet.show(context: context, child: const LanguageSelectorSheet());
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
              AppBottomSheetHeader(title: 'select_language'.tr),
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
                              controller.setLocale(locale);
                              Navigator.of(context).pop();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.base,
                                vertical: AppSpacing.md,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lang['title'] as String,
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
                                          lang['subtitle'] as String,
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
