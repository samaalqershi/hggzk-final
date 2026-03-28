import 'package:equatable/equatable.dart';

/// يمثل كل المحفزات القادمة من واجهات المصادقة نحو `AuthBloc`.
/// Represents every trigger sent from auth UI surfaces into `AuthBloc`.
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

/// يطلب من الـ bloc فحص وجود جلسة قابلة للاستعادة.
/// Asks the bloc to check whether a session can be restored.
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

/// يحمل بيانات تسجيل الدخول التقليدي من الواجهة.
/// Carries the classic sign-in payload from the UI.
class LoginEvent extends AuthEvent {
  /// البريد الإلكتروني أو الهاتف المستخدم للتسجيل.
  /// Email address or phone number used for sign-in.
  final String emailOrPhone;

  /// كلمة المرور التي أدخلها المستخدم.
  /// Password entered by the user.
  final String password;

  /// يحدد ما إذا كان المستخدم يريد تذكر جلسته.
  /// Indicates whether the user wants the session to be remembered.
  final bool rememberMe;
  const LoginEvent({
    required this.emailOrPhone,
    required this.password,
    this.rememberMe = false,
  });
  @override
  List<Object?> get props => [emailOrPhone, password, rememberMe];
}

/// يطلب استئناف الجلسة عبر رمز تحديث محفوظ.
/// Requests a session restore using a cached refresh token.
class LoginWithRefreshTokenEvent extends AuthEvent {
  /// رمز التحديث المستخدم لإعادة بناء الجلسة.
  /// Refresh token used to rebuild the session.
  final String refreshToken;
  const LoginWithRefreshTokenEvent({required this.refreshToken});
  @override
  List<Object?> get props => [refreshToken];
}

/// يحمل بيانات إنشاء الحساب من شاشة التسجيل.
/// Carries the sign-up payload collected by the registration screen.
class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String passwordConfirmation;
  const RegisterEvent({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
  });
  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        password,
        passwordConfirmation,
      ];
}

/// يطلب إنهاء الجلسة الحالية.
/// Requests termination of the current authenticated session.
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

/// يطلق مسار إعادة تعيين كلمة المرور.
/// Starts the password-reset flow.
class ResetPasswordEvent extends AuthEvent {
  final String emailOrPhone;
  const ResetPasswordEvent({
    required this.emailOrPhone,
  });
  @override
  List<Object?> get props => [emailOrPhone];
}

/// يحمل تعديلات الملف الشخصي المراد تطبيقها.
/// Carries the profile edits that should be applied.
class UpdateProfileEvent extends AuthEvent {
  final String name;
  final String? email;
  final String? phone;
  const UpdateProfileEvent({
    required this.name,
    this.email,
    this.phone,
  });
  @override
  List<Object?> get props => [name, email, phone];
}

class ChangePasswordEvent extends AuthEvent {
  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirmation;
  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });
  @override
  List<Object?> get props =>
      [currentPassword, newPassword, newPasswordConfirmation];
}

/// يطلب رفع صورة ملف شخصي جديدة.
/// Requests uploading a new profile image.
class UploadProfileImageEvent extends AuthEvent {
  final String imagePath;
  const UploadProfileImageEvent({
    required this.imagePath,
  });
  @override
  List<Object?> get props => [imagePath];
}

/// يطلب حذف الحساب مع وسيلة التأكيد المناسبة.
/// Requests account deletion with the selected confirmation method.
class DeleteAccountEvent extends AuthEvent {
  final String? password;
  final String? socialProvider;
  final String? socialToken;
  final String? socialNonce;
  final String? reason;
  const DeleteAccountEvent({
    this.password,
    this.socialProvider,
    this.socialToken,
    this.socialNonce,
    this.reason,
  });
  @override
  List<Object?> get props => [
        password,
        socialProvider,
        socialToken,
        socialNonce,
        reason,
      ];
}

/// يطلق تسجيل الدخول عبر مزود هوية خارجي.
/// Starts sign-in through an external identity provider.
class SocialLoginEvent extends AuthEvent {
  final SocialLoginProvider provider;
  final String token;
  final String? nonce;
  final String? name;
  const SocialLoginEvent({
    required this.provider,
    required this.token,
    this.nonce,
    this.name,
  });
  @override
  List<Object?> get props => [provider, token, nonce, name];
}

/// يحدد مزودي تسجيل الدخول الاجتماعي المدعومين في الواجهة.
/// Lists the social sign-in providers supported by the UI.
enum SocialLoginProvider {
  google,
  facebook,
  apple,
}
