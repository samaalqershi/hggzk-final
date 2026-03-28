import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

/// يعرّف الكلاس `EditMessageUseCase`.
/// Describes the `EditMessageUseCase` class.
class EditMessageUseCase implements UseCase<Message, EditMessageParams> {
  /// Holds the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final ChatRepository repository;

  /// ينشئ مثيلاً من `EditMessageUseCase`.
  /// Builds an instance of `EditMessageUseCase`.
  EditMessageUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  @override
  Future<Either<Failure, Message>> call(EditMessageParams params) async {
    return await repository.editMessage(
      messageId: params.messageId,
      content: params.content,
    );
  }
}

/// يعرّف الكلاس `EditMessageParams`.
/// Describes the `EditMessageParams` class.
class EditMessageParams extends Equatable {
  /// Holds the `messageId` value.
  /// العربية: يخزن القيمة `messageId`.
  final String messageId;

  /// يخزن العضو `content`.
  /// Holds the `content` member.
  final String content;

  /// ينشئ مثيلاً من `EditMessageParams`.
  /// Builds an instance of `EditMessageParams`.
  const EditMessageParams({
    required this.messageId,
    required this.content,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object> get props => [messageId, content];
}
