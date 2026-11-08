import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import '../../constants/icons.dart';
import '../../constants/spacing.dart';
import '../../controllers/vpn_controller.dart';
import '../widgets/app_filter_chip.dart';
import '../widgets/app_search_field.dart';
import 'widgets/app_filter_item_tile.dart';

/// Target Applications Selector View
class AppFilterView extends StatefulWidget {
  const AppFilterView({super.key});

  @override
  State<AppFilterView> createState() => _AppFilterViewState();
}

class _AppFilterViewState extends State<AppFilterView> {
  final TextEditingController _searchController = TextEditingController();

  VpnController get controller => VpnController.to;

  @override
  void initState() {
    super.initState();
    controller.loadInstalledApps();
  }

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
        title: Text('select_target_apps'.tr),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Options',
            icon: const Icon(AppIcons.moreVert),
            onSelected: (val) {
              if (val == 'clear') {
                controller.clearSelection();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    const Icon(
                      AppIcons.deselectAll,
                      color: AppColors.statusServerError,
                    ),
                    AppSpacing.horizontalSm,
                    Text('deselect_all_menu'.tr),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingApps.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                AppSpacing.verticalBase,
                Text('loading_apps'.tr),
              ],
            ),
          );
        }

        final visibleApps = controller.visibleApps;
        final selectedCount = controller.selectedPackages.length;
        final currentTab = controller.currentAppTab.value;
        final totalAppsCount = controller.installedApps.length;

        return Column(
          children: [
            // Search & Filter Header
            Container(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              child: Column(
                children: [
                  AppSearchField(
                    controller: _searchController,
                    hintText: currentTab == AppViewTab.selectedOnly
                        ? 'search_selected_hint'.tr
                        : 'search_apps_hint'.tr,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base,
                      AppSpacing.md,
                      AppSpacing.base,
                      AppSpacing.sm,
                    ),
                    onChanged: (val) => controller.setAppSearchQuery(val),
                    onClear: () => controller.setAppSearchQuery(''),
                  ),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        AppSpacing.horizontalBase,
                        AppFilterChip(
                          label: 'filter_all_apps'.tr,
                          count: totalAppsCount,
                          isSelected: currentTab == AppViewTab.all,
                          onSelected: () => controller.setAppTab(AppViewTab.all),
                        ),
                        AppSpacing.horizontal6,
                        AppFilterChip(
                          label: 'filter_selected_only'.tr,
                          count: selectedCount,
                          color: AppColors.statusSuccess,
                          isSelected: currentTab == AppViewTab.selectedOnly,
                          onSelected: () =>
                              controller.setAppTab(AppViewTab.selectedOnly),
                        ),
                        AppSpacing.horizontal6,
                        AppFilterChip(
                          label: 'filter_user_apps'.tr,
                          isSelected: currentTab == AppViewTab.userApps,
                          onSelected: () =>
                              controller.setAppTab(AppViewTab.userApps),
                        ),
                        AppSpacing.horizontal6,
                        AppFilterChip(
                          label: 'filter_system_apps'.tr,
                          isSelected: currentTab == AppViewTab.systemApps,
                          onSelected: () =>
                              controller.setAppTab(AppViewTab.systemApps),
                        ),
                        AppSpacing.horizontalBase,
                      ],
                    ),
                  ),
                  AppSpacing.verticalSm,

                  // Summary & Quick Selection Action
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            selectedCount == 0
                                ? 'mode_monitoring_all'.tr
                                : 'mode_monitoring_selected'.trParams({
                                    'count': '$selectedCount',
                                  }),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: selectedCount == 0
                                  ? theme.colorScheme.primary
                                  : AppColors.statusSuccess,
                            ),
                          ),
                        ),
                        if (visibleApps.isNotEmpty &&
                            currentTab != AppViewTab.selectedOnly) ...[
                          AppSpacing.horizontalSm,
                          TextButton(
                            onPressed: () {
                              final visiblePkgs =
                                  visibleApps.map((a) => a.packageName);
                              final allSelected = visiblePkgs.every(
                                (p) => controller.selectedPackages.contains(p),
                              );
                              if (allSelected) {
                                for (final p in visiblePkgs) {
                                  controller.togglePackage(p);
                                }
                              } else {
                                controller.selectAll(visiblePkgs);
                              }
                            },
                            child: Text(
                              visibleApps.every(
                                (a) => controller.selectedPackages
                                    .contains(a.packageName),
                              )
                                  ? 'deselect_all_visible'.tr
                                  : 'select_all_visible'.trParams({
                                      'count': '${visibleApps.length}',
                                    }),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Active VPN Live Sync Notice
            if (controller.isVpnRunning.value)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.space6,
                ),
                color: AppColors.statusSuccess.withValues(alpha: 0.12),
                child: Row(
                  children: [
                    const Icon(
                      AppIcons.sync,
                      size: AppSpacing.iconXs,
                      color: AppColors.statusSuccess,
                    ),
                    AppSpacing.horizontal6,
                    Expanded(
                      child: Text(
                        'live_sync_notice'.tr,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.statusSuccess,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // App List
            Expanded(
              child: visibleApps.isEmpty
                  ? Center(
                      child: Padding(
                        padding: AppSpacing.paddingAllXl,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              currentTab == AppViewTab.selectedOnly
                                  ? AppIcons.checkboxBlank
                                  : AppIcons.searchEmpty,
                              size: 48,
                              color: AppColors.textMuted(context),
                            ),
                            AppSpacing.verticalMd,
                            Text(
                              currentTab == AppViewTab.selectedOnly
                                  ? 'no_selected_apps'.tr
                                  : 'no_apps_found'.tr,
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
                  : ListView.builder(
                      itemCount: visibleApps.length,
                      itemBuilder: (context, index) {
                        final app = visibleApps[index];
                        final isSelected =
                            controller.selectedPackages.contains(app.packageName);

                        return AppFilterItemTile(
                          app: app,
                          isSelected: isSelected,
                          onChanged: (_) =>
                              controller.togglePackage(app.packageName),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }
}
