import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// يغلّف عملية تغيير كلمة المرور داخل حالة استخدام واضحة يمكن للـ bloc
/// استدعاؤها دون معرفة تفاصيل المصدر.
/// Wraps the password-change flow in a dedicated use case so blocs can invoke
/// it without knowing data-source details.
class ChangePasswordUseCase implements UseCase<void, ChangePasswordParams> {
  /// المستودع الذي ينفذ التغيير الفعلي على مستوى البيانات.
  /// Repository that performs the actual password change.
  final AuthRepository repository;

  /// يبني حالة الاستخدام مع مستودع المصادقة المعتمد.
  /// Creates the use case with the configured auth repository.
  ChangePasswordUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ChangePasswordParams params) async {
    return await repository.changePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
      newPasswordConfirmation: params.newPasswordConfirmation,
    );
  }
}

/// يحمل القيم المطلوبة لتغيير كلمة المرور بأمان.
/// Carries the values required to change the password safely.
class ChangePasswordParams extends Equatable {
  /// كلمة المرور الحالية لإثبات ملكية الحساب.
  /// Current password used to prove ownership of the account.
  final String currentPassword;

  /// كلمة المرور الجديدة التي يريد المستخدم اعتمادها.
  /// New password the user wants to set.
  final String newPassword;

  /// إعادة إدخال كلمة المرور الجديدة للتحقق من التطابق.
  /// Confirmation of the new password to guard against input mistakes.
  final String newPasswordConfirmation;

  const ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });
  @override
  List<Object?> get props =>
      [currentPassword, newPassword, newPasswordConfirmation];
}
