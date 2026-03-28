import 'package:dio/dio.dart';

/// استثناء طبقة البيانات عندما يرد الخادم برسالة قابلة للقراءة أو
/// برمز حالة نريد تحويله إلى فشل أعلى.
/// Data-layer exception used when the server returns a readable error
/// or a status code we want to translate upward.
class ServerException implements Exception {
  /// الرسالة الخام الصادرة من الخادم أو المولدة داخليًا.
  /// Raw message from the backend or from local translation logic.
  final String message;

  /// رمز حالة أو رمز داخلي يساعد على التتبع.
  /// Status or internal code used for classification and tracing.
  final String? code;

  /// يحدد ما إذا كان ينبغي عرض الخطأ مباشرة للمستخدم.
  /// Tells the UI whether the error should be shown directly.
  final bool showAsDialog;

  /// يُستخدم عند التقاط استجابة خادم يجب تحويلها إلى فشل.
  /// Used when a server response must be converted into a failure.
  const ServerException(this.message, {this.code, this.showAsDialog = false});
}

/// استثناء يعبّر عن فشل الاتصال بالشبكة نفسها.
/// Exception that represents a network connectivity failure.
class NetworkException implements Exception {
  /// وصف موجز للمشكلة الشبكية.
  /// Short description of the network problem.
  final String message;

  /// يستخدم عندما يتعذر الوصول إلى الخادم بسبب الشبكة.
  /// Used when the backend cannot be reached due to connectivity.
  const NetworkException(this.message);
}

/// استثناء التخزين المحلي أو الكاش.
/// Exception for local storage or cache failures.
class CacheException implements Exception {
  /// رسالة توضح سبب فشل القراءة أو الكتابة المحلية.
  /// Explains why the local read or write failed.
  final String message;

  /// يستخدم عندما ينهار التخزين المحلي أو يفشل في الوصول للبيانات.
  /// Used when local persistence fails or becomes unreadable.
  const CacheException(this.message);
}

/// استثناء يعكس فشل التحقق من الهوية.
/// Exception that reflects an identity verification failure.
class AuthenticationException implements Exception {
  /// رسالة الفشل الخاصة بالمصادقة.
  /// Authentication failure message.
  final String message;

  /// يستخدم عندما لا يمكن تأكيد هوية المستخدم.
  /// Used when the user's identity cannot be confirmed.
  const AuthenticationException(this.message);
}

/// استثناء يُستخدم عندما لا يملك الطلب إذنًا كافيًا.
/// Exception used when the request lacks sufficient authorization.
class UnauthorizedException implements Exception {
  /// رسالة تشرح سبب رفض الصلاحية.
  /// Message explaining why access was denied.
  final String message;

  /// يستخدم عندما تكون الصلاحية مفقودة أو منتهية.
  /// Used when authorization is missing or expired.
  const UnauthorizedException(this.message);
}

/// استثناء يصف فشل التحقق مع إمكانية حمل أخطاء الحقول.
/// Exception describing validation failure with optional field errors.
class ValidationException implements Exception {
  /// الرسالة العامة لفشل التحقق.
  /// General validation failure message.
  final String message;

  /// خرائط الأخطاء التفصيلية المرتبطة بالحقول.
  /// Per-field validation errors.
  final Map<String, List<String>>? errors;

  /// يستخدم عندما يرفض الخادم البيانات المدخلة.
  /// Used when the backend rejects the submitted data.
  const ValidationException(this.message, {this.errors});
}

/// استثناء يُستخدم عندما لا يوجد المورد المطلوب.
/// Exception used when the requested resource does not exist.
class NotFoundException implements Exception {
  /// رسالة توضح أن العنصر غير موجود.
  /// Message indicating the resource was not found.
  final String message;

  /// يستخدم عند طلب مسار أو مورد غير متاح.
  /// Used when the app requests a missing route or resource.
  const NotFoundException(this.message);
}

/// استثناء يفيد بأن المهلة انتهت قبل اكتمال العملية.
/// Exception indicating the operation timed out before completion.
class TimeoutException implements Exception {
  /// يوضح أن الاتصال استغرق وقتًا أطول من المسموح.
  /// Explains that the request took longer than allowed.
  final String message;

  /// يستخدم عندما تنتهي مهلة الاتصال أو الاستجابة.
  /// Used when the connection or response exceeds its time budget.
  const TimeoutException(this.message);
}

/// استثناء يحول أخطاء Dio أو استجابات الـ API إلى شكل موحد داخل
/// طبقة البيانات.
/// Exception that normalizes Dio and API failures inside the data layer.
class ApiException implements Exception {
  /// الرسالة الخام المرتبطة بفشل الـ API.
  /// Raw API failure message.
  final String message;

  /// رمز الحالة إن كان متاحًا.
  /// Optional HTTP status code.
  final int? statusCode;

  /// نوع خطأ Dio عندما يكون التحويل من مستوى النقل مطلوبًا.
  /// Dio error type when transport-level classification matters.
  final DioExceptionType? type;

  /// يُستخدم عندما نحتاج إلى الاحتفاظ بالمعلومة الخام قبل تحويلها
  /// إلى فشل أعلى.
  /// Used when the raw error must be preserved before conversion into
  /// a higher-level failure.
  const ApiException(this.message, {this.statusCode, this.type});
}
