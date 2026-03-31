import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

/// العربية: ينفذ حالة الاستخدام `RemoveReactionUseCase`.
class RemoveReactionUseCase implements UseCase<void, RemoveReactionParams> {
  /// العربية: يخزن القيمة `repository`.
  final ChatRepository repository;

  /// العربية: ينشئ مثيلًا جديدًا من `RemoveReactionUseCase`.
  RemoveReactionUseCase(this.repository);

  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, void>> call(RemoveReactionParams params) async {
    return await repository.removeReaction(
      messageId: params.messageId,
      reactionType: params.reactionType,
    );
  }
}

/// العربية: يمثل `RemoveReactionParams`.
class RemoveReactionParams extends Equatable {
  /// العربية: يخزن القيمة `messageId`.
  final String messageId;

  /// العربية: يخزن القيمة `reactionType`.
  final String reactionType;

  /// العربية: ينشئ مثيلًا جديدًا من `RemoveReactionParams`.
  const RemoveReactionParams({
    required this.messageId,
    required this.reactionType,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [messageId, reactionType];
}
