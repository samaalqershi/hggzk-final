import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// يعرّف الكلاس `ChangePasswordUseCase`.
/// Describes the `ChangePasswordUseCase` class.
class ChangePasswordUseCase implements UseCase<void, ChangePasswordParams> {
  /// Holds the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final AuthRepository repository;

  /// ينشئ مثيلاً من `ChangePasswordUseCase`.
  /// Builds an instance of `ChangePasswordUseCase`.
  ChangePasswordUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  @override
  Future<Either<Failure, void>> call(ChangePasswordParams params) async {
    return await repository.changePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
      newPasswordConfirmation: params.newPasswordConfirmation,
    );
  }
}

/// يعرّف الكلاس `ChangePasswordParams`.
/// Describes the `ChangePasswordParams` class.
class ChangePasswordParams extends Equatable {
  /// Holds the `currentPassword` value.
  /// العربية: يخزن القيمة `currentPassword`.
  final String currentPassword;

  /// يخزن العضو `newPassword`.
  /// Holds the `newPassword` member.
  final String newPassword;

  /// يخزن العضو `newPasswordConfirmation`.
  /// Holds the `newPasswordConfirmation` member.
  final String newPasswordConfirmation;

  /// ينشئ مثيلاً من `ChangePasswordParams`.
  /// Builds an instance of `ChangePasswordParams`.
  const ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props =>
      [currentPassword, newPassword, newPasswordConfirmation];
}
