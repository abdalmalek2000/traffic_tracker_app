import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/icons.dart';
import '../../controllers/vpn_controller.dart';
import '../../theme/app_colors.dart';

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
                    const Icon(AppIcons.deselectAll, color: AppColors.statusServerError),
                    const SizedBox(width: 8),
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
                const SizedBox(height: 16),
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: currentTab == AppViewTab.selectedOnly
                          ? 'search_selected_hint'.tr
                          : 'search_apps_hint'.tr,
                      prefixIcon: const Icon(AppIcons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(AppIcons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                controller.setAppSearchQuery('');
                                setState(() {});
                              },
                            )
                          : null,
                      isDense: true,
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                    ),
                    onChanged: (val) {
                      controller.setAppSearchQuery(val);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 10),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: '${'filter_all_apps'.tr} ($totalAppsCount)',
                          isSelected: currentTab == AppViewTab.all,
                          onSelected: () => controller.setAppTab(AppViewTab.all),
                        ),
                        const SizedBox(width: 6),
                        _buildFilterChip(
                          label: '${'filter_selected_only'.tr} ($selectedCount)',
                          color: AppColors.statusSuccess,
                          isSelected: currentTab == AppViewTab.selectedOnly,
                          onSelected: () => controller.setAppTab(AppViewTab.selectedOnly),
                        ),
                        const SizedBox(width: 6),
                        _buildFilterChip(
                          label: 'filter_user_apps'.tr,
                          isSelected: currentTab == AppViewTab.userApps,
                          onSelected: () => controller.setAppTab(AppViewTab.userApps),
                        ),
                        const SizedBox(width: 6),
                        _buildFilterChip(
                          label: 'filter_system_apps'.tr,
                          isSelected: currentTab == AppViewTab.systemApps,
                          onSelected: () => controller.setAppTab(AppViewTab.systemApps),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Summary & Quick Selection Action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          selectedCount == 0
                              ? 'mode_monitoring_all'.tr
                              : 'mode_monitoring_selected'.trParams({'count': '$selectedCount'}),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: selectedCount == 0
                                ? theme.colorScheme.primary
                                : AppColors.statusSuccess,
                          ),
                        ),
                      ),
                      if (visibleApps.isNotEmpty && currentTab != AppViewTab.selectedOnly)
                        TextButton(
                          onPressed: () {
                            final visiblePkgs = visibleApps.map((a) => a.packageName);
                            final allSelected = visiblePkgs
                                .every((p) => controller.selectedPackages.contains(p));
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
                                    (a) => controller.selectedPackages.contains(a.packageName))
                                ? 'deselect_all_visible'.tr
                                : 'select_all_visible'.trParams({'count': '${visibleApps.length}'}),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Active VPN Live Sync Notice
            if (controller.isVpnRunning.value)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: AppColors.statusSuccess.withValues(alpha: 0.12),
                child: Row(
                  children: [
                    const Icon(AppIcons.sync, size: 16, color: AppColors.statusSuccess),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'live_sync_notice'.tr,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.statusSuccess,
                            fontWeight: FontWeight.bold),
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
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              currentTab == AppViewTab.selectedOnly
                                  ? AppIcons.checkboxBlank
                                  : AppIcons.searchEmpty,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              currentTab == AppViewTab.selectedOnly
                                  ? 'no_selected_apps'.tr
                                  : 'no_apps_found'.tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
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

                        return CheckboxListTile(
                          value: isSelected,
                          activeColor: AppColors.statusSuccess,
                          onChanged: (_) => controller.togglePackage(app.packageName),
                          secondary: app.iconBytes != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    app.iconBytes!,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(AppIcons.android,
                                  size: 36, color: AppColors.statusSuccess),
                          title: Text(
                            app.appName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Row(
                            children: [
                              if (app.isSystemApp)
                                Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'system_badge'.tr,
                                    style: const TextStyle(
                                        fontSize: 9.5, color: Colors.grey),
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  app.packageName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 11.5, color: Colors.grey.shade600),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterChip({
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
}
