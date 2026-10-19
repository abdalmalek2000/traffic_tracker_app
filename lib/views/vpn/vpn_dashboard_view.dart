import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../constants/icons.dart';
import '../../controllers/vpn_controller.dart';
import '../../models/captured_connection.dart';
import '../../theme/app_colors.dart';
import 'app_filter_view.dart';
import 'connection_detail_view.dart';

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

  void _showPcapExportDialog(String? pcapPath) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(AppIcons.file, color: AppColors.protocolHttp),
            const SizedBox(width: 8),
            Text('pcap_export_title'.tr),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'pcap_export_desc'.tr,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                pcapPath ?? 'No capture session active',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('close'.tr),
          ),
          if (pcapPath != null)
            FilledButton.icon(
              icon: const Icon(AppIcons.copy, size: 16),
              label: Text('copy_file_path'.tr),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: pcapPath));
                Get.back();
                Get.rawSnackbar(
                  message: 'copied_to_clipboard'.tr,
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
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/app_logo.png',
                width: 26,
                height: 26,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            Text('system_vpn_title'.tr),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.filter),
            tooltip: 'select_target_apps'.tr,
            onPressed: () => Get.to(() => const AppFilterView()),
          ),
          IconButton(
            icon: const Icon(AppIcons.pcapExport),
            tooltip: 'pcap_export_title'.tr,
            onPressed: () => _showPcapExportDialog(controller.currentPcapPath.value),
          ),
          IconButton(
            icon: const Icon(AppIcons.delete),
            tooltip: 'clear_records'.tr,
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
            // Top Dashboard Status & Metric Card
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isRunning
                      ? AppColors.statusSuccess.withValues(alpha: 0.6)
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
                          color: isRunning ? AppColors.statusSuccess : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isRunning ? 'vpn_active'.tr : 'vpn_stopped'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isRunning ? AppColors.statusSuccess : Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      // Target Apps Pill button
                      InkWell(
                        onTap: () => Get.to(() => const AppFilterView()),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(AppIcons.apps,
                                  size: 14, color: theme.colorScheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                selectedCount == 0
                                    ? 'all_apps'.tr
                                    : 'target_apps_selected'.trParams({'count': '$selectedCount'}),
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

                  // Metrics Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetric(
                        context,
                        title: 'packets_captured'.tr,
                        value: '${controller.totalPackets.value}',
                        icon: AppIcons.layers,
                      ),
                      _buildMetric(
                        context,
                        title: 'data_volume'.tr,
                        value: controller.formattedTotalBytes,
                        icon: AppIcons.dataUsage,
                      ),
                      _buildMetric(
                        context,
                        title: 'live_connections'.tr,
                        value: '${filteredList.length}',
                        icon: AppIcons.connections,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Big Toggle Button
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: isRunning
                            ? AppColors.statusServerError
                            : theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => controller.toggleVpn(),
                      icon: Icon(isRunning ? AppIcons.stop : AppIcons.play),
                      label: Text(
                        isRunning ? 'stop_inspection'.tr : 'start_inspection'.tr,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Target Mode Active Notice Banner (if apps are selected)
            if (selectedCount > 0)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.statusSuccess.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.statusSuccess.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(AppIcons.filterActive,
                        size: 18, color: AppColors.statusSuccess),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'target_mode_active_banner'.trParams({'count': '$selectedCount'}),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.statusSuccess,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Get.to(() => const AppFilterView()),
                      child: Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
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
                  hintText: 'search_vpn_hint'.tr,
                  prefixIcon: const Icon(AppIcons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(AppIcons.clear, size: 18),
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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${'live_connections'.tr} (${filteredList.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  if (selectedCount > 0)
                    FilterChip(
                      label: Text(
                        'mode_target_only'.tr,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: controller.filterBySelectedAppsOnly.value
                              ? Colors.white
                              : null,
                        ),
                      ),
                      selected: controller.filterBySelectedAppsOnly.value,
                      selectedColor: AppColors.statusSuccess,
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
                            color: AppColors.statusSuccess,
                          ),
                        ),
                        const SizedBox(width: 4),
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

            // Live Connection List
            Expanded(
              child: filteredList.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              AppIcons.vpnSecurity,
                              size: 54,
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isRunning
                                  ? (_searchController.text.isNotEmpty
                                      ? 'no_connections_search'.trParams({'query': _searchController.text})
                                      : 'no_connections_active'.tr)
                                  : 'no_connections_idle'.tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
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
    // Protocol badge uses theme-independent AppColors
    final protocolColor = AppColors.getProtocolColor(item.protocol);

    return InkWell(
      onTap: () {
        ConnectionDetailView.show(item);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Theme-independent vibrant Protocol Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: protocolColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.protocol,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10.5,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // App Name Badge, Primary Host, and Intuitive Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (item.appName != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: AppColors.protocolHttp.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.appName!,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.protocolHttp,
                            ),
                          ),
                        ),
                      ],
                      Expanded(
                        child: Text(
                          item.primaryTitle,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Clear, intuitive destination & service subtitle
                  Text(
                    item.readableSubtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Packet size & formatted time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.formattedSize,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
                Text(
                  item.formattedTime,
                  style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(AppIcons.chevronRight, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
