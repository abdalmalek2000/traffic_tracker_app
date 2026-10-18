import 'traffic_record.dart';

/// نموذج اتصال شبكي تم التقاطه عبر خدمة VpnService
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

  String get displayName {
    if (domain != null && domain!.isNotEmpty) return domain!;
    return '$dstIp:$dstPort';
  }

  String get formattedSize => TrafficRecord.formatBytes(length);

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
