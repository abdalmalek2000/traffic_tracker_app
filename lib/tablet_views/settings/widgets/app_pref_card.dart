
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:traffic_tracker_app/constants/colors.dart';
import 'package:traffic_tracker_app/constants/icons.dart';
import 'package:traffic_tracker_app/constants/spacing.dart';
import 'package:traffic_tracker_app/controllers/settings_controller.dart';


  // ==========================================
  // APPLICATION PREFERENCES (Battery + PCAP Accordion)
  // ==========================================
Widget buildAppPreferencesCard(BuildContext context, SettingsController controller) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // 1. Battery Optimization (Exactly preserved original design & functionality)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
            leading: Icon(AppIcons.battery, color: theme.colorScheme.primary),
            title: Text(
              'battery_optimization_option'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
            ),
            subtitle: Text(
              'battery_optimization_subtitle'.tr,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
            ),
            trailing: Obx(() {
              final isIgnored = controller.isIgnoringBatteryOptimizations.value;
              return Icon(
                isIgnored ? AppIcons.checkCircle : AppIcons.minusCircle,
                color: isIgnored
                    ? AppColors.statusSuccess
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                size: AppSpacing.iconLg,
              );
            }),
            onTap: () => controller.requestIgnoreBatteryOptimization(),
          ),

          Divider(height: 1, thickness: 0.5, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),

          // 2. PCAP Storage Location (Expandable Accordion just like Language)
          Obx(() {
            final activeType = controller.pcapLocationType.value;

            final locationOptions = [
              {
                'id': 'downloads',
                'title': 'pcap_dir_downloads'.tr,
                'subtitle': 'pcap_dir_downloads_desc'.tr,
                'icon': AppIcons.folderDownload,
              },
              {
                'id': 'documents',
                'title': 'pcap_dir_documents'.tr,
                'subtitle': 'pcap_dir_documents_desc'.tr,
                'icon': AppIcons.folder,
              },
              {
                'id': 'app_storage',
                'title': 'pcap_dir_app_storage'.tr,
                'subtitle': 'pcap_dir_app_storage_desc'.tr,
                'icon': AppIcons.device,
              },
            ];

            return Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: false,
                tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                childrenPadding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                leading: Icon(AppIcons.folderDownload, color: theme.colorScheme.primary),
                title: Text(
                  'pcap_location_option'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                ),
                subtitle: Text(
                  controller.pcapLocationDisplayName,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
                ),
                children: [
                  ...locationOptions.map((opt) {
                    final id = opt['id'] as String;
                    final isSelected = activeType == id;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: InkWell(
                        onTap: () => controller.setPcapLocationType(id),
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
                                      opt['title'] as String,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.5,
                                        color: isSelected ? theme.colorScheme.primary : null,
                                      ),
                                    ),
                                    Text(
                                      opt['subtitle'] as String,
                                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary(context)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  // Custom Folder picker button
                  InkWell(
                    onTap: () => controller.pickCustomPcapDirectory(),
                    borderRadius: AppSpacing.borderRadiusMd,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: activeType == 'custom'
                            ? theme.colorScheme.primary.withValues(alpha: 0.12)
                            : theme.colorScheme.surface,
                        borderRadius: AppSpacing.borderRadiusMd,
                        border: Border.all(
                          color: activeType == 'custom'
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
                          width: activeType == 'custom' ? 1.5 : 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            activeType == 'custom' ? AppIcons.checkCircle : AppIcons.folder,
                            color: activeType == 'custom' ? theme.colorScheme.primary : AppColors.textMuted(context),
                            size: 20,
                          ),
                          AppSpacing.horizontalMd,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'pcap_dir_custom'.tr,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                    color: activeType == 'custom' ? theme.colorScheme.primary : null,
                                  ),
                                ),
                                Text(
                                  controller.customPcapPath.value ?? 'pcap_dir_custom_desc'.tr,
                                  style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary(context)),
                                ),
                              ],
                            ),
                          ),
                          Icon(AppIcons.edit, size: 18, color: theme.colorScheme.primary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
