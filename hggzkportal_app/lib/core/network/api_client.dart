import 'package:hggzkportal/core/utils/timezone_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_constants.dart';
import 'api_interceptors.dart';
import 'api_exceptions.dart';

/// Shared Dio wrapper that prepares the app's HTTP stack in one place.
/// يغلّف Dio بشكل مشترك ليجهّز طبقة الشبكة كاملة من مكان واحد.
class ApiClient {
  /// The injected Dio instance that all requests flow through.
  /// نسخة Dio المحقونة التي تمر عبرها جميع الطلبات.
  late final Dio _dio;

  /// Tracks whether timezone initialization has already run for this process.
  /// يتتبع ما إذا كانت تهيئة المنطقة الزمنية قد نُفذت مسبقًا في هذه العملية.
  static bool _timezoneInitialized = false;

  /// Creates an API client around the provided Dio instance and applies shared setup immediately.
  /// ينشئ عميل الشبكة حول نسخة Dio المعطاة ويطبّق الإعدادات المشتركة مباشرة.
  ApiClient(Dio dio) {
    _dio = dio;
    _setupDioClient();
    _initializeTimezone();
  }

  /// Initializes timezone support once so date-sensitive requests and headers stay consistent.
  /// يهيئ دعم المنطقة الزمنية مرة واحدة حتى تبقى الطلبات والرؤوس المرتبطة بالتوقيت متسقة.
  Future<void> _initializeTimezone() async {
    if (_timezoneInitialized) return;

    try {
      await TimezoneHelper.initialize();
      _timezoneInitialized = true;
      debugPrint('✅ Timezone initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize timezone: $e');
    }
  }

  /// Applies the shared Dio options and registers the interceptors used by every request.
  /// يطبّق إعدادات Dio المشتركة ويسجل الـ interceptors المستخدمة في كل طلب.
  void _setupDioClient() {
    final normalizedBaseUrl = _normalizeBaseUrl(ApiConstants.baseUrl);
    _dio.options = BaseOptions(
      baseUrl: normalizedBaseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      // ASP.NET Core expects repeated query keys for arrays.
      listFormat: ListFormat.multi,
      contentType: ApiConstants.applicationJson,
      headers: {
        ApiConstants.acceptLanguage: 'ar',
      },
    );

    _dio.interceptors.addAll([
      AuthInterceptor(), // يحتوي الآن على منطق timezone
      // TimezoneInterceptor(), // أو استخدم interceptor منفصل
      RequestHeadersLoggingInterceptor(),
      UserFeedbackInterceptor(),
      ErrorInterceptor(_dio),
      if (const bool.fromEnvironment('DEBUG'))
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
    ]);
  }

  /// Normalizes a base URL by trimming spaces and removing a trailing slash.
  /// يوحّد عنوان الخادم عبر إزالة المسافات والشرطة المائلة النهائية.
  String _normalizeBaseUrl(String baseUrl) {
    var v = baseUrl.trim();
    if (v.endsWith('/')) {
      v = v.substring(0, v.length - 1);
    }
    return v;
  }

  /// Sends a GET request and retries short-lived transport failures with exponential backoff.
  /// يرسل طلب GET ويعيد المحاولة عند أخطاء النقل العابرة مع زيادة تدريجية في التأخير.
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    int retries = 2,
  }) async {
    int attempt = 0;
    DioException? lastError;
    while (attempt <= retries) {
      try {
        final response = await _dio.get(
          path,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
        );
        return response;
      } on DioException catch (e) {
        lastError = e;
        final isTimeout = e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout;
        final isNetwork = e.type == DioExceptionType.unknown;
        if (attempt < retries && (isTimeout || isNetwork)) {
          final delay = Duration(milliseconds: 300 * (1 << attempt));
          await Future.delayed(delay);
          attempt++;
          continue;
        }
        break;
      }
    }
    throw ApiException.fromDioError(lastError!);
  }

  // Future<Response> post(
  //   String path, {
  //   dynamic data,
  //   Map<String, dynamic>? queryParameters,
  //   Options? options,
  //   CancelToken? cancelToken,
  //   ProgressCallback? onSendProgress,
  //   ProgressCallback? onReceiveProgress,
  // }) async {
  //   try {
  //     final response = await _dio.post(
  //       path,
  //       data: data,
  //       queryParameters: queryParameters,
  //       options: options,
  //       cancelToken: cancelToken,
  //       onSendProgress: onSendProgress,
  //       onReceiveProgress: onReceiveProgress,
  //     );
  //     return response;
  /// Sends a POST request, preserving multipart boundaries when the payload is FormData.
  /// يرسل طلب POST مع الحفاظ على حدود multipart عندما تكون الحمولة من نوع FormData.
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      // Auto-detect FormData and ensure proper Content-Type handling
      if (data is FormData) {
        options ??= Options();
        options.headers ??= {};

        // For FormData, always remove Content-Type to let Dio add the boundary
        // Dio will automatically add: Content-Type: multipart/form-data; boundary=...
        options.headers!.remove('Content-Type');
        options.headers!.remove('content-type');

        if (const bool.fromEnvironment('DEBUG') || true) {
          debugPrint(
              '🎯 FormData detected - removing Content-Type to let Dio handle boundary');
        }
      }

      // طباعة البيانات للتطوير
      if (const bool.fromEnvironment('DEBUG') || true) {
        // مؤقتاً للتطوير
        final bool isAbsolute =
            path.startsWith('http://') || path.startsWith('https://');
        final String fullUrl = isAbsolute
            ? path
            : '${_dio.options.baseUrl}${path.startsWith('/') ? path : '/$path'}';
        debugPrint('🔵 POST Request to: $path');
        debugPrint('🌐 Resolved URL: $fullUrl');
        debugPrint('📦 Data: $data');
        if (options?.extra != null && options!.extra!.isNotEmpty) {
          debugPrint('⚙️ Options.extra: ${options.extra}');
        }
      }

      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      if (kDebugMode) {
        debugPrint('✅ Response: ${response.data}');
      }

      return response;
    } on DioException catch (e) {
      final suppressLog = (e.requestOptions.extra['suppressErrorLog'] == true);
      // معالجة خاصة للخطأ 400
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        String errorMessage = 'طلب غير صحيح';

        if (errorData is Map) {
          // محاولة استخراج رسالة الخطأ
          if (errorData['errors'] is Map) {
            // أخطاء التحقق من النموذج
            final errors = errorData['errors'] as Map;
            final List<String> errorMessages = [];

            errors.forEach((key, value) {
              if (value is List && value.isNotEmpty) {
                // استخراج الرسائل من قائمة الأخطاء
                errorMessages.addAll(value.map((e) => e.toString()));
              } else {
                errorMessages.add(value.toString());
              }
            });

            errorMessage = errorMessages.join('\n');
          } else {
            // رسالة خطأ عامة
            errorMessage = errorData['message'] ??
                errorData['error'] ??
                'طلب غير صحيح: تحقق من البيانات المدخلة';
          }
        }

        throw ApiException(
          message: errorMessage,
          statusCode: 400,
        );
      }

      // طباعة تفاصيل الخطأ
      if (!suppressLog && kDebugMode && e.response != null) {
        debugPrint('❌ Error Status: ${e.response?.statusCode}');
        debugPrint('❌ Error Data: ${e.response?.data}');
      }

      throw ApiException.fromDioError(e);
    }
  }

  /// Sends a PUT request and translates Dio failures into the app's exception model.
  /// يرسل طلب PUT ويحوّل أخطاء Dio إلى نموذج الاستثناء المعتمد في التطبيق.
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Sends a PATCH request and returns the raw server response on success.
  /// يرسل طلب PATCH ويعيد استجابة الخادم الخام عند النجاح.
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Sends a DELETE request for the given resource path.
  /// يرسل طلب DELETE للمسار المحدد.
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Uploads multipart content through POST with a safe FormData default content type.
  /// يرفع محتوى multipart عبر POST مع محتوى افتراضي آمن لـ FormData.
  Future<Response> upload(
    String path, {
    required FormData formData,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        options: options ??
            Options(
              headers: {
                'Content-Type': 'multipart/form-data',
              },
            ),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Replaces the active base URL while keeping normalization rules intact.
  /// يستبدل عنوان الخادم النشط مع الحفاظ على قواعد التطبيع نفسها.
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = _normalizeBaseUrl(baseUrl);
  }

  /// Merges new default headers into the shared Dio configuration.
  /// يدمج رؤوسًا افتراضية جديدة في إعدادات Dio المشتركة.
  void updateHeaders(Map<String, dynamic> headers) {
    _dio.options.headers.addAll(headers);
  }

  /// Removes all default headers from the shared Dio instance.
  /// يحذف جميع الرؤوس الافتراضية من نسخة Dio المشتركة.
  void clearHeaders() {
    _dio.options.headers.clear();
  }
}
