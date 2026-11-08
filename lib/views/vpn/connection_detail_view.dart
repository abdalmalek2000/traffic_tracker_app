import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import '../../constants/icons.dart';
import '../../constants/spacing.dart';
import '../../models/captured_connection.dart';
import '../widgets/app_bottom_sheet.dart';
import '../widgets/app_buttons.dart';
import 'widgets/vpn_detail_card.dart';

/// Modal BottomSheet displaying deep details of a captured connection.
class ConnectionDetailView extends StatelessWidget {
  final CapturedConnection connection;

  const ConnectionDetailView({
    super.key,
    required this.connection,
  });

  static void show(CapturedConnection conn) {
    AppBottomSheet.showWithGet(
      child: ConnectionDetailView(connection: conn),
    );
  }

  @override
  Widget build(BuildContext context) {
    final protocolColor = AppColors.getProtocolColor(connection.protocol);

    return AppBottomSheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with Protocol & Title
          AppBottomSheetHeader(
            title: connection.primaryTitle,
            subtitle: connection.serviceName,
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space8,
                vertical: AppSpacing.xs,
              ),
              margin: const EdgeInsetsDirectional.only(end: AppSpacing.xs),
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
          ),

          // Scrollable Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.base,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
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
                  AppSpacing.verticalLg,

                  // Dynamic Unified Secondary Button
                  AppSecondaryButton(
                    text: 'close'.tr,
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
