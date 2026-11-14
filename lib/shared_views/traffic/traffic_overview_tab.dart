import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../constants/icons.dart';
import '../../../constants/spacing.dart';
import '../../../models/traffic_record.dart';
import 'traffic_headers_card.dart';

/// Overview tab in TrafficDetailView displaying summary, timings, and parameters.
class TrafficOverviewTab extends StatelessWidget {
  final TrafficRecord record;

  const TrafficOverviewTab({
    super.key,
    required this.record,
  });

  Widget _buildRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: isError ? AppColors.statusServerError : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusLg,
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'full_url'.tr,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(AppIcons.copy, size: AppSpacing.iconSm),
                  tooltip: 'copy_curl'.tr,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: record.url));
                    Get.rawSnackbar(
                      message: 'copied_to_clipboard'.tr,
                      duration: const Duration(seconds: 1),
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ],
            ),
            AppSpacing.verticalXs,
            SelectableText(
              record.url,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: AppSpacing.paddingCard,
      children: [
        _buildUrlCard(context),
        AppSpacing.verticalMd,
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusLg,
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: AppSpacing.paddingCard,
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
          AppSpacing.verticalBase,
          Text(
            'query_params'.tr,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.verticalSm,
          TrafficHeadersCard(headers: record.queryParameters),
        ],
      ],
    );
  }
}
