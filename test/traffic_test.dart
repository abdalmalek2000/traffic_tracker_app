import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:traffic_tracker_app/models/traffic_record.dart';
import 'package:traffic_tracker_app/models/captured_connection.dart';
import 'package:traffic_tracker_app/models/app_info.dart';
import 'package:traffic_tracker_app/controllers/traffic_controller.dart';
import 'package:traffic_tracker_app/controllers/vpn_controller.dart';

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

  group('TrafficController (GetX) Tests', () {
    test('Filtering and searching works as expected', () {
      final controller = Get.put(TrafficController());
      controller.clearRecords();

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

      controller.addRecord(r1);
      controller.addRecord(r2);

      expect(controller.records.length, 2);

      // Search by keyword
      controller.setSearchQuery('users');
      expect(controller.filteredRecords.length, 1);
      expect(controller.filteredRecords.first.id, 'r1');

      // Clear search
      controller.setSearchQuery('');
      expect(controller.filteredRecords.length, 2);

      // Filter by status category
      controller.setActiveFilter(TrafficFilter.clientError);
      expect(controller.filteredRecords.length, 1);
      expect(controller.filteredRecords.first.id, 'r2');

      // Reset filter
      controller.setActiveFilter(TrafficFilter.all);
      expect(controller.filteredRecords.length, 2);
    });
  });

  group('CapturedConnection & AppInfo Models Tests', () {
    test('CapturedConnection correctly parses map and formats name', () {
      final conn = CapturedConnection.fromMap({
        'timestamp': 1700000000000,
        'protocol': 'TLS/HTTPS',
        'srcIp': '10.0.0.2',
        'srcPort': 52341,
        'dstIp': '142.250.180.46',
        'dstPort': 443,
        'domain': 'google.com',
        'packageName': 'com.android.chrome',
        'appName': 'Chrome',
        'length': 1420,
      });

      expect(conn.protocol, 'TLS/HTTPS');
      expect(conn.domain, 'google.com');
      expect(conn.packageName, 'com.android.chrome');
      expect(conn.appName, 'Chrome');
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

  group('VpnController (GetX) Tests', () {
    test('Package selection and connection filtering work reactively', () {
      final vpnCtrl = Get.put(VpnController());
      vpnCtrl.clearSelection();
      vpnCtrl.clearConnections();

      vpnCtrl.togglePackage('com.whatsapp');
      expect(vpnCtrl.selectedPackages.contains('com.whatsapp'), isTrue);

      vpnCtrl.togglePackage('com.whatsapp');
      expect(vpnCtrl.selectedPackages.contains('com.whatsapp'), isFalse);
    });
  });
}
