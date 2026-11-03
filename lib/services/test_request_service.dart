import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import 'traffic_client.dart';

/// خدمة إرسال طلبات شبكة تجريبية لاختبار عمل المراقبة
class TestRequestService {
  final TrafficHttpClient _client = TrafficHttpClient();

  /// GET Request (200 OK)
  Future<void> sendSampleGet() async {
    try {
      await _client.get(
        Uri.parse(ApiEndpoints.httpbinGet),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'TrafficTracker/1.0',
        },
      );
    } catch (_) {}
  }

  /// POST Request with JSON & Bearer Token (200 OK)
  Future<void> sendSamplePost() async {
    try {
      await _client.post(
        Uri.parse(ApiEndpoints.httpbinPost),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer sample_sec_token_98234',
        },
        body: jsonEncode({
          'title': 'تقرير فحص أمني',
          'body': 'بيانات اختبارية لمراقبة حركة طلبات الشبكة وحزم البيانات',
          'userId': 42,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
    } catch (_) {}
  }

  /// PUT Request with JSON (200 OK)
  Future<void> sendSamplePut() async {
    try {
      await _client.put(
        Uri.parse(ApiEndpoints.httpbinPut),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'action': 'update_record',
          'status': 'updated',
          'updatedAt': DateTime.now().toIso8601String(),
        }),
      );
    } catch (_) {}
  }

  /// DELETE Request (200 OK)
  Future<void> sendSampleDelete() async {
    try {
      await _client.delete(
        Uri.parse(ApiEndpoints.httpbinDelete),
        headers: {
          'Accept': 'application/json',
        },
      );
    } catch (_) {}
  }

  /// Redirect Request (302 Found)
  Future<void> sendSampleRedirect() async {
    try {
      final request = http.Request(
        'GET',
        Uri.parse(ApiEndpoints.httpbinRedirect302),
      );
      // Disable auto-following redirects so the 302 Found response itself is captured
      request.followRedirects = false;
      request.headers['Accept'] = 'application/json';
      await _client.send(request);
    } catch (_) {}
  }

  /// Client Error (404 Not Found)
  Future<void> sendSampleClientError() async {
    try {
      await _client.get(
        Uri.parse(ApiEndpoints.httpbinNotFound404),
        headers: {'Accept': 'application/json'},
      );
    } catch (_) {}
  }

  /// Server Error (500 Internal Server Error)
  Future<void> sendSampleServerError() async {
    try {
      await _client.get(
        Uri.parse(ApiEndpoints.httpbinServerError500),
        headers: {'Accept': 'application/json'},
      );
    } catch (_) {}
  }

  /// Custom Request
  Future<void> sendCustomRequest({
    required String url,
    required String method,
    Map<String, String>? headers,
    String? body,
    bool followRedirects = true,
  }) async {
    final uri = Uri.parse(url);
    final reqHeaders = headers ?? {};

    final request = http.Request(method.toUpperCase(), uri);
    request.followRedirects = followRedirects;
    request.headers.addAll(reqHeaders);
    if (body != null && body.isNotEmpty) {
      request.body = body;
    }

    await _client.send(request);
  }
}
