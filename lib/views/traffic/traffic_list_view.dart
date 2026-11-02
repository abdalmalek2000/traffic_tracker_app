import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/icons.dart';
import '../../controllers/traffic_controller.dart';
import '../../models/traffic_record.dart';
import '../../services/test_request_service.dart';
import '../../constants/colors.dart';
import '../../constants/spacing.dart';
import '../settings/settings_view.dart';
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
        padding: AppSpacing.paddingBottomSheet,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: AppSpacing.radiusCircularXxl,
          ),
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(AppIcons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              AppSpacing.vertical6,
              Text(
                'test_requests_subtitle'.tr,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              AppSpacing.verticalBase,
              ListTile(
                leading: _buildMethodBadge(
                  'GET',
                  AppColors.getProtocolColor('HTTP'),
                ),
                title: const Text('GET Request (200 OK)'),
                subtitle: const Text('jsonplaceholder.typicode.com/posts/1'),
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadiusBase,
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                onTap: () {
                  Get.back();
                  _triggerSampleRequest(_testService.sendSampleGet);
                },
              ),
              AppSpacing.verticalSm,
              ListTile(
                leading: _buildMethodBadge('POST', AppColors.statusSuccess),
                title: const Text('POST Request with JSON (201 Created)'),
                subtitle: const Text('Includes payload & auth bearer header'),
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadiusBase,
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                onTap: () {
                  Get.back();
                  _triggerSampleRequest(_testService.sendSamplePost);
                },
              ),
              AppSpacing.verticalSm,
              ListTile(
                leading: _buildMethodBadge(
                  'GET',
                  AppColors.getProtocolColor('HTTP'),
                ),
                title: const Text('Client Error (404 Not Found)'),
                subtitle: const Text('Test non-existent API route handling'),
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadiusBase,
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                onTap: () {
                  Get.back();
                  _triggerSampleRequest(_testService.sendSampleClientError);
                },
              ),
              AppSpacing.verticalSm,
              ListTile(
                leading: _buildMethodBadge(
                  'GET',
                  AppColors.getProtocolColor('HTTP'),
                ),
                title: const Text('Server Error (500 Error)'),
                subtitle: const Text('Test internal server crash simulation'),
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadiusBase,
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                onTap: () {
                  Get.back();
                  _triggerSampleRequest(_testService.sendSampleServerError);
                },
              ),
              AppSpacing.verticalMd,
              OutlinedButton.icon(
                icon: const Icon(AppIcons.edit),
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
    final urlController = TextEditingController(
      text: 'https://jsonplaceholder.typicode.com/todos/1',
    );
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
                      if (val != null) {
                        setDialogState(() => selectedMethod = val);
                      }
                    },
                  ),
                  AppSpacing.vertical10,
                  TextField(
                    controller: urlController,
                    decoration: InputDecoration(labelText: 'url_label'.tr),
                  ),
                  if (selectedMethod != 'GET') ...[
                    AppSpacing.vertical10,
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
              TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
              FilledButton(
                onPressed: () {
                  final url = urlController.text.trim();
                  if (url.isNotEmpty) {
                    Get.back();
                    _triggerSampleRequest(
                      () => _testService.sendCustomRequest(
                        url: url,
                        method: selectedMethod,
                        body: bodyController.text.isNotEmpty
                            ? bodyController.text
                            : null,
                      ),
                    );
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
              borderRadius: AppSpacing.borderRadiusSm,
              child: Image.asset(
                'assets/images/app_logo.png',
                width: AppSpacing.appLogoSize,
                height: AppSpacing.appLogoSize,
                fit: BoxFit.cover,
              ),
            ),
            AppSpacing.horizontalSm,
            Expanded(
              flex: 12,
              child: Text(
                'network_inspector'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Spacer(),
            Obx(() {
              final isRec = controller.isRecording.value;
              return Tooltip(
                message: isRec
                    ? 'monitoring_active'.tr
                    : 'monitoring_paused'.tr,
                child: IconButton(
                  icon: Icon(
                    isRec ? AppIcons.pause : AppIcons.play,
                    color: isRec ? AppColors.statusSuccess : Colors.grey,
                    size: 26,
                  ),
                  onPressed: () => controller.toggleRecording(),
                ),
              );
            }),
            PopupMenuButton<String>(
              icon: const Icon(AppIcons.moreVert),
              shape: RoundedRectangleBorder(
                borderRadius: AppSpacing.borderRadiusLg,
              ),
              onSelected: (val) {
                if (val == 'clear') {
                  controller.clearRecords();
                  Get.rawSnackbar(
                    message: 'records_cleared'.tr,
                    duration: const Duration(seconds: 1),
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } else if (val == 'settings') {
                  Get.to(() => const SettingsView());
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'clear',
                  child: Row(
                    children: [
                      const Icon(
                        AppIcons.delete,
                        size: AppSpacing.iconMd,
                        color: AppColors.statusServerError,
                      ),
                      AppSpacing.horizontal10,
                      Text('clear_records'.tr),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(
                        AppIcons.settings,
                        size: AppSpacing.iconMd,
                        color: theme.colorScheme.onSurface,
                      ),
                      AppSpacing.horizontal10,
                      Text('settings_title'.tr),
                    ],
                  ),
                ),
              ],
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
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(AppIcons.send),
        label: Text(_isSendingTest ? 'Sending...' : 'test_request_btn'.tr),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            // Search & Filter Bar
            Container(
              padding: AppSpacing.paddingVSm,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.4,
                    ),
                  ),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: AppSpacing.paddingHMd,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'search_hint_http'.tr,
                        prefixIcon: const Icon(AppIcons.search, size: AppSpacing.iconMd),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(AppIcons.clear, size: AppSpacing.iconSm),
                                onPressed: () {
                                  _searchController.clear();
                                  controller.setSearchQuery('');
                                  setState(() {});
                                },
                              )
                            : null,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.space10,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: AppSpacing.borderRadiusBase,
                          borderSide: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        controller.setSearchQuery(val);
                        setState(() {});
                      },
                    ),
                  ),
                  AppSpacing.verticalSm,
                  _buildFilterChips(),
                ],
              ),
            ),

            // Main List
            Expanded(
              child: Obx(() {
                final records = controller.filteredRecords;

                if (records.isEmpty) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Padding(
                              padding: const EdgeInsets.all(28.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    AppIcons.networkCheck,
                                    size: 64,
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                  AppSpacing.verticalBase,
                                  Text(
                                    'no_records_title'.tr,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  AppSpacing.verticalSm,
                                  Text(
                                    'no_records_desc'.tr,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  AppSpacing.verticalLg,
                                  FilledButton.tonalIcon(
                                    onPressed: _showTestRequestsBottomSheet,
                                    icon: const Icon(AppIcons.start),
                                    label: Text('test_request_btn'.tr),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                return ListView.separated(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: records.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    thickness: 0.5,
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.4,
                    ),
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
            AppSpacing.horizontalMd,
            _buildChip(
              label: '${'filter_all'.tr} ($total)',
              isSelected: active == TrafficFilter.all,
              onSelected: () => controller.setActiveFilter(TrafficFilter.all),
            ),
            AppSpacing.horizontal6,
            _buildChip(
              label: 'filter_2xx'.tr,
              color: AppColors.statusSuccess,
              isSelected: active == TrafficFilter.success,
              onSelected: () =>
                  controller.setActiveFilter(TrafficFilter.success),
            ),
            AppSpacing.horizontal6,
            _buildChip(
              label: 'filter_3xx'.tr,
              color: AppColors.statusRedirect,
              isSelected: active == TrafficFilter.redirect,
              onSelected: () =>
                  controller.setActiveFilter(TrafficFilter.redirect),
            ),
            AppSpacing.horizontal6,
            _buildChip(
              label: 'filter_4xx'.tr,
              color: AppColors.statusClientError,
              isSelected: active == TrafficFilter.clientError,
              onSelected: () =>
                  controller.setActiveFilter(TrafficFilter.clientError),
            ),
            AppSpacing.horizontal6,
            _buildChip(
              label: 'filter_5xx'.tr,
              color: AppColors.statusServerError,
              isSelected: active == TrafficFilter.serverError,
              onSelected: () =>
                  controller.setActiveFilter(TrafficFilter.serverError),
            ),
            AppSpacing.horizontalMd,
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
      padding: AppSpacing.paddingHXs,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildTrafficItemTile(BuildContext context, TrafficRecord item) {
    final statusColor = AppColors.getStatusCategoryColor(
      item.statusCode,
      isPending: item.isPending,
    );
    final methodColor = TrafficDetailView.getMethodColor(item.method);

    return InkWell(
      onTap: () {
        Get.to(() => TrafficDetailView(record: item));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space14,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: AppSpacing.minTouchTarget,
              height: AppSpacing.minTouchTarget,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: AppSpacing.borderRadiusBase,
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.6),
                  width: 1.2,
                ),
              ),
              child: item.isPending
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: statusColor,
                      ),
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
            AppSpacing.horizontalMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildMethodBadge(item.method, methodColor),
                      AppSpacing.horizontalSm,
                      Expanded(
                        child: Text(
                          item.path,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.verticalXxs,
                  Text(
                    item.host,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            AppSpacing.horizontalSm,
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
                AppSpacing.verticalXxs,
                Text(
                  item.formattedResponseSize,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
            AppSpacing.horizontalXs,
            const Icon(AppIcons.chevronRight, size: AppSpacing.iconSm, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodBadge(String method, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space6,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppSpacing.borderRadiusXs,
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
