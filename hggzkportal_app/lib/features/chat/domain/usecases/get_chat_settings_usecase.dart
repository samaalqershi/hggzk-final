import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/attachment.dart';
import '../repositories/chat_repository.dart';

/// يعرّف الكلاس `GetChatSettingsUseCase`.
/// Describes the `GetChatSettingsUseCase` class.
class GetChatSettingsUseCase implements UseCase<ChatSettings, NoParams> {
  /// Holds the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final ChatRepository repository;

  /// ينشئ مثيلاً من `GetChatSettingsUseCase`.
  /// Builds an instance of `GetChatSettingsUseCase`.
  GetChatSettingsUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  @override
  Future<Either<Failure, ChatSettings>> call(NoParams params) async {
    return await repository.getChatSettings();
  }
}
