import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// يعرّف الكلاس `DeleteOwnerAccountUseCase`.
/// Describes the `DeleteOwnerAccountUseCase` class.
class DeleteOwnerAccountUseCase
    implements UseCase<void, DeleteOwnerAccountParams> {
  /// يخزن العضو `repository`.
  /// Holds the `repository` member.
  final AuthRepository repository;

  /// ينشئ مثيلاً من `DeleteOwnerAccountUseCase`.
  /// Builds an instance of `DeleteOwnerAccountUseCase`.
  DeleteOwnerAccountUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  @override
  Future<Either<Failure, void>> call(DeleteOwnerAccountParams params) async {
    return await repository.deleteOwnerAccount(
      password: params.password,
      socialProvider: params.socialProvider,
      socialToken: params.socialToken,
      socialNonce: params.socialNonce,
      reason: params.reason,
    );
  }
}

/// يعرّف الكلاس `DeleteOwnerAccountParams`.
/// Describes the `DeleteOwnerAccountParams` class.
class DeleteOwnerAccountParams extends Equatable {
  /// Holds the `password` value.
  /// العربية: يخزن القيمة `password`.
  final String? password;

  /// يخزن العضو `socialProvider`.
  /// Holds the `socialProvider` member.
  final String? socialProvider;

  /// يخزن العضو `socialToken`.
  /// Holds the `socialToken` member.
  final String? socialToken;

  /// يخزن العضو `socialNonce`.
  /// Holds the `socialNonce` member.
  final String? socialNonce;

  /// يخزن العضو `reason`.
  /// Holds the `reason` member.
  final String? reason;

  /// ينشئ مثيلاً من `DeleteOwnerAccountParams`.
  /// Builds an instance of `DeleteOwnerAccountParams`.
  const DeleteOwnerAccountParams({
    this.password,
    this.socialProvider,
    this.socialToken,
    this.socialNonce,
    this.reason,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [
        password,
        socialProvider,
        socialToken,
        socialNonce,
        reason,
      ];
}
