import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// يعرّف الكلاس `GetCurrentUserUseCase`.
/// Describes the `GetCurrentUserUseCase` class.
class GetCurrentUserUseCase implements UseCase<User, NoParams> {
  /// Holds the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final AuthRepository repository;

  /// ينشئ مثيلاً من `GetCurrentUserUseCase`.
  /// Builds an instance of `GetCurrentUserUseCase`.
  GetCurrentUserUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}
