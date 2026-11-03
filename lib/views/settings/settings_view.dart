import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import '../../constants/icons.dart';
import '../../constants/spacing.dart';
import '../../controllers/settings_controller.dart';
import 'widgets/about_app_sheet.dart';
import 'widgets/language_selector_sheet.dart';
import 'widgets/palette_selector_sheet.dart';
import 'widgets/settings_section.dart';
import 'widgets/settings_tile.dart';
import 'widgets/theme_selector_sheet.dart';

/// Settings screen allowing users to configure language, theme, and view application info.
/// Designed modularly with easily extendable sections and tiles.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsController = SettingsController.to;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'settings_title'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        // Reactive rebuild when locale or theme changes
        final currentLanguage = settingsController.currentLanguageName;
        final currentTheme = settingsController.themeModeName;
        final currentThemeIcon = settingsController.themeModeIcon;

        return ListView(
          padding: AppSpacing.paddingScreen,
          children: [
            // ==========================================
            // GENERAL PREFERENCES SECTION
            // ==========================================
            SettingsSection(
              title: 'general_section'.tr,
              children: [
                // Language Setting
                SettingsTile(
                  icon: AppIcons.language,
                  iconColor: theme.colorScheme.primary,
                  title: 'language_option'.tr,
                  subtitle: 'language_subtitle'.tr,
                  value: currentLanguage,
                  onTap: () => LanguageSelectorSheet.show(context),
                ),

                // Theme Setting
                SettingsTile(
                  icon: currentThemeIcon,
                  iconColor: theme.colorScheme.primary,
                  title: 'theme_option'.tr,
                  subtitle: 'theme_subtitle'.tr,
                  value: currentTheme,
                  onTap: () => ThemeSelectorSheet.show(context),
                ),

                // Color Scheme (Material You / Dynamic Colors & Static Palettes)
                SettingsTile(
                  icon: AppIcons.palette,
                  iconColor: theme.colorScheme.primary,
                  title: 'color_scheme_option'.tr,
                  subtitle: 'color_scheme_subtitle'.tr,
                  //value: settingsController.colorSchemeSummaryName,
                  onTap: () => PaletteSelectorSheet.show(context),
                ),
              ],
            ),

            AppSpacing.verticalXl,

            // ==========================================
            // APPLICATION INFO SECTION
            // ==========================================
            SettingsSection(
              title: 'about_section'.tr,
              children: [
                // About App
                SettingsTile(
                  icon: AppIcons.info,
                  iconColor: theme.colorScheme.primary,
                  title: 'about_option'.tr,
                  subtitle: 'about_subtitle'.tr,
                  onTap: () => AboutAppSheet.show(context),
                ),
              ],
            ),

            AppSpacing.verticalXxl,

            // Subtle Footer
            Center(
              child: Text(
                '${'app_title'.tr} • ${'app_version'.tr}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted(context),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
