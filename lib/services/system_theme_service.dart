import 'package:flutter/services.dart';

/// Lightweight native service to extract Android 12+ (Material You) system accent colors
/// without requiring third-party plugins or external Gradle dependencies.
class SystemThemeService {
  SystemThemeService._();

  static const MethodChannel _channel = MethodChannel('traffic_tracker/system_theme');

  /// Queries the native system accent color extracted from the user's wallpaper/device theme.
  /// Returns `null` on older Android versions or unsupported platforms.
  static Future<Color?> getDynamicAccentColor() async {
    try {
      final int? colorInt = await _channel.invokeMethod<int>('getDynamicAccentColor');
      if (colorInt != null) {
        return Color(colorInt);
      }
    } catch (_) {
      // Gracefully ignored on non-Android or older devices
    }
    return null;
  }
}
