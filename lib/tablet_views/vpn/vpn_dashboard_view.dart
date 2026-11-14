import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import '../../constants/icons.dart';
import '../../constants/spacing.dart';
import '../../controllers/vpn_controller.dart';
import 'package:traffic_tracker_app/shared_views/widgets/app_search_field.dart';
import 'package:traffic_tracker_app/shared_views/vpn/build_connection_tile.dart';
import 'package:traffic_tracker_app/shared_views/vpn/vpn_filter_bar.dart';
import 'package:traffic_tracker_app/shared_views/vpn/vpn_status_card.dart';
import 'package:traffic_tracker_app/shared_views/vpn/vpn_target_banner.dart';
import '../widgets/tablet_resizable_split_view.dart';
import 'app_filter_view.dart';
import 'connection_detail_view.dart';

/// System VPN Traffic Inspector Dashboard View optimized for Tablet with Resizable Splitter.
class TabletVpnDashboardView extends StatefulWidget {
  const TabletVpnDashboardView({super.key});

  @override
  State<TabletVpnDashboardView> createState() => _TabletVpnDashboardViewState();
}

class _TabletVpnDashboardViewState extends State<TabletVpnDashboardView> {
  final TextEditingController _searchController = TextEditingController();
  static double _splitRatio = 0.38;

  VpnController get controller => VpnController.to;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'system_vpn_title'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.pcapExport),
            tooltip: 'export_pcap_menu'.tr,
            onPressed: () => controller.exportPcapFile(),
          ),
          IconButton(
            icon: const Icon(AppIcons.clearAll),
            tooltip: 'clear_connections_menu'.tr,
            onPressed: () {
              controller.clearConnections();
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
      body: Obx(() {
        final isRunning = controller.isVpnRunning.value;
        final filteredList = controller.filteredConnections;
        final selectedCount = controller.selectedPackages.length;

        // Left Pane: Status, Controls, and Target Banner
        final leftPane = SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VpnStatusCard(
                controller: controller,
                onOpenAppFilter: () =>
                    Get.to(() => const TabletAppFilterView()),
              ),
              VpnTargetBanner(
                selectedCount: selectedCount,
                onEdit: () =>
                    Get.to(() => const TabletAppFilterView()),
              ),
            ],
          ),
        );

        // Right Pane: Live Captured Connections Feed
        final rightPane = Column(
          children: [
            // Search & Filter header
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: AppSearchField(
                controller: _searchController,
                hintText: 'search_vpn_hint'.tr,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.xs,
                ),
                onChanged: (val) => controller.setSearchQuery(val),
                onClear: () => controller.setSearchQuery(''),
              ),
            ),

            // Feed Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'connections_count'.trParams({
                        'count': '${filteredList.length}',
                      }),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted(context),
                      ),
                    ),
                  ),
                  if (isRunning)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.statusSuccess,
                            shape: BoxShape.circle,
                          ),
                        ),
                        AppSpacing.horizontalXs,
                        Text(
                          'live_feed'.tr,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.statusSuccess,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Filter Chips Bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: VpnFilterBar(controller: controller),
            ),
            const Divider(height: 1, thickness: 0.5),

            // Connections List or Empty State
            Expanded(
              child: filteredList.isEmpty
                  ? Center(
                      child: Padding(
                        padding: AppSpacing.paddingAllXl,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              AppIcons.vpnSecurity,
                              size: 54,
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            AppSpacing.verticalMd,
                            Text(
                              isRunning
                                  ? (_searchController.text.isNotEmpty
                                      ? 'no_connections_search'.trParams({
                                          'query': _searchController.text,
                                        })
                                      : 'no_connections_active'.tr)
                                  : 'no_connections_idle'.tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary(context),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredList.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        thickness: 0.5,
                        color: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.3),
                      ),
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        return BuildConnectionTile(
                          item: item,
                          onTap: () => TabletConnectionDetailView
                              .showDialog(context, item),
                        );
                      },
                    ),
            ),
          ],
        );

        return TabletResizableSplitView(
          initialRatio: _splitRatio,
          minRatio: 0.30,
          maxRatio: 0.70,
          onRatioChanged: (newRatio) => _splitRatio = newRatio,
          leftChild: leftPane,
          rightChild: rightPane,
        );
      }),
    );
  }
}
