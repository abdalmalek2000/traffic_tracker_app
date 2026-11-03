import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_tracker_app/constants/api_endpoints.dart';
import 'package:traffic_tracker_app/services/test_request_service.dart';

void main() {
  group('ApiEndpoints Tests', () {
    test('Correctly formats URLs for methods', () {
      expect(ApiEndpoints.getUrlForMethod('GET'), 'https://httpbin.org/get');
      expect(ApiEndpoints.getUrlForMethod('POST'), 'https://httpbin.org/post');
      expect(ApiEndpoints.getUrlForMethod('PUT'), 'https://httpbin.org/put');
      expect(ApiEndpoints.getUrlForMethod('DELETE'), 'https://httpbin.org/delete');
      expect(ApiEndpoints.getUrlForMethod('PATCH'), 'https://httpbin.org/patch');
    });

    test('Correctly formats URLs for status codes', () {
      expect(ApiEndpoints.getUrlForStatus(200), 'https://httpbin.org/status/200');
      expect(ApiEndpoints.getUrlForStatus(302), 'https://httpbin.org/status/302');
      expect(ApiEndpoints.getUrlForStatus(404), 'https://httpbin.org/status/404');
      expect(ApiEndpoints.getUrlForStatus(500), 'https://httpbin.org/status/500');
    });
  });

  group('TestRequestService Tests', () {
    test('Service instance initializes and methods execute without uncaught exceptions', () async {
      final service = TestRequestService();
      expect(service, isNotNull);

      // In Flutter test environment, HttpClient returns status 400 without crashing
      await service.sendSampleGet();
      await service.sendSamplePost();
      await service.sendSamplePut();
      await service.sendSampleDelete();
      await service.sendSampleRedirect();
      await service.sendSampleClientError();
      await service.sendSampleServerError();
      await service.sendCustomRequest(
        url: 'https://httpbin.org/get',
        method: 'GET',
      );
      await service.sendCustomRequest(
        url: 'https://httpbin.org/status/302',
        method: 'GET',
        followRedirects: false,
      );
    });
  });
}
