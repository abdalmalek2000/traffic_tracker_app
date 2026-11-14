import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import '../../constants/icons.dart';
import '../../constants/spacing.dart';
import '../../controllers/vpn_controller.dart';
import 'package:traffic_tracker_app/shared_views/widgets/app_filter_chip.dart';
import 'package:traffic_tracker_app/shared_views/widgets/app_search_field.dart';
import 'package:traffic_tracker_app/shared_views/vpn/app_filter_item_tile.dart';

/// Target Applications Selector View optimized for Tablet (Multi-column Grid).
class TabletAppFilterView extends StatefulWidget {
  const TabletAppFilterView({super.key});

  @override
  State<TabletAppFilterView> createState() => _TabletAppFilterViewState();
}

class _TabletAppFilterViewState extends State<TabletAppFilterView> {
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
        final currentTab = controller.currentAppTab.value;
        final selectedCount = controller.selectedPackages.length;
        final totalAppsCount = controller.installedApps.length;

        return Column(
          children: [
            // Search Bar & Filter Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Column(
                children: [
                  AppSearchField(
                    controller: _searchController,
                    hintText: currentTab == AppViewTab.selectedOnly
                        ? 'search_selected_hint'.tr
                        : 'search_apps_hint'.tr,
                    padding: EdgeInsets.zero,
                    onChanged: (val) => controller.setAppSearchQuery(val),
                    onClear: () => controller.setAppSearchQuery(''),
                  ),
                  AppSpacing.verticalSm,
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        AppFilterChip(
                          label: 'filter_all_apps'.tr,
                          count: totalAppsCount,
                          isSelected: currentTab == AppViewTab.all,
                          onSelected: () => controller.setAppTab(AppViewTab.all),
                        ),
                        AppSpacing.horizontalSm,
                        AppFilterChip(
                          label: 'filter_selected_only'.tr,
                          count: selectedCount,
                          color: AppColors.statusSuccess,
                          isSelected: currentTab == AppViewTab.selectedOnly,
                          onSelected: () =>
                              controller.setAppTab(AppViewTab.selectedOnly),
                        ),
                        AppSpacing.horizontalSm,
                        AppFilterChip(
                          label: 'filter_user_apps'.tr,
                          isSelected: currentTab == AppViewTab.userApps,
                          onSelected: () =>
                              controller.setAppTab(AppViewTab.userApps),
                        ),
                        AppSpacing.horizontalSm,
                        AppFilterChip(
                          label: 'filter_system_apps'.tr,
                          isSelected: currentTab == AppViewTab.systemApps,
                          onSelected: () =>
                              controller.setAppTab(AppViewTab.systemApps),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Selection notification banner
            if (selectedCount > 0)
              Container(
                color: AppColors.statusSuccess.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    const Icon(
                      AppIcons.checkCircle,
                      color: AppColors.statusSuccess,
                      size: AppSpacing.iconSm,
                    ),
                    AppSpacing.horizontalSm,
                    Expanded(
                      child: Text(
                        'apps_selected_banner'.trParams({
                          'count': '$selectedCount',
                        }),
                        style: const TextStyle(
                          color: AppColors.statusSuccess,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => controller.clearSelection(),
                      child: Text('clear'.tr),
                    ),
                  ],
                ),
              ),

            // Responsive Two-column Grid for Tablet
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
                              size: 56,
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
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth > 900 ? 3 : 2;
                        return GridView.builder(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 3.8,
                            crossAxisSpacing: AppSpacing.sm,
                            mainAxisSpacing: AppSpacing.xs,
                          ),
                          itemCount: visibleApps.length,
                          itemBuilder: (context, index) {
                            final app = visibleApps[index];
                            final isSelected = controller.selectedPackages
                                .contains(app.packageName);

                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppSpacing.borderRadiusMd,
                                side: BorderSide(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outlineVariant
                                          .withValues(alpha: 0.3),
                                  width: isSelected ? 1.5 : 0.5,
                                ),
                              ),
                              child: AppFilterItemTile(
                                app: app,
                                isSelected: isSelected,
                                onChanged: (_) =>
                                    controller.togglePackage(app.packageName),
                              ),
                            );
                          },
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
