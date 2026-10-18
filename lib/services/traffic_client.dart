import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/traffic_record.dart';
import '../controllers/traffic_controller.dart';

/// عميل شبكة مخصص يعترض كافة طلبات واستجابات HTTP ويسجلها في متحكم TrafficController
class TrafficHttpClient extends http.BaseClient {
  final http.Client _inner;
  static int _idCounter = 0;

  TrafficHttpClient([http.Client? inner]) : _inner = inner ?? http.Client();

  TrafficController? get _controller {
    try {
      if (Get.isRegistered<TrafficController>()) {
        return TrafficController.to;
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final recordId = '${DateTime.now().millisecondsSinceEpoch}_${++_idCounter}';
    final timestamp = DateTime.now();
    final stopwatch = Stopwatch()..start();

    String? requestBody;
    int requestContentLength = request.contentLength ?? 0;

    if (request is http.Request) {
      requestBody = request.body;
      requestContentLength = request.bodyBytes.length;
    }

    final record = TrafficRecord(
      id: recordId,
      timestamp: timestamp,
      url: request.url.toString(),
      method: request.method,
      requestHeaders: Map<String, String>.from(request.headers),
      requestBody: requestBody,
      requestContentLength: requestContentLength,
      isPending: true,
    );

    _controller?.addRecord(record);

    try {
      final streamedResponse = await _inner.send(request);
      final responseBodyBytes = await streamedResponse.stream.toBytes();
      stopwatch.stop();

      String responseBody;
      try {
        responseBody = utf8.decode(responseBodyBytes, allowMalformed: true);
      } catch (_) {
        responseBody = '[بيانات ثنائية / Non-UTF8: ${responseBodyBytes.length} bytes]';
      }

      final updatedRecord = record.copyWith(
        statusCode: streamedResponse.statusCode,
        statusMessage: streamedResponse.reasonPhrase,
        responseHeaders: Map<String, String>.from(streamedResponse.headers),
        responseBody: responseBody,
        responseContentLength: responseBodyBytes.length,
        durationMs: stopwatch.elapsedMilliseconds,
        isPending: false,
      );

      _controller?.updateRecord(updatedRecord);

      return http.StreamedResponse(
        Stream.value(responseBodyBytes),
        streamedResponse.statusCode,
        contentLength: responseBodyBytes.length,
        request: streamedResponse.request,
        headers: streamedResponse.headers,
        isRedirect: streamedResponse.isRedirect,
        persistentConnection: streamedResponse.persistentConnection,
        reasonPhrase: streamedResponse.reasonPhrase,
      );
    } catch (error) {
      stopwatch.stop();
      final failedRecord = record.copyWith(
        durationMs: stopwatch.elapsedMilliseconds,
        error: error.toString(),
        isPending: false,
      );
      _controller?.updateRecord(failedRecord);
      rethrow;
    }
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
