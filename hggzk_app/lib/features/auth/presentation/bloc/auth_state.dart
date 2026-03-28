import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// يمثل اللقطات المختلفة لحالة المصادقة كما تراها الواجهة.
/// Represents the different authentication snapshots observed by the UI.
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

/// الحالة الابتدائية قبل تنفيذ أي فحص أو طلب مصادقة.
/// Initial state before any auth check or request has run.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// حالة عامة تشير إلى وجود عملية مصادقة جارية.
/// Generic loading state that signals an auth operation is in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// حالة تؤكد وجود مستخدم مصادق وجاهز للاستخدام داخل التطبيق.
/// State confirming that an authenticated user is available to the app.
class AuthAuthenticated extends AuthState {
  /// بيانات المستخدم الحالية المرتبطة بالجلسة النشطة.
  /// Current user data associated with the active session.
  final User user;
  const AuthAuthenticated({
    required this.user,
  });
  @override
  List<Object?> get props => [user];
}

/// حالة تشير إلى غياب أي جلسة صالحة.
/// State indicating that no valid authenticated session exists.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// تحمل رسالة خطأ يمكن للواجهة عرضها بعد فشل عملية مصادقة.
/// Carries an error message the UI can surface after an auth failure.
class AuthError extends AuthState {
  final String message;
  const AuthError({
    required this.message,
  });
  @override
  List<Object?> get props => [message];
}

/// حالة انتقالية بعد نجاح تسجيل الدخول مباشرة.
/// Transitional state emitted right after a successful login.
class AuthLoginSuccess extends AuthState {
  final User user;
  const AuthLoginSuccess({
    required this.user,
  });
  @override
  List<Object?> get props => [user];
}

/// حالة انتقالية بعد نجاح إنشاء الحساب.
/// Transitional state emitted after a successful registration.
class AuthRegistrationSuccess extends AuthState {
  final User user;
  const AuthRegistrationSuccess({
    required this.user,
  });
  @override
  List<Object?> get props => [user];
}

/// تؤكد أن عملية تسجيل الخروج اكتملت.
/// Confirms that logout completed successfully.
class AuthLogoutSuccess extends AuthState {
  const AuthLogoutSuccess();
}

/// تؤكد إرسال تعليمات إعادة تعيين كلمة المرور.
/// Confirms that password-reset instructions were sent.
class AuthPasswordResetSent extends AuthState {
  final String message;
  const AuthPasswordResetSent({
    required this.message,
  });
  @override
  List<Object?> get props => [message];
}

/// تؤكد نجاح تحديث الملف الشخصي مع البيانات الجديدة.
/// Confirms a successful profile update together with the refreshed user.
class AuthProfileUpdateSuccess extends AuthState {
  final User user;
  const AuthProfileUpdateSuccess({
    required this.user,
  });
  @override
  List<Object?> get props => [user];
}

/// تؤكد نجاح رفع صورة الملف الشخصي.
/// Confirms that the profile image upload completed successfully.
class AuthProfileImageUploadSuccess extends AuthState {
  final User user;
  const AuthProfileImageUploadSuccess({
    required this.user,
  });
  @override
  List<Object?> get props => [user];
}

/// تؤكد نجاح تغيير كلمة المرور.
/// Confirms a successful password change.
class AuthPasswordChangeSuccess extends AuthState {
  final String message;
  const AuthPasswordChangeSuccess({
    this.message = 'تم تغيير كلمة المرور بنجاح',
  });
  @override
  List<Object?> get props => [message];
}

/// تؤكد نجاح حذف الحساب.
/// Confirms that account deletion completed successfully.
class AuthAccountDeleteSuccess extends AuthState {
  final String message;
  const AuthAccountDeleteSuccess({
    this.message = 'تم حذف الحساب بنجاح',
  });
  @override
  List<Object?> get props => [message];
}
