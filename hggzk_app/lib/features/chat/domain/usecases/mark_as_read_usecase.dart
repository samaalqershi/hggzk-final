import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

/// العربية: ينفذ حالة الاستخدام `MarkAsReadUseCase`.
class MarkAsReadUseCase implements UseCase<void, MarkAsReadParams> {
  /// العربية: يخزن القيمة `repository`.
  final ChatRepository repository;

  /// العربية: ينشئ مثيلًا جديدًا من `MarkAsReadUseCase`.
  MarkAsReadUseCase(this.repository);

  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, void>> call(MarkAsReadParams params) async {
    return await repository.markAsRead(
      conversationId: params.conversationId,
      messageIds: params.messageIds,
    );
  }
}

/// العربية: يمثل `MarkAsReadParams`.
class MarkAsReadParams extends Equatable {
  /// العربية: يخزن القيمة `conversationId`.
  final String conversationId;

  /// العربية: يخزن القيمة `messageIds`.
  final List<String> messageIds;

  /// العربية: ينشئ مثيلًا جديدًا من `MarkAsReadParams`.
  const MarkAsReadParams({
    required this.conversationId,
    required this.messageIds,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [conversationId, messageIds];
}
