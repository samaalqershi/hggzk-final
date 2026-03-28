import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

/// يعرّف الكلاس `MarkAsReadUseCase`.
/// Describes the `MarkAsReadUseCase` class.
class MarkAsReadUseCase implements UseCase<void, MarkAsReadParams> {
  /// Holds the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final ChatRepository repository;

  /// ينشئ مثيلاً من `MarkAsReadUseCase`.
  /// Builds an instance of `MarkAsReadUseCase`.
  MarkAsReadUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  @override
  Future<Either<Failure, void>> call(MarkAsReadParams params) async {
    return await repository.markAsRead(
      conversationId: params.conversationId,
      messageIds: params.messageIds,
    );
  }
}

/// يعرّف الكلاس `MarkAsReadParams`.
/// Describes the `MarkAsReadParams` class.
class MarkAsReadParams extends Equatable {
  /// Holds the `conversationId` value.
  /// العربية: يخزن القيمة `conversationId`.
  final String conversationId;

  /// يخزن العضو `messageIds`.
  /// Holds the `messageIds` member.
  final List<String> messageIds;

  /// ينشئ مثيلاً من `MarkAsReadParams`.
  /// Builds an instance of `MarkAsReadParams`.
  const MarkAsReadParams({
    required this.conversationId,
    required this.messageIds,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object> get props => [conversationId, messageIds];
}
