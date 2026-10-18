import 'traffic_record.dart';

class CapturedConnection {
  final String id;
  final DateTime timestamp;
  final String protocol;
  final String srcIp;
  final int srcPort;
  final String dstIp;
  final int dstPort;
  final String? domain;
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
    required this.length,
  });

  String get displayName => domain ?? '$dstIp:$dstPort';

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
      length: map['length'] as int? ?? 0,
    );
  }
}
