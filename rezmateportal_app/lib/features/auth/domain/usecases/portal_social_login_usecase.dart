import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_response.dart';
import '../repositories/auth_repository.dart';

class PortalSocialLoginUseCase
    implements UseCase<AuthResponse, PortalSocialLoginParams> {
  final AuthRepository repository;

  PortalSocialLoginUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResponse>> call(
    PortalSocialLoginParams params,
  ) async {
    return await repository.portalSocialLogin(
      provider: params.provider,
      token: params.token,
      nonce: params.nonce,
      name: params.name,
    );
  }
}

class PortalSocialLoginParams extends Equatable {
  final String provider;
  final String token;
  final String? nonce;
  final String? name;

  const PortalSocialLoginParams({
    required this.provider,
    required this.token,
    this.nonce,
    this.name,
  });

  @override
  List<Object?> get props => [provider, token, nonce, name];
}
