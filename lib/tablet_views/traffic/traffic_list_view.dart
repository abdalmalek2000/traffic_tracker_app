import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import '../../constants/icons.dart';
import '../../constants/spacing.dart';
import '../../controllers/traffic_controller.dart';
import '../../models/traffic_record.dart';
import 'package:traffic_tracker_app/shared_views/widgets/app_buttons.dart';
import 'package:traffic_tracker_app/shared_views/widgets/app_search_field.dart';
import 'package:traffic_tracker_app/shared_views/traffic/custom_request_dialog.dart';
import 'package:traffic_tracker_app/shared_views/traffic/traffic_filter_bar.dart';
import 'package:traffic_tracker_app/shared_views/traffic/traffic_item_tile.dart';
import '../widgets/tablet_resizable_split_view.dart';
import 'traffic_detail_view.dart';
import 'widgets/tablet_test_requests_dialog.dart';

/// Tablet Optimized Master-Detail HTTP Traffic Inspector View with Resizable Splitter.
class TabletTrafficListView extends StatefulWidget {
  const TabletTrafficListView({super.key});

  @override
  State<TabletTrafficListView> createState() => _TabletTrafficListViewState();
}

class _TabletTrafficListViewState extends State<TabletTrafficListView> {
  final TextEditingController _searchController = TextEditingController();
  final Rxn<TrafficRecord> _selectedRecord = Rxn<TrafficRecord>();
  static double _splitRatio = 0.40;
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
    TabletTestRequestsDialog.show(
      context,
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

    // Left Pane: Master List
    final leftPane = Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: AppSearchField(
            controller: _searchController,
            hintText: 'search_traffic_hint'.tr,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.xs,
            ),
            onChanged: (val) => controller.setSearchQuery(val),
            onClear: () => controller.setSearchQuery(''),
          ),
        ),
        // Filter bar
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: TrafficFilterBar(controller: controller),
        ),
        const Divider(height: 1, thickness: 0.5),
        // Traffic Records List
        Expanded(
          child: Obx(() {
            final records = controller.filteredRecords;

            if (records.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        AppIcons.networkCheck,
                        size: 48,
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.4,
                        ),
                      ),
                      AppSpacing.verticalBase,
                      Text(
                        'no_records_title'.tr,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.verticalSm,
                      Text(
                        'no_records_desc'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      AppSpacing.verticalMd,
                      AppSecondaryButton(
                        text: 'test_request_btn'.tr,
                        icon: AppIcons.start,
                        isFullWidth: false,
                        onPressed: _showTestRequestsBottomSheet,
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
                color: theme.colorScheme.outlineVariant.withValues(
                  alpha: 0.3,
                ),
              ),
              itemBuilder: (context, index) {
                final item = records[index];
                return Obx(() {
                  final isSelected =
                      _selectedRecord.value?.id == item.id;
                  return TrafficItemTile(
                    item: item,
                    isSelected: isSelected,
                    onTap: () {
                      _selectedRecord.value = item;
                    },
                  );
                });
              },
            );
          }),
        ),
      ],
    );

    // Right Pane: Detail View
    final rightPane = Obx(() {
      final selected = _selectedRecord.value;
      if (selected == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                AppIcons.http,
                size: 64,
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
              AppSpacing.verticalMd,
              Text(
                'select_record_detail'.tr.isNotEmpty
                    ? 'select_record_detail'.tr
                    : 'Select a request to view details',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        );
      }
      return TabletTrafficDetailView(record: selected);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'network_inspector'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: _isSendingTest
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(AppIcons.start),
            tooltip: 'test_request_btn'.tr,
            onPressed: _isSendingTest ? null : _showTestRequestsBottomSheet,
          ),
          IconButton(
            icon: const Icon(AppIcons.clearAll),
            tooltip: 'clear_logs'.tr,
            onPressed: () {
              controller.clearRecords();
              _selectedRecord.value = null;
              Get.rawSnackbar(
                message: 'records_cleared'.tr,
                duration: const Duration(seconds: 1),
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          AppSpacing.horizontalXs,
        ],
      ),
      body: TabletResizableSplitView(
        initialRatio: _splitRatio,
        minRatio: 0.30,
        maxRatio: 0.70,
        onRatioChanged: (newRatio) => _splitRatio = newRatio,
        leftChild: leftPane,
        rightChild: rightPane,
      ),
    );
  }
}
