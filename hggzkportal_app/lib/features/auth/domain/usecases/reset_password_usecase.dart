import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// يعرّف الكلاس `ResetPasswordUseCase`.
/// Describes the `ResetPasswordUseCase` class.
class ResetPasswordUseCase implements UseCase<void, ResetPasswordParams> {
  /// Holds the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final AuthRepository repository;

  /// ينشئ مثيلاً من `ResetPasswordUseCase`.
  /// Builds an instance of `ResetPasswordUseCase`.
  ResetPasswordUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) async {
    return await repository.resetPassword(
      emailOrPhone: params.emailOrPhone,
    );
  }
}

/// يعرّف الكلاس `ResetPasswordParams`.
/// Describes the `ResetPasswordParams` class.
class ResetPasswordParams extends Equatable {
  /// Holds the `emailOrPhone` value.
  /// العربية: يخزن القيمة `emailOrPhone`.
  final String emailOrPhone;

  /// ينشئ مثيلاً من `ResetPasswordParams`.
  /// Builds an instance of `ResetPasswordParams`.
  const ResetPasswordParams({
    required this.emailOrPhone,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [emailOrPhone];
}
