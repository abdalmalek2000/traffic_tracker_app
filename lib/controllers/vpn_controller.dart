import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../constants/colors.dart';
import '../constants/icons.dart';
import '../constants/spacing.dart';
import '../models/app_info.dart';
import '../models/captured_connection.dart';
import '../models/traffic_record.dart';
import '../models/vpn_filter_types.dart';
import '../services/vpn_native_bridge.dart';
import 'settings_controller.dart';

export '../models/vpn_filter_types.dart';

/// متحكم خدمة مراقبة شبكة الجهاز بالكامل (System VPN Controller)
class VpnController extends GetxController with WidgetsBindingObserver {
  static VpnController get to => Get.find();

  final RxBool isVpnRunning = false.obs;
  final RxnString currentPcapPath = RxnString();
  final RxInt totalPackets = 0.obs;
  final RxInt totalBytes = 0.obs;
  final RxList<CapturedConnection> connections = <CapturedConnection>[].obs;
  final RxSet<String> selectedPackages = <String>{}.obs;
  final RxList<AppInfo> installedApps = <AppInfo>[].obs;
  final RxBool isLoadingApps = false.obs;

  final RxString searchQuery = ''.obs;
  final RxBool filterBySelectedAppsOnly = false.obs;
  final Rx<VpnTrafficFilter> activeTrafficFilter = VpnTrafficFilter.all.obs;
  final Rx<AppViewTab> currentAppTab = AppViewTab.all.obs;
  final RxString appSearchQuery = ''.obs;

  StreamSubscription? _eventSubscription;

  String get formattedTotalBytes => TrafficRecord.formatBytes(totalBytes.value);

  /// قائمة الاتصالات الحية المفلترة بحسب البحث والتطبيقات المحددة
  List<CapturedConnection> get filteredConnections {
    final query = searchQuery.value.trim().toLowerCase();
    final onlySelected =
        filterBySelectedAppsOnly.value || selectedPackages.isNotEmpty;
    final trafficFilter = activeTrafficFilter.value;

    return connections.where((conn) {
      if (onlySelected &&
          selectedPackages.isNotEmpty &&
          (conn.packageName == null || !selectedPackages.contains(conn.packageName))) {
        return false;
      }
      if (trafficFilter == VpnTrafficFilter.appsOnly && conn.isSystemOrUnattributed) {
        return false;
      }
      if (trafficFilter == VpnTrafficFilter.systemOnly && !conn.isSystemOrUnattributed) {
        return false;
      }
      if (query.isNotEmpty) {
        return (conn.domain?.toLowerCase().contains(query) ?? false) ||
            conn.dstIp.toLowerCase().contains(query) ||
            conn.srcIp.toLowerCase().contains(query) ||
            (conn.appName?.toLowerCase().contains(query) ?? false) ||
            (conn.packageName?.toLowerCase().contains(query) ?? false) ||
            conn.protocol.toLowerCase().contains(query) ||
            conn.dstPort.toString().contains(query) ||
            conn.srcPort.toString().contains(query);
      }
      return true;
    }).toList();
  }

  /// قائمة التطبيقات المفلترة في شاشة اختيار التطبيقات
  List<AppInfo> get visibleApps {
    final query = appSearchQuery.value.trim().toLowerCase();
    final tab = currentAppTab.value;

    return installedApps.where((app) {
      if (tab == AppViewTab.selectedOnly && !selectedPackages.contains(app.packageName)) {
        return false;
      }
      if (tab == AppViewTab.userApps && app.isSystemApp) return false;
      if (tab == AppViewTab.systemApps && !app.isSystemApp) return false;

      if (query.isNotEmpty) {
        return app.appName.toLowerCase().contains(query) ||
            app.packageName.toLowerCase().contains(query);
      }
      return true;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initStream();
    checkStatus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkStatus();
    }
  }

  void _initStream() {
    try {
      _eventSubscription = VpnNativeBridge.vpnEventStream.listen(
        (dynamic event) {
          if (event is Map) {
            final type = event['type'] as String?;
            if (type == 'STATUS_CHANGED') {
              isVpnRunning.value = event['isRunning'] as bool? ?? false;
              currentPcapPath.value = event['pcapPath'] as String?;
            } else if (type == 'PACKET') {
              final conn = CapturedConnection.fromMap(event);
              connections.insert(0, conn);
              if (connections.length > 500) {
                connections.removeLast();
              }
              totalPackets.value =
                  event['totalPackets'] as int? ?? (totalPackets.value + 1);
              totalBytes.value =
                  event['totalBytes'] as int? ?? (totalBytes.value + conn.length);
            }
          }
        },
        onError: (dynamic error) {
          debugPrint('VPN Stream Error: $error');
        },
      );
    } catch (e) {
      debugPrint('Failed to initialize stream: $e');
    }
  }

  Future<void> checkStatus() async {
    final sessionData = await VpnNativeBridge.getVpnSessionData();
    if (sessionData != null) {
      final running = sessionData['isRunning'] as bool? ?? false;
      isVpnRunning.value = running;

      if (running) {
        currentPcapPath.value = sessionData['pcapPath'] as String?;
        totalPackets.value = sessionData['totalPackets'] as int? ?? 0;
        totalBytes.value = sessionData['totalBytes'] as int? ?? 0;

        final rawList = sessionData['connections'] as List<dynamic>? ?? [];
        final loadedConnections = rawList
            .map((c) => CapturedConnection.fromMap(c as Map))
            .toList();

        if (connections.isEmpty) {
          connections.assignAll(loadedConnections);
        } else if (loadedConnections.isNotEmpty) {
          final existingIds = connections.map((c) => c.id).toSet();
          final newConnections = loadedConnections
              .where((c) => !existingIds.contains(c.id))
              .toList();
          if (newConnections.isNotEmpty) {
            connections.insertAll(0, newConnections);
            if (connections.length > 500) {
              connections.removeRange(500, connections.length);
            }
          }
        }
        return;
      }
    } else {
      isVpnRunning.value = await VpnNativeBridge.isVpnRunning();
      if (isVpnRunning.value) {
        currentPcapPath.value = await VpnNativeBridge.getPcapPath();
        return;
      }
    }

    currentPcapPath.value = null;
    if (connections.isEmpty) {
      // If VPN is not active upon opening the app, purge any stale PCAP files
      await VpnNativeBridge.clearPcap();
    }
  }

  void _showNoInternetSnackbar() {
    Get.snackbar(
      'no_internet_title'.tr,
      'no_internet_message'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.statusServerError,
      colorText: Colors.white,
      icon: const Icon(Icons.wifi_off_rounded, color: Colors.white),
      margin: const EdgeInsets.all(AppSpacing.base),
      duration: const Duration(seconds: 4),
    );
  }

  Future<bool> startVpn() async {
    // 1. التحقق المسبق من وجود اتصال نشط بشبكة Wi-Fi أو بيانات الجوال
    final isConnected = await VpnNativeBridge.isNetworkAvailable();
    if (!isConnected) {
      _showNoInternetSnackbar();
      isVpnRunning.value = false;
      return false;
    }

    try {
      final allowed =
          selectedPackages.isNotEmpty ? selectedPackages.toList() : null;
      final success = await VpnNativeBridge.startVpn(allowedPackages: allowed);
      isVpnRunning.value = success;
      return success;
    } on PlatformException catch (e) {
      if (e.code == 'NO_INTERNET') {
        _showNoInternetSnackbar();
      }
      isVpnRunning.value = false;
      return false;
    } catch (_) {
      isVpnRunning.value = false;
      return false;
    }
  }

  Future<bool> stopVpn() async {
    final success = await VpnNativeBridge.stopVpn();
    isVpnRunning.value = false;
    return success;
  }

  void toggleVpn() {
    if (isVpnRunning.value) {
      stopVpn();
    } else {
      startVpn();
    }
  }

  Future<void> loadInstalledApps() async {
    if (installedApps.isNotEmpty) return;
    isLoadingApps.value = true;
    try {
      final rawApps = await VpnNativeBridge.getInstalledApps();
      if (rawApps != null) {
        installedApps.value =
            rawApps.map((a) => AppInfo.fromMap(a as Map)).toList();
      }
    } finally {
      isLoadingApps.value = false;
    }
  }

  void togglePackage(String packageName) {
    if (selectedPackages.contains(packageName)) {
      selectedPackages.remove(packageName);
    } else {
      selectedPackages.add(packageName);
    }
    _syncPackagesToNative();
  }

  void selectAll(Iterable<String> packageNames) {
    selectedPackages.addAll(packageNames);
    _syncPackagesToNative();
  }

  void clearSelection() {
    selectedPackages.clear();
    _syncPackagesToNative();
  }

  void _syncPackagesToNative() {
    final allowed =
        selectedPackages.isNotEmpty ? selectedPackages.toList() : null;
    VpnNativeBridge.updateAllowedPackages(allowed);
  }

  void clearConnections() {
    connections.clear();
    totalPackets.value = 0;
    totalBytes.value = 0;
    currentPcapPath.value = null;
    VpnNativeBridge.clearPcap();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setFilterBySelectedAppsOnly(bool value) {
    filterBySelectedAppsOnly.value = value;
  }

  void setTrafficFilter(VpnTrafficFilter filter) {
    activeTrafficFilter.value = filter;
  }

  void setAppTab(AppViewTab tab) {
    currentAppTab.value = tab;
  }

  void setAppSearchQuery(String query) {
    appSearchQuery.value = query;
  }

  /// تصدير ملف الـ PCAP إلى المكان المحدد في الإعدادات وإظهار رسالة بسيطة بإتمام الحفظ
  Future<void> exportPcapFile() async {
    final settings = SettingsController.to;
    final hasData = connections.isNotEmpty && totalPackets.value > 0;
    final savedPath = hasData
        ? await VpnNativeBridge.exportPcapFile(
            locationType: settings.pcapLocationType.value,
            customUri: settings.customPcapUri.value,
          )
        : null;

    if (savedPath == null || savedPath.isEmpty) {
      Get.rawSnackbar(
        message: 'pcap_no_data'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        margin: const EdgeInsets.all(AppSpacing.base),
        borderRadius: AppSpacing.radiusMd,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    Get.rawSnackbar(
      message: 'pcap_saved_success'.trParams({
        'location': settings.pcapLocationDisplayName,
      }),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.statusSuccess,
      icon: const Icon(AppIcons.checkCircle, color: Colors.white),
      margin: const EdgeInsets.all(AppSpacing.base),
      borderRadius: AppSpacing.radiusMd,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _eventSubscription?.cancel();
    super.onClose();
  }
}
