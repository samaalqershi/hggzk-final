import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

/// يعرّف الكلاس `SearchChatsUseCase`.
/// Describes the `SearchChatsUseCase` class.
class SearchChatsUseCase implements UseCase<SearchResult, SearchChatsParams> {
  /// Holds the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final ChatRepository repository;

  /// ينشئ مثيلاً من `SearchChatsUseCase`.
  /// Builds an instance of `SearchChatsUseCase`.
  SearchChatsUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  @override
  Future<Either<Failure, SearchResult>> call(SearchChatsParams params) async {
    return await repository.searchChats(
      query: params.query,
      conversationId: params.conversationId,
      messageType: params.messageType,
      senderId: params.senderId,
      dateFrom: params.dateFrom,
      dateTo: params.dateTo,
      page: params.page,
      limit: params.limit,
    );
  }
}

/// يعرّف الكلاس `SearchChatsParams`.
/// Describes the `SearchChatsParams` class.
class SearchChatsParams extends Equatable {
  /// Holds the `query` value.
  /// العربية: يخزن القيمة `query`.
  final String query;

  /// يخزن العضو `conversationId`.
  /// Holds the `conversationId` member.
  final String? conversationId;

  /// يخزن العضو `messageType`.
  /// Holds the `messageType` member.
  final String? messageType;

  /// يخزن العضو `senderId`.
  /// Holds the `senderId` member.
  final String? senderId;

  /// يخزن العضو `dateFrom`.
  /// Holds the `dateFrom` member.
  final DateTime? dateFrom;

  /// يخزن العضو `dateTo`.
  /// Holds the `dateTo` member.
  final DateTime? dateTo;

  /// يخزن العضو `page`.
  /// Holds the `page` member.
  final int page;

  /// يخزن العضو `limit`.
  /// Holds the `limit` member.
  final int limit;

  /// ينشئ مثيلاً من `SearchChatsParams`.
  /// Builds an instance of `SearchChatsParams`.
  const SearchChatsParams({
    required this.query,
    this.conversationId,
    this.messageType,
    this.senderId,
    this.dateFrom,
    this.dateTo,
    this.page = 1,
    this.limit = 20,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [
        query,
        conversationId,
        messageType,
        senderId,
        dateFrom,
        dateTo,
        page,
        limit,
      ];
}
