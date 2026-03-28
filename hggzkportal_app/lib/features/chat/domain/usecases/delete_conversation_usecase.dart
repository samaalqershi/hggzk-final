import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

/// يعرّف الكلاس `DeleteConversationUseCase`.
/// Describes the `DeleteConversationUseCase` class.
class DeleteConversationUseCase
    implements UseCase<void, DeleteConversationParams> {
  /// يخزن العضو `repository`.
  /// Holds the `repository` member.
  final ChatRepository repository;

  /// ينشئ مثيلاً من `DeleteConversationUseCase`.
  /// Builds an instance of `DeleteConversationUseCase`.
  DeleteConversationUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  @override
  Future<Either<Failure, void>> call(DeleteConversationParams params) async {
    return await repository.deleteConversation(params.conversationId);
  }
}

/// يعرّف الكلاس `DeleteConversationParams`.
/// Describes the `DeleteConversationParams` class.
class DeleteConversationParams extends Equatable {
  /// Holds the `conversationId` value.
  /// العربية: يخزن القيمة `conversationId`.
  final String conversationId;

  /// ينشئ مثيلاً من `DeleteConversationParams`.
  /// Builds an instance of `DeleteConversationParams`.
  const DeleteConversationParams({required this.conversationId});

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object> get props => [conversationId];
}
