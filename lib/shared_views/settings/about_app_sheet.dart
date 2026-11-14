import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/icons.dart';
import '../../../constants/spacing.dart';
import 'package:traffic_tracker_app/shared_views/widgets/app_bottom_sheet.dart';
import 'package:traffic_tracker_app/shared_views/widgets/app_buttons.dart';

/// Modal bottom sheet showcasing information about Traffic Tracker,
/// application version, core features, and architectural notes.
class AboutAppSheet extends StatelessWidget {
  const AboutAppSheet({super.key});

  static void show(BuildContext context) {
    AppBottomSheet.show(context: context, child: const AboutAppSheet());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.sizeOf(context).height;

    final List<String> features = <String>[
      'feature_in_app_inspection'.tr,
      'feature_vpn_capture'.tr,
      'feature_app_filtering'.tr,
      'feature_pcap_export'.tr,
    ];

    final isCompact = screenHeight < 500;
    final initialFraction = isCompact ? 0.92 : 0.75;
    final maxFraction = 0.95;
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
              AppBottomSheetHeader(title: 'about_app_title'.tr),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // App Identity Header
                      Center(
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: AppSpacing.borderRadiusLg,
                              child: Image.asset(
                                'assets/images/app_logo.png',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            AppSpacing.verticalSm,
                            Text(
                              'app_name'.tr,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            AppSpacing.verticalXxs,
                            Text(
                              'app_version'.tr,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.verticalBase,

                      // Mission Statement
                      Text(
                        'about_app_desc'.tr,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                        ),
                      ),
                      AppSpacing.verticalBase,

                      // Highlights Section
                      Text(
                        'core_capabilities'.tr,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.verticalSm,

                      Container(
                        padding: const EdgeInsets.all(AppSpacing.base),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                        child: Column(
                          children: features.map((feature) {
                            final isLast = feature == features.last;
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: isLast ? 0 : AppSpacing.sm,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Icon(
                                      AppIcons.circle,
                                      size: AppSpacing.iconXs,
                                      color: theme.colorScheme.primary,
                                    ),
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
                            );
                          }).toList(),
                        ),
                      ),
                      AppSpacing.verticalBase,

                      // Close secondary button
                      AppSecondaryButton(
                        text: 'close'.tr,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
