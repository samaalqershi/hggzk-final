import 'package:dio/dio.dart';

/// Raised when the backend returns a failure that should be handled as a runtime exception.
/// يُرمى عندما يعيد الخادم فشلًا يجب التعامل معه كاستثناء أثناء التنفيذ.
class ServerException implements Exception {
  /// Human-readable message that can be surfaced in logs or UI fallbacks.
  /// رسالة قابلة للقراءة يمكن عرضها في السجلات أو كبديل للمستخدم.
  final String message;

  /// Optional backend error code used for debugging or client-side branching.
  /// كود خطأ اختياري من الخادم يفيد في التشخيص أو في اتخاذ قرار على الطرف العميل.
  final String? code;

  /// Whether the error should be presented as a dialog instead of a passive toast.
  /// يحدد ما إذا كان الخطأ يجب أن يظهر كحوار بدل إشعار عابر.
  final bool showAsDialog;

  /// ينشئ استثناء خادم يحمل الرسالة مع خيارات إضافية تخص الكود وطريقة العرض.
  /// Creates a server exception with the message plus optional code and UI
  /// presentation hint.
  const ServerException(this.message, {this.code, this.showAsDialog = false});
}

/// Signals that the request could not be completed because the network layer failed.
/// يدل على أن الطلب تعذر إكماله بسبب فشل في طبقة الشبكة.
class NetworkException implements Exception {
  /// Reason reported by the connectivity or transport layer.
  /// السبب الذي أبلغته طبقة الاتصال أو النقل.
  final String message;

  /// ينشئ استثناء شبكة عند فشل الوصول أو انقطاع طبقة النقل.
  /// Creates a network exception when connectivity or transport fails.
  const NetworkException(this.message);
}

/// Raised when local storage cannot satisfy a read or write operation.
/// يُرمى عندما يعجز التخزين المحلي عن تنفيذ عملية قراءة أو كتابة.
class CacheException implements Exception {
  /// Local storage failure description.
  /// وصف فشل التخزين المحلي.
  final String message;

  /// ينشئ استثناء تخزين محلي عند تعذر القراءة أو الحفظ.
  /// Creates a cache exception when local read or write operations fail.
  const CacheException(this.message);
}

/// Raised when the current credentials are invalid or missing.
/// يُرمى عندما تكون بيانات الاعتماد الحالية غير صالحة أو غير موجودة.
class AuthenticationException implements Exception {
  /// Authentication failure explanation.
  /// شرح فشل المصادقة.
  final String message;

  /// ينشئ استثناء مصادقة عندما تكون بيانات الاعتماد مفقودة أو غير صالحة.
  /// Creates an authentication exception when credentials are missing or
  /// invalid.
  const AuthenticationException(this.message);
}

/// Raised when access is denied after authentication has already been evaluated.
/// يُرمى عندما يُرفض الوصول بعد التحقق من الهوية.
class UnauthorizedException implements Exception {
  /// Authorization failure explanation.
  /// شرح فشل التفويض.
  final String message;

  /// ينشئ استثناء تفويض عندما يُرفض الوصول رغم توفر هوية المستخدم.
  /// Creates an authorization exception when access is denied despite having
  /// an identified user.
  const UnauthorizedException(this.message);
}

/// Raised when the server rejects user input and returns field-level validation errors.
/// يُرمى عندما يرفض الخادم مدخلات المستخدم ويعيد أخطاء تحقق على مستوى الحقول.
class ValidationException implements Exception {
  /// Summary of why validation failed.
  /// ملخص سبب فشل التحقق.
  final String message;

  /// Detailed validation messages keyed by field name.
  /// رسائل تحقق مفصلة مفهرسة بحسب اسم الحقل.
  final Map<String, List<String>>? errors;

  /// ينشئ استثناء تحقق مع ملخص عام وخريطة أخطاء تفصيلية اختيارية.
  /// Creates a validation exception with a summary message and optional
  /// field-level errors map.
  const ValidationException(this.message, {this.errors});
}

/// Raised when the requested resource does not exist on the server.
/// يُرمى عندما لا يكون المورد المطلوب موجودًا على الخادم.
class NotFoundException implements Exception {
  /// Human-readable description of the missing resource.
  /// وصف قابل للقراءة للمورد غير الموجود.
  final String message;

  /// ينشئ استثناء عدم وجود عندما يعجز الخادم عن العثور على المورد المطلوب.
  /// Creates a not-found exception when the backend cannot locate the
  /// requested resource.
  const NotFoundException(this.message);
}

/// Raised when a request exceeds the allowed time budget.
/// يُرمى عندما يتجاوز الطلب الوقت المسموح به.
class TimeoutException implements Exception {
  /// Timeout description that can be surfaced in diagnostics.
  /// وصف مهلة الاتصال للعرض في السجلات أو الواجهة.
  final String message;

  /// ينشئ استثناء مهلة عندما يتجاوز الطلب الزمن المسموح به.
  /// Creates a timeout exception when a request exceeds the allowed time
  /// budget.
  const TimeoutException(this.message);
}

/// Generic wrapper for API-level failures returned by Dio or backend parsing.
/// غلاف عام لأخطاء الـ API التي تنتج عن Dio أو عن تفسير استجابة الخادم.
class ApiException implements Exception {
  /// Final message prepared for logs or presentation.
  /// الرسالة النهائية الجاهزة للسجلات أو العرض.
  final String message;

  /// HTTP status code, when the response came from the backend.
  /// رمز الحالة HTTP عندما تأتي الاستجابة من الخادم.
  final int? statusCode;

  /// Dio error classification that helps decide retry or fallback behavior.
  /// تصنيف Dio للخطأ ويساعد في اتخاذ قرار إعادة المحاولة أو الرجوع لخطة بديلة.
  final DioExceptionType? type;

  /// ينشئ استثناء API عامًا يحمل الرسالة ورمز الحالة ونوع خطأ Dio إن وجد.
  /// Creates a generic API exception carrying the message, status code, and
  /// Dio error type when available.
  const ApiException(this.message, {this.statusCode, this.type});
}
