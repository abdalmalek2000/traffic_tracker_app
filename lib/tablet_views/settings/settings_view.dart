import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:traffic_tracker_app/tablet_views/settings/widgets/about_dialog_card.dart';
import 'package:traffic_tracker_app/tablet_views/settings/widgets/app_pref_card.dart';
import 'package:traffic_tracker_app/tablet_views/settings/widgets/languages_card.dart';
import 'package:traffic_tracker_app/tablet_views/settings/widgets/theme_mode_card.dart';
import 'package:traffic_tracker_app/tablet_views/settings/widgets/theme_scheme_card.dart';
import '../../constants/colors.dart';
import '../../constants/icons.dart';
import '../../constants/spacing.dart';
import '../../controllers/settings_controller.dart';

/// Redesigned Settings screen for Tablet matching the custom wireframe design.
class TabletSettingsView extends StatelessWidget {
  const TabletSettingsView({super.key});

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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            children: [
              // ==========================================
              // 1. LANGUAGES SECTION (Wireframe Accordion)
              // ==========================================
              _buildSectionHeader(
                context,
                'language_option'.tr,
                icon: AppIcons.language,
              ),
              AppSpacing.verticalSm,
              buildLanguagesCard(context, settingsController),

              AppSpacing.verticalXl,

              // ==========================================
              // 2. THEME MODE SECTION (Wireframe 3 Cards)
              // ==========================================
              _buildSectionHeader(
                context,
                'theme_option'.tr,
                icon: AppIcons.theme,
              ),
              AppSpacing.verticalSm,
              buildThemeModeCard(context, settingsController),

              AppSpacing.verticalXl,

              // ==========================================
              // 3. THEME SCHEME SECTION (Dynamic + Presets)
              // ==========================================
              _buildSectionHeader(
                context,
                'color_scheme_option'.tr,
                icon: AppIcons.palette,
              ),
              AppSpacing.verticalSm,
              buildThemeSchemeCard(context, settingsController),

              AppSpacing.verticalXl,

              // ==========================================
              // 4. APPLICATION PREFERENCES SECTION
              // ==========================================
              _buildSectionHeader(
                context,
                'app_preferences_section'.tr,
                icon: AppIcons.settings,
              ),
              AppSpacing.verticalSm,
              buildAppPreferencesCard(context, settingsController),

              AppSpacing.verticalXl,

              // ==========================================
              // 5. ABOUT APPLICATION SECTION (Dialog launcher)
              // ==========================================
              _buildSectionHeader(
                context,
                'about_section'.tr,
                icon: AppIcons.info,
              ),
              AppSpacing.verticalSm,
              buildAboutCard(context),

              AppSpacing.verticalXxl,

              // Footer
              Center(
                child: Text(
                  '${'app_title'.tr} • ${'app_version'.tr}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted(context),
                  ),
                ),
              ),
              AppSpacing.verticalBase,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          AppSpacing.horizontalSm,
        ],
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
