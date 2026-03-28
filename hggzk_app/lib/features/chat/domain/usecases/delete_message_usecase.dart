import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

/// العربية: ينفذ حالة الاستخدام `DeleteMessageUseCase`.
class DeleteMessageUseCase implements UseCase<void, DeleteMessageParams> {
  /// العربية: يخزن القيمة `repository`.
  final ChatRepository repository;

  /// العربية: ينشئ مثيلًا جديدًا من `DeleteMessageUseCase`.
  DeleteMessageUseCase(this.repository);

  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, void>> call(DeleteMessageParams params) async {
    return await repository.deleteMessage(params.messageId);
  }
}

/// العربية: يمثل `DeleteMessageParams`.
class DeleteMessageParams extends Equatable {
  /// العربية: يخزن القيمة `messageId`.
  final String messageId;

  /// العربية: ينشئ مثيلًا جديدًا من `DeleteMessageParams`.
  const DeleteMessageParams({required this.messageId});

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [messageId];
}
