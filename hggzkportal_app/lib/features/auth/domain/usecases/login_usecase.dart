import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_response.dart';
import '../repositories/auth_repository.dart';

/// يعرّف الكلاس `LoginUseCase`.
/// Describes the `LoginUseCase` class.
class LoginUseCase implements UseCase<AuthResponse, LoginParams> {
  /// Holds the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final AuthRepository repository;

  /// ينشئ مثيلاً من `LoginUseCase`.
  /// Builds an instance of `LoginUseCase`.
  LoginUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  @override
  Future<Either<Failure, AuthResponse>> call(LoginParams params) async {
    return await repository.login(
      emailOrPhone: params.emailOrPhone,
      password: params.password,
      rememberMe: params.rememberMe,
    );
  }
}

/// يعرّف الكلاس `LoginParams`.
/// Describes the `LoginParams` class.
class LoginParams extends Equatable {
  /// Holds the `emailOrPhone` value.
  /// العربية: يخزن القيمة `emailOrPhone`.
  final String emailOrPhone;

  /// يخزن العضو `password`.
  /// Holds the `password` member.
  final String password;

  /// يخزن العضو `rememberMe`.
  /// Holds the `rememberMe` member.
  final bool rememberMe;

  /// ينشئ مثيلاً من `LoginParams`.
  /// Builds an instance of `LoginParams`.
  const LoginParams({
    required this.emailOrPhone,
    required this.password,
    this.rememberMe = false,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [emailOrPhone, password, rememberMe];
}
