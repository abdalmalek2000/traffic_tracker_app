import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../constants/icons.dart';
import '../../models/captured_connection.dart';
import '../../constants/colors.dart';
import '../../constants/spacing.dart';

/// Modal / BottomSheet displaying deep details of a captured connection.
class ConnectionDetailView extends StatelessWidget {
  final CapturedConnection connection;

  const ConnectionDetailView({
    super.key,
    required this.connection,
  });

  static void show(CapturedConnection conn) {
    Get.bottomSheet(
      ConnectionDetailView(connection: conn),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final protocolColor = AppColors.getProtocolColor(connection.protocol);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.base,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: AppSpacing.radiusCircularXxl,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.base),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: AppSpacing.borderRadiusXs,
                ),
              ),
            ),

            // Header: Protocol Badge + Primary Host Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space8,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: protocolColor,
                    borderRadius: AppSpacing.borderRadiusMd,
                  ),
                  child: Text(
                    connection.protocol,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                AppSpacing.horizontalMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        connection.primaryTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        connection.serviceName,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(AppIcons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            AppSpacing.verticalBase,
            const Divider(),
            AppSpacing.verticalMd,

            // Detailed Sections
            _buildDetailCard(
              context,
              title: 'application'.tr,
              value: connection.appName ?? 'Unknown App',
              subtitle: connection.packageName,
              icon: AppIcons.apps,
              canCopy: connection.packageName != null,
              copyText: connection.packageName,
            ),
            AppSpacing.vertical10,

            _buildDetailCard(
              context,
              title: 'destination_host'.tr,
              value: connection.domain ?? connection.dstIp,
              subtitle: 'IP: ${connection.dstIp} (Port ${connection.dstPort})',
              icon: AppIcons.public,
              canCopy: true,
              copyText: connection.domain ?? connection.dstIp,
            ),
            AppSpacing.vertical10,

            _buildDetailCard(
              context,
              title: 'local_address'.tr,
              value: '${connection.srcIp}:${connection.srcPort}',
              icon: AppIcons.device,
            ),
            AppSpacing.vertical10,

            Row(
              children: [
                Expanded(
                  child: _buildDetailCard(
                    context,
                    title: 'packet_length'.tr,
                    value: connection.formattedSize,
                    icon: AppIcons.dataUsage,
                  ),
                ),
                AppSpacing.horizontal10,
                Expanded(
                  child: _buildDetailCard(
                    context,
                    title: 'timestamp'.tr,
                    value: connection.formattedTime,
                    icon: AppIcons.time,
                  ),
                ),
              ],
            ),
            AppSpacing.verticalLg,

            // Action: Close
            FilledButton.tonal(
              onPressed: () => Get.back(),
              child: Text('close'.tr),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    bool canCopy = false,
    String? copyText,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: AppSpacing.paddingAllMd,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppSpacing.iconMd, color: theme.colorScheme.primary),
          AppSpacing.horizontal10,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                AppSpacing.verticalXxs,
                SelectableText(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  AppSpacing.verticalXxs,
                  SelectableText(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.grey.shade600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (canCopy)
            IconButton(
              icon: const Icon(AppIcons.copy, size: AppSpacing.iconXs),
              tooltip: 'Copy',
              onPressed: () {
                final txt = copyText ?? value;
                Clipboard.setData(ClipboardData(text: txt));
                Get.rawSnackbar(
                  message: 'copied_to_clipboard'.tr,
                  duration: const Duration(seconds: 1),
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
        ],
      ),
    );
  }
}
