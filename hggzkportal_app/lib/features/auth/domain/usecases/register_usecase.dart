import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_response.dart';
import '../repositories/auth_repository.dart';

/// يعرّف الكلاس `RegisterUseCase`.
/// Describes the `RegisterUseCase` class.
class RegisterUseCase implements UseCase<AuthResponse, RegisterParams> {
  /// Holds the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final AuthRepository repository;

  /// ينشئ مثيلاً من `RegisterUseCase`.
  /// Builds an instance of `RegisterUseCase`.
  RegisterUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  @override
  Future<Either<Failure, AuthResponse>> call(RegisterParams params) async {
    return await repository.register(
      name: params.name,
      email: params.email,
      phone: params.phone,
      password: params.password,
      passwordConfirmation: params.passwordConfirmation,
    );
  }
}

/// يعرّف الكلاس `RegisterParams`.
/// Describes the `RegisterParams` class.
class RegisterParams extends Equatable {
  /// Holds the `name` value.
  /// العربية: يخزن القيمة `name`.
  final String name;

  /// يخزن العضو `email`.
  /// Holds the `email` member.
  final String email;

  /// يخزن العضو `phone`.
  /// Holds the `phone` member.
  final String phone;

  /// يخزن العضو `password`.
  /// Holds the `password` member.
  final String password;

  /// يخزن العضو `passwordConfirmation`.
  /// Holds the `passwordConfirmation` member.
  final String passwordConfirmation;

  /// ينشئ مثيلاً من `RegisterParams`.
  /// Builds an instance of `RegisterParams`.
  const RegisterParams({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        password,
        passwordConfirmation,
      ];
}
