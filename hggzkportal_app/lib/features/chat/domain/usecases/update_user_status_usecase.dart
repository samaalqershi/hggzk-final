import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

/// يعرّف الكلاس `UpdateUserStatusUseCase`.
/// Describes the `UpdateUserStatusUseCase` class.
class UpdateUserStatusUseCase implements UseCase<void, UpdateUserStatusParams> {
  /// Holds the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final ChatRepository repository;

  /// ينشئ مثيلاً من `UpdateUserStatusUseCase`.
  /// Builds an instance of `UpdateUserStatusUseCase`.
  UpdateUserStatusUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  @override
  Future<Either<Failure, void>> call(UpdateUserStatusParams params) async {
    return await repository.updateUserStatus(params.status);
  }
}

/// يعرّف الكلاس `UpdateUserStatusParams`.
/// Describes the `UpdateUserStatusParams` class.
class UpdateUserStatusParams extends Equatable {
  /// Holds the `status` value.
  /// العربية: يخزن القيمة `status`.
  final String status;

  /// ينشئ مثيلاً من `UpdateUserStatusParams`.
  /// Builds an instance of `UpdateUserStatusParams`.
  const UpdateUserStatusParams({required this.status});

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object> get props => [status];
}
