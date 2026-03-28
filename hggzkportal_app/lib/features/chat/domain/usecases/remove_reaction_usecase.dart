import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

/// يعرّف الكلاس `RemoveReactionUseCase`.
/// Describes the `RemoveReactionUseCase` class.
class RemoveReactionUseCase implements UseCase<void, RemoveReactionParams> {
  /// Holds the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final ChatRepository repository;

  /// ينشئ مثيلاً من `RemoveReactionUseCase`.
  /// Builds an instance of `RemoveReactionUseCase`.
  RemoveReactionUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  @override
  Future<Either<Failure, void>> call(RemoveReactionParams params) async {
    return await repository.removeReaction(
      messageId: params.messageId,
      reactionType: params.reactionType,
    );
  }
}

/// يعرّف الكلاس `RemoveReactionParams`.
/// Describes the `RemoveReactionParams` class.
class RemoveReactionParams extends Equatable {
  /// Holds the `messageId` value.
  /// العربية: يخزن القيمة `messageId`.
  final String messageId;

  /// يخزن العضو `reactionType`.
  /// Holds the `reactionType` member.
  final String reactionType;

  /// ينشئ مثيلاً من `RemoveReactionParams`.
  /// Builds an instance of `RemoveReactionParams`.
  const RemoveReactionParams({
    required this.messageId,
    required this.reactionType,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object> get props => [messageId, reactionType];
}
