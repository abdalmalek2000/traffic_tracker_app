import 'dart:async';
import 'package:flutter/services.dart';

/// جسر التواصل المباشر مع طبقة أندرويد الأصلية (Android Native Bridge)
class VpnNativeBridge {
  static const MethodChannel _controlChannel =
      MethodChannel('traffic_tracker/vpn_control');
  static const EventChannel _streamChannel =
      EventChannel('traffic_tracker/vpn_stream');

  /// التحقق من توفر اتصال فعلي بشبكة الإنترنت (Wi-Fi أو بيانات الهاتف)
  static Future<bool> isNetworkAvailable() async {
    try {
      final available =
          await _controlChannel.invokeMethod<bool>('isNetworkAvailable');
      return available ?? false;
    } catch (_) {
      return false;
    }
  }

  /// بدء تشغيل خدمة الـ VPN مع قائمة الحزم المسموحة
  static Future<bool> startVpn({List<String>? allowedPackages}) async {
    try {
      final result = await _controlChannel.invokeMethod<bool>('startVpn', {
        'allowedPackages': allowedPackages,
      });
      return result ?? false;
    } on PlatformException {
      rethrow;
    } catch (_) {
      return false;
    }
  }

  /// إيقاف خدمة الـ VPN
  static Future<bool> stopVpn() async {
    try {
      final result = await _controlChannel.invokeMethod<bool>('stopVpn');
      return result ?? true;
    } catch (_) {
      return false;
    }
  }

  /// التحقق من حالة الـ VPN
  static Future<bool> isVpnRunning() async {
    try {
      final running = await _controlChannel.invokeMethod<bool>('isVpnRunning');
      return running ?? false;
    } catch (_) {
      return false;
    }
  }

  /// جلب مسار ملف الـ PCAP
  static Future<String?> getPcapPath() async {
    try {
      return await _controlChannel.invokeMethod<String>('getPcapPath');
    } catch (_) {
      return null;
    }
  }

  /// تحديث قائمة التطبيقات المسموحة ديناميكياً أثناء تشغيل الـ VPN
  static Future<void> updateAllowedPackages(List<String>? allowedPackages) async {
    try {
      await _controlChannel.invokeMethod('updateAllowedPackages', {
        'allowedPackages': allowedPackages,
      });
    } catch (_) {}
  }

  /// جلب قائمة بكافة تطبيقات الجهاز
  static Future<List<dynamic>?> getInstalledApps() async {
    try {
      return await _controlChannel.invokeMethod<List<dynamic>>('getInstalledApps');
    } catch (_) {
      return null;
    }
  }

  /// الاستماع إلى تيار أحداث الـ VPN المباشرة
  static Stream<dynamic> get vpnEventStream {
    return _streamChannel.receiveBroadcastStream();
  }
}
