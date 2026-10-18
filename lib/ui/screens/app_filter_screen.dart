import 'package:flutter/material.dart';
import '../../services/vpn_service_manager.dart';

enum AppViewTab {
  all,
  selectedOnly,
  userApps,
  systemApps,
}

class AppFilterScreen extends StatefulWidget {
  const AppFilterScreen({super.key});

  @override
  State<AppFilterScreen> createState() => _AppFilterScreenState();
}

class _AppFilterScreenState extends State<AppFilterScreen> {
  final TextEditingController _searchController = TextEditingController();
  AppViewTab _currentTab = AppViewTab.all;

  @override
  void initState() {
    super.initState();
    final manager = VpnServiceManager.instance;
    if (manager.installedApps.isEmpty) {
      manager.loadInstalledApps();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manager = VpnServiceManager.instance;
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
                manager.clearPackageSelection();
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
      body: ListenableBuilder(
        listenable: manager,
        builder: (context, _) {
          if (manager.isLoadingApps) {
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

          final allApps = manager.installedApps;
          final selectedSet = manager.selectedPackages;

          // 1. Filter by active category tab
          final tabFilteredApps = allApps.where((app) {
            switch (_currentTab) {
              case AppViewTab.all:
                return true;
              case AppViewTab.selectedOnly:
                return selectedSet.contains(app.packageName);
              case AppViewTab.userApps:
                return !app.isSystemApp;
              case AppViewTab.systemApps:
                return app.isSystemApp;
            }
          }).toList();

          // 2. Filter by search query within the active category
          final query = _searchController.text.trim().toLowerCase();
          final visibleApps = tabFilteredApps.where((app) {
            if (query.isEmpty) return true;
            return app.appName.toLowerCase().contains(query) ||
                app.packageName.toLowerCase().contains(query);
          }).toList();

          final selectedCount = selectedSet.length;

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
                        hintText: _currentTab == AppViewTab.selectedOnly
                            ? 'بحث داخل التطبيقات المحددة فقط ($selectedCount)...'
                            : 'بحث باسم التطبيق أو الحزمة...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
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
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),

                    // Filter Chips (All, Selected Only, User Apps, System Apps)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'الكل (${allApps.length})',
                            isSelected: _currentTab == AppViewTab.all,
                            onSelected: () => setState(() => _currentTab = AppViewTab.all),
                          ),
                          const SizedBox(width: 6),
                          _buildFilterChip(
                            label: 'المحددة فقط ($selectedCount)',
                            color: Colors.green,
                            isSelected: _currentTab == AppViewTab.selectedOnly,
                            onSelected: () =>
                                setState(() => _currentTab = AppViewTab.selectedOnly),
                          ),
                          const SizedBox(width: 6),
                          _buildFilterChip(
                            label: 'تطبيقات المستخدم',
                            isSelected: _currentTab == AppViewTab.userApps,
                            onSelected: () =>
                                setState(() => _currentTab = AppViewTab.userApps),
                          ),
                          const SizedBox(width: 6),
                          _buildFilterChip(
                            label: 'تطبيقات النظام',
                            isSelected: _currentTab == AppViewTab.systemApps,
                            onSelected: () =>
                                setState(() => _currentTab = AppViewTab.systemApps),
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
                        if (visibleApps.isNotEmpty && _currentTab != AppViewTab.selectedOnly)
                          TextButton(
                            onPressed: () {
                              final visiblePkgs = visibleApps.map((a) => a.packageName);
                              final allSelected = visiblePkgs.every((p) => selectedSet.contains(p));
                              if (allSelected) {
                                for (final p in visiblePkgs) {
                                  manager.togglePackageSelection(p);
                                }
                              } else {
                                manager.selectAllPackages(visiblePkgs);
                              }
                            },
                            child: Text(
                              visibleApps.every((a) => selectedSet.contains(a.packageName))
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
              if (manager.isVpnRunning)
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
                          style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
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
                                _currentTab == AppViewTab.selectedOnly
                                    ? Icons.check_box_outline_blank_rounded
                                    : Icons.search_off_rounded,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _currentTab == AppViewTab.selectedOnly
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
                          final isSelected = selectedSet.contains(app.packageName);

                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (_) => manager.togglePackageSelection(app.packageName),
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
                                : const Icon(Icons.android_rounded, size: 36, color: Colors.green),
                            title: Text(
                              app.appName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Row(
                              children: [
                                if (app.isSystemApp)
                                  Container(
                                    margin: const EdgeInsets.only(left: 6),
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'نظام',
                                      style: TextStyle(fontSize: 9.5, color: Colors.grey),
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    app.packageName,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
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
        },
      ),
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
