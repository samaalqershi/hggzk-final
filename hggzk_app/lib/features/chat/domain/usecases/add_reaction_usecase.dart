import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

/// العربية: ينفذ حالة الاستخدام `AddReactionUseCase`.
class AddReactionUseCase implements UseCase<void, AddReactionParams> {
  /// العربية: يخزن القيمة `repository`.
  final ChatRepository repository;

  /// العربية: ينشئ مثيلًا جديدًا من `AddReactionUseCase`.
  AddReactionUseCase(this.repository);

  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, void>> call(AddReactionParams params) async {
    return await repository.addReaction(
      messageId: params.messageId,
      reactionType: params.reactionType,
    );
  }
}

/// العربية: يمثل `AddReactionParams`.
class AddReactionParams extends Equatable {
  /// العربية: يخزن القيمة `messageId`.
  final String messageId;

  /// العربية: يخزن القيمة `reactionType`.
  final String reactionType;

  /// العربية: ينشئ مثيلًا جديدًا من `AddReactionParams`.
  const AddReactionParams({
    required this.messageId,
    required this.reactionType,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [messageId, reactionType];
}
