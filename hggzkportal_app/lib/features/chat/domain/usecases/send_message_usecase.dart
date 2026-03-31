import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

/// Sends a chat message through the repository boundary so the bloc does not
/// speak to data sources directly.
/// يرسل رسالة دردشة عبر حدود المستودع حتى لا يتحدث الـ bloc مباشرة مع
/// مصادر البيانات.
class SendMessageUseCase implements UseCase<Message, SendMessageParams> {
  /// Repository that performs the actual send operation.
  /// المستودع الذي ينفذ عملية الإرسال فعليًا.
  final ChatRepository repository;

  /// Builds the send-message use case with its chat repository.
  /// ينشئ حالة استخدام إرسال الرسائل مع مستودع الدردشة الخاص بها.
  SendMessageUseCase(this.repository);

  /// Forwards the request to the repository using the provided payload.
  /// يمرر الطلب إلى المستودع باستخدام الحمولة المرسلة.
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

/// Parameters required to send one chat message.
/// المعاملات المطلوبة لإرسال رسالة دردشة واحدة.
class SendMessageParams extends Equatable {
  /// Target conversation for the outgoing message.
  /// المحادثة المستهدفة للرسالة الصادرة.
  final String conversationId;

  /// Backend-recognized message type.
  /// نوع الرسالة المعتمد من الخادم.
  final String messageType;

  /// Optional text body for the message.
  /// النص الاختياري للرسالة.
  final String? content;

  /// Optional geographic payload.
  /// حمولة موقع اختيارية.
  final Location? location;

  /// Original message id when this message is a reply.
  /// معرّف الرسالة الأصلية عندما تكون هذه رسالة رد.
  final String? replyToMessageId;

  /// Uploaded attachment ids that should be linked to the message.
  /// معرّفات المرفقات المرفوعة التي يجب ربطها بالرسالة.
  final List<String>? attachmentIds;

  /// Builds the full payload that the repository expects for a send request.
  /// ينشئ الحمولة الكاملة التي يتوقعها المستودع لطلب الإرسال.
  const SendMessageParams({
    required this.conversationId,
    required this.messageType,
    this.content,
    this.location,
    this.replyToMessageId,
    this.attachmentIds,
  });

  /// Equality is based on the request payload.
  /// تُبنى المساواة على حمولة الطلب.
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
