import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_tracker_app/core/models/traffic_record.dart';
import 'package:traffic_tracker_app/core/models/captured_connection.dart';
import 'package:traffic_tracker_app/core/models/app_info.dart';
import 'package:traffic_tracker_app/services/traffic_manager.dart';

void main() {
  group('TrafficRecord Unit Tests', () {
    test('Correctly categorizes status codes', () {
      final successRecord = TrafficRecord(
        id: '1',
        timestamp: DateTime.now(),
        url: 'https://api.example.com/data',
        method: 'GET',
        requestHeaders: {},
        statusCode: 200,
        isPending: false,
      );
      expect(successRecord.statusCategory, TrafficStatusCategory.success);

      final clientErrorRecord = TrafficRecord(
        id: '2',
        timestamp: DateTime.now(),
        url: 'https://api.example.com/auth',
        method: 'POST',
        requestHeaders: {},
        statusCode: 401,
        isPending: false,
      );
      expect(clientErrorRecord.statusCategory, TrafficStatusCategory.clientError);

      final serverErrorRecord = TrafficRecord(
        id: '3',
        timestamp: DateTime.now(),
        url: 'https://api.example.com/crash',
        method: 'GET',
        requestHeaders: {},
        statusCode: 503,
        isPending: false,
      );
      expect(serverErrorRecord.statusCategory, TrafficStatusCategory.serverError);
    });

    test('Generates valid cURL command with headers and payload', () {
      final record = TrafficRecord(
        id: '4',
        timestamp: DateTime.now(),
        url: 'https://api.example.com/users',
        method: 'POST',
        requestHeaders: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer token123',
        },
        requestBody: '{"name":"Alice"}',
        isPending: false,
      );

      final curl = record.toCurlCommand();
      expect(curl.contains('curl -X POST "https://api.example.com/users"'), isTrue);
      expect(curl.contains('-H "Content-Type: application/json"'), isTrue);
      expect(curl.contains('-H "Authorization: Bearer token123"'), isTrue);
      expect(curl.contains('--data \'{"name":"Alice"}\''), isTrue);
    });
  });

  group('TrafficManager Tests', () {
    test('Filtering and searching works as expected', () {
      final manager = TrafficManager.instance;
      manager.clearRecords();

      final r1 = TrafficRecord(
        id: 'r1',
        timestamp: DateTime.now(),
        url: 'https://example.com/users',
        method: 'GET',
        requestHeaders: {},
        statusCode: 200,
        isPending: false,
      );

      final r2 = TrafficRecord(
        id: 'r2',
        timestamp: DateTime.now(),
        url: 'https://api.test.com/login',
        method: 'POST',
        requestHeaders: {},
        statusCode: 400,
        isPending: false,
      );

      manager.addRecord(r1);
      manager.addRecord(r2);

      expect(manager.allRecords.length, 2);

      // Search by keyword
      manager.setSearchQuery('users');
      expect(manager.filteredRecords.length, 1);
      expect(manager.filteredRecords.first.id, 'r1');

      // Clear search
      manager.setSearchQuery('');
      expect(manager.filteredRecords.length, 2);

      // Filter by status category
      manager.setActiveFilter(TrafficFilter.clientError);
      expect(manager.filteredRecords.length, 1);
      expect(manager.filteredRecords.first.id, 'r2');

      // Reset filter
      manager.setActiveFilter(TrafficFilter.all);
      expect(manager.filteredRecords.length, 2);
    });
  });

  group('CapturedConnection & AppInfo Tests', () {
    test('CapturedConnection correctly parses map and formats name', () {
      final conn = CapturedConnection.fromMap({
        'timestamp': 1700000000000,
        'protocol': 'TLS/HTTPS',
        'srcIp': '10.0.0.2',
        'srcPort': 52341,
        'dstIp': '142.250.180.46',
        'dstPort': 443,
        'domain': 'google.com',
        'length': 1420,
      });

      expect(conn.protocol, 'TLS/HTTPS');
      expect(conn.domain, 'google.com');
      expect(conn.displayName, 'google.com');
      expect(conn.formattedSize, '1.4 KB');
    });

    test('AppInfo correctly parses map and handles system flag', () {
      final app = AppInfo.fromMap({
        'appName': 'Test Browser',
        'packageName': 'com.test.browser',
        'isSystemApp': false,
      });

      expect(app.appName, 'Test Browser');
      expect(app.packageName, 'com.test.browser');
      expect(app.isSystemApp, isFalse);
    });
  });
}
