import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import '../../constants/icons.dart';
import '../../constants/spacing.dart';
import '../../controllers/traffic_controller.dart';
import '../settings/settings_view.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_search_field.dart';
import 'widgets/custom_request_dialog.dart';
import 'widgets/test_requests_sheet.dart';
import 'widgets/traffic_filter_bar.dart';
import 'widgets/traffic_item_tile.dart';

/// In-App HTTP/HTTPS Traffic Inspector View
class TrafficListView extends StatefulWidget {
  const TrafficListView({super.key});

  @override
  State<TrafficListView> createState() => _TrafficListViewState();
}

class _TrafficListViewState extends State<TrafficListView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSendingTest = false;

  TrafficController get controller => TrafficController.to;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _triggerSampleRequest(Future<void> Function() action) async {
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
    TestRequestsSheet.show(
      onTriggerRequest: _triggerSampleRequest,
      onShowCustomRequest: _showCustomRequestDialog,
    );
  }

  void _showCustomRequestDialog() {
    CustomRequestDialog.show(onTriggerRequest: _triggerSampleRequest);
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
                  onPressed: _isSendingTest ? null : _showTestRequestsBottomSheet,
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
                  onPressed: _isSendingTest ? null : _showTestRequestsBottomSheet,
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
                      AppSearchField(
                        controller: _searchController,
                        hintText: 'search_hint_http'.tr,
                        padding: AppSpacing.paddingHMd,
                        onChanged: (val) => controller.setSearchQuery(val),
                        onClear: () => controller.setSearchQuery(''),
                      ),
                      AppSpacing.verticalXs,
                      TrafficFilterBar(controller: controller),
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
                          AppSecondaryButton(
                            text: 'test_request_btn'.tr,
                            icon: AppIcons.start,
                            isFullWidth: false,
                            onPressed: _showTestRequestsBottomSheet,
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
                      return TrafficItemTile(item: item);
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
}
