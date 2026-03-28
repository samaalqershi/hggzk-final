import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hggzkportal/features/chat/domain/entities/conversation.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

/// يعرّف الكلاس `CreateConversationUseCase`.
/// Describes the `CreateConversationUseCase` class.
class CreateConversationUseCase
    implements UseCase<Conversation, CreateConversationParams> {
  /// يخزن العضو `repository`.
  /// Holds the `repository` member.
  final ChatRepository repository;

  /// ينشئ مثيلاً من `CreateConversationUseCase`.
  /// Builds an instance of `CreateConversationUseCase`.
  CreateConversationUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
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

/// يعرّف الكلاس `CreateConversationParams`.
/// Describes the `CreateConversationParams` class.
class CreateConversationParams extends Equatable {
  /// Holds the `participantIds` value.
  /// العربية: يخزن القيمة `participantIds`.
  final List<String> participantIds;

  /// يخزن العضو `conversationType`.
  /// Holds the `conversationType` member.
  final String conversationType;

  /// يخزن العضو `title`.
  /// Holds the `title` member.
  final String? title;

  /// يخزن العضو `description`.
  /// Holds the `description` member.
  final String? description;

  /// يخزن العضو `propertyId`.
  /// Holds the `propertyId` member.
  final String? propertyId;

  /// ينشئ مثيلاً من `CreateConversationParams`.
  /// Builds an instance of `CreateConversationParams`.
  const CreateConversationParams({
    required this.participantIds,
    required this.conversationType,
    this.title,
    this.description,
    this.propertyId,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [
        participantIds,
        conversationType,
        title,
        description,
        propertyId,
      ];
}
