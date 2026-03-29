import 'package:equatable/equatable.dart';
import 'package:hggzk/core/localization/app_localizations.dart';

String _normalizeFailureMessage(String message) {
  final normalized = message.trim();
  if (normalized.isEmpty) {
    return AppLocalizations.translateSync('common.unexpectedError');
  }

  const directMap = <String, String>{
    'Server error occurred': 'common.serverError',
    'Invalid language code': 'common.invalidLanguageCode',
  };

  final directKey = directMap[normalized];
  if (directKey != null) {
    return AppLocalizations.translateSync(directKey);
  }

  if (normalized.startsWith('Invalid response structure') ||
      normalized == 'Invalid response format' ||
      normalized == 'Invalid availability response format' ||
      normalized == 'Invalid amenity GUIDs provided' ||
      normalized == 'Invalid service GUIDs provided') {
    return AppLocalizations.translateSync('common.invalidResponse');
  }

  if (normalized == 'Invalid date value' ||
      normalized.startsWith('FormatException:')) {
    return AppLocalizations.translateSync('common.invalidData');
  }

  if (normalized.contains('feature not initialized')) {
    return AppLocalizations.translateSync('common.featureNotInitialized');
  }

  if (normalized.startsWith('Network error')) {
    return AppLocalizations.translateSync('common.noInternet');
  }

  if (normalized.startsWith('SocketException') ||
      normalized.contains('xmlhttprequest error')) {
    return AppLocalizations.translateSync('common.noInternet');
  }

  if (normalized.startsWith('Unexpected error:') ||
      normalized.startsWith('Exception:') ||
      normalized.startsWith('DioException') ||
      normalized.startsWith('HttpException') ||
      normalized.startsWith('PlatformException') ||
      normalized.startsWith('type ') ||
      normalized.contains('is not a subtype of type') ||
      normalized.contains('null check operator used on a null value')) {
    return AppLocalizations.translateSync('common.unexpectedError');
  }

  if (normalized.contains('cache expired') ||
      normalized.contains('no cached ')) {
    return AppLocalizations.translateSync('common.localStorageError');
  }

  if (normalized == 'Failed to refresh access token') {
    return AppLocalizations.translateSync('common.sessionExpired');
  }

  if (normalized == 'Search failed' || normalized.startsWith('Failed to ')) {
    return AppLocalizations.translateSync('common.operationFailed');
  }

  return normalized;
}

/// يمثل الطبقة العليا لجميع حالات الفشل التي يقرأها منطق المجال
/// ويحوّلها إلى رسائل أو حالات UI مفهومة.
/// Base type for failures that domain and presentation layers can turn
/// into predictable messages or states.
abstract class Failure extends Equatable {
  /// الرسالة المرافقة للفشل والمقصودة لعرضها أو تسجيلها.
  /// The message attached to the failure for display or logging.
  final String _message;

  /// النص الخام قبل التطبيع المركزي.
  /// Raw message before centralized normalization.
  String get rawMessage => _message;

  /// الرسالة النهائية بعد تمريرها على مطبّع الرسائل المركزي.
  /// Final message after applying centralized normalization.
  String get message => _normalizeFailureMessage(_message);

  /// يتيح إنشاء فشل عام عندما لا يوجد نوع أكثر تخصصًا.
  /// Allows a generic failure when no more specific subtype fits.
  Failure([String? message])
      : _message =
            message ?? AppLocalizations.translateSync('common.unexpectedError');

  /// يحدد الرسالة وحدها كأساس للمقارنة.
  /// Uses the message as the equality anchor.
  @override
  List<Object> get props => [_message];
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
  ServerFailure([String? message])
      : code = null,
        showAsDialog = false,
        super(message ?? AppLocalizations.translateSync('common.serverError'));

  /// يستخدم عندما نعرف الرسالة أو الرمز أو نريد التحكم في طريقة العرض.
  /// Used when message, code, or dialog presentation need explicit
  /// control.
  ServerFailure.meta({
    String? message,
    this.code,
    this.showAsDialog = false,
  }) : super(message ?? AppLocalizations.translateSync('common.serverError'));

  /// يجعل الرسالة والرمز وخيار الحوار جزءًا من المقارنة.
  /// Includes message, code, and dialog flag in equality checks.
  @override
  List<Object> get props => [rawMessage, code ?? '', showAsDialog];
}

/// يشير إلى فشل في التخزين المحلي أو القراءة منه.
/// Indicates a local storage or cache failure.
class CacheFailure extends Failure {
  /// يستخدم عندما تكون طبقة التخزين المحلي هي مصدر المشكلة.
  /// Used when the local persistence layer is the source of failure.
  CacheFailure([String? message])
      : super(
          message ?? AppLocalizations.translateSync('common.localStorageError'),
        );
}

/// يشير إلى أن الاتصال بالشبكة نفسه لم ينجح.
/// Indicates the network connection itself failed.
class NetworkFailure extends Failure {
  /// يستخدم عندما لا يمكن الوصول إلى الخادم بسبب الشبكة.
  /// Used when the backend cannot be reached due to connectivity.
  NetworkFailure([String? message])
      : super(message ?? AppLocalizations.translateSync('common.noInternet'));
}

/// يشير إلى فشل عام في المصادقة.
/// Indicates a generic authentication failure.
class AuthFailure extends Failure {
  /// يستخدم عندما تكون المشكلة مرتبطة بتسجيل الدخول أو الجلسة.
  /// Used when the issue is tied to login or session handling.
  AuthFailure([String? message])
      : super(
          message ?? AppLocalizations.translateSync('common.unauthorized'),
        );
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
  ValidationFailure([String? message, this.errors])
      : super(message ?? AppLocalizations.translateSync('common.invalidData'));

  /// يضم الرسالة والخريطة التفصيلية في المقارنة.
  /// Includes the message and validation map in equality checks.
  @override
  List<Object> get props => [rawMessage, errors ?? {}];
}

/// يشير إلى أن المورد المطلوب غير موجود.
/// Indicates that the requested resource does not exist.
class NotFoundFailure extends Failure {
  /// يستخدم عند غياب المورد المقصود.
  /// Used when the target resource is missing.
  NotFoundFailure([String? message])
      : super(message ?? AppLocalizations.translateSync('common.notFound'));
}

/// يشير إلى أن الطلب افتقد اعتمادًا صالحًا.
/// Indicates that the request lacked valid authorization.
class UnauthorizedFailure extends Failure {
  /// يستخدم عندما لا توجد صلاحية للدخول إلى المورد.
  /// Used when access to the resource is not permitted.
  UnauthorizedFailure([String? message])
      : super(message ?? AppLocalizations.translateSync('common.unauthorized'));
}

/// يشير إلى أن الطلب تجاوز الزمن المسموح به.
/// Indicates that the request exceeded the allowed time.
class TimeoutFailure extends Failure {
  /// يستخدم عندما يستغرق الاتصال أو الاستجابة وقتًا أطول من اللازم.
  /// Used when the network or backend response took too long.
  TimeoutFailure([String? message])
      : super(
          message ?? AppLocalizations.translateSync('common.requestTimeout'),
        );
}

/// يغطي الحالات التي لا نستطيع تصنيفها تحت نوع أدق.
/// Covers cases that do not fit a more specific failure type.
class UnknownFailure extends Failure {
  /// يستخدم كملاذ أخير للحالات غير المتوقعة.
  /// Used as a last resort for unexpected conditions.
  UnknownFailure([String? message])
      : super(
          message ?? AppLocalizations.translateSync('common.unexpectedError'),
        );
}

/// يشير إلى فشل مصادقة أعمق من مجرد غياب الصلاحية.
/// Indicates an authentication problem rather than a mere permission
/// issue.
class AuthenticationFailure extends Failure {
  /// يستخدم عند فشل التحقق من هوية المستخدم نفسها.
  /// Used when the user identity itself cannot be verified.
  AuthenticationFailure([String? message])
      : super(
          message ?? AppLocalizations.translateSync('common.unauthorized'),
        );
}

/// يمثل فشلًا صريحًا من طبقة API مع رمز محدد.
/// Represents an explicit API-level failure with a specific code.
class ApiFailure extends Failure {
  /// الرمز الذي يشرح نوع الفشل الصادر من الـ API.
  /// Code that identifies the API failure type.
  final String code;

  /// يستخدم عندما يرسل الـ API رسالة ورمزًا يمكن التعامل معهما.
  /// Used when the API provides a message and code the app can act on.
  ApiFailure({required String message, required this.code}) : super(message);

  /// يضم الرسالة والرمز في المقارنة.
  /// Includes message and code in equality checks.
  @override
  List<Object> get props => [rawMessage, code];
}

/// يشير إلى انتهاء الجلسة المصادقة.
/// Indicates that the authenticated session has expired.
class SessionExpiredFailure extends Failure {
  /// يستخدم عندما ينبغي إعادة تسجيل الدخول.
  /// Used when the user needs to sign in again.
  SessionExpiredFailure([String? message])
      : super(
          message ?? AppLocalizations.translateSync('common.sessionExpired'),
        );
}

/// يشير إلى أن المستخدم لا يملك إذنًا كافيًا.
/// Indicates that the user lacks sufficient permission.
class PermissionDeniedFailure extends Failure {
  /// يستخدم عندما يكون المورد محجوبًا بسبب الصلاحيات.
  /// Used when access is blocked by permissions.
  PermissionDeniedFailure([String? message])
      : super(
          message ?? AppLocalizations.translateSync('common.permissionDenied'),
        );
}

/// نسخة من فشل التحقق تحتفظ بتفاصيل الحقول كاملة.
/// Validation failure variant that keeps the full field-level detail.
class ValidationFailureWithErrors extends Failure {
  /// خرائط الأخطاء التفصيلية لكل حقل.
  /// Detailed per-field error map.
  final Map<String, List<String>> errors;

  /// يستخدم عندما يحتاج النموذج إلى عرض أخطاء حقلية مباشرة.
  /// Used when the form needs to surface direct field-level feedback.
  ValidationFailureWithErrors({required String message, required this.errors})
      : super(message);

  /// يجعل الرسالة وخريطة الأخطاء جزءًا من المقارنة.
  /// Includes the message and error map in equality checks.
  @override
  List<Object> get props => [rawMessage, errors];
}
