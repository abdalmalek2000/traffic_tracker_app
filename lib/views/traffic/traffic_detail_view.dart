import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import '../../constants/icons.dart';
import '../../constants/spacing.dart';
import '../../models/traffic_record.dart';
import '../widgets/app_buttons.dart';
import '../widgets/json_viewer_widget.dart';
import 'widgets/traffic_headers_card.dart';
import 'widgets/traffic_overview_tab.dart';

/// Deep HTTP request & response detail inspection view.
class TrafficDetailView extends StatelessWidget {
  final TrafficRecord record;

  const TrafficDetailView({
    super.key,
    required this.record,
  });

  static Color getStatusColor(TrafficStatusCategory category) {
    switch (category) {
      case TrafficStatusCategory.success:
        return AppColors.statusSuccess;
      case TrafficStatusCategory.redirect:
        return AppColors.statusRedirect;
      case TrafficStatusCategory.clientError:
        return AppColors.statusClientError;
      case TrafficStatusCategory.serverError:
      case TrafficStatusCategory.failed:
        return AppColors.statusServerError;
      case TrafficStatusCategory.pending:
        return AppColors.statusPending;
    }
  }

  static Color getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return AppColors.protocolHttp;
      case 'POST':
        return AppColors.statusSuccess;
      case 'PUT':
        return AppColors.protocolDns;
      case 'DELETE':
        return AppColors.statusServerError;
      case 'PATCH':
        return AppColors.protocolTls;
      default:
        return AppColors.protocolOther;
    }
  }

  Widget _buildRequestTab(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: AppSpacing.paddingCard,
      children: [
        Text(
          'req_headers'.tr,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.verticalSm,
        TrafficHeadersCard(headers: record.requestHeaders),
        AppSpacing.verticalBase,
        Text(
          'request'.tr,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.verticalSm,
        JsonViewerWidget(
          content: record.prettyRequestBody,
          title: 'Request Payload',
        ),
      ],
    );
  }

  Widget _buildResponseTab(BuildContext context) {
    final theme = Theme.of(context);
    final resHeaders = record.responseHeaders ?? {};

    return ListView(
      padding: AppSpacing.paddingCard,
      children: [
        Text(
          'res_headers'.tr,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.verticalSm,
        TrafficHeadersCard(headers: resHeaders),
        AppSpacing.verticalBase,
        Text(
          'response'.tr,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.verticalSm,
        JsonViewerWidget(
          content: record.prettyResponseBody,
          title: 'Response Payload (${record.formattedResponseSize})',
        ),
      ],
    );
  }

  Widget _buildCurlTab(BuildContext context) {
    final curl = record.toCurlCommand();

    return ListView(
      padding: AppSpacing.paddingCard,
      children: [
        Text(
          'curl_instruction'.tr,
          style: const TextStyle(fontSize: 13),
        ),
        AppSpacing.verticalMd,
        JsonViewerWidget(
          content: curl,
          title: 'cURL Command',
        ),
        AppSpacing.verticalBase,
        AppPrimaryButton(
          text: 'copy_curl'.tr,
          icon: AppIcons.copy,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: curl));
            Get.rawSnackbar(
              message: 'copied_to_clipboard'.tr,
              duration: const Duration(seconds: 1),
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor(record.statusCategory);
    final methodColor = getMethodColor(record.method);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: methodColor,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Text(
                  record.method.toUpperCase(),
                  style: TextStyle(
                    color: AppColors.getContrastingColor(methodColor),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              AppSpacing.horizontalSm,
              if (record.statusCode != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: AppSpacing.borderRadiusSm,
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    '${record.statusCode}',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              AppSpacing.horizontal10,
              Expanded(
                child: Text(
                  record.path,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(AppIcons.terminal),
              tooltip: 'copy_curl'.tr,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: record.toCurlCommand()));
                Get.rawSnackbar(
                  message: 'copied_to_clipboard'.tr,
                  duration: const Duration(seconds: 1),
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(icon: const Icon(AppIcons.overview), text: 'overview'.tr),
              Tab(icon: const Icon(AppIcons.requestUpload), text: 'request'.tr),
              Tab(icon: const Icon(AppIcons.responseDownload), text: 'response'.tr),
              Tab(icon: const Icon(AppIcons.terminal), text: 'curl'.tr),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TrafficOverviewTab(record: record),
            _buildRequestTab(context),
            _buildResponseTab(context),
            _buildCurlTab(context),
          ],
        ),
      ),
    );
  }
}
