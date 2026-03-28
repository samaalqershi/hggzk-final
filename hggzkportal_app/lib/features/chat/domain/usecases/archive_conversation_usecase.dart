import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

/// يعرّف الكلاس `ArchiveConversationUseCase`.
/// Describes the `ArchiveConversationUseCase` class.
class ArchiveConversationUseCase
    implements UseCase<void, ArchiveConversationParams> {
  /// يخزن العضو `repository`.
  /// Holds the `repository` member.
  final ChatRepository repository;

  /// ينشئ مثيلاً من `ArchiveConversationUseCase`.
  /// Builds an instance of `ArchiveConversationUseCase`.
  ArchiveConversationUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  @override
  Future<Either<Failure, void>> call(ArchiveConversationParams params) async {
    return await repository.archiveConversation(params.conversationId);
  }
}

/// يعرّف الكلاس `ArchiveConversationParams`.
/// Describes the `ArchiveConversationParams` class.
class ArchiveConversationParams extends Equatable {
  /// Holds the `conversationId` value.
  /// العربية: يخزن القيمة `conversationId`.
  final String conversationId;

  /// ينشئ مثيلاً من `ArchiveConversationParams`.
  /// Builds an instance of `ArchiveConversationParams`.
  const ArchiveConversationParams({required this.conversationId});

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object> get props => [conversationId];
}
