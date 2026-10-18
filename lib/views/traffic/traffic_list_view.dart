import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/traffic_controller.dart';
import '../../models/traffic_record.dart';
import '../../services/test_request_service.dart';
import '../../theme/app_colors.dart';
import 'traffic_detail_view.dart';

/// In-App HTTP/HTTPS Traffic Inspector View
class TrafficListView extends StatefulWidget {
  const TrafficListView({super.key});

  @override
  State<TrafficListView> createState() => _TrafficListViewState();
}

class _TrafficListViewState extends State<TrafficListView> {
  final TextEditingController _searchController = TextEditingController();
  final TestRequestService _testService = TestRequestService();
  bool _isSendingTest = false;

  TrafficController get controller => TrafficController.to;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _triggerSampleRequest(Future<void> Function() action) async {
    setState(() => _isSendingTest = true);
    try {
      await action();
    } finally {
      if (mounted) {
        setState(() => _isSendingTest = false);
      }
    }
  }

  void _showTestRequestsBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'test_requests_title'.tr,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'test_requests_subtitle'.tr,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: _buildMethodBadge('GET', AppColors.getProtocolColor('HTTP')),
                title: const Text('GET Request (200 OK)'),
                subtitle: const Text('jsonplaceholder.typicode.com/posts/1'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                onTap: () {
                  Get.back();
                  _triggerSampleRequest(_testService.sendSampleGet);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: _buildMethodBadge('POST', AppColors.statusSuccess),
                title: const Text('POST Request with JSON (201 Created)'),
                subtitle: const Text('Includes payload & auth bearer header'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                onTap: () {
                  Get.back();
                  _triggerSampleRequest(_testService.sendSamplePost);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: _buildMethodBadge('GET', AppColors.getProtocolColor('HTTP')),
                title: const Text('Client Error (404 Not Found)'),
                subtitle: const Text('Test non-existent API route handling'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                onTap: () {
                  Get.back();
                  _triggerSampleRequest(_testService.sendSampleClientError);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: _buildMethodBadge('GET', AppColors.getProtocolColor('HTTP')),
                title: const Text('Server Error (500 Error)'),
                subtitle: const Text('Test internal server crash simulation'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                onTap: () {
                  Get.back();
                  _triggerSampleRequest(_testService.sendSampleServerError);
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.edit_note_rounded),
                label: Text('send_custom_request'.tr),
                onPressed: () {
                  Get.back();
                  _showCustomRequestDialog();
                },
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showCustomRequestDialog() {
    final urlController =
        TextEditingController(text: 'https://jsonplaceholder.typicode.com/todos/1');
    String selectedMethod = 'GET';
    final bodyController = TextEditingController();

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('send_custom_request'.tr),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedMethod,
                    decoration: InputDecoration(labelText: 'method_label'.tr),
                    items: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedMethod = val);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: urlController,
                    decoration: InputDecoration(labelText: 'url_label'.tr),
                  ),
                  if (selectedMethod != 'GET') ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: bodyController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'body_label'.tr,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('cancel'.tr),
              ),
              FilledButton(
                onPressed: () {
                  final url = urlController.text.trim();
                  if (url.isNotEmpty) {
                    Get.back();
                    _triggerSampleRequest(() => _testService.sendCustomRequest(
                          url: url,
                          method: selectedMethod,
                          body: bodyController.text.isNotEmpty
                              ? bodyController.text
                              : null,
                        ));
                  }
                },
                child: Text('send_and_inspect'.tr),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/app_logo.png',
                width: 26,
                height: 26,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            Text('network_inspector'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            Obx(() {
              final isRec = controller.isRecording.value;
              return Tooltip(
                message: isRec ? 'monitoring_active'.tr : 'monitoring_paused'.tr,
                child: IconButton(
                  icon: Icon(
                    isRec
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                    color: isRec ? AppColors.statusSuccess : Colors.grey,
                    size: 26,
                  ),
                  onPressed: () => controller.toggleRecording(),
                ),
              );
            }),
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: 'clear_records'.tr,
              onPressed: () {
                controller.clearRecords();
                Get.rawSnackbar(
                  message: 'records_cleared'.tr,
                  duration: const Duration(seconds: 1),
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSendingTest ? null : _showTestRequestsBottomSheet,
        icon: _isSendingTest
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.send_rounded),
        label: Text(_isSendingTest ? 'Sending...' : 'test_request_btn'.tr),
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              border: Border(
                bottom: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'search_hint_http'.tr,
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              controller.setSearchQuery('');
                              setState(() {});
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                  ),
                  onChanged: (val) {
                    controller.setSearchQuery(val);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 8),
                _buildFilterChips(),
              ],
            ),
          ),

          // Main List
          Expanded(
            child: Obx(() {
              final records = controller.filteredRecords;

              if (records.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.network_check_rounded,
                          size: 64,
                          color: theme.colorScheme.primary.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'no_records_title'.tr,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'no_records_desc'.tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        FilledButton.tonalIcon(
                          onPressed: _showTestRequestsBottomSheet,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text('test_request_btn'.tr),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                itemCount: records.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  thickness: 0.5,
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
                itemBuilder: (context, index) {
                  final item = records[index];
                  return _buildTrafficItemTile(context, item);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Obx(() {
      final active = controller.activeFilter.value;
      final total = controller.records.length;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildChip(
              label: '${'filter_all'.tr} ($total)',
              isSelected: active == TrafficFilter.all,
              onSelected: () => controller.setActiveFilter(TrafficFilter.all),
            ),
            const SizedBox(width: 6),
            _buildChip(
              label: 'filter_2xx'.tr,
              color: AppColors.statusSuccess,
              isSelected: active == TrafficFilter.success,
              onSelected: () => controller.setActiveFilter(TrafficFilter.success),
            ),
            const SizedBox(width: 6),
            _buildChip(
              label: 'filter_3xx'.tr,
              color: AppColors.statusRedirect,
              isSelected: active == TrafficFilter.redirect,
              onSelected: () => controller.setActiveFilter(TrafficFilter.redirect),
            ),
            const SizedBox(width: 6),
            _buildChip(
              label: 'filter_4xx'.tr,
              color: AppColors.statusClientError,
              isSelected: active == TrafficFilter.clientError,
              onSelected: () => controller.setActiveFilter(TrafficFilter.clientError),
            ),
            const SizedBox(width: 6),
            _buildChip(
              label: 'filter_5xx'.tr,
              color: AppColors.statusServerError,
              isSelected: active == TrafficFilter.serverError,
              onSelected: () => controller.setActiveFilter(TrafficFilter.serverError),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildChip({
    required String label,
    Color? color,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : null,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: Colors.transparent,
      selectedColor: color ?? Theme.of(context).colorScheme.primary,
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildTrafficItemTile(BuildContext context, TrafficRecord item) {
    final statusColor = AppColors.getStatusCategoryColor(item.statusCode, isPending: item.isPending);
    final methodColor = TrafficDetailView.getMethodColor(item.method);

    return InkWell(
      onTap: () {
        Get.to(() => TrafficDetailView(record: item));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: statusColor.withValues(alpha: 0.6), width: 1.2),
              ),
              child: item.isPending
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: statusColor),
                    )
                  : Text(
                      item.statusCode?.toString() ?? 'ERR',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: statusColor,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildMethodBadge(item.method, methodColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.path,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.host,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.formattedDuration,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.formattedResponseSize,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodBadge(String method, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        method.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
