import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

/// يعرّف الكلاس `AddReactionUseCase`.
/// Describes the `AddReactionUseCase` class.
class AddReactionUseCase implements UseCase<void, AddReactionParams> {
  /// Holds the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final ChatRepository repository;

  /// ينشئ مثيلاً من `AddReactionUseCase`.
  /// Builds an instance of `AddReactionUseCase`.
  AddReactionUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  @override
  Future<Either<Failure, void>> call(AddReactionParams params) async {
    return await repository.addReaction(
      messageId: params.messageId,
      reactionType: params.reactionType,
    );
  }
}

/// يعرّف الكلاس `AddReactionParams`.
/// Describes the `AddReactionParams` class.
class AddReactionParams extends Equatable {
  /// Holds the `messageId` value.
  /// العربية: يخزن القيمة `messageId`.
  final String messageId;

  /// يخزن العضو `reactionType`.
  /// Holds the `reactionType` member.
  final String reactionType;

  /// ينشئ مثيلاً من `AddReactionParams`.
  /// Builds an instance of `AddReactionParams`.
  const AddReactionParams({
    required this.messageId,
    required this.reactionType,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object> get props => [messageId, reactionType];
}
