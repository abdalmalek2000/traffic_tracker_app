import 'package:flutter/material.dart';

/// Centralized application color palette.
/// Easily extendable for additional custom palettes in the future.
class AppColors {
  AppColors._();

  // ==========================================
  // LIGHT THEME PALETTE
  // ==========================================
  static const Color lightBackground = Color(0xFFF5F3F4);
  static const Color lightPrimary = Color(0xFF2C4829);
  static const Color lightSecondary = Color(0xFFF1E4D3);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1E1F1E);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightBorder = Color(0xFFE5E7EB);

  // ==========================================
  // DARK THEME PALETTE
  // ==========================================
  static const Color darkBackground = Color(0xFF1E1F1E);
  static const Color darkPrimary = Color(0xFF87A481);
  static const Color darkSecondary = Color(0xFFF1E4D3);
  static const Color darkSurface = Color(0xFF262826);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkBorder = Color(0xFF374151);

  // ==========================================
  // PROTOCOL BADGES (Theme-Independent Constants)
  // Preserves vibrant, distinct contrast in both Light and Dark modes.
  // ==========================================
  static const Color protocolTls = Color(0xFF8B5CF6); // Purple (TLS/HTTPS)
  static const Color protocolHttp = Color(0xFF3B82F6); // Blue (HTTP)
  static const Color protocolDns = Color(0xFFF59E0B); // Amber (DNS)
  static const Color protocolTcp = Color(0xFF10B981); // Emerald (TCP)
  static const Color protocolUdp = Color(0xFF06B6D4); // Cyan (UDP)
  static const Color protocolOther = Color(0xFF6B7280); // Grey (Other/IP)

  // ==========================================
  // STATUS BADGES (Theme-Independent Constants)
  // ==========================================
  static const Color statusSuccess = Color(0xFF2ECC71); // 2xx Green
  static const Color statusRedirect = Color(0xFF3498DB); // 3xx Blue
  static const Color statusClientError = Color(0xFFE67E22); // 4xx Orange
  static const Color statusServerError = Color(0xFFE74C3C); // 5xx Red
  static const Color statusPending = Color(0xFFF1C40F); // Pending Amber

  /// Helper to get the designated badge color for any protocol name.
  static Color getProtocolColor(String protocol) {
    switch (protocol.toUpperCase()) {
      case 'TLS/HTTPS':
      case 'HTTPS':
      case 'TLS':
        return protocolTls;
      case 'HTTP':
        return protocolHttp;
      case 'DNS':
        return protocolDns;
      case 'TCP':
        return protocolTcp;
      case 'UDP':
        return protocolUdp;
      default:
        return protocolOther;
    }
  }

  /// Helper to get HTTP status category color.
  static Color getStatusCategoryColor(int? statusCode, {bool isPending = false}) {
    if (isPending) return statusPending;
    final code = statusCode ?? 0;
    if (code >= 200 && code < 300) return statusSuccess;
    if (code >= 300 && code < 400) return statusRedirect;
    if (code >= 400 && code < 500) return statusClientError;
    if (code >= 500) return statusServerError;
    return statusServerError;
  }
}
