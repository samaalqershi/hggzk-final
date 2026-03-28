import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// يطلق مسار استرجاع كلمة المرور عبر الهوية التي أدخلها المستخدم.
/// Starts the password-recovery flow using the identifier supplied by the
/// user.
class ResetPasswordUseCase implements UseCase<void, ResetPasswordParams> {
  /// المستودع الذي يتواصل مع الخادم لتنفيذ طلب الاسترجاع.
  /// Repository that communicates with the backend for password recovery.
  final AuthRepository repository;

  /// ينشئ حالة الاستخدام مع مستودع المصادقة.
  /// Creates the use case with the auth repository.
  ResetPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) async {
    return await repository.resetPassword(
      emailOrPhone: params.emailOrPhone,
    );
  }
}

/// يحمل هوية المستخدم اللازمة لبدء إعادة تعيين كلمة المرور.
/// Holds the user identifier required to begin password reset.
class ResetPasswordParams extends Equatable {
  /// البريد الإلكتروني أو رقم الهاتف الذي يحدد الحساب المستهدف.
  /// Email address or phone number that identifies the target account.
  final String emailOrPhone;

  const ResetPasswordParams({
    required this.emailOrPhone,
  });
  @override
  List<Object?> get props => [emailOrPhone];
}
