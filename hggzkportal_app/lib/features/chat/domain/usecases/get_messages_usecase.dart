import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

/// يعرّف الكلاس `GetMessagesUseCase`.
/// Describes the `GetMessagesUseCase` class.
class GetMessagesUseCase implements UseCase<List<Message>, GetMessagesParams> {
  /// Holds the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final ChatRepository repository;

  /// ينشئ مثيلاً من `GetMessagesUseCase`.
  /// Builds an instance of `GetMessagesUseCase`.
  GetMessagesUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
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

/// يعرّف الكلاس `GetMessagesParams`.
/// Describes the `GetMessagesParams` class.
class GetMessagesParams extends Equatable {
  /// Holds the `conversationId` value.
  /// العربية: يخزن القيمة `conversationId`.
  final String conversationId;

  /// يخزن العضو `pageNumber`.
  /// Holds the `pageNumber` member.
  final int pageNumber;

  /// يخزن العضو `pageSize`.
  /// Holds the `pageSize` member.
  final int pageSize;

  /// يخزن العضو `beforeMessageId`.
  /// Holds the `beforeMessageId` member.
  final String? beforeMessageId;

  /// ينشئ مثيلاً من `GetMessagesParams`.
  /// Builds an instance of `GetMessagesParams`.
  const GetMessagesParams({
    required this.conversationId,
    this.pageNumber = 1,
    this.pageSize = 50,
    this.beforeMessageId,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [
        conversationId,
        pageNumber,
        pageSize,
        beforeMessageId,
      ];
}
