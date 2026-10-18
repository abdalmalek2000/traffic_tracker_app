import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/vpn_controller.dart';

/// واجهة اختيار وتصفية التطبيقات المستهدفة لمراقبة شبكتها
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
        title: const Text('تحديد التطبيقات المستهدفة'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'خيارات التحديد',
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (val) {
              if (val == 'clear') {
                controller.clearSelection();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all_rounded, color: Colors.red),
                    SizedBox(width: 8),
                    Text('إلغاء تحديد كافة التطبيقات'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingApps.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('جاري فحص وتجهيز قائمة تطبيقات الجهاز...'),
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
                          ? 'بحث داخل التطبيقات المحددة فقط ($selectedCount)...'
                          : 'بحث باسم التطبيق أو الحزمة...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
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
                          label: 'الكل ($totalAppsCount)',
                          isSelected: currentTab == AppViewTab.all,
                          onSelected: () => controller.setAppTab(AppViewTab.all),
                        ),
                        const SizedBox(width: 6),
                        _buildFilterChip(
                          label: 'المحددة فقط ($selectedCount)',
                          color: Colors.green,
                          isSelected: currentTab == AppViewTab.selectedOnly,
                          onSelected: () => controller.setAppTab(AppViewTab.selectedOnly),
                        ),
                        const SizedBox(width: 6),
                        _buildFilterChip(
                          label: 'تطبيقات المستخدم',
                          isSelected: currentTab == AppViewTab.userApps,
                          onSelected: () => controller.setAppTab(AppViewTab.userApps),
                        ),
                        const SizedBox(width: 6),
                        _buildFilterChip(
                          label: 'تطبيقات النظام',
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
                      Text(
                        selectedCount == 0
                            ? 'الوضع: مراقبة حركة كافة التطبيقات'
                            : 'المحدد: $selectedCount تطبيق (يتم حصر المراقبة فيها)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: selectedCount == 0
                              ? theme.colorScheme.primary
                              : Colors.green.shade700,
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
                                ? 'إلغاء المعروض'
                                : 'تحديد كل المعروض (${visibleApps.length})',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Active VPN Notice
            if (controller.isVpnRunning.value)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: Colors.green.withValues(alpha: 0.12),
                child: const Row(
                  children: [
                    Icon(Icons.sync_rounded, size: 16, color: Colors.green),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'المراقبة نشطة: أي تعديل في التحديد يطبّق فورياً على تيار الحزم.',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.green,
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
                                  ? Icons.check_box_outline_blank_rounded
                                  : Icons.search_off_rounded,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              currentTab == AppViewTab.selectedOnly
                                  ? 'لم تقم بتحديد أي تطبيقات بعد.\nاختر تبويب "الكل" وحدد التطبيقات التي ترغب بفحصها.'
                                  : 'لا توجد تطبيقات مطابقة للبحث',
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
                              : const Icon(Icons.android_rounded,
                                  size: 36, color: Colors.green),
                          title: Text(
                            app.appName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Row(
                            children: [
                              if (app.isSystemApp)
                                Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'نظام',
                                    style: TextStyle(
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
