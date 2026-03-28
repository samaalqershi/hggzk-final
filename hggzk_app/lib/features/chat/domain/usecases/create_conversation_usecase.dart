import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hggzk/features/chat/domain/entities/conversation.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

/// Creates a new conversation thread through the repository boundary.
/// ينشئ محادثة جديدة عبر حدود المستودع.
class CreateConversationUseCase
    implements UseCase<Conversation, CreateConversationParams> {
  /// Repository used to create the conversation on the data layer.
  /// المستودع المستخدم لإنشاء المحادثة في طبقة البيانات.
  final ChatRepository repository;

  /// Builds the create-conversation use case with the required repository.
  /// ينشئ حالة استخدام إنشاء المحادثة مع المستودع المطلوب.
  CreateConversationUseCase(this.repository);

  /// Sends the request to the repository and returns the resulting thread.
  /// يرسل الطلب إلى المستودع ثم يعيد السلسلة الناتجة.
  @override
  Future<Either<Failure, Conversation>> call(
      CreateConversationParams params) async {
    return await repository.createConversation(
      participantIds: params.participantIds,
      conversationType: params.conversationType,
      title: params.title,
      description: params.description,
      propertyId: params.propertyId,
    );
  }
}

/// Parameters used to seed a new conversation thread.
/// المعاملات المستخدمة لتجهيز سلسلة محادثة جديدة.
class CreateConversationParams extends Equatable {
  /// Participants that should join the new conversation.
  /// المشاركون الذين يجب أن ينضموا إلى المحادثة الجديدة.
  final List<String> participantIds;

  /// Backend thread type such as direct or group.
  /// نوع السلسلة لدى الخادم مثل direct أو group.
  final String conversationType;

  /// Optional display title for the new thread.
  /// عنوان عرض اختياري للسلسلة الجديدة.
  final String? title;

  /// Optional description used as group context.
  /// وصف اختياري يستخدم كسياق للمجموعة.
  final String? description;

  /// Optional property context attached to the conversation.
  /// سياق العقار الاختياري المرفق بالمحادثة.
  final String? propertyId;

  /// Builds the payload required to start a new chat thread.
  /// ينشئ الحمولة المطلوبة لبدء سلسلة دردشة جديدة.
  const CreateConversationParams({
    required this.participantIds,
    required this.conversationType,
    this.title,
    this.description,
    this.propertyId,
  });

  /// Equality is based on the seeded conversation payload.
  /// تُبنى المساواة على حمولة تجهيز المحادثة.
  @override
  List<Object?> get props => [
        participantIds,
        conversationType,
        title,
        description,
        propertyId,
      ];
}
