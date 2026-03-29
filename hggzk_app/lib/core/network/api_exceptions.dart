import 'package:dio/dio.dart';
import 'package:hggzk/core/localization/app_localizations.dart';

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
        message = AppLocalizations.translateSync('common.requestTimeout');
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
        message = AppLocalizations.translateSync('common.requestCancelled');
        break;
      case DioExceptionType.connectionError:
        message = AppLocalizations.translateSync('common.noInternet');
        break;
      case DioExceptionType.badCertificate:
        message = AppLocalizations.translateSync('common.badCertificate');
        break;
      case DioExceptionType.unknown:
      default:
        message = dioError.message ??
            AppLocalizations.translateSync('common.unexpectedError');
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
        return errorMessage.isNotEmpty
            ? errorMessage
            : AppLocalizations.translateSync('common.badRequest');
      case 401:
        return errorMessage.isNotEmpty
            ? errorMessage
            : AppLocalizations.translateSync('common.unauthorized');
      case 403:
        return errorMessage.isNotEmpty
            ? errorMessage
            : AppLocalizations.translateSync('common.permissionDenied');
      case 404:
        return errorMessage.isNotEmpty
            ? errorMessage
            : AppLocalizations.translateSync('common.notFound');
      case 422:
        return errorMessage.isNotEmpty
            ? errorMessage
            : AppLocalizations.translateSync('common.invalidData');
      case 500:
        return errorMessage.isNotEmpty
            ? errorMessage
            : AppLocalizations.translateSync('common.serverError');
      case 503:
        return errorMessage.isNotEmpty
            ? errorMessage
            : AppLocalizations.translateSync('common.serviceUnavailable');
      default:
        return errorMessage.isNotEmpty
            ? errorMessage
            : AppLocalizations.translateSync('common.unexpectedError');
    }
  }

  /// يعرض الرسالة المبسطة نفسها لأن الاستهلاك الخارجي لا يحتاج التفاصيل الخام.
  /// Exposes the normalized message because downstream callers only need the stable user-facing text.
  @override
  String toString() => message;
}
