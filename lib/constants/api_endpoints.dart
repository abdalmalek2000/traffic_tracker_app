/// Centralized API endpoint constants for testing and network inspection.
class ApiEndpoints {
  ApiEndpoints._();

  /// Primary test service base URL
  static const String httpbinBaseUrl = 'https://httpbin.org';

  // Standard REST endpoints
  static const String httpbinGet = '$httpbinBaseUrl/get';
  static const String httpbinPost = '$httpbinBaseUrl/post';
  static const String httpbinPut = '$httpbinBaseUrl/put';
  static const String httpbinDelete = '$httpbinBaseUrl/delete';
  static const String httpbinPatch = '$httpbinBaseUrl/patch';

  // HTTP Status simulation endpoints
  static const String httpbinRedirect302 = '$httpbinBaseUrl/status/302';
  static const String httpbinNotFound404 = '$httpbinBaseUrl/status/404';
  static const String httpbinServerError500 = '$httpbinBaseUrl/status/500';

  /// Helper to get test URL for any HTTP method
  static String getUrlForMethod(String method) {
    switch (method.toUpperCase()) {
      case 'POST':
        return httpbinPost;
      case 'PUT':
        return httpbinPut;
      case 'DELETE':
        return httpbinDelete;
      case 'PATCH':
        return httpbinPatch;
      case 'GET':
      default:
        return httpbinGet;
    }
  }

  /// Helper to get test URL for any HTTP status code
  static String getUrlForStatus(int statusCode) {
    return '$httpbinBaseUrl/status/$statusCode';
  }
}
