/// Represents `ApiConstants`.
/// العربية: يمثل `ApiConstants`.
class ApiConstants {
  /// Builds the `ApiConstants._` instance used by this layer.
  /// العربية: ينشئ مثيلًا جديدًا من `ApiConstants._`.
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
    defaultValue: '',
  );

  static String get resolvedSocketUrl {
    final configured = socketUrl.trim();
    if (configured.isNotEmpty) {
      return _normalizeSocketUrl(configured);
    }

    return _normalizeSocketUrl(baseUrl);
  }

  static String _normalizeSocketUrl(String value) {
    final base = _stripTrailingSlash(value);
    if (base.startsWith('https://')) {
      return 'wss://${base.substring('https://'.length)}';
    }
    if (base.startsWith('http://')) {
      return 'ws://${base.substring('http://'.length)}';
    }
    return base;
  }

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout =
      Duration(seconds: 1800); // 30 minutes for long-running endpoints
  static const Duration sendTimeout =
      Duration(seconds: 1800); // 30 minutes for uploads and long requests

  // Headers
  /// Keeps the `contentType` value so this type can use it later.
  /// العربية: يخزن القيمة `contentType`.
  static const String contentType = 'Content-Type';

  /// Keeps the `applicationJson` value so this type can use it later.
  /// العربية: يخزن القيمة `applicationJson`.
  static const String applicationJson = 'application/json';

  /// Keeps the `authorization` value so this type can use it later.
  /// العربية: يخزن القيمة `authorization`.
  static const String authorization = 'Authorization';

  /// Keeps the `bearer` value so this type can use it later.
  /// العربية: يخزن القيمة `bearer`.
  static const String bearer = 'Bearer';

  /// Keeps the `acceptLanguage` value so this type can use it later.
  /// العربية: يخزن القيمة `acceptLanguage`.
  static const String acceptLanguage = 'Accept-Language';

  // API Versions
  /// Keeps the `apiVersion` value so this type can use it later.
  /// العربية: يخزن القيمة `apiVersion`.
  static const String apiVersion = 'v1';

  // Pagination
  /// Keeps the `defaultPageSize` value so this type can use it later.
  /// العربية: يخزن القيمة `defaultPageSize`.
  static const int defaultPageSize = 20;

  /// Keeps the `maxPageSize` value so this type can use it later.
  /// العربية: يخزن القيمة `maxPageSize`.
  static const int maxPageSize = 100;

  /// Processes the `stripTrailingSlash` flow and maps it into the app-level behavior.
  /// العربية: يعالج `stripTrailingSlash`.
  static String _stripTrailingSlash(String value) {
    final trimmed = value.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
