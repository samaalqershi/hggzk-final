import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

/// العربية: ينفذ حالة الاستخدام `EditMessageUseCase`.
class EditMessageUseCase implements UseCase<Message, EditMessageParams> {
  /// العربية: يخزن القيمة `repository`.
  final ChatRepository repository;

  /// العربية: ينشئ مثيلًا جديدًا من `EditMessageUseCase`.
  EditMessageUseCase(this.repository);

  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, Message>> call(EditMessageParams params) async {
    return await repository.editMessage(
      messageId: params.messageId,
      content: params.content,
    );
  }
}

/// العربية: يمثل `EditMessageParams`.
class EditMessageParams extends Equatable {
  /// العربية: يخزن القيمة `messageId`.
  final String messageId;

  /// العربية: يخزن القيمة `content`.
  final String content;

  /// العربية: ينشئ مثيلًا جديدًا من `EditMessageParams`.
  const EditMessageParams({
    required this.messageId,
    required this.content,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [messageId, content];
}
