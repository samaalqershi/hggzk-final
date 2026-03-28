import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_response.dart';
import '../repositories/auth_repository.dart';

/// ينفذ إنشاء حساب جديد ويعيد استجابة المصادقة الأولية عند النجاح.
/// Executes account registration and returns the initial auth response on
/// success.
class RegisterUseCase implements UseCase<AuthResponse, RegisterParams> {
  /// المستودع الذي ينفذ عملية التسجيل الفعلية.
  /// Repository that performs the actual registration flow.
  final AuthRepository repository;

  /// ينشئ حالة الاستخدام مع مستودع المصادقة.
  /// Creates the use case with the auth repository.
  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResponse>> call(RegisterParams params) async {
    return await repository.register(
      name: params.name,
      email: params.email,
      phone: params.phone,
      password: params.password,
      passwordConfirmation: params.passwordConfirmation,
    );
  }
}

/// يحمل بيانات التسجيل الأساسية القادمة من شاشة إنشاء الحساب.
/// Holds the registration payload collected from the sign-up UI.
class RegisterParams extends Equatable {
  /// الاسم الكامل الظاهر للمستخدم داخل التطبيق.
  /// Full display name for the new user.
  final String name;

  /// البريد الإلكتروني الذي سيُربط بالحساب.
  /// Email address that will be linked to the account.
  final String email;

  /// رقم الهاتف المستخدم للتواصل أو التحقق.
  /// Phone number used for contact or verification.
  final String phone;

  /// كلمة المرور الأولية التي يختارها المستخدم.
  /// Initial password chosen by the user.
  final String password;

  /// تأكيد كلمة المرور لضمان صحة الإدخال قبل الإرسال.
  /// Password confirmation used to validate the entry before submission.
  final String passwordConfirmation;

  const RegisterParams({
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
