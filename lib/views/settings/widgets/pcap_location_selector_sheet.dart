import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/icons.dart';
import '../../../constants/spacing.dart';
import '../../../controllers/settings_controller.dart';

/// Modal bottom sheet allowing users to select the destination directory
/// where raw PCAP network capture files are saved.
class PcapLocationSelectorSheet extends StatelessWidget {
  const PcapLocationSelectorSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PcapLocationSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = SettingsController.to;

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
                      'select_pcap_location'.tr,
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
                final activeType = controller.pcapLocationType.value;
                return Column(
                  children: [
                    ...locationOptions.map((opt) {
                      final id = opt['id'] as String;
                      final isSelected = activeType == id;
                      final icon = opt['icon'] as IconData;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Material(
                          color: isSelected
                              ? theme.colorScheme.primary.withValues(alpha: 0.08)
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderRadiusLg,
                            side: BorderSide(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
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
                                icon,
                                size: AppSpacing.iconSm,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            title: Text(
                              opt['title'] as String,
                              style: TextStyle(
                                fontWeight:
                                    isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              opt['subtitle'] as String,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    AppIcons.checkCircle,
                                    color: theme.colorScheme.primary,
                                  )
                                : null,
                            onTap: () {
                              controller.setPcapLocationType(id);
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      );
                    }),
                    // Custom folder option
                    _buildCustomFolderTile(context, theme, controller, activeType),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomFolderTile(
    BuildContext context,
    ThemeData theme,
    SettingsController controller,
    String activeType,
  ) {
    final isSelected = activeType == 'custom';
    final customPath = controller.customPcapPath.value;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLg,
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
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
              AppIcons.edit,
              size: AppSpacing.iconSm,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          title: Text(
            'pcap_dir_custom'.tr,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            customPath ?? 'pcap_dir_custom_desc'.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: isSelected
              ? Icon(
                  AppIcons.checkCircle,
                  color: theme.colorScheme.primary,
                )
              : null,
          onTap: () async {
            final picked = await controller.pickCustomPcapDirectory();
            if (picked && context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }
}
