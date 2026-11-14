import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import '../../constants/icons.dart';
import '../../constants/spacing.dart';
import '../../controllers/settings_controller.dart';
import 'package:traffic_tracker_app/shared_views/settings/about_app_sheet.dart';
import 'package:traffic_tracker_app/shared_views/settings/language_selector_sheet.dart';
import 'package:traffic_tracker_app/shared_views/settings/palette_selector_sheet.dart';
import 'package:traffic_tracker_app/shared_views/settings/pcap_location_selector_sheet.dart';
import 'package:traffic_tracker_app/shared_views/settings/settings_section.dart';
import 'package:traffic_tracker_app/shared_views/settings/settings_tile.dart';
import 'package:traffic_tracker_app/shared_views/settings/theme_selector_sheet.dart';

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
                  value: settingsController.colorSchemeSummaryName,
                  onTap: () => PaletteSelectorSheet.show(context),
                ),
              ],
            ),

            AppSpacing.verticalXl,

            // ==========================================
            // APPLICATION PREFERENCES SECTION
            // ==========================================
            SettingsSection(
              title: 'app_preferences_section'.tr,
              children: [
                // Battery Optimization Setting (Doze / Unrestricted Background Inspection)
                SettingsTile(
                  icon: AppIcons.battery,
                  iconColor: theme.colorScheme.primary,
                  title: 'battery_optimization_option'.tr,
                  subtitle: 'battery_optimization_subtitle'.tr,
                  trailing: Obx(() {
                    final isIgnored =
                        settingsController.isIgnoringBatteryOptimizations.value;
                    return Icon(
                      isIgnored ? AppIcons.checkCircle : AppIcons.minusCircle,
                      color: isIgnored
                          ? AppColors.statusSuccess
                          : theme.colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                      size: AppSpacing.iconLg,
                    );
                  }),
                  onTap: () =>
                      settingsController.requestIgnoreBatteryOptimization(),
                ),

                // PCAP Capture Save Location
                SettingsTile(
                  icon: AppIcons.folderDownload,
                  iconColor: theme.colorScheme.primary,
                  title: 'pcap_location_option'.tr,
                  subtitle: 'pcap_location_subtitle'.tr,
                  value: settingsController.pcapLocationDisplayName,
                  onTap: () => PcapLocationSelectorSheet.show(context),
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
