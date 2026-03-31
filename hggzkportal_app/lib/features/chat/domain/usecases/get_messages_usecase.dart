import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

/// العربية: ينفذ حالة الاستخدام `GetMessagesUseCase`.
class GetMessagesUseCase implements UseCase<List<Message>, GetMessagesParams> {
  /// العربية: يخزن القيمة `repository`.
  final ChatRepository repository;

  /// العربية: ينشئ مثيلًا جديدًا من `GetMessagesUseCase`.
  GetMessagesUseCase(this.repository);

  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, List<Message>>> call(GetMessagesParams params) async {
    return await repository.getMessages(
      conversationId: params.conversationId,
      pageNumber: params.pageNumber,
      pageSize: params.pageSize,
      beforeMessageId: params.beforeMessageId,
    );
  }
}

/// العربية: يمثل `GetMessagesParams`.
class GetMessagesParams extends Equatable {
  /// العربية: يخزن القيمة `conversationId`.
  final String conversationId;

  /// العربية: يخزن القيمة `pageNumber`.
  final int pageNumber;

  /// العربية: يخزن القيمة `pageSize`.
  final int pageSize;

  /// العربية: يخزن القيمة `beforeMessageId`.
  final String? beforeMessageId;

  /// العربية: ينشئ مثيلًا جديدًا من `GetMessagesParams`.
  const GetMessagesParams({
    required this.conversationId,
    this.pageNumber = 1,
    this.pageSize = 50,
    this.beforeMessageId,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [
        conversationId,
        pageNumber,
        pageSize,
        beforeMessageId,
      ];
}
