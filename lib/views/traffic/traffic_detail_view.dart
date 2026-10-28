import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../constants/icons.dart';
import '../../models/traffic_record.dart';
import '../../constants/colors.dart';
import '../widgets/json_viewer_widget.dart';

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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: methodColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  record.method.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (record.statusCode != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
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
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  record.path,
                  overflow: TextOverflow.ellipsis,
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
            _buildOverviewTab(context),
            _buildRequestTab(context),
            _buildResponseTab(context),
            _buildCurlTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          context,
          title: 'full_url'.tr,
          content: record.url,
          canCopy: true,
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildRow('host'.tr, record.host),
                const Divider(),
                _buildRow('path'.tr, record.path),
                const Divider(),
                _buildRow('method_label'.tr, record.method.toUpperCase()),
                const Divider(),
                _buildRow(
                  'status'.tr,
                  record.statusCode != null
                      ? '${record.statusCode} (${record.statusMessage ?? ''})'
                      : (record.isPending ? 'Pending...' : 'Failed'),
                ),
                const Divider(),
                _buildRow('duration'.tr, record.formattedDuration),
                const Divider(),
                _buildRow('req_size'.tr, record.formattedRequestSize),
                const Divider(),
                _buildRow('res_size'.tr, record.formattedResponseSize),
                const Divider(),
                _buildRow('timestamp'.tr, record.timestamp.toLocal().toString()),
                if (record.error != null) ...[
                  const Divider(),
                  _buildRow('Error', record.error!, isError: true),
                ],
              ],
            ),
          ),
        ),
        if (record.queryParameters.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'query_params'.tr,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildHeadersCard(context, record.queryParameters),
        ],
      ],
    );
  }

  Widget _buildRequestTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'req_headers'.tr,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildHeadersCard(context, record.requestHeaders),
        const SizedBox(height: 16),
        Text(
          'request'.tr,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        JsonViewerWidget(
          content: record.prettyRequestBody,
          title: 'Request Payload',
        ),
      ],
    );
  }

  Widget _buildResponseTab(BuildContext context) {
    final resHeaders = record.responseHeaders ?? {};

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'res_headers'.tr,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildHeadersCard(context, resHeaders),
        const SizedBox(height: 16),
        Text(
          'response'.tr,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
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
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'curl_instruction'.tr,
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 12),
        JsonViewerWidget(
          content: curl,
          title: 'cURL Command',
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: curl));
            Get.rawSnackbar(
              message: 'copied_to_clipboard'.tr,
              duration: const Duration(seconds: 1),
              snackPosition: SnackPosition.BOTTOM,
            );
          },
          icon: const Icon(AppIcons.copy),
          label: Text('copy_curl'.tr),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context,
      {required String title, required String content, bool canCopy = false}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                if (canCopy)
                  IconButton(
                    icon: const Icon(AppIcons.copy, size: 16),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: content));
                      Get.rawSnackbar(
                        message: 'copied_to_clipboard'.tr,
                        duration: const Duration(seconds: 1),
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 4),
            SelectableText(
              content,
              style: const TextStyle(fontSize: 13, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeadersCard(BuildContext context, Map<String, String> headers) {
    if (headers.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('no_headers'.tr, style: const TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: headers.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: SelectableText(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const Text(' : '),
                  Expanded(
                    flex: 3,
                    child: SelectableText(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: SelectableText(
              value,
              style: TextStyle(
                fontSize: 13,
                color: isError ? AppColors.statusServerError : null,
                fontFamily: isError ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
