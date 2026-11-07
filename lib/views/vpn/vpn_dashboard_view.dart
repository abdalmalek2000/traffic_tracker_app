import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/icons.dart';
import '../../controllers/vpn_controller.dart';
import '../../models/captured_connection.dart';
import '../../constants/colors.dart';
import '../../constants/spacing.dart';
import '../settings/settings_view.dart';
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
                    // Top Dashboard Status & Metric Card
                    Container(
                      margin: const EdgeInsets.fromLTRB(
                        AppSpacing.base,
                        AppSpacing.md,
                        AppSpacing.base,
                        AppSpacing.sm,
                      ),
                      padding: AppSpacing.paddingCard,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: AppSpacing.borderRadiusXl,
                        border: Border.all(
                          color: isRunning
                              ? AppColors.statusSuccess.withValues(alpha: 0.6)
                              : theme.colorScheme.outlineVariant.withValues(
                                  alpha: 0.5,
                                ),
                          width: isRunning ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: AppSpacing.md,
                                height: AppSpacing.md,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isRunning
                                      ? AppColors.statusSuccess
                                      : AppColors.textMuted(context),
                                ),
                              ),
                              AppSpacing.horizontalSm,
                              Expanded(
                                child: Text(
                                  isRunning
                                      ? 'vpn_active'.tr
                                      : 'vpn_stopped'.tr,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isRunning
                                        ? AppColors.statusSuccess
                                        : AppColors.textSecondary(context),
                                  ),
                                ),
                              ),
                              AppSpacing.horizontalSm,
                              // Target Apps Pill button
                              Flexible(
                                child: InkWell(
                                  onTap: () =>
                                      Get.to(() => const AppFilterView()),
                                  borderRadius: AppSpacing.borderRadiusXxl,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.space10,
                                      vertical: AppSpacing.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.secondary
                                          .withValues(alpha: 0.1),
                                      borderRadius: AppSpacing.borderRadiusXxl,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          AppIcons.apps,
                                          size: 14,
                                          color: theme.colorScheme.primary,
                                        ),
                                        AppSpacing.horizontalXs,
                                        Flexible(
                                          child: Text(
                                            selectedCount == 0
                                                ? 'all_apps'.tr
                                                : 'target_apps_selected'.trParams({
                                                    'count': '$selectedCount',
                                                  }),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.vertical14,

                          // Metrics Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: _buildMetric(
                                  context,
                                  title: 'packets_captured'.tr,
                                  value: '${controller.totalPackets.value}',
                                  icon: AppIcons.layers,
                                ),
                              ),
                              Expanded(
                                child: _buildMetric(
                                  context,
                                  title: 'data_volume'.tr,
                                  value: controller.formattedTotalBytes,
                                  icon: AppIcons.dataUsage,
                                ),
                              ),
                              Expanded(
                                child: _buildMetric(
                                  context,
                                  title: 'live_connections'.tr,
                                  value: '${filteredList.length}',
                                  icon: AppIcons.connections,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.vertical14,

                          // Big Toggle Button
                          SizedBox(
                            width: double.infinity,
                            height: AppSpacing.buttonHeight,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: isRunning
                                    ? AppColors.statusServerError
                                    : theme.colorScheme.primary,
                                foregroundColor: isRunning
                                    ? Colors.white
                                    : theme.colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppSpacing.borderRadiusLg,
                                ),
                              ),
                              onPressed: () => controller.toggleVpn(),
                              icon: Icon(
                                isRunning ? AppIcons.stop : AppIcons.play,
                              ),
                              label: Text(
                                isRunning
                                    ? 'stop_inspection'.tr
                                    : 'start_inspection'.tr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Target Mode Active Notice Banner (if apps are selected)
                    if (selectedCount > 0)
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.base,
                          vertical: AppSpacing.xs,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.space14,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.statusSuccess.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: AppSpacing.borderRadiusBase,
                          border: Border.all(
                            color: AppColors.statusSuccess.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              AppIcons.filterActive,
                              size: AppSpacing.iconSm,
                              color: AppColors.statusSuccess,
                            ),
                            AppSpacing.horizontalSm,
                            Expanded(
                              child: Text(
                                'target_mode_active_banner'.trParams({
                                  'count': '$selectedCount',
                                }),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.base,
                        vertical: AppSpacing.xs,
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'search_vpn_hint'.tr,
                          prefixIcon: const Icon(
                            AppIcons.search,
                            size: AppSpacing.iconMd,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    AppIcons.clear,
                                    size: AppSpacing.iconSm,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    controller.setSearchQuery('');
                                    setState(() {});
                                  },
                                )
                              : null,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: AppSpacing.borderRadiusBase,
                            borderSide: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                            ),
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
                          if (selectedCount > 0) ...[
                            AppSpacing.horizontalSm,
                            Flexible(
                              child: FilterChip(
                                label: Text(
                                  'mode_target_only'.tr,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        controller.filterBySelectedAppsOnly.value
                                        ? AppColors.getContrastingColor(AppColors.statusSuccess)
                                        : null,
                                  ),
                                ),
                                selected:
                                    controller.filterBySelectedAppsOnly.value,
                                selectedColor: AppColors.statusSuccess,
                                checkmarkColor: AppColors.getContrastingColor(AppColors.statusSuccess),
                                onSelected: (val) =>
                                    controller.setFilterBySelectedAppsOnly(val),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                              ),
                            ),
                          ],
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
                  ],
                ),
              ),

              // Live Connection List or Empty State
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
                    return _buildConnectionTile(context, item);
                  },
                ),
            ],
          ),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: AppSpacing.iconMd,
          color: Theme.of(context).colorScheme.primary,
        ),
        AppSpacing.verticalXs,
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
        ),
        Text(
          title,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionTile(BuildContext context, CapturedConnection item) {
    // Protocol badge uses theme-independent AppColors
    final protocolColor = AppColors.getProtocolColor(item.protocol);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isNarrow = screenWidth < 360;

    return InkWell(
      onTap: () {
        ConnectionDetailView.show(item);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isNarrow ? AppSpacing.space8 : AppSpacing.base,
          vertical: isNarrow ? AppSpacing.space8 : AppSpacing.space10,
        ),
        child: Row(
          children: [
            // Theme-independent vibrant Protocol Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: protocolColor,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Text(
                item.protocol,
                style: TextStyle(
                  color: AppColors.getContrastingColor(protocolColor),
                  fontWeight: FontWeight.bold,
                  fontSize: 10.5,
                ),
              ),
            ),
            isNarrow ? AppSpacing.horizontalSm : AppSpacing.horizontalMd,

            // App Name Badge, Primary Host, and Intuitive Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (item.appName != null) ...[
                        Flexible(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1.5,
                            ),
                            margin: const EdgeInsetsDirectional.only(
                              end: AppSpacing.space6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.protocolHttp.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: AppSpacing.borderRadiusXs,
                            ),
                            child: Text(
                              item.appName!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.protocolHttp,
                              ),
                            ),
                          ),
                        ),
                      ],
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.primaryTitle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.verticalXxs,
                  // Clear, intuitive destination & service subtitle
                  Text(
                    item.readableSubtitle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            isNarrow ? AppSpacing.horizontalXs : AppSpacing.horizontalSm,

            // Packet size & formatted time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.formattedSize,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  item.formattedTime,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textMuted(context),
                  ),
                ),
              ],
            ),
            AppSpacing.horizontalXs,
            Icon(
              AppIcons.chevronRight,
              size: AppSpacing.iconSm,
              color: AppColors.textMuted(context),
            ),
          ],
        ),
      ),
    );
  }
}
