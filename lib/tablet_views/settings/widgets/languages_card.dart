


  // ==========================================
  // LANGUAGES CARD (Accordion)
  // ==========================================
  import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:traffic_tracker_app/constants/colors.dart';
import 'package:traffic_tracker_app/constants/icons.dart';
import 'package:traffic_tracker_app/constants/spacing.dart';
import 'package:traffic_tracker_app/controllers/settings_controller.dart';

Widget buildLanguagesCard(BuildContext context, SettingsController controller) {
    final theme = Theme.of(context);

    return Obx(() {
      final currentLocale = controller.currentLocale.value;
      final isArabic = currentLocale.languageCode == 'ar';

      return Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLg,
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: false,
            tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
            childrenPadding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
            leading: Icon(AppIcons.language, color: theme.colorScheme.primary),
            title: Text(
              controller.currentLanguageName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Text(
              'language_subtitle'.tr,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
            ),
            children: [
              _buildLanguageItem(
                context,
                title: 'العربية',
                subtitle: 'المملكة العربية السعودية (ar-SA)',
                isSelected: isArabic,
                onTap: () => controller.setLocale(const Locale('ar', 'SA')),
              ),
              AppSpacing.verticalSm,
              _buildLanguageItem(
                context,
                title: 'English',
                subtitle: 'United States (en-US)',
                isSelected: !isArabic,
                onTap: () => controller.setLocale(const Locale('en', 'US')),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLanguageItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusMd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : theme.colorScheme.surface,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
            width: isSelected ? 1.5 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? AppIcons.checkCircle : AppIcons.circle,
              color: isSelected ? theme.colorScheme.primary : AppColors.textMuted(context),
              size: 20,
            ),
            AppSpacing.horizontalMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
