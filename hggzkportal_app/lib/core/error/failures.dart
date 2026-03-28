import 'package:equatable/equatable.dart';

/// Value object that models a recoverable failure and carries a user-facing message.
/// كائن قيمة يمثّل فشلًا يمكن التعامل معه ويحمل رسالة قابلة للعرض.
abstract class Failure extends Equatable {
  /// Default explanation that can be shown when no specific reason is available.
  /// الرسالة الافتراضية التي يمكن عرضها عندما لا تتوفر تفاصيل أدق.
  final String message;

  /// ينشئ فشلًا أساسيًا يحمل الرسالة المشتركة التي تعتمد عليها كل الأنواع
  /// الفرعية.
  /// Creates the base failure object carrying the shared message used by all
  /// specialized failure types.
  const Failure([this.message = 'An unexpected error occurred']);

  /// يعيد الحقول التي تحدد المساواة بين حالات الفشل.
  /// Returns the fields that define equality between failure instances.
  @override
  List<Object> get props => [message];
}

/// Represents a failure returned by the remote API or its mapping layer.
/// يمثّل فشلًا صادرًا من الـ API أو من طبقة تحويل البيانات.
class ServerFailure extends Failure {
  /// Optional backend code used to classify the failure.
  /// كود اختياري من الخادم يساعد في تصنيف الفشل.
  final String? code;

  /// Controls whether the UI should escalate the failure into a dialog.
  /// يحدد ما إذا كانت الواجهة يجب أن ترفع الفشل إلى حوار بدلاً من إشعار بسيط.
  final bool showAsDialog;

  /// ينشئ فشل خادم قياسيًا عندما لا نحتاج إلى بيانات وصفية إضافية.
  /// Creates a standard server failure when no extra metadata is needed.
  const ServerFailure([super.message = 'Server failure'])
      : code = null,
        showAsDialog = false;

  /// ينشئ فشل خادم غنيًا بالبيانات الوصفية مثل الكود وطريقة العرض.
  /// Creates a metadata-rich server failure with an optional code and display
  /// hint.
  const ServerFailure.meta({
    String message = 'Server failure',
    this.code,
    this.showAsDialog = false,
  }) : super(message);

  /// يعيد الحقول المستخدمة لمقارنة حالات فشل الخادم بالكامل.
  /// Returns the fields used to compare server failures comprehensively.
  @override
  List<Object> get props => [message, code ?? '', showAsDialog];
}

/// Failure produced when a cached read or write operation cannot be completed.
/// فشل ينتج عندما يتعذر إكمال عملية قراءة أو كتابة على التخزين المحلي.
class CacheFailure extends Failure {
  /// ينشئ فشل تخزين محلي عندما يتعذر إتمام قراءة أو كتابة من الكاش.
  /// Creates a cache failure when a local read or write cannot be completed.
  const CacheFailure([super.message = 'Cache failure']);
}

/// Failure raised when the app cannot reach the network layer.
/// فشل يظهر عندما لا يستطيع التطبيق الوصول إلى طبقة الشبكة.
class NetworkFailure extends Failure {
  /// ينشئ فشل شبكة عندما يتعذر الوصول إلى الاتصال أو الخدمة البعيدة.
  /// Creates a network failure when connectivity or remote reachability
  /// breaks down.
  const NetworkFailure([super.message = 'Network failure']);
}

/// Failure used when authentication prerequisites are not satisfied.
/// فشل يستخدم عندما لا تتحقق شروط المصادقة.
class AuthFailure extends Failure {
  /// ينشئ فشل مصادقة عام عندما لا تتحقق شروط الدخول أو التوثيق.
  /// Creates a generic authentication failure when sign-in requirements are
  /// not satisfied.
  const AuthFailure([super.message = 'Authentication failure']);
}

/// Failure that carries validation messages for the offending fields.
/// فشل يحمل رسائل التحقق الخاصة بالحقول المخالفة.
class ValidationFailure extends Failure {
  /// Field-level validation errors grouped by name.
  /// أخطاء التحقق المفهرسة بحسب اسم الحقل.
  final Map<String, List<String>>? errors;

  /// ينشئ فشل تحقق مع رسالة عامة وخريطة أخطاء حقول اختيارية.
  /// Creates a validation failure with a summary message and optional field
  /// error map.
  const ValidationFailure([super.message = 'Validation failure', this.errors]);

  /// يعيد الحقول التي تحدد المساواة بين أخطاء التحقق.
  /// Returns the fields that define equality between validation failures.
  @override
  List<Object> get props => [message, errors ?? {}];
}

/// Failure returned when the requested item does not exist.
/// فشل يعود عندما لا يكون العنصر المطلوب موجودًا.
class NotFoundFailure extends Failure {
  /// ينشئ فشل عدم وجود عند طلب مورد غير متاح أو محذوف.
  /// Creates a not-found failure when a requested resource is missing or has
  /// been removed.
  const NotFoundFailure([super.message = 'Resource not found']);
}

/// Failure used when access is denied before or after authentication.
/// فشل يستخدم عند رفض الوصول قبل المصادقة أو بعدها.
class UnauthorizedFailure extends Failure {
  /// ينشئ فشل تفويض عندما يرفض النظام الوصول إلى المورد المطلوب.
  /// Creates an unauthorized failure when the system denies access to the
  /// requested resource.
  const UnauthorizedFailure([super.message = 'Unauthorized access']);
}

/// Failure used when the server takes too long to respond.
/// فشل يستخدم عندما يتأخر رد الخادم أكثر من اللازم.
class TimeoutFailure extends Failure {
  /// ينشئ فشل مهلة عندما يتأخر تنفيذ الطلب أو الاستجابة أكثر من المتوقع.
  /// Creates a timeout failure when request execution or response time exceeds
  /// expectations.
  const TimeoutFailure([super.message = 'Request timeout']);
}

/// Catch-all failure for cases where the app cannot classify the problem.
/// فشل عام للحالات التي لا يستطيع التطبيق تصنيف المشكلة فيها.
class UnknownFailure extends Failure {
  /// ينشئ فشلًا عامًا للحالات التي لا يمكن تصنيفها بدقة.
  /// Creates a catch-all failure for cases that cannot be classified
  /// precisely.
  const UnknownFailure([super.message = 'Unknown failure']);
}

/// Failure dedicated to login and token-refresh problems.
/// فشل مخصص لمشاكل تسجيل الدخول وتجديد التوكن.
class AuthenticationFailure extends Failure {
  /// ينشئ فشل مصادقة مخصصًا لعمليات الدخول وتجديد الجلسة.
  /// Creates a specialized authentication failure for login and session
  /// renewal flows.
  const AuthenticationFailure([super.message = 'Authentication failure']);
}

/// Failure that preserves the backend message and machine code together.
/// فشل يحتفظ برسالة الخادم والرمز الآلي معًا.
class ApiFailure extends Failure {
  /// Stable error code emitted by the backend.
  /// الرمز الثابت الذي يعيده الخادم.
  final String code;

  /// ينشئ فشل API يجمع الرسالة البشرية مع الكود التقني القادم من الخادم.
  /// Creates an API failure that combines a user-facing message with the
  /// backend's technical code.
  const ApiFailure({required String message, required this.code})
      : super(message);

  /// يعيد الرسالة والكود لأنهما معًا يحددان هوية هذا الفشل.
  /// Returns the message and code together because both define this failure.
  @override
  List<Object> get props => [message, code];
}

/// Failure used when the user session must be renewed.
/// فشل يستخدم عندما تحتاج الجلسة إلى تجديد.
class SessionExpiredFailure extends Failure {
  /// ينشئ فشل انتهاء جلسة عندما يحتاج المستخدم إلى المصادقة من جديد.
  /// Creates a session-expired failure when the user must authenticate again.
  const SessionExpiredFailure([super.message = 'Session expired']);
}

/// Failure that tells the UI a permission was refused by policy or the user.
/// فشل يوضح أن الإذن رُفض بسبب السياسة أو بسبب قرار المستخدم.
class PermissionDeniedFailure extends Failure {
  /// ينشئ فشل رفض إذن عندما تمنع السياسة أو النظام تنفيذ العملية.
  /// Creates a permission-denied failure when policy or system rules block
  /// the operation.
  const PermissionDeniedFailure([super.message = 'Permission denied']);
}

/// Validation failure that requires a non-null error map.
/// فشل تحقق يفرض وجود خريطة أخطاء غير فارغة.
class ValidationFailureWithErrors extends Failure {
  /// Concrete validation messages grouped by field.
  /// رسائل التحقق العملية مفهرسة بحسب الحقل.
  final Map<String, List<String>> errors;

  /// ينشئ فشل تحقق يفرض وجود خريطة أخطاء عملية غير فارغة.
  /// Creates a validation failure that guarantees a concrete non-null field
  /// errors map.
  const ValidationFailureWithErrors(
      {required String message, required this.errors})
      : super(message);

  /// يعيد الرسالة وخريطة الأخطاء لأنهما يمثلان هوية فشل التحقق هذا.
  /// Returns the message and errors map because together they define this
  /// validation failure.
  @override
  List<Object> get props => [message, errors];
}
