import 'dart:convert';
import 'dart:typed_data';

/// نموذج يمثل تطبيق أندرويد مثبت على الجهاز
class AppInfo {
  final String appName;
  final String packageName;
  final bool isSystemApp;
  final Uint8List? iconBytes;

  AppInfo({
    required this.appName,
    required this.packageName,
    this.isSystemApp = false,
    this.iconBytes,
  });

  factory AppInfo.fromMap(Map<dynamic, dynamic> map) {
    Uint8List? icon;
    final iconBase64 = map['iconBase64'] as String?;
    if (iconBase64 != null && iconBase64.isNotEmpty) {
      try {
        icon = base64Decode(iconBase64);
      } catch (_) {}
    }

    return AppInfo(
      appName: map['appName'] as String? ?? 'Unknown',
      packageName: map['packageName'] as String? ?? '',
      isSystemApp: map['isSystemApp'] as bool? ?? false,
      iconBytes: icon,
    );
  }
}
