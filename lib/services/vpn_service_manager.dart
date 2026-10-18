import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../core/models/app_info.dart';
import '../core/models/captured_connection.dart';
import '../core/models/traffic_record.dart';

class VpnServiceManager extends ChangeNotifier {
  VpnServiceManager._internal() {
    _initStream();
    checkVpnStatus();
  }
  static final VpnServiceManager instance = VpnServiceManager._internal();

  static const MethodChannel _controlChannel = MethodChannel('traffic_tracker/vpn_control');
  static const EventChannel _streamChannel = EventChannel('traffic_tracker/vpn_stream');

  bool _isVpnRunning = false;
  String? _currentPcapPath;
  int _totalPackets = 0;
  int _totalBytes = 0;
  final List<CapturedConnection> _connections = [];
  final Set<String> _selectedPackages = {};
  List<AppInfo> _installedApps = [];
  bool _isLoadingApps = false;

  bool get isVpnRunning => _isVpnRunning;
  String? get currentPcapPath => _currentPcapPath;
  int get totalPackets => _totalPackets;
  int get totalBytes => _totalBytes;
  List<CapturedConnection> get connections => List.unmodifiable(_connections);
  Set<String> get selectedPackages => _selectedPackages;
  List<AppInfo> get installedApps => _installedApps;
  bool get isLoadingApps => _isLoadingApps;

  String get formattedTotalBytes => TrafficRecord.formatBytes(_totalBytes);

  StreamSubscription? _subscription;

  void _initStream() {
    try {
      _subscription = _streamChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          if (event is Map) {
            final type = event['type'] as String?;
            if (type == 'STATUS_CHANGED') {
              _isVpnRunning = event['isRunning'] as bool? ?? false;
              _currentPcapPath = event['pcapPath'] as String?;
              notifyListeners();
            } else if (type == 'PACKET') {
              final conn = CapturedConnection.fromMap(event);
              _connections.insert(0, conn);
              if (_connections.length > 500) {
                _connections.removeLast();
              }
              _totalPackets = event['totalPackets'] as int? ?? _totalPackets + 1;
              _totalBytes = event['totalBytes'] as int? ?? _totalBytes + conn.length;
              notifyListeners();
            }
          }
        },
        onError: (dynamic error) {
          debugPrint('VPN Event stream error: $error');
        },
      );
    } catch (e) {
      debugPrint('Failed to initialize VPN event stream: $e');
    }
  }

  Future<void> checkVpnStatus() async {
    try {
      final running = await _controlChannel.invokeMethod<bool>('isVpnRunning');
      _isVpnRunning = running ?? false;
      _currentPcapPath = await _controlChannel.invokeMethod<String>('getPcapPath');
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> startVpn() async {
    try {
      final allowed = _selectedPackages.isNotEmpty ? _selectedPackages.toList() : null;
      final result = await _controlChannel.invokeMethod<bool>('startVpn', {
        'allowedPackages': allowed,
      });
      _isVpnRunning = result ?? false;
      notifyListeners();
      return _isVpnRunning;
    } catch (e) {
      debugPrint('Failed to start VPN: $e');
      return false;
    }
  }

  Future<bool> stopVpn() async {
    try {
      final result = await _controlChannel.invokeMethod<bool>('stopVpn');
      _isVpnRunning = false;
      notifyListeners();
      return result ?? true;
    } catch (e) {
      debugPrint('Failed to stop VPN: $e');
      return false;
    }
  }

  Future<List<AppInfo>> loadInstalledApps() async {
    if (_installedApps.isNotEmpty) return _installedApps;
    _isLoadingApps = true;
    notifyListeners();

    try {
      final List<dynamic>? appsData = await _controlChannel.invokeMethod<List<dynamic>>('getInstalledApps');
      if (appsData != null) {
        _installedApps = appsData.map((item) => AppInfo.fromMap(item as Map)).toList();
      }
    } catch (e) {
      debugPrint('Failed to load apps: $e');
    } finally {
      _isLoadingApps = false;
      notifyListeners();
    }
    return _installedApps;
  }

  void togglePackageSelection(String packageName) {
    if (_selectedPackages.contains(packageName)) {
      _selectedPackages.remove(packageName);
    } else {
      _selectedPackages.add(packageName);
    }
    notifyListeners();
  }

  void selectAllPackages(Iterable<String> packageNames) {
    _selectedPackages.addAll(packageNames);
    notifyListeners();
  }

  void clearPackageSelection() {
    _selectedPackages.clear();
    notifyListeners();
  }

  void clearConnections() {
    _connections.clear();
    _totalPackets = 0;
    _totalBytes = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
