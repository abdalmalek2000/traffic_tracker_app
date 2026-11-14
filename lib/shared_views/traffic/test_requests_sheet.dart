import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../constants/icons.dart';
import '../../../constants/spacing.dart';
import '../../../services/test_request_service.dart';
import 'package:traffic_tracker_app/shared_views/widgets/app_bottom_sheet.dart';
import 'package:traffic_tracker_app/shared_views/widgets/app_buttons.dart';
import 'traffic_item_tile.dart';

/// Modal bottom sheet allowing users to dispatch sample HTTP requests for inspection.
class TestRequestsSheet extends StatelessWidget {
  final Future<void> Function(Future<void> Function() action) onTriggerRequest;
  final VoidCallback onShowCustomRequest;

  const TestRequestsSheet({
    super.key,
    required this.onTriggerRequest,
    required this.onShowCustomRequest,
  });

  static void show({
    required Future<void> Function(Future<void> Function() action) onTriggerRequest,
    required VoidCallback onShowCustomRequest,
  }) {
    AppBottomSheet.showWithGet(
      child: TestRequestsSheet(
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
        method: 'PUT',
        color: AppColors.statusRedirect,
        title: 'test_put_title'.tr,
        subtitle: 'httpbin.org/put • Test data update payload',
        action: testService.sendSamplePut,
      ),
      _TestItem(
        method: 'DELETE',
        color: AppColors.statusServerError,
        title: 'test_delete_title'.tr,
        subtitle: 'httpbin.org/delete • Test resource removal',
        action: testService.sendSampleDelete,
      ),
      _TestItem(
        method: '302',
        color: AppColors.statusRedirect,
        title: 'test_redirect_title'.tr,
        subtitle: 'httpbin.org/status/302 • Redirect simulation',
        action: testService.sendSampleRedirect,
      ),
      _TestItem(
        method: '404',
        color: AppColors.statusClientError,
        title: 'test_404_title'.tr,
        subtitle: 'httpbin.org/status/404 • Not found error',
        action: testService.sendSampleClientError,
      ),
      _TestItem(
        method: '500',
        color: AppColors.statusServerError,
        title: 'test_500_title'.tr,
        subtitle: 'httpbin.org/status/500 • Internal server crash',
        action: testService.sendSampleServerError,
      ),
    ];

    return AppBottomSheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBottomSheetHeader(
            title: 'test_requests_title'.tr,
            subtitle: 'test_requests_subtitle'.tr,
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: AppSpacing.paddingBottomSheet,
              itemCount: testItems.length + 1,
              separatorBuilder: (_, _) => AppSpacing.verticalSm,
              itemBuilder: (context, index) {
                if (index == testItems.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: AppSecondaryButton(
                      icon: AppIcons.edit,
                      text: 'send_custom_request'.tr,
                      onPressed: () {
                        Get.back();
                        onShowCustomRequest();
                      },
                    ),
                  );
                }

                final item = testItems[index];
                return ListTile(
                  leading: TrafficItemTile.buildMethodBadge(item.method, item.color),
                  title: Text(item.title),
                  subtitle: Text(item.subtitle),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusBase,
                    side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  onTap: () {
                    Get.back();
                    onTriggerRequest(item.action);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TestItem {
  final String method;
  final Color color;
  final String title;
  final String subtitle;
  final Future<void> Function() action;

  const _TestItem({
    required this.method,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.action,
  });
}
