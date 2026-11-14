import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../constants/icons.dart';
import '../../../constants/spacing.dart';
import '../../../services/test_request_service.dart';
import 'package:traffic_tracker_app/shared_views/traffic/traffic_item_tile.dart';
import 'package:traffic_tracker_app/shared_views/widgets/app_buttons.dart';
import '../../widgets/tablet_dialog.dart';

/// Center dialog for dispatching test HTTP requests on Tablet.
class TabletTestRequestsDialog extends StatelessWidget {
  final Future<void> Function(Future<void> Function() action) onTriggerRequest;
  final VoidCallback onShowCustomRequest;

  const TabletTestRequestsDialog({
    super.key,
    required this.onTriggerRequest,
    required this.onShowCustomRequest,
  });

  static void show(
    BuildContext context, {
    required Future<void> Function(Future<void> Function() action) onTriggerRequest,
    required VoidCallback onShowCustomRequest,
  }) {
    TabletDialog.show(
      context: context,
      title: 'test_requests_title'.tr,
      subtitle: 'test_requests_desc'.tr,
      maxWidth: 550,
      maxHeight: 620,
      child: TabletTestRequestsDialog(
        onTriggerRequest: onTriggerRequest,
        onShowCustomRequest: onShowCustomRequest,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final testService = TestRequestService();

    final testItems = [
      _TestItem(
        method: 'GET',
        color: AppColors.getProtocolColor('HTTP'),
        title: 'test_get_title'.tr,
        subtitle: 'httpbin.org/get',
        action: testService.sendSampleGet,
      ),
      _TestItem(
        method: 'POST',
        color: AppColors.statusSuccess,
        title: 'test_post_title'.tr,
        subtitle: 'httpbin.org/post • Payload & Bearer header',
        action: testService.sendSamplePost,
      ),
      _TestItem(
        method: 'GET',
        color: AppColors.statusRedirect,
        title: 'test_redirect_title'.tr,
        subtitle: 'httpbin.org/redirect/1 • 302 Foundation',
        action: testService.sendSampleRedirect,
      ),
      _TestItem(
        method: 'GET',
        color: AppColors.statusClientError,
        title: 'test_404_title'.tr,
        subtitle: 'httpbin.org/status/404 • Not Found',
        action: testService.sendSampleClientError,
      ),
      _TestItem(
        method: 'GET',
        color: AppColors.statusServerError,
        title: 'test_500_title'.tr,
        subtitle: 'httpbin.org/status/500 • Internal Error',
        action: testService.sendSampleServerError,
      ),
      _TestItem(
        method: 'PUT',
        color: AppColors.protocolDns,
        title: 'test_put_title'.tr,
        subtitle: 'httpbin.org/put • Payload Update',
        action: testService.sendSamplePut,
      ),
    ];

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      children: [
        // Custom Request Launcher Card
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd,
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(
                  AppIcons.terminal,
                  color: Theme.of(context).colorScheme.primary,
                  size: AppSpacing.iconLg,
                ),
                AppSpacing.horizontalMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'custom_request_title'.tr,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'custom_request_subtitle'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                AppPrimaryButton(
                  text: 'send_btn'.tr,
                  isFullWidth: false,
                  onPressed: () {
                    Navigator.of(context).pop();
                    onShowCustomRequest();
                  },
                ),
              ],
            ),
          ),
        ),
        AppSpacing.verticalMd,

        // Test Request Presets
        ...testItems.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: AppSpacing.borderRadiusMd,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  onTriggerRequest(item.action);
                },
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      TrafficItemTile.buildMethodBadge(item.method, item.color),
                      AppSpacing.horizontalMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              item.subtitle,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        AppIcons.chevronRight,
                        size: AppSpacing.iconSm,
                        color: AppColors.textMuted(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _TestItem {
  final String method;
  final Color color;
  final String title;
  final String subtitle;
  final Future<void> Function() action;

  _TestItem({
    required this.method,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.action,
  });
}
