import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

/// يعرّف الكلاس `GetAdminUsersUseCase`.
/// Describes the `GetAdminUsersUseCase` class.
class GetAdminUsersUseCase implements UseCase<List<ChatUser>, NoParams> {
  /// Holds the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final ChatRepository repository;

  /// ينشئ مثيلاً من `GetAdminUsersUseCase`.
  /// Builds an instance of `GetAdminUsersUseCase`.
  GetAdminUsersUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  @override
  Future<Either<Failure, List<ChatUser>>> call(NoParams params) async {
    return await repository.getAdminUsers();
  }
}
