import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/icons.dart';
import '../../../constants/spacing.dart';
import 'package:traffic_tracker_app/shared_views/widgets/app_buttons.dart';
import '../../widgets/tablet_dialog.dart';

/// Modal center dialog showcasing application details, version, and core architecture on Tablet.
class TabletAboutAppDialog extends StatelessWidget {
  const TabletAboutAppDialog({super.key});

  static void show(BuildContext context) {
    TabletDialog.show(
      context: context,
      title: 'about_app_title'.tr,
      maxWidth: 520,
      maxHeight: 600,
      child: const TabletAboutAppDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<String> features = <String>[
      'feature_in_app_inspection'.tr,
      'feature_vpn_capture'.tr,
      'feature_app_filtering'.tr,
      'feature_pcap_export'.tr,
    ];

    return SingleChildScrollView(
      padding: AppSpacing.paddingAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // App Logo & Identity
          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: AppSpacing.borderRadiusMd,
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
                AppSpacing.verticalMd,
                Text(
                  'app_title'.tr,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.verticalXxs,
                Text(
                  'app_version'.tr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.verticalLg,

          // Description Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Text(
              'about_app_desc'.tr,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ),
          AppSpacing.verticalLg,

          // Features List
          Text(
            'core_features_title'.tr,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.verticalSm,
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  Icon(
                    AppIcons.checkCircle,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  AppSpacing.horizontalSm,
                  Expanded(
                    child: Text(
                      feature,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.verticalXl,

          // Close button
          AppSecondaryButton(
            text: 'close'.tr,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
