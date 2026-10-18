import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/traffic_record.dart';
import '../../services/traffic_manager.dart';

/// An HTTP client wrapper that intercepts, inspects, and logs all network requests.
class TrafficHttpClient extends http.BaseClient {
  final http.Client _inner;
  static int _idCounter = 0;

  TrafficHttpClient([http.Client? inner]) : _inner = inner ?? http.Client();

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

    TrafficManager.instance.addRecord(record);

    try {
      final streamedResponse = await _inner.send(request);
      final responseBodyBytes = await streamedResponse.stream.toBytes();
      stopwatch.stop();

      String responseBody;
      try {
        responseBody = utf8.decode(responseBodyBytes, allowMalformed: true);
      } catch (_) {
        responseBody = '[Binary Data / Non-UTF8: ${responseBodyBytes.length} bytes]';
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

      TrafficManager.instance.updateRecord(updatedRecord);

      // Return a new StreamedResponse with the same data so caller can read it
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
      TrafficManager.instance.updateRecord(failedRecord);
      rethrow;
    }
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
