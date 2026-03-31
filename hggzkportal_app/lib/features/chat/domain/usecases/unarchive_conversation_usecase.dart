import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

/// العربية: ينفذ حالة الاستخدام `UnarchiveConversationUseCase`.
class UnarchiveConversationUseCase
    implements UseCase<void, UnarchiveConversationParams> {
  /// العربية: يخزن القيمة `repository`.
  final ChatRepository repository;

  /// العربية: ينشئ مثيلًا جديدًا من `UnarchiveConversationUseCase`.
  UnarchiveConversationUseCase(this.repository);

  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, void>> call(UnarchiveConversationParams params) async {
    return await repository.unarchiveConversation(params.conversationId);
  }
}

/// العربية: يمثل `UnarchiveConversationParams`.
class UnarchiveConversationParams extends Equatable {
  /// العربية: يخزن القيمة `conversationId`.
  final String conversationId;

  /// العربية: ينشئ مثيلًا جديدًا من `UnarchiveConversationParams`.
  const UnarchiveConversationParams({required this.conversationId});

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [conversationId];
}
