import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../models/captured_connection.dart';
import '../../theme/app_colors.dart';

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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header: Protocol Badge + Primary Host Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: protocolColor,
                    borderRadius: BorderRadius.circular(8),
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
                const SizedBox(width: 12),
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
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Detailed Sections
            _buildDetailCard(
              context,
              title: 'application'.tr,
              value: connection.appName ?? 'Unknown App',
              subtitle: connection.packageName,
              icon: Icons.apps_rounded,
              canCopy: connection.packageName != null,
              copyText: connection.packageName,
            ),
            const SizedBox(height: 10),

            _buildDetailCard(
              context,
              title: 'destination_host'.tr,
              value: connection.domain ?? connection.dstIp,
              subtitle: 'IP: ${connection.dstIp} (Port ${connection.dstPort})',
              icon: Icons.public_rounded,
              canCopy: true,
              copyText: connection.domain ?? connection.dstIp,
            ),
            const SizedBox(height: 10),

            _buildDetailCard(
              context,
              title: 'local_address'.tr,
              value: '${connection.srcIp}:${connection.srcPort}',
              icon: Icons.phone_android_rounded,
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _buildDetailCard(
                    context,
                    title: 'packet_length'.tr,
                    value: connection.formattedSize,
                    icon: Icons.data_usage_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDetailCard(
                    context,
                    title: 'timestamp'.tr,
                    value: connection.formattedTime,
                    icon: Icons.access_time_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
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
                const SizedBox(height: 2),
                SelectableText(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
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
              icon: const Icon(Icons.copy_rounded, size: 16),
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
