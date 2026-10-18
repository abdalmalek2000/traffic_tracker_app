import 'dart:convert';
import '../core/interceptor/traffic_client.dart';

class TestRequestService {
  final TrafficHttpClient _client = TrafficHttpClient();

  Future<void> sendSampleGet() async {
    try {
      await _client.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'TrafficTracker/1.0',
        },
      );
    } catch (_) {}
  }

  Future<void> sendSamplePost() async {
    try {
      await _client.post(
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer sample_sec_token_98234',
        },
        body: jsonEncode({
          'title': 'Security Audit Report',
          'body': 'Payload verification for HTTP traffic monitoring',
          'userId': 42,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
    } catch (_) {}
  }

  Future<void> sendSampleClientError() async {
    try {
      await _client.get(
        Uri.parse('https://jsonplaceholder.typicode.com/non_existent_endpoint_404'),
        headers: {'Accept': 'application/json'},
      );
    } catch (_) {}
  }

  Future<void> sendSampleServerError() async {
    try {
      // Testing an endpoint that responds with 500 or simulates failure
      await _client.get(
        Uri.parse('https://httpstat.us/500'),
        headers: {'Accept': 'application/json'},
      );
    } catch (_) {}
  }

  Future<void> sendCustomRequest({
    required String url,
    required String method,
    Map<String, String>? headers,
    String? body,
  }) async {
    final uri = Uri.parse(url);
    final reqHeaders = headers ?? {};

    switch (method.toUpperCase()) {
      case 'GET':
        await _client.get(uri, headers: reqHeaders);
        break;
      case 'POST':
        await _client.post(uri, headers: reqHeaders, body: body);
        break;
      case 'PUT':
        await _client.put(uri, headers: reqHeaders, body: body);
        break;
      case 'DELETE':
        await _client.delete(uri, headers: reqHeaders, body: body);
        break;
      case 'PATCH':
        await _client.patch(uri, headers: reqHeaders, body: body);
        break;
      default:
        await _client.get(uri, headers: reqHeaders);
    }
  }
}
