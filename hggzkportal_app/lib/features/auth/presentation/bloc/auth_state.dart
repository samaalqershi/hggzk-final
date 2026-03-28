import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// العربية: تغطي كل مراحل المصادقة من البداية وحتى تسجيل الدخول والخطأ
/// والتحديثات التالية، حتى تظل الواجهة مرتبطة بحالة واحدة واضحة.
/// Covers the full authentication lifecycle from startup to login,
/// errors, and follow-up updates so the UI stays tied to one clear state.
abstract class AuthState extends Equatable {
  /// العربية: تثبت أن حالات المصادقة تقارن وفق بياناتها فقط.
  /// Ensures authentication states compare only by the data they carry.
  const AuthState();

  /// العربية: لا توجد حقول مشتركة على مستوى القاعدة.
  /// No shared fields exist at the base level.
  @override
  List<Object?> get props => [];
}

/// العربية: حالة البداية قبل معرفة وضع الجلسة.
/// Initial state before the session status is known.
class AuthInitial extends AuthState {
  /// العربية: تمثل نقطة الانطلاق فقط.
  /// Represents the starting point only.
  const AuthInitial();
}

/// العربية: تعني أن عملية مصادقة أو تحديث حساب تعمل الآن.
/// Indicates that an authentication or account update flow is running.
class AuthLoading extends AuthState {
  /// العربية: تعلن أن النظام في مرحلة عمل مؤقتة.
  /// Signals that the system is temporarily busy.
  const AuthLoading();
}

/// العربية: تمثل جلسة صالحة لمستخدم معروف.
/// Represents a valid session for a known user.
class AuthAuthenticated extends AuthState {
  /// العربية: المستخدم الذي تم التحقق منه.
  /// Verified user attached to the session.
  final User user;

  /// العربية: تحفظ المستخدم بعد نجاح المصادقة.
  /// Holds the user after successful authentication.
  const AuthAuthenticated({
    required this.user,
  });

  /// العربية: تعتمد المقارنة على المستخدم الحالي فقط.
  /// Equality depends on the current user only.
  @override
  List<Object?> get props => [user];
}

/// العربية: تمثل غياب جلسة صالحة.
/// Represents the absence of a valid session.
class AuthUnauthenticated extends AuthState {
  /// العربية: تشير إلى أن التطبيق يحتاج تسجيل دخول.
  /// Indicates the app needs a login.
  const AuthUnauthenticated();
}

/// العربية: تمثل فشلًا في المصادقة مع رسالة مناسبة للعرض.
/// Represents an authentication failure with a displayable message.
class AuthError extends AuthState {
  /// العربية: رسالة الخطأ المعروضة للمستخدم.
  /// Error message shown to the user.
  final String message;

  /// العربية: تسجل الفشل مع النص الذي يوضحه.
  /// Records the failure together with its explanation.
  const AuthError({
    required this.message,
  });

  /// العربية: تعتمد المقارنة على الرسالة فقط.
  /// Equality depends on the message only.
  @override
  List<Object?> get props => [message];
}

/// العربية: تمثل نجاح تسجيل الدخول قبل انتقال الواجهة إلى الحالة النهائية.
/// Represents a successful login before the UI settles on the final authenticated state.
class AuthLoginSuccess extends AuthState {
  /// العربية: المستخدم الذي تم تسجيل دخوله بنجاح.
  /// User who just logged in successfully.
  final User user;

  /// العربية: تحتفظ بالمستخدم بعد نجاح تسجيل الدخول.
  /// Holds the user after login succeeds.
  const AuthLoginSuccess({
    required this.user,
  });

  /// العربية: تعتمد المقارنة على المستخدم المسجل فقط.
  /// Equality depends on the logged-in user only.
  @override
  List<Object?> get props => [user];
}

/// العربية: تمثل نجاح إنشاء حساب جديد.
/// Represents successful account creation.
class AuthRegistrationSuccess extends AuthState {
  /// العربية: المستخدم الذي أنشئ حسابه للتو.
  /// User whose account was just created.
  final User user;

  /// العربية: تحتفظ بالمستخدم بعد نجاح التسجيل.
  /// Holds the user after registration succeeds.
  const AuthRegistrationSuccess({
    required this.user,
  });

  /// العربية: تعتمد المقارنة على المستخدم الناتج عن التسجيل.
  /// Equality depends on the user returned by registration.
  @override
  List<Object?> get props => [user];
}

/// العربية: تمثل اكتمال تسجيل الخروج.
/// Represents a completed logout.
class AuthLogoutSuccess extends AuthState {
  /// العربية: تؤكد أن الجلسة أغلقت بنجاح.
  /// Confirms the session was closed successfully.
  const AuthLogoutSuccess();
}

/// العربية: تمثل إرسال طلب إعادة تعيين كلمة المرور بنجاح.
/// Represents a successfully sent password-reset request.
class AuthPasswordResetSent extends AuthState {
  /// العربية: الرسالة التي تعرض بعد إرسال الطلب.
  /// Message shown after the request is sent.
  final String message;

  /// العربية: تحتفظ برسالة التأكيد المرتبطة بإرسال الطلب.
  /// Holds the confirmation text for the request.
  const AuthPasswordResetSent({
    required this.message,
  });

  /// العربية: تعتمد المقارنة على الرسالة.
  /// Equality depends on the message.
  @override
  List<Object?> get props => [message];
}

/// العربية: تمثل نجاح تحديث الملف الشخصي.
/// Represents a successful profile update.
class AuthProfileUpdateSuccess extends AuthState {
  /// العربية: المستخدم بعد التحديث.
  /// User after the update.
  final User user;

  /// العربية: تحتفظ بالمستخدم المحدث.
  /// Holds the updated user.
  const AuthProfileUpdateSuccess({
    required this.user,
  });

  /// العربية: تعتمد المقارنة على المستخدم المحدث.
  /// Equality depends on the updated user.
  @override
  List<Object?> get props => [user];
}

/// العربية: تمثل نجاح رفع صورة الملف الشخصي.
/// Represents a successful profile image upload.
class AuthProfileImageUploadSuccess extends AuthState {
  /// العربية: المستخدم بعد تحديث الصورة.
  /// User after the image update.
  final User user;

  /// العربية: تحتفظ بالمستخدم بعد رفع الصورة.
  /// Holds the user after the image upload.
  const AuthProfileImageUploadSuccess({
    required this.user,
  });

  /// العربية: تعتمد المقارنة على المستخدم المحدث.
  /// Equality depends on the updated user.
  @override
  List<Object?> get props => [user];
}

/// العربية: تمثل نجاح تغيير كلمة المرور.
/// Represents a successful password change.
class AuthPasswordChangeSuccess extends AuthState {
  /// العربية: رسالة النجاح التي تظهر للمستخدم.
  /// Success message shown to the user.
  final String message;

  /// العربية: تحتفظ برسالة النجاح.
  /// Holds the success message.
  const AuthPasswordChangeSuccess({
    this.message = 'تم تغيير كلمة المرور بنجاح',
  });

  /// العربية: تعتمد المقارنة على الرسالة.
  /// Equality depends on the message.
  @override
  List<Object?> get props => [message];
}

/// العربية: تمثل نجاح حذف الحساب.
/// Represents a successful account deletion.
class AuthAccountDeleteSuccess extends AuthState {
  /// العربية: رسالة النجاح التي تظهر بعد الحذف.
  /// Success message shown after deletion.
  final String message;

  /// العربية: تحتفظ برسالة نجاح حذف الحساب.
  /// Holds the account deletion success text.
  const AuthAccountDeleteSuccess({
    this.message = 'تم حذف الحساب بنجاح',
  });

  /// العربية: تعتمد المقارنة على الرسالة.
  /// Equality depends on the message.
  @override
  List<Object?> get props => [message];
}
