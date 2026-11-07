import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/icons.dart';
import '../../controllers/traffic_controller.dart';
import '../../models/traffic_record.dart';
import '../../services/test_request_service.dart';
import '../../constants/api_endpoints.dart';
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
      Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: AppSpacing.radiusCircularXxl,
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: AppSpacing.paddingBottomSheet,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'test_requests_title'.tr,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context)),
              ),
              AppSpacing.verticalBase,
              ListTile(
                leading: _buildMethodBadge(
                  'GET',
                  AppColors.getProtocolColor('HTTP'),
                ),
                title: Text('test_get_title'.tr),
                subtitle: const Text('httpbin.org/get'),
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
                title: Text('test_post_title'.tr),
                subtitle: const Text('httpbin.org/post • Payload & Bearer header'),
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
                leading: _buildMethodBadge('PUT', AppColors.statusRedirect),
                title: Text('test_put_title'.tr),
                subtitle: const Text('httpbin.org/put • Test data update payload'),
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadiusBase,
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                onTap: () {
                  Get.back();
                  _triggerSampleRequest(_testService.sendSamplePut);
                },
              ),
              AppSpacing.verticalSm,
              ListTile(
                leading: _buildMethodBadge('DELETE', AppColors.statusServerError),
                title: Text('test_delete_title'.tr),
                subtitle: const Text('httpbin.org/delete • Test resource removal'),
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadiusBase,
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                onTap: () {
                  Get.back();
                  _triggerSampleRequest(_testService.sendSampleDelete);
                },
              ),
              AppSpacing.verticalSm,
              ListTile(
                leading: _buildMethodBadge('302', AppColors.statusRedirect),
                title: Text('test_redirect_title'.tr),
                subtitle: const Text('httpbin.org/status/302 • Redirect simulation'),
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadiusBase,
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                onTap: () {
                  Get.back();
                  _triggerSampleRequest(_testService.sendSampleRedirect);
                },
              ),
              AppSpacing.verticalSm,
              ListTile(
                leading: _buildMethodBadge(
                  '404',
                  AppColors.statusClientError,
                ),
                title: Text('test_404_title'.tr),
                subtitle: const Text('httpbin.org/status/404 • Not found error'),
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
                  '500',
                  AppColors.statusServerError,
                ),
                title: Text('test_500_title'.tr),
                subtitle: const Text('httpbin.org/status/500 • Internal server crash'),
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
    ),
    isScrollControlled: true,
  );
  }

  void _showCustomRequestDialog() {
    String selectedMethod = 'GET';
    bool followRedirects = true;
    final urlController = TextEditingController(
      text: ApiEndpoints.httpbinGet,
    );
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
                        setDialogState(() {
                          final prevMethodUrl = ApiEndpoints.getUrlForMethod(selectedMethod);
                          if (urlController.text.trim() == prevMethodUrl) {
                            urlController.text = ApiEndpoints.getUrlForMethod(val);
                          }
                          selectedMethod = val;
                        });
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
                  AppSpacing.verticalSm,
                  CheckboxListTile(
                    value: followRedirects,
                    title: Text(
                      'follow_redirects'.tr,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'follow_redirects_desc'.tr,
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary(context)),
                    ),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (val) {
                      setDialogState(() => followRedirects = val ?? true);
                    },
                  ),
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
                        followRedirects: followRedirects,
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
              child: Text(
                'network_inspector'.tr,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
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
      floatingActionButton: MediaQuery.sizeOf(context).height < 320
          ? null
          : (MediaQuery.sizeOf(context).height < 450
              ? FloatingActionButton.small(
                  onPressed:
                      _isSendingTest ? null : _showTestRequestsBottomSheet,
                  tooltip: 'test_request_btn'.tr,
                  child: _isSendingTest
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        )
                      : const Icon(AppIcons.send, size: 18),
                )
              : FloatingActionButton.extended(
                  onPressed:
                      _isSendingTest ? null : _showTestRequestsBottomSheet,
                  icon: _isSendingTest
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        )
                      : const Icon(AppIcons.send),
                  label: Text(
                    _isSendingTest ? 'sending'.tr : 'test_request_btn'.tr,
                  ),
                )),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Obx(() {
          final records = controller.filteredRecords;

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              // Search & Filter Bar
              SliverToBoxAdapter(
                child: Container(
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
                            prefixIcon: const Icon(
                              AppIcons.search,
                              size: AppSpacing.iconMd,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      AppIcons.clear,
                                      size: AppSpacing.iconSm,
                                    ),
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
                              vertical: AppSpacing.space8,
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
                      AppSpacing.verticalXs,
                      _buildFilterChips(),
                    ],
                  ),
                ),
              ),

              // Empty State or List of Records
              if (records.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            AppIcons.networkCheck,
                            size: 56,
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
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary(context),
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
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final itemIndex = index ~/ 2;
                      if (index.isOdd) {
                        return Divider(
                          height: 1,
                          thickness: 0.5,
                          color: theme.colorScheme.outlineVariant.withValues(
                            alpha: 0.4,
                          ),
                        );
                      }
                      final item = records[itemIndex];
                      return _buildTrafficItemTile(context, item);
                    },
                    childCount: records.isEmpty ? 0 : (records.length * 2) - 1,
                  ),
                ),
            ],
          );
        }),
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
    final chipBg = color ?? Theme.of(context).colorScheme.primary;
    final onChipColor = isSelected
        ? AppColors.getContrastingColor(chipBg)
        : null;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: onChipColor,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: Colors.transparent,
      selectedColor: chipBg,
      checkmarkColor: onChipColor,
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isNarrow = screenWidth < 360;

    return InkWell(
      onTap: () {
        Get.to(() => TrafficDetailView(record: item));
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isNarrow ? AppSpacing.space8 : AppSpacing.space14,
          vertical: isNarrow ? AppSpacing.space10 : AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: isNarrow ? 38 : AppSpacing.minTouchTarget,
              height: isNarrow ? 38 : AppSpacing.minTouchTarget,
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
            isNarrow ? AppSpacing.horizontalSm : AppSpacing.horizontalMd,
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
                          maxLines: 1,
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
                    maxLines: 1,
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
                  ),
                ],
              ),
            ),
            isNarrow ? AppSpacing.horizontalXs : AppSpacing.horizontalSm,
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
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted(context)),
                ),
              ],
            ),
            AppSpacing.horizontalXs,
            Icon(AppIcons.chevronRight, size: AppSpacing.iconSm, color: AppColors.textMuted(context)),
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
        style: TextStyle(
          color: AppColors.getContrastingColor(color),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
