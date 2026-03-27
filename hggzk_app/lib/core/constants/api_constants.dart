class ApiConstants {
  ApiConstants._();

  // Base URLs
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    // defaultValue: 'https://api.hggzk.com/',
    defaultValue: 'http://192.168.0.101:5000/',
  );

  static const String _imageBaseUrlFromEnv = String.fromEnvironment(
    'IMAGE_BASE_URL',
    defaultValue: '',
  );

  static final String imageBaseUrl = _imageBaseUrlFromEnv.trim().isNotEmpty
      ? _stripTrailingSlash(_imageBaseUrlFromEnv)
      : _stripTrailingSlash(baseUrl);

  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'wss://ws.api.hggzk.com',
  );

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout =
      Duration(seconds: 1800); // 30 minutes for long-running endpoints
  static const Duration sendTimeout =
      Duration(seconds: 1800); // 30 minutes for uploads and long requests

  // Headers
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
  static const String acceptLanguage = 'Accept-Language';

  // API Versions
  static const String apiVersion = 'v1';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  static String _stripTrailingSlash(String value) {
    final trimmed = value.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
