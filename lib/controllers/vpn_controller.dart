import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/app_info.dart';
import '../models/captured_connection.dart';
import '../models/traffic_record.dart';
import '../services/vpn_native_bridge.dart';

/// تبويبات تصنيف تطبيقات الجهاز في شاشة الاختيار
enum AppViewTab {
  all,
  selectedOnly,
  userApps,
  systemApps,
}

/// متحكم خدمة مراقبة شبكة الجهاز بالكامل (System VPN Controller)
class VpnController extends GetxController {
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
  final Rx<AppViewTab> currentAppTab = AppViewTab.all.obs;
  final RxString appSearchQuery = ''.obs;

  StreamSubscription? _eventSubscription;

  String get formattedTotalBytes => TrafficRecord.formatBytes(totalBytes.value);

  /// قائمة الاتصالات الحية المفلترة بحسب البحث والتطبيقات المحددة
  List<CapturedConnection> get filteredConnections {
    final query = searchQuery.value.trim().toLowerCase();
    final onlySelected = filterBySelectedAppsOnly.value || selectedPackages.isNotEmpty;

    return connections.where((conn) {
      // 1. تصفية بحسب التطبيقات المحددة
      if (onlySelected && selectedPackages.isNotEmpty) {
        if (conn.packageName != null && !selectedPackages.contains(conn.packageName)) {
          return false;
        }
      }

      // 2. تصفية بحسب نص البحث
      if (query.isNotEmpty) {
        final matchesDomain = conn.domain?.toLowerCase().contains(query) ?? false;
        final matchesDstIp = conn.dstIp.toLowerCase().contains(query);
        final matchesSrcIp = conn.srcIp.toLowerCase().contains(query);
        final matchesApp = conn.appName?.toLowerCase().contains(query) ?? false;
        final matchesPkg = conn.packageName?.toLowerCase().contains(query) ?? false;
        final matchesProto = conn.protocol.toLowerCase().contains(query);
        final matchesPort = conn.dstPort.toString().contains(query) ||
            conn.srcPort.toString().contains(query);

        return matchesDomain ||
            matchesDstIp ||
            matchesSrcIp ||
            matchesApp ||
            matchesPkg ||
            matchesProto ||
            matchesPort;
      }

      return true;
    }).toList();
  }

  /// قائمة التطبيقات المفلترة في شاشة اختيار التطبيقات
  List<AppInfo> get visibleApps {
    final query = appSearchQuery.value.trim().toLowerCase();
    final tab = currentAppTab.value;

    return installedApps.where((app) {
      // 1. التصفية بحسب التبويب المحدد
      switch (tab) {
        case AppViewTab.all:
          break;
        case AppViewTab.selectedOnly:
          if (!selectedPackages.contains(app.packageName)) return false;
          break;
        case AppViewTab.userApps:
          if (app.isSystemApp) return false;
          break;
        case AppViewTab.systemApps:
          if (!app.isSystemApp) return false;
          break;
      }

      // 2. التصفية بنص البحث داخل التبويب
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
    _initStream();
    checkStatus();
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
              totalPackets.value = event['totalPackets'] as int? ?? (totalPackets.value + 1);
              totalBytes.value = event['totalBytes'] as int? ?? (totalBytes.value + conn.length);
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
    isVpnRunning.value = await VpnNativeBridge.isVpnRunning();
    currentPcapPath.value = await VpnNativeBridge.getPcapPath();
  }

  Future<bool> startVpn() async {
    final allowed = selectedPackages.isNotEmpty ? selectedPackages.toList() : null;
    final success = await VpnNativeBridge.startVpn(allowedPackages: allowed);
    isVpnRunning.value = success;
    return success;
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
        installedApps.value = rawApps.map((a) => AppInfo.fromMap(a as Map)).toList();
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
    final allowed = selectedPackages.isNotEmpty ? selectedPackages.toList() : null;
    VpnNativeBridge.updateAllowedPackages(allowed);
  }

  void clearConnections() {
    connections.clear();
    totalPackets.value = 0;
    totalBytes.value = 0;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setFilterBySelectedAppsOnly(bool value) {
    filterBySelectedAppsOnly.value = value;
  }

  void setAppTab(AppViewTab tab) {
    currentAppTab.value = tab;
  }

  void setAppSearchQuery(String query) {
    appSearchQuery.value = query;
  }

  @override
  void onClose() {
    _eventSubscription?.cancel();
    super.onClose();
  }
}
