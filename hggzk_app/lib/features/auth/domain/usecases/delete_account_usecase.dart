import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class DeleteAccountUseCase implements UseCase<void, DeleteAccountParams> {
  final AuthRepository repository;

  DeleteAccountUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteAccountParams params) async {
    return await repository.deleteAccount(
      password: params.password,
      socialProvider: params.socialProvider,
      socialToken: params.socialToken,
      socialNonce: params.socialNonce,
      reason: params.reason,
    );
  }
}

class DeleteAccountParams extends Equatable {
  final String? password;
  final String? socialProvider;
  final String? socialToken;
  final String? socialNonce;
  final String? reason;

  const DeleteAccountParams({
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
