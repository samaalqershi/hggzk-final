import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

/// يعرّف الكلاس `SendMessageUseCase`.
/// Describes the `SendMessageUseCase` class.
class SendMessageUseCase implements UseCase<Message, SendMessageParams> {
  /// Holds the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final ChatRepository repository;

  /// ينشئ مثيلاً من `SendMessageUseCase`.
  /// Builds an instance of `SendMessageUseCase`.
  SendMessageUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  @override
  Future<Either<Failure, Message>> call(SendMessageParams params) async {
    return await repository.sendMessage(
      conversationId: params.conversationId,
      messageType: params.messageType,
      content: params.content,
      location: params.location,
      replyToMessageId: params.replyToMessageId,
      attachmentIds: params.attachmentIds,
    );
  }
}

/// يعرّف الكلاس `SendMessageParams`.
/// Describes the `SendMessageParams` class.
class SendMessageParams extends Equatable {
  /// Holds the `conversationId` value.
  /// العربية: يخزن القيمة `conversationId`.
  final String conversationId;

  /// يخزن العضو `messageType`.
  /// Holds the `messageType` member.
  final String messageType;

  /// يخزن العضو `content`.
  /// Holds the `content` member.
  final String? content;

  /// يخزن العضو `location`.
  /// Holds the `location` member.
  final Location? location;

  /// يخزن العضو `replyToMessageId`.
  /// Holds the `replyToMessageId` member.
  final String? replyToMessageId;

  /// يخزن العضو `attachmentIds`.
  /// Holds the `attachmentIds` member.
  final List<String>? attachmentIds;

  /// ينشئ مثيلاً من `SendMessageParams`.
  /// Builds an instance of `SendMessageParams`.
  const SendMessageParams({
    required this.conversationId,
    required this.messageType,
    this.content,
    this.location,
    this.replyToMessageId,
    this.attachmentIds,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [
        conversationId,
        messageType,
        content,
        location,
        replyToMessageId,
        attachmentIds,
      ];
}
