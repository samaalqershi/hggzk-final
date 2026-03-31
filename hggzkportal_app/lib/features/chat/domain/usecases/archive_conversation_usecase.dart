import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

/// العربية: ينفذ حالة الاستخدام `ArchiveConversationUseCase`.
class ArchiveConversationUseCase
    implements UseCase<void, ArchiveConversationParams> {
  /// العربية: يخزن القيمة `repository`.
  final ChatRepository repository;

  /// العربية: ينشئ مثيلًا جديدًا من `ArchiveConversationUseCase`.
  ArchiveConversationUseCase(this.repository);

  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, void>> call(ArchiveConversationParams params) async {
    return await repository.archiveConversation(params.conversationId);
  }
}

/// العربية: يمثل `ArchiveConversationParams`.
class ArchiveConversationParams extends Equatable {
  /// العربية: يخزن القيمة `conversationId`.
  final String conversationId;

  /// العربية: ينشئ مثيلًا جديدًا من `ArchiveConversationParams`.
  const ArchiveConversationParams({required this.conversationId});

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [conversationId];
}
