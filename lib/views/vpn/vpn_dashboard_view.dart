import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import '../../constants/icons.dart';
import '../../constants/spacing.dart';
import '../../controllers/vpn_controller.dart';
import 'app_filter_view.dart';
import 'connection_detail_view.dart';
import '../settings/settings_view.dart';
import 'package:traffic_tracker_app/shared_views/widgets/app_search_field.dart';
import 'package:traffic_tracker_app/shared_views/vpn/build_connection_tile.dart';
import 'package:traffic_tracker_app/shared_views/vpn/vpn_filter_bar.dart';
import 'package:traffic_tracker_app/shared_views/vpn/vpn_status_card.dart';
import 'package:traffic_tracker_app/shared_views/vpn/vpn_target_banner.dart';

/// System VPN Traffic Inspector Dashboard View
class VpnDashboardView extends StatefulWidget {
  const VpnDashboardView({super.key});

  @override
  State<VpnDashboardView> createState() => _VpnDashboardViewState();
}

class _VpnDashboardViewState extends State<VpnDashboardView> {
  final TextEditingController _searchController = TextEditingController();

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
                'system_vpn_title'.tr,
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
              if (val == 'pcap') {
                controller.exportPcapFile();
              } else if (val == 'clear') {
                controller.clearConnections();
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
                value: 'pcap',
                child: Row(
                  children: [
                    Icon(
                      AppIcons.pcapExport,
                      size: AppSpacing.iconMd,
                      color: theme.colorScheme.primary,
                    ),
                    AppSpacing.horizontal10,
                    Text('download_pcap'.tr),
                  ],
                ),
              ),
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
                    Text('delete_records'.tr),
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
      body: Obx(() {
        final isRunning = controller.isVpnRunning.value;
        final filteredList = controller.filteredConnections;
        final selectedCount = controller.selectedPackages.length;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Status and Metrics Card
                    VpnStatusCard(
                      controller: controller,
                      onOpenAppFilter: () => Get.to(() => const AppFilterView()),
                    ),

                    // Active Target Mode Banner
                    VpnTargetBanner(
                      selectedCount: selectedCount,
                      onEdit: () => Get.to(() => const AppFilterView()),
                    ),

                    // Unified Search Field
                    AppSearchField(
                      controller: _searchController,
                      hintText: 'search_vpn_hint'.tr,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.base,
                        vertical: AppSpacing.xs,
                      ),
                      onChanged: (val) => controller.setSearchQuery(val),
                      onClear: () => controller.setSearchQuery(''),
                    ),

                    // Feed Header Row
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${'live_connections'.tr} (${filteredList.length})',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (isRunning)
                            Row(
                              children: [
                                Container(
                                  width: AppSpacing.sm,
                                  height: AppSpacing.sm,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.statusSuccess,
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

                    // Unified Filter Chips Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: VpnFilterBar(controller: controller),
                    ),
                  ],
                ),
              ),

              // Connections List or Empty State
              if (filteredList.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
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
                  ),
                )
              else
                SliverList.separated(
                  itemCount: filteredList.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    thickness: 0.5,
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.4,
                    ),
                  ),
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    return BuildConnectionTile(
                      item: item,
                      onTap: () => ConnectionDetailView.show(item),
                    );
                  },
                ),
            ],
          ),
        );
      }),
    );
  }
}
