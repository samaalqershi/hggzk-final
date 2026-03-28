import 'package:equatable/equatable.dart';

/// يمثل الطبقة العليا لجميع حالات الفشل التي يقرأها منطق المجال
/// ويحوّلها إلى رسائل أو حالات UI مفهومة.
/// Base type for failures that domain and presentation layers can turn
/// into predictable messages or states.
abstract class Failure extends Equatable {
  /// الرسالة المرافقة للفشل والمقصودة لعرضها أو تسجيلها.
  /// The message attached to the failure for display or logging.
  final String message;

  /// يتيح إنشاء فشل عام عندما لا يوجد نوع أكثر تخصصًا.
  /// Allows a generic failure when no more specific subtype fits.
  const Failure([this.message = 'An unexpected error occurred']);

  /// يحدد الرسالة وحدها كأساس للمقارنة.
  /// Uses the message as the equality anchor.
  @override
  List<Object> get props => [message];
}

// General failures
/// يشير إلى أن الخادم أعاد فشلًا يمكن قراءته على مستوى التطبيق.
/// Signals a server-side failure that the app can reason about.
class ServerFailure extends Failure {
  /// رمز إضافي قد يرسله الخادم لتصنيف الخطأ.
  /// Optional code returned by the server to classify the issue.
  final String? code;

  /// يحدد ما إذا كانت الواجهة تحتاج إلى إظهار الحوار للمستخدم.
  /// Tells the UI whether this failure should be surfaced in a dialog.
  final bool showAsDialog;

  /// يستخدم عندما يكون لدينا فشل خادم عام بدون معلومات إضافية.
  /// Used for a generic server failure without extra metadata.
  const ServerFailure([super.message = 'Server failure'])
      : code = null,
        showAsDialog = false;

  /// يستخدم عندما نعرف الرسالة أو الرمز أو نريد التحكم في طريقة العرض.
  /// Used when message, code, or dialog presentation need explicit
  /// control.
  const ServerFailure.meta({
    String message = 'Server failure',
    this.code,
    this.showAsDialog = false,
  }) : super(message);

  /// يجعل الرسالة والرمز وخيار الحوار جزءًا من المقارنة.
  /// Includes message, code, and dialog flag in equality checks.
  @override
  List<Object> get props => [message, code ?? '', showAsDialog];
}

/// يشير إلى فشل في التخزين المحلي أو القراءة منه.
/// Indicates a local storage or cache failure.
class CacheFailure extends Failure {
  /// يستخدم عندما تكون طبقة التخزين المحلي هي مصدر المشكلة.
  /// Used when the local persistence layer is the source of failure.
  const CacheFailure([super.message = 'Cache failure']);
}

/// يشير إلى أن الاتصال بالشبكة نفسه لم ينجح.
/// Indicates the network connection itself failed.
class NetworkFailure extends Failure {
  /// يستخدم عندما لا يمكن الوصول إلى الخادم بسبب الشبكة.
  /// Used when the backend cannot be reached due to connectivity.
  const NetworkFailure([super.message = 'Network failure']);
}

/// يشير إلى فشل عام في المصادقة.
/// Indicates a generic authentication failure.
class AuthFailure extends Failure {
  /// يستخدم عندما تكون المشكلة مرتبطة بتسجيل الدخول أو الجلسة.
  /// Used when the issue is tied to login or session handling.
  const AuthFailure([super.message = 'Authentication failure']);
}

/// يصف فشل التحقق مع خريطة أخطاء تفصيلية يمكن عرضها في النموذج.
/// Describes validation failure together with field-level errors that
/// a form can render.
class ValidationFailure extends Failure {
  /// رسائل التحقق المرتبطة بكل حقل أو قاعدة.
  /// Validation messages grouped by field or rule.
  final Map<String, List<String>>? errors;

  /// يستخدم عندما يفشل التحقق لكننا لا نحتاج إلى تفاصيل الحقول.
  /// Used when validation fails but field-level details are optional.
  const ValidationFailure([super.message = 'Validation failure', this.errors]);

  /// يضم الرسالة والخريطة التفصيلية في المقارنة.
  /// Includes the message and validation map in equality checks.
  @override
  List<Object> get props => [message, errors ?? {}];
}

/// يشير إلى أن المورد المطلوب غير موجود.
/// Indicates that the requested resource does not exist.
class NotFoundFailure extends Failure {
  /// يستخدم عند غياب المورد المقصود.
  /// Used when the target resource is missing.
  const NotFoundFailure([super.message = 'Resource not found']);
}

/// يشير إلى أن الطلب افتقد اعتمادًا صالحًا.
/// Indicates that the request lacked valid authorization.
class UnauthorizedFailure extends Failure {
  /// يستخدم عندما لا توجد صلاحية للدخول إلى المورد.
  /// Used when access to the resource is not permitted.
  const UnauthorizedFailure([super.message = 'Unauthorized access']);
}

/// يشير إلى أن الطلب تجاوز الزمن المسموح به.
/// Indicates that the request exceeded the allowed time.
class TimeoutFailure extends Failure {
  /// يستخدم عندما يستغرق الاتصال أو الاستجابة وقتًا أطول من اللازم.
  /// Used when the network or backend response took too long.
  const TimeoutFailure([super.message = 'Request timeout']);
}

/// يغطي الحالات التي لا نستطيع تصنيفها تحت نوع أدق.
/// Covers cases that do not fit a more specific failure type.
class UnknownFailure extends Failure {
  /// يستخدم كملاذ أخير للحالات غير المتوقعة.
  /// Used as a last resort for unexpected conditions.
  const UnknownFailure([super.message = 'Unknown failure']);
}

/// يشير إلى فشل مصادقة أعمق من مجرد غياب الصلاحية.
/// Indicates an authentication problem rather than a mere permission
/// issue.
class AuthenticationFailure extends Failure {
  /// يستخدم عند فشل التحقق من هوية المستخدم نفسها.
  /// Used when the user identity itself cannot be verified.
  const AuthenticationFailure([super.message = 'Authentication failure']);
}

/// يمثل فشلًا صريحًا من طبقة API مع رمز محدد.
/// Represents an explicit API-level failure with a specific code.
class ApiFailure extends Failure {
  /// الرمز الذي يشرح نوع الفشل الصادر من الـ API.
  /// Code that identifies the API failure type.
  final String code;

  /// يستخدم عندما يرسل الـ API رسالة ورمزًا يمكن التعامل معهما.
  /// Used when the API provides a message and code the app can act on.
  const ApiFailure({required String message, required this.code})
      : super(message);

  /// يضم الرسالة والرمز في المقارنة.
  /// Includes message and code in equality checks.
  @override
  List<Object> get props => [message, code];
}

/// يشير إلى انتهاء الجلسة المصادقة.
/// Indicates that the authenticated session has expired.
class SessionExpiredFailure extends Failure {
  /// يستخدم عندما ينبغي إعادة تسجيل الدخول.
  /// Used when the user needs to sign in again.
  const SessionExpiredFailure([super.message = 'Session expired']);
}

/// يشير إلى أن المستخدم لا يملك إذنًا كافيًا.
/// Indicates that the user lacks sufficient permission.
class PermissionDeniedFailure extends Failure {
  /// يستخدم عندما يكون المورد محجوبًا بسبب الصلاحيات.
  /// Used when access is blocked by permissions.
  const PermissionDeniedFailure([super.message = 'Permission denied']);
}

/// نسخة من فشل التحقق تحتفظ بتفاصيل الحقول كاملة.
/// Validation failure variant that keeps the full field-level detail.
class ValidationFailureWithErrors extends Failure {
  /// خرائط الأخطاء التفصيلية لكل حقل.
  /// Detailed per-field error map.
  final Map<String, List<String>> errors;

  /// يستخدم عندما يحتاج النموذج إلى عرض أخطاء حقلية مباشرة.
  /// Used when the form needs to surface direct field-level feedback.
  const ValidationFailureWithErrors(
      {required String message, required this.errors})
      : super(message);

  /// يجعل الرسالة وخريطة الأخطاء جزءًا من المقارنة.
  /// Includes the message and error map in equality checks.
  @override
  List<Object> get props => [message, errors];
}
