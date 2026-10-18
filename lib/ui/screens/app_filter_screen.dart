import 'package:flutter/material.dart';
import '../../services/vpn_service_manager.dart';

class AppFilterScreen extends StatefulWidget {
  const AppFilterScreen({super.key});

  @override
  State<AppFilterScreen> createState() => _AppFilterScreenState();
}

class _AppFilterScreenState extends State<AppFilterScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _hideSystemApps = true;

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
          IconButton(
            icon: Icon(_hideSystemApps ? Icons.visibility_off_rounded : Icons.visibility_rounded),
            tooltip: _hideSystemApps ? 'إظهار تطبيقات النظام' : 'إخفاء تطبيقات النظام',
            onPressed: () {
              setState(() {
                _hideSystemApps = !_hideSystemApps;
              });
            },
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
          final filteredApps = allApps.where((app) {
            if (_hideSystemApps && app.isSystemApp) return false;
            if (_searchController.text.isNotEmpty) {
              final query = _searchController.text.toLowerCase();
              return app.appName.toLowerCase().contains(query) ||
                  app.packageName.toLowerCase().contains(query);
            }
            return true;
          }).toList();

          final selectedCount = manager.selectedPackages.length;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'بحث باسم التطبيق أو الحزمة...',
                        prefixIcon: const Icon(Icons.search_rounded),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedCount == 0
                              ? 'الوضع الحالي: مراقبة كافة التطبيقات'
                              : 'المحدد: $selectedCount تطبيق',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: selectedCount == 0
                                ? theme.colorScheme.primary
                                : Colors.green,
                          ),
                        ),
                        if (selectedCount > 0)
                          TextButton(
                            onPressed: () => manager.clearPackageSelection(),
                            child: const Text('إلغاء التحديد'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredApps.isEmpty
                    ? const Center(child: Text('لا توجد تطبيقات مطابقة للبحث'))
                    : ListView.builder(
                        itemCount: filteredApps.length,
                        itemBuilder: (context, index) {
                          final app = filteredApps[index];
                          final isSelected = manager.selectedPackages.contains(app.packageName);

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
                            subtitle: Text(
                              app.packageName,
                              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
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
}
