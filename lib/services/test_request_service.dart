import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../controllers/settings_controller.dart';
import 'traffic_client.dart';

/// خدمة إرسال طلبات شبكة تجريبية لاختبار عمل المراقبة، ترسل الترويسات والبيانات بحسب لغة التطبيق الحالية
class TestRequestService {
  final TrafficHttpClient _client = TrafficHttpClient();

  /// فحص ما إذا كانت لغة التطبيق الحالية عربية
  bool get _isArabic {
    try {
      if (Get.isRegistered<SettingsController>()) {
        return SettingsController.to.isArabic;
      }
    } catch (_) {}
    return Get.locale?.languageCode.startsWith('ar') ?? false;
  }

  /// بناء ترويسات موحدة متوافقة مع لغة الواجهة
  Map<String, String> _buildHeaders({Map<String, String>? extra}) {
    final ar = _isArabic;
    final headers = <String, String>{
      'Accept': 'application/json',
      'Accept-Language':
          ar ? 'ar-SA,ar;q=0.9,en;q=0.8' : 'en-US,en;q=0.9,ar;q=0.8',
      'X-App-Language': ar ? 'ar' : 'en',
      'X-Client-Locale': ar ? 'ar_SA' : 'en_US',
      'User-Agent': ar
          ? 'TrafficTracker/1.0 (Arabic; Android)'
          : 'TrafficTracker/1.0 (English; Android)',
    };
    if (extra != null) {
      headers.addAll(extra);
    }
    return headers;
  }

  /// GET Request (200 OK)
  Future<void> sendSampleGet() async {
    try {
      final ar = _isArabic;
      final uri = Uri.parse(ApiEndpoints.httpbinGet).replace(
        queryParameters: ar
            ? {
                'lang': 'ar',
                'topic': 'فحص_الشبكة',
                'status': 'نشط',
              }
            : {
                'lang': 'en',
                'topic': 'network_inspection',
                'status': 'active',
              },
      );
      await _client.get(
        uri,
        headers: _buildHeaders(),
      );
    } catch (_) {}
  }

  /// POST Request with JSON & Bearer Token (200 OK)
  Future<void> sendSamplePost() async {
    try {
      final ar = _isArabic;
      await _client.post(
        Uri.parse(ApiEndpoints.httpbinPost),
        headers: _buildHeaders(
          extra: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer sample_sec_token_98234',
            'X-Payload-Type': ar ? 'security_report_ar' : 'security_report_en',
          },
        ),
        body: jsonEncode(
          ar
              ? {
                  'title': 'تقرير فحص أمني تجريبي',
                  'body':
                      'بيانات اختبارية لمراقبة حركة طلبات الشبكة وحزم البيانات',
                  'language': 'العربية (ar)',
                  'userId': 42,
                  'timestamp': DateTime.now().toIso8601String(),
                }
              : {
                  'title': 'Security Audit Inspection Report',
                  'body':
                      'Sample test payload for monitoring network traffic and packet inspection',
                  'language': 'English (en)',
                  'userId': 42,
                  'timestamp': DateTime.now().toIso8601String(),
                },
        ),
        encoding: utf8,
      );
    } catch (_) {}
  }

  /// PUT Request with JSON (200 OK)
  Future<void> sendSamplePut() async {
    try {
      final ar = _isArabic;
      await _client.put(
        Uri.parse(ApiEndpoints.httpbinPut),
        headers: _buildHeaders(
          extra: {
            'Content-Type': 'application/json; charset=UTF-8',
            'X-Action-Type': ar ? 'update_data_ar' : 'update_data_en',
          },
        ),
        body: jsonEncode(
          ar
              ? {
                  'action': 'تحديث_سجل_الفحص',
                  'status': 'تم التحديث بنجاح',
                  'notes': 'تعديل بيانات طلب الشبكة التجريبي باللغة العربية',
                  'updatedAt': DateTime.now().toIso8601String(),
                }
              : {
                  'action': 'update_inspection_record',
                  'status': 'successfully_updated',
                  'notes':
                      'Modified sample test network request payload in English',
                  'updatedAt': DateTime.now().toIso8601String(),
                },
        ),
        encoding: utf8,
      );
    } catch (_) {}
  }

  /// DELETE Request (200 OK)
  Future<void> sendSampleDelete() async {
    try {
      final ar = _isArabic;
      await _client.delete(
        Uri.parse(ApiEndpoints.httpbinDelete),
        headers: _buildHeaders(
          extra: {
            'X-Delete-Reason':
                ar ? 'temporary_cleanup_ar' : 'temporary_resource_cleanup',
          },
        ),
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
      request.headers.addAll(_buildHeaders());
      await _client.send(request);
    } catch (_) {}
  }

  /// Client Error (404 Not Found)
  Future<void> sendSampleClientError() async {
    try {
      await _client.get(
        Uri.parse(ApiEndpoints.httpbinNotFound404),
        headers: _buildHeaders(),
      );
    } catch (_) {}
  }

  /// Server Error (500 Internal Server Error)
  Future<void> sendSampleServerError() async {
    try {
      await _client.get(
        Uri.parse(ApiEndpoints.httpbinServerError500),
        headers: _buildHeaders(),
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
    final reqHeaders = _buildHeaders(extra: headers);

    final request = http.Request(method.toUpperCase(), uri);
    request.followRedirects = followRedirects;
    if (body != null && body.isNotEmpty) {
      reqHeaders.putIfAbsent(
        'Content-Type',
        () => 'application/json; charset=UTF-8',
      );
      request.encoding = utf8;
      request.body = body;
    }
    request.headers.addAll(reqHeaders);

    await _client.send(request);
  }
}
