import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/icons.dart';
import '../../../constants/spacing.dart';

/// Modal bottom sheet showcasing information about Traffic Tracker,
/// application version, core features, and architectural notes.
class AboutAppSheet extends StatelessWidget {
  const AboutAppSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AboutAppSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.sizeOf(context).height;

    final features = [
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
                            'about_app_title'.tr,
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
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // App Logo & Name Card
                      Container(
                        padding: AppSpacing.paddingCard,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.35),
                          borderRadius: AppSpacing.borderRadiusLg,
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: AppSpacing.borderRadiusMd,
                              child: Image.asset(
                                'assets/images/app_logo.png',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            AppSpacing.verticalSm,
                            Text(
                              'app_title'.tr,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            AppSpacing.verticalXxs,
                            Container(
                              padding: AppSpacing.paddingBadge,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.12),
                                borderRadius: AppSpacing.borderRadiusRound,
                              ),
                              child: Text(
                                'app_version'.tr,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            AppSpacing.verticalSm,
                            Text(
                              'app_description'.tr,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.verticalBase,

                      // Features Header
                      Text(
                        'features_heading'.tr,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.verticalSm,

                      // Feature list
                      ...features.map(
                        (feature) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Icon(
                                  AppIcons.checkCircle,
                                  size: AppSpacing.iconSm,
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
                        ),
                      ),
                      AppSpacing.verticalBase,

                      // Close button
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: FilledButton.styleFrom(
                          minimumSize:
                              const Size.fromHeight(AppSpacing.buttonHeight),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderRadiusBase,
                          ),
                        ),
                        child: Text('close'.tr),
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
