import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_response.dart';
import '../repositories/auth_repository.dart';

/// يغلّف عملية تسجيل الدخول التقليدية داخل حالة استخدام قابلة للاختبار
/// وإعادة الاستخدام.
/// Encapsulates the classic sign-in flow inside a reusable and testable use
/// case.
class LoginUseCase implements UseCase<AuthResponse, LoginParams> {
  /// المستودع الذي ينفذ طلب المصادقة الفعلي.
  /// Repository that performs the actual sign-in request.
  final AuthRepository repository;

  /// ينشئ حالة الاستخدام مع مستودع المصادقة.
  /// Creates the use case with the auth repository.
  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResponse>> call(LoginParams params) async {
    return await repository.login(
      emailOrPhone: params.emailOrPhone,
      password: params.password,
      rememberMe: params.rememberMe,
    );
  }
}

/// يحمل القيم الأساسية اللازمة لتسجيل الدخول من واجهة العميل.
/// Carries the core values required to sign in from the client UI.
class LoginParams extends Equatable {
  /// البريد الإلكتروني أو رقم الهاتف الذي يستخدمه المستخدم للتعريف بنفسه.
  /// Email address or phone number used to identify the user.
  final String emailOrPhone;

  /// كلمة المرور المدخلة لتسجيل الدخول.
  /// Password entered for authentication.
  final String password;

  /// يحدد ما إذا كان ينبغي تفضيل جلسة أطول أو حفظ هوية المستخدم محليًا.
  /// Indicates whether a longer-lived or remembered session is preferred.
  final bool rememberMe;

  const LoginParams({
    required this.emailOrPhone,
    required this.password,
    this.rememberMe = false,
  });
  @override
  List<Object?> get props => [emailOrPhone, password, rememberMe];
}
