import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

/// يعرّف الكلاس `GetConversationsUseCase`.
/// Describes the `GetConversationsUseCase` class.
class GetConversationsUseCase
    implements UseCase<List<Conversation>, GetConversationsParams> {
  /// يخزن العضو `repository`.
  /// Holds the `repository` member.
  final ChatRepository repository;

  /// ينشئ مثيلاً من `GetConversationsUseCase`.
  /// Builds an instance of `GetConversationsUseCase`.
  GetConversationsUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  @override
  Future<Either<Failure, List<Conversation>>> call(
      GetConversationsParams params) async {
    return await repository.getConversations(
      pageNumber: params.pageNumber,
      pageSize: params.pageSize,
    );
  }
}

/// يعرّف الكلاس `GetConversationsParams`.
/// Describes the `GetConversationsParams` class.
class GetConversationsParams extends Equatable {
  /// Holds the `pageNumber` value.
  /// العربية: يخزن القيمة `pageNumber`.
  final int pageNumber;

  /// يخزن العضو `pageSize`.
  /// Holds the `pageSize` member.
  final int pageSize;

  /// ينشئ مثيلاً من `GetConversationsParams`.
  /// Builds an instance of `GetConversationsParams`.
  const GetConversationsParams({
    this.pageNumber = 1,
    this.pageSize = 20,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object> get props => [pageNumber, pageSize];
}
