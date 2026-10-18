import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/vpn_controller.dart';
import '../../models/captured_connection.dart';
import 'app_filter_view.dart';

/// شاشة لوحة تحكم ومراقبة شبكة الجهاز بالكامل (System VPN Dashboard)
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

  static Color getProtocolColor(String protocol) {
    switch (protocol.toUpperCase()) {
      case 'TLS/HTTPS':
        return const Color(0xFF8B5CF6);
      case 'HTTP':
        return const Color(0xFF3B82F6);
      case 'DNS':
        return const Color(0xFFF59E0B);
      case 'TCP':
        return const Color(0xFF10B981);
      case 'UDP':
        return const Color(0xFF06B6D4);
      default:
        return const Color(0xFF6B7280);
    }
  }

  void _showPcapExportDialog(String? pcapPath) {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.file_present_rounded, color: Colors.blue),
            SizedBox(width: 8),
            Text('ملف تسجيل الحزم PCAP'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تم تسجيل كافة الحزم في ملف PCAP قياسي متوافق مع برنامج Wireshark:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                pcapPath ?? 'لم يتم بدء أي جلسة بعد',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إغلاق'),
          ),
          if (pcapPath != null)
            FilledButton.icon(
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('نسخ مسار الملف'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: pcapPath));
                Get.back();
                Get.rawSnackbar(
                  message: 'تم نسخ مسار ملف PCAP إلى الحافظة',
                  duration: const Duration(seconds: 1),
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('مراقب شبكة الجهاز (System VPN)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'تحديد التطبيقات المستهدفة',
            onPressed: () => Get.to(() => const AppFilterView()),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'تصدير ملف PCAP',
            onPressed: () => _showPcapExportDialog(controller.currentPcapPath.value),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'مسح السجل',
            onPressed: () => controller.clearConnections(),
          ),
        ],
      ),
      body: Obx(() {
        final isRunning = controller.isVpnRunning.value;
        final filteredList = controller.filteredConnections;
        final selectedCount = controller.selectedPackages.length;

        return Column(
          children: [
            // Top Dashboard Status Card
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: isRunning
                      ? Colors.green.withValues(alpha: 0.5)
                      : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  width: isRunning ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isRunning ? Colors.green : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isRunning ? 'المراقبة نشطة (VPN يعمل)' : 'المراقبة متوقفة',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isRunning ? Colors.green : Colors.grey.shade700,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => Get.to(() => const AppFilterView()),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.apps_rounded,
                                  size: 14, color: theme.colorScheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                selectedCount == 0
                                    ? 'كافة التطبيقات'
                                    : '$selectedCount تطبيقات محددة',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetric(
                        context,
                        title: 'الحزم الملتقطة',
                        value: '${controller.totalPackets.value}',
                        icon: Icons.layers_rounded,
                      ),
                      _buildMetric(
                        context,
                        title: 'حجم البيانات',
                        value: controller.formattedTotalBytes,
                        icon: Icons.data_usage_rounded,
                      ),
                      _buildMetric(
                        context,
                        title: 'المعروض حالياً',
                        value: '${filteredList.length}',
                        icon: Icons.hub_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            isRunning ? Colors.red.shade600 : const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => controller.toggleVpn(),
                      icon: Icon(isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded),
                      label: Text(
                        isRunning
                            ? 'إيقاف فحص الشبكة'
                            : 'بدء فحص حركة تطبيقات الجهاز',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar in Dashboard
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'بحث بالنطاق، الـ IP، اسم التطبيق، أو المنفذ...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            controller.setSearchQuery('');
                            setState(() {});
                          },
                        )
                      : null,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                ),
                onChanged: (val) {
                  controller.setSearchQuery(val);
                  setState(() {});
                },
              ),
            ),

            // Filter toggles & Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الاتصالات (${filteredList.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  if (selectedCount > 0)
                    FilterChip(
                      label: Text(
                        'التطبيقات المحددة فقط ($selectedCount)',
                        style: TextStyle(
                          fontSize: 11,
                          color: controller.filterBySelectedAppsOnly.value
                              ? Colors.white
                              : null,
                        ),
                      ),
                      selected: controller.filterBySelectedAppsOnly.value,
                      selectedColor: Colors.green,
                      checkmarkColor: Colors.white,
                      onSelected: (val) => controller.setFilterBySelectedAppsOnly(val),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  if (isRunning)
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('بث حي',
                            style: TextStyle(fontSize: 11, color: Colors.green)),
                      ],
                    ),
                ],
              ),
            ),

            // Connection List
            Expanded(
              child: filteredList.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.security_rounded,
                              size: 54,
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isRunning
                                  ? (_searchController.text.isNotEmpty
                                      ? 'لا توجد اتصالات تطابق البحث "${_searchController.text}"'
                                      : 'المراقبة تعمل بنشاط، افتح أي تطبيق على جهازك لتبدأ حزم الشبكة بالظهور هنا!')
                                  : 'اضغط على "بدء فحص حركة تطبيقات الجهاز" أعلاه للبدء بالتقاط حزم الـ IP والـ TLS والـ DNS.',
                              textAlign: TextAlign.center,
                              style:
                                  const TextStyle(color: Colors.grey, fontSize: 13),
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
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        return _buildConnectionTile(context, item);
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMetric(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildConnectionTile(BuildContext context, CapturedConnection item) {
    final protocolColor = getProtocolColor(item.protocol);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: protocolColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: protocolColor.withValues(alpha: 0.5)),
            ),
            child: Text(
              item.protocol,
              style: TextStyle(
                color: protocolColor,
                fontWeight: FontWeight.bold,
                fontSize: 10.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (item.appName != null) ...[
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        margin: const EdgeInsets.only(left: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.appName!,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                    Expanded(
                      child: Text(
                        item.displayName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.srcIp}:${item.srcPort} ➔ ${item.dstIp}:${item.dstPort}',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.formattedSize,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
              ),
              Text(
                '${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}:${item.timestamp.second.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
