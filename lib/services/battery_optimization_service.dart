import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service interfacing with the native Android platform to query
/// and request battery optimization exemption (Doze bypass).
class BatteryOptimizationService {
  BatteryOptimizationService._();

  static const MethodChannel _channel =
      MethodChannel('traffic_tracker/battery_optimization');

  /// Check whether battery optimization is currently ignored for this app.
  /// Returns `true` if unrestricted / not optimized.
  /// Returns `false` if optimized / restricted.
  static Future<bool> isIgnoringBatteryOptimizations() async {
    if (kIsWeb) return false;
    try {
      final isIgnoring =
          await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations');
      return isIgnoring ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Request battery optimization exemption via native system dialog
  /// or navigate to system battery optimization settings screen.
  static Future<bool> requestIgnoreBatteryOptimization() async {
    if (kIsWeb) return false;
    try {
      final result =
          await _channel.invokeMethod<bool>('requestIgnoreBatteryOptimization');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}
