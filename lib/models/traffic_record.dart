import 'dart:convert';

/// تصنيف حالة المعاملة الشبكية
enum TrafficStatusCategory {
  pending,
  success,
  redirect,
  clientError,
  serverError,
  failed,
}

/// نموذج بيانات معاملة شبكة HTTP/HTTPS
class TrafficRecord {
  final String id;
  final DateTime timestamp;
  final String url;
  final String method;
  final Map<String, String> requestHeaders;
  final String? requestBody;
  final int requestContentLength;

  int? statusCode;
  String? statusMessage;
  Map<String, String>? responseHeaders;
  String? responseBody;
  int responseContentLength;
  int? durationMs;
  String? error;
  bool isPending;

  TrafficRecord({
    required this.id,
    required this.timestamp,
    required this.url,
    required this.method,
    required this.requestHeaders,
    this.requestBody,
    this.requestContentLength = 0,
    this.statusCode,
    this.statusMessage,
    this.responseHeaders,
    this.responseBody,
    this.responseContentLength = 0,
    this.durationMs,
    this.error,
    this.isPending = true,
  });

  Uri get uri {
    try {
      return Uri.parse(url);
    } catch (_) {
      return Uri();
    }
  }

  String get host => uri.host.isNotEmpty ? uri.host : url;

  String get path => uri.path.isNotEmpty ? uri.path : '/';

  Map<String, String> get queryParameters => uri.queryParameters;

  TrafficStatusCategory get statusCategory {
    if (isPending) return TrafficStatusCategory.pending;
    if (error != null) return TrafficStatusCategory.failed;
    final code = statusCode ?? 0;
    if (code >= 200 && code < 300) return TrafficStatusCategory.success;
    if (code >= 300 && code < 400) return TrafficStatusCategory.redirect;
    if (code >= 400 && code < 500) return TrafficStatusCategory.clientError;
    if (code >= 500) return TrafficStatusCategory.serverError;
    return TrafficStatusCategory.failed;
  }

  String get formattedDuration {
    if (durationMs == null) return isPending ? '...' : 'N/A';
    if (durationMs! < 1000) return '$durationMs ms';
    return '${(durationMs! / 1000).toStringAsFixed(2)} s';
  }

  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String get formattedResponseSize => formatBytes(responseContentLength);
  String get formattedRequestSize => formatBytes(requestContentLength);

  /// توليد أمر cURL كامل للطلب
  String toCurlCommand() {
    final buffer = StringBuffer('curl -X ${method.toUpperCase()}');
    buffer.write(' "$url"');

    requestHeaders.forEach((key, value) {
      final escaped = value.replaceAll('"', r'\"');
      buffer.write(' \\\n  -H "$key: $escaped"');
    });

    if (requestBody != null && requestBody!.isNotEmpty) {
      final escapedBody = requestBody!.replaceAll("'", r"'\''");
      buffer.write(" \\\n  --data '$escapedBody'");
    }

    return buffer.toString();
  }

  String get prettyResponseBody {
    if (responseBody == null || responseBody!.isEmpty) return '';
    try {
      final dynamic decoded = jsonDecode(responseBody!);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(decoded);
    } catch (_) {
      return responseBody!;
    }
  }

  String get prettyRequestBody {
    if (requestBody == null || requestBody!.isEmpty) return '';
    try {
      final dynamic decoded = jsonDecode(requestBody!);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(decoded);
    } catch (_) {
      return requestBody!;
    }
  }

  TrafficRecord copyWith({
    int? statusCode,
    String? statusMessage,
    Map<String, String>? responseHeaders,
    String? responseBody,
    int? responseContentLength,
    int? durationMs,
    String? error,
    bool? isPending,
  }) {
    return TrafficRecord(
      id: id,
      timestamp: timestamp,
      url: url,
      method: method,
      requestHeaders: requestHeaders,
      requestBody: requestBody,
      requestContentLength: requestContentLength,
      statusCode: statusCode ?? this.statusCode,
      statusMessage: statusMessage ?? this.statusMessage,
      responseHeaders: responseHeaders ?? this.responseHeaders,
      responseBody: responseBody ?? this.responseBody,
      responseContentLength: responseContentLength ?? this.responseContentLength,
      durationMs: durationMs ?? this.durationMs,
      error: error ?? this.error,
      isPending: isPending ?? this.isPending,
    );
  }
}
