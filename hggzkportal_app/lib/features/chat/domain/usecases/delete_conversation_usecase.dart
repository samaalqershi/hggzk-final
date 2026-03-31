import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

/// العربية: ينفذ حالة الاستخدام `DeleteConversationUseCase`.
class DeleteConversationUseCase
    implements UseCase<void, DeleteConversationParams> {
  /// العربية: يخزن القيمة `repository`.
  final ChatRepository repository;

  /// العربية: ينشئ مثيلًا جديدًا من `DeleteConversationUseCase`.
  DeleteConversationUseCase(this.repository);

  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, void>> call(DeleteConversationParams params) async {
    return await repository.deleteConversation(params.conversationId);
  }
}

/// العربية: يمثل `DeleteConversationParams`.
class DeleteConversationParams extends Equatable {
  /// العربية: يخزن القيمة `conversationId`.
  final String conversationId;

  /// العربية: ينشئ مثيلًا جديدًا من `DeleteConversationParams`.
  const DeleteConversationParams({required this.conversationId});

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [conversationId];
}
