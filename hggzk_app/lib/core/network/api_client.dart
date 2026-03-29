import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:hggzk/core/utils/timezone_helper.dart';
import 'package:hggzk/core/localization/app_localizations.dart';
import '../constants/api_constants.dart';
import 'api_interceptors.dart';
import 'api_exceptions.dart';

/// طبقة وصول شبكة موحدة تضبط Dio وتطبّق السياسات المشتركة قبل أي طلب.
/// Central network gateway that configures Dio and applies shared request policy.
class ApiClient {
  /// نسخة Dio التي تعمل عليها الإعدادات والـ interceptors.
  /// Backing Dio instance configured by this client.
  late final Dio _dio;

  /// يمنع إعادة تهيئة المنطقة الزمنية أكثر من مرة خلال عمر التطبيق.
  /// Prevents repeated timezone initialization during the app lifetime.
  static bool _timezoneInitialized = false;

  /// يثبت نسخة Dio الواحدة ويطبق عليها إعدادات الشبكة المشتركة
  /// فور إنشاء العميل.
  /// Attaches the shared Dio instance and applies the app-wide
  /// networking policy immediately.
  ApiClient(Dio dio) {
    _dio = dio;
    _setupDioClient();
    _initializeTimezone(); // إضافة
  }

  /// يحمّل معلومات المنطقة الزمنية مرة واحدة كي تُستخدم في جميع الطلبات لاحقًا.
  /// Loads timezone metadata once so subsequent requests can reuse it.
  Future<void> _initializeTimezone() async {
    if (_timezoneInitialized) return;

    try {
      await TimezoneHelper.initialize();
      _timezoneInitialized = true;
      print('✅ Timezone initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize timezone: $e');
    }
  }

  /// يضبط عناوين الطلبات الافتراضية والاعتراضات التي تحفظ سياق الجلسة.
  /// Configures default headers and interceptors that preserve session context.
  void _setupDioClient() {
    final normalizedBaseUrl = _normalizeBaseUrl(ApiConstants.baseUrl);
    _dio.options = BaseOptions(
      baseUrl: normalizedBaseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      headers: {
        ApiConstants.contentType: ApiConstants.applicationJson,
        ApiConstants.acceptLanguage: 'ar',
      },
    );

    _dio.interceptors.addAll([
      AuthInterceptor(), // يحتوي الآن على منطق timezone
      // TimezoneInterceptor(), // أو استخدم interceptor منفصل
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

  /// يطبع العنوان الأساسي قبل استخدامه حتى لا تتضاعف الشرطات عند
  /// بناء المسارات النسبية.
  /// Normalizes the base URL before use so relative paths do not end
  /// up with duplicated slashes.
  String _normalizeBaseUrl(String baseUrl) {
    var v = baseUrl.trim();
    // Remove trailing slash to avoid double slashes when passing relative paths
    if (v.endsWith('/')) {
      v = v.substring(0, v.length - 1);
    }
    return v;
  }

  /// يجري طلب `GET` مع إعادة محاولة محدودة للأخطاء المؤقتة فقط.
  /// Performs a GET request with bounded retries for transient failures only.
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
        // فقط أعد المحاولة على مهلات الاتصال أو أخطاء الشبكة المؤقتة
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
  //   } on DioException catch (e) {
  //     throw ApiException.fromDioError(e);
  //   }
  // }
  /// يرسل طلب `POST` ويحوّل أخطاء Dio إلى استثناءات التطبيق الموحدة.
  /// Sends a POST request and converts Dio failures into the app's normalized exception.
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
      // طباعة البيانات للتطوير
      if (const bool.fromEnvironment('DEBUG') || true) {
        // مؤقتاً للتطوير
        print('🔵 POST Request to: $path');
        print('📦 Data: $data');
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

      if (const bool.fromEnvironment('DEBUG') || true) {
        print('✅ Response: ${response.data}');
      }

      return response;
    } on DioException catch (e) {
      // طباعة تفاصيل الخطأ
      if (e.response != null) {
        print('❌ Error Status: ${e.response?.statusCode}');
        print('❌ Error Data: ${e.response?.data}');

        // معالجة خاصة للخطأ 400
        if (e.response?.statusCode == 400) {
          final errorData = e.response?.data;
          String errorMessage =
              AppLocalizations.translateSync('common.badRequest');

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
                  AppLocalizations.translateSync('common.badRequest');
            }
          }

          throw ApiException(
            message: errorMessage,
            statusCode: 400,
          );
        }
      }

      throw ApiException.fromDioError(e);
    }
  }

  /// يرسل طلب `PUT` مع نفس آلية تحويل الأخطاء المستخدمة في بقية
  /// العمليات.
  /// Sends a `PUT` request using the same error translation strategy
  /// as the rest of the client.
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

  /// Processes the `patch` flow and maps it into the app-level behavior.
  /// العربية: يعالج `patch`.
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

  /// Deletes the required operation for `delete`.
  /// العربية: يحذف العملية المطلوبة لـ `delete`.
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

  /// Processes the `upload` flow and maps it into the app-level behavior.
  /// العربية: يعالج `upload`.
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

  /// Updates the base url.
  /// العربية: يحدّث base url.
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = _normalizeBaseUrl(baseUrl);
  }

  /// Updates the headers.
  /// العربية: يحدّث headers.
  void updateHeaders(Map<String, dynamic> headers) {
    _dio.options.headers.addAll(headers);
  }

  /// Processes the `clearHeaders` flow and maps it into the app-level behavior.
  /// العربية: يعالج `clearHeaders`.
  void clearHeaders() {
    _dio.options.headers.clear();
  }
}
