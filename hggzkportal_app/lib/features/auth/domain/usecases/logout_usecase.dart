import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// يعرّف الكلاس `LogoutUseCase`.
/// Describes the `LogoutUseCase` class.
class LogoutUseCase implements UseCase<void, NoParams> {
  /// Holds the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final AuthRepository repository;

  /// ينشئ مثيلاً من `LogoutUseCase`.
  /// Builds an instance of `LogoutUseCase`.
  LogoutUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}
