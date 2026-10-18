import 'traffic_record.dart';

/// Represents a network packet connection intercepted via Android VpnService.
class CapturedConnection {
  final String id;
  final DateTime timestamp;
  final String protocol;
  final String srcIp;
  final int srcPort;
  final String dstIp;
  final int dstPort;
  final String? domain;
  final String? packageName;
  final String? appName;
  final int length;

  CapturedConnection({
    required this.id,
    required this.timestamp,
    required this.protocol,
    required this.srcIp,
    required this.srcPort,
    required this.dstIp,
    required this.dstPort,
    this.domain,
    this.packageName,
    this.appName,
    required this.length,
  });

  /// The primary host / domain name or destination IP if domain is unresolved.
  String get primaryTitle {
    if (domain != null && domain!.trim().isNotEmpty) {
      return domain!.trim();
    }
    return dstIp;
  }

  /// Display name alias for primaryTitle
  String get displayName => primaryTitle;

  /// Human-readable service description based on destination port.
  String get serviceName {
    switch (dstPort) {
      case 443:
        return 'HTTPS (Port 443)';
      case 80:
        return 'HTTP (Port 80)';
      case 53:
        return 'DNS Lookup (Port 53)';
      case 853:
        return 'DNS-over-TLS (Port 853)';
      case 5228:
      case 5229:
      case 5230:
        return 'Google Services (Port $dstPort)';
      case 123:
        return 'NTP Time (Port 123)';
      default:
        return '$protocol (Port $dstPort)';
    }
  }

  /// Clean, intuitive subtitle for list item display (e.g. "To 142.250.180.46 • HTTPS (Port 443)")
  String get readableSubtitle {
    return 'To $dstIp • $serviceName';
  }

  /// Formatted packet size (e.g. "1.4 KB")
  String get formattedSize => TrafficRecord.formatBytes(length);

  /// Formatted time string (HH:mm:ss)
  String get formattedTime {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  factory CapturedConnection.fromMap(Map<dynamic, dynamic> map) {
    final ts = map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch;
    return CapturedConnection(
      id: '${ts}_${map['srcPort']}_${map['dstPort']}',
      timestamp: DateTime.fromMillisecondsSinceEpoch(ts),
      protocol: map['protocol'] as String? ?? 'IP',
      srcIp: map['srcIp'] as String? ?? '',
      srcPort: map['srcPort'] as int? ?? 0,
      dstIp: map['dstIp'] as String? ?? '',
      dstPort: map['dstPort'] as int? ?? 0,
      domain: map['domain'] as String?,
      packageName: map['packageName'] as String?,
      appName: map['appName'] as String?,
      length: map['length'] as int? ?? 0,
    );
  }
}
