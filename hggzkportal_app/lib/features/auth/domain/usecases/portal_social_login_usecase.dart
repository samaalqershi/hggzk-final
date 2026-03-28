import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_response.dart';
import '../repositories/auth_repository.dart';

/// يعرّف الكلاس `PortalSocialLoginUseCase`.
/// Describes the `PortalSocialLoginUseCase` class.
class PortalSocialLoginUseCase
    implements UseCase<AuthResponse, PortalSocialLoginParams> {
  /// يخزن العضو `repository`.
  /// Holds the `repository` member.
  final AuthRepository repository;

  /// ينشئ مثيلاً من `PortalSocialLoginUseCase`.
  /// Builds an instance of `PortalSocialLoginUseCase`.
  PortalSocialLoginUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
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

/// يعرّف الكلاس `PortalSocialLoginParams`.
/// Describes the `PortalSocialLoginParams` class.
class PortalSocialLoginParams extends Equatable {
  /// Holds the `provider` value.
  /// العربية: يخزن القيمة `provider`.
  final String provider;

  /// يخزن العضو `token`.
  /// Holds the `token` member.
  final String token;

  /// يخزن العضو `nonce`.
  /// Holds the `nonce` member.
  final String? nonce;

  /// يخزن العضو `name`.
  /// Holds the `name` member.
  final String? name;

  /// ينشئ مثيلاً من `PortalSocialLoginParams`.
  /// Builds an instance of `PortalSocialLoginParams`.
  const PortalSocialLoginParams({
    required this.provider,
    required this.token,
    this.nonce,
    this.name,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [provider, token, nonce, name];
}
