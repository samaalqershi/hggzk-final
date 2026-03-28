import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// يعرّف الكلاس `CheckAuthStatusUseCase`.
/// Describes the `CheckAuthStatusUseCase` class.
class CheckAuthStatusUseCase implements UseCase<bool, NoParams> {
  /// Holds the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final AuthRepository repository;

  /// ينشئ مثيلاً من `CheckAuthStatusUseCase`.
  /// Builds an instance of `CheckAuthStatusUseCase`.
  CheckAuthStatusUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.checkAuthStatus();
  }
}
