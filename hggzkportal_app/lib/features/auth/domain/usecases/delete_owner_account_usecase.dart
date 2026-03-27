import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class DeleteOwnerAccountUseCase
    implements UseCase<void, DeleteOwnerAccountParams> {
  final AuthRepository repository;

  DeleteOwnerAccountUseCase(this.repository);

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

class DeleteOwnerAccountParams extends Equatable {
  final String? password;
  final String? socialProvider;
  final String? socialToken;
  final String? socialNonce;
  final String? reason;

  const DeleteOwnerAccountParams({
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
