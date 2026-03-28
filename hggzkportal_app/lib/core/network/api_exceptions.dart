import 'package:dio/dio.dart';

/// App-level exception that normalizes Dio failures and backend error envelopes.
/// استثناء على مستوى التطبيق يوحّد أخطاء Dio وأغلفة الخطأ القادمة من الخادم.
class ApiException implements Exception {
  /// Human-readable message used by logs, dialogs, and fallback UI.
  /// رسالة واضحة للإنسان تُستخدم في السجلات والحوار والواجهات البديلة.
  final String message;

  /// HTTP status code returned by the server, when available.
  /// رمز حالة HTTP الذي أرسله الخادم عندما يكون متاحًا.
  final int? statusCode;

  /// Raw response payload or parsed backend error object.
  /// الحمولة الخام أو كائن الخطأ المحلل القادم من الخادم.
  final dynamic data;

  /// Dio classification that tells callers whether this was a timeout, cancel, or transport issue.
  /// تصنيف Dio الذي يوضح ما إذا كان الخطأ مهلة أو إلغاءً أو مشكلة نقل.
  final DioExceptionType? type;

  /// Optional backend error code preserved for branching, telemetry, or analytics.
  /// كود خطأ اختياري من الخادم يُحفظ للتفرع المنطقي أو القياس والتحليل.
  final String? code;

  /// Creates a normalized exception from already parsed error details.
  /// ينشئ استثناءً موحدًا من تفاصيل خطأ محللة مسبقًا.
  ApiException({
    required this.message,
    this.statusCode,
    this.data,
    this.type,
    this.code,
  });

  /// Converts a Dio failure into a stable exception message and metadata for the app.
  /// يحول خطأ Dio إلى رسالة وبيانات وصفية ثابتة مناسبة للتطبيق.
  factory ApiException.fromDioError(DioException dioError) {
    String message;
    int? statusCode;
    dynamic data;

    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'انتهت مهلة الاتصال';
        break;
      case DioExceptionType.badResponse:
        statusCode = dioError.response?.statusCode;
        data = dioError.response?.data;

        // Check if response contains ResultDto structure
        if (data is Map<String, dynamic>) {
          if (data.containsKey('success') && data['success'] == false) {
            message = data['message'] ??
                (data['errors'] as List?)?.join(', ') ??
                _handleStatusCode(statusCode, data);
          } else {
            message = _handleStatusCode(statusCode, data);
          }
        } else {
          message = _handleStatusCode(statusCode, data);
        }
        break;
      case DioExceptionType.cancel:
        message = 'تم إلغاء الطلب';
        break;
      case DioExceptionType.connectionError:
        message = 'لا يوجد اتصال بالإنترنت';
        break;
      case DioExceptionType.badCertificate:
        message = 'خطأ في شهادة الأمان';
        break;
      case DioExceptionType.unknown:
        message = dioError.message ?? 'حدث خطأ غير متوقع';
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: data,
      type: dioError.type,
      code: data is Map<String, dynamic> ? data['errorCode'] as String? : null,
    );
  }

  /// Maps common HTTP status codes to the fallback message the UI should surface.
  /// يحول رموز HTTP الشائعة إلى رسالة بديلة مناسبة لعرضها في الواجهة.
  static String _handleStatusCode(int? statusCode, dynamic data) {
    final errorMessage = data is Map<String, dynamic>
        ? (data['message'] ?? data['error'] ?? '')
        : '';

    switch (statusCode) {
      case 400:
        return errorMessage.isNotEmpty ? errorMessage : 'طلب غير صحيح';
      case 401:
        return errorMessage.isNotEmpty ? errorMessage : 'غير مصرح بالوصول';
      case 403:
        return errorMessage.isNotEmpty ? errorMessage : 'ليس لديك صلاحية';
      case 404:
        return errorMessage.isNotEmpty
            ? errorMessage
            : 'لم يتم العثور على البيانات';
      case 422:
        return errorMessage.isNotEmpty
            ? errorMessage
            : 'البيانات المدخلة غير صحيحة';
      case 500:
        return errorMessage.isNotEmpty ? errorMessage : 'خطأ في الخادم';
      case 502:
        return errorMessage.isNotEmpty
            ? errorMessage
            : 'الخادم غير متاح مؤقتاً (502). يرجى المحاولة بعد قليل';
      case 503:
        return errorMessage.isNotEmpty
            ? errorMessage
            : 'الخدمة غير متاحة حالياً';
      case 504:
        return errorMessage.isNotEmpty
            ? errorMessage
            : 'الخادم يستغرق وقتاً أطول من المعتاد. حاول مرة أخرى';
      default:
        return errorMessage.isNotEmpty ? errorMessage : 'حدث خطأ غير متوقع';
    }
  }

  /// Returns the final message so the exception prints cleanly in logs and debug output.
  /// يعيد الرسالة النهائية كي يظهر الاستثناء بشكل واضح في السجلات ومخرجات التصحيح.
  @override
  String toString() => message;
}
