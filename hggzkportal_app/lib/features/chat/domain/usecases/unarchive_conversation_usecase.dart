import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

/// يعرّف الكلاس `UnarchiveConversationUseCase`.
/// Describes the `UnarchiveConversationUseCase` class.
class UnarchiveConversationUseCase
    implements UseCase<void, UnarchiveConversationParams> {
  /// يخزن العضو `repository`.
  /// Holds the `repository` member.
  final ChatRepository repository;

  /// ينشئ مثيلاً من `UnarchiveConversationUseCase`.
  /// Builds an instance of `UnarchiveConversationUseCase`.
  UnarchiveConversationUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  @override
  Future<Either<Failure, void>> call(UnarchiveConversationParams params) async {
    return await repository.unarchiveConversation(params.conversationId);
  }
}

/// يعرّف الكلاس `UnarchiveConversationParams`.
/// Describes the `UnarchiveConversationParams` class.
class UnarchiveConversationParams extends Equatable {
  /// Holds the `conversationId` value.
  /// العربية: يخزن القيمة `conversationId`.
  final String conversationId;

  /// ينشئ مثيلاً من `UnarchiveConversationParams`.
  /// Builds an instance of `UnarchiveConversationParams`.
  const UnarchiveConversationParams({required this.conversationId});

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object> get props => [conversationId];
}
