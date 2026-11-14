import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import '../../constants/icons.dart';
import '../../constants/spacing.dart';
import '../../models/captured_connection.dart';
import 'package:traffic_tracker_app/shared_views/widgets/app_buttons.dart';
import 'package:traffic_tracker_app/shared_views/vpn/vpn_detail_card.dart';

/// Side panel / modal detail inspector for a captured connection on Tablet.
class TabletConnectionDetailView extends StatelessWidget {
  final CapturedConnection connection;
  final VoidCallback? onClose;

  const TabletConnectionDetailView({
    super.key,
    required this.connection,
    this.onClose,
  });

  static void showDialog(BuildContext context, CapturedConnection conn) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550, maxHeight: 600),
            child: Material(
              borderRadius: AppSpacing.borderRadiusLg,
              clipBehavior: Clip.antiAlias,
              child: TabletConnectionDetailView(
                connection: conn,
                onClose: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final protocolColor = AppColors.getProtocolColor(connection.protocol);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
          ),
          child: Row(
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
                  style: TextStyle(
                    color: AppColors.getContrastingColor(protocolColor),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              AppSpacing.horizontalSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      connection.primaryTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      connection.serviceName,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (onClose != null)
                IconButton(
                  icon: const Icon(AppIcons.close),
                  onPressed: onClose,
                ),
            ],
          ),
        ),

        // Body Cards
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                VpnDetailCard(
                  title: 'application'.tr,
                  value: connection.appName ?? 'Unknown App',
                  subtitle: connection.packageName,
                  icon: AppIcons.apps,
                  canCopy: connection.packageName != null,
                  copyText: connection.packageName,
                ),
                AppSpacing.vertical10,
                VpnDetailCard(
                  title: 'destination_host'.tr,
                  value: connection.domain ?? connection.dstIp,
                  subtitle: 'IP: ${connection.dstIp} (Port ${connection.dstPort})',
                  icon: AppIcons.public,
                  canCopy: true,
                  copyText: connection.domain ?? connection.dstIp,
                ),
                AppSpacing.vertical10,
                VpnDetailCard(
                  title: 'local_address'.tr,
                  value: '${connection.srcIp}:${connection.srcPort}',
                  icon: AppIcons.device,
                ),
                AppSpacing.vertical10,
                Row(
                  children: [
                    Expanded(
                      child: VpnDetailCard(
                        title: 'packet_length'.tr,
                        value: connection.formattedSize,
                        icon: AppIcons.dataUsage,
                      ),
                    ),
                    AppSpacing.horizontal10,
                    Expanded(
                      child: VpnDetailCard(
                        title: 'timestamp'.tr,
                        value: connection.formattedTime,
                        icon: AppIcons.time,
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalBase,
                AppSecondaryButton(
                  text: 'close'.tr,
                  onPressed: onClose ?? () => Get.back(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
