import 'package:dio/dio.dart';

/// يطبع أخطاء الشبكة بصيغة موحدة يمكن عرضها أو تسجيلها مباشرة.
/// Normalizes transport and API failures into a single app-level exception.
class ApiException implements Exception {
  /// الرسالة النهائية التي سيقرأها المستخدم أو سجل الأخطاء.
  /// Final message surfaced to the user or logs.
  final String message;

  /// رمز HTTP إن كان الخلل مرتبطًا باستجابة من الخادم.
  /// HTTP status code when the failure came from a server response.
  final int? statusCode;

  /// الحمولة الخام المرتجعة من الخادم لتسهيل التشخيص.
  /// Raw payload returned by the backend for diagnostics.
  final dynamic data;

  /// نوع خطأ Dio الأصلي قبل التطبيع.
  /// Original Dio error type before normalization.
  final DioExceptionType? type;

  /// ينشئ الخطأ الموحّد بعد أن تحدد الطبقة العليا الرسالة النهائية.
  /// Builds the normalized exception after upper layers choose the final message.
  ApiException({
    required this.message,
    this.statusCode,
    this.data,
    this.type,
  });

  /// يترجم خطأ Dio الخام إلى رسالة قابلة للفهم داخل التطبيق.
  /// Converts a raw Dio exception into a user-friendly application message.
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
      default:
        message = dioError.message ?? 'حدث خطأ غير متوقع';
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: data,
      type: dioError.type,
    );
  }

  /// يفسر رموز HTTP الشائعة مع أولوية لرسالة الخادم إن كانت أكثر تحديدًا.
  /// Maps common HTTP status codes while preferring a backend message when available.
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
      case 503:
        return errorMessage.isNotEmpty
            ? errorMessage
            : 'الخدمة غير متاحة حالياً';
      default:
        return errorMessage.isNotEmpty ? errorMessage : 'حدث خطأ غير متوقع';
    }
  }

  /// يعرض الرسالة المبسطة نفسها لأن الاستهلاك الخارجي لا يحتاج التفاصيل الخام.
  /// Exposes the normalized message because downstream callers only need the stable user-facing text.
  @override
  String toString() => message;
}
