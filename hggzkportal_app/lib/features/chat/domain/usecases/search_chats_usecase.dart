import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

/// العربية: ينفذ حالة الاستخدام `SearchChatsUseCase`.
class SearchChatsUseCase implements UseCase<SearchResult, SearchChatsParams> {
  /// العربية: يخزن القيمة `repository`.
  final ChatRepository repository;

  /// العربية: ينشئ مثيلًا جديدًا من `SearchChatsUseCase`.
  SearchChatsUseCase(this.repository);

  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
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

/// العربية: يمثل `SearchChatsParams`.
class SearchChatsParams extends Equatable {
  /// العربية: يخزن القيمة `query`.
  final String query;

  /// العربية: يخزن القيمة `conversationId`.
  final String? conversationId;

  /// العربية: يخزن القيمة `messageType`.
  final String? messageType;

  /// العربية: يخزن القيمة `senderId`.
  final String? senderId;

  /// العربية: يخزن القيمة `dateFrom`.
  final DateTime? dateFrom;

  /// العربية: يخزن القيمة `dateTo`.
  final DateTime? dateTo;

  /// العربية: يخزن القيمة `page`.
  final int page;

  /// العربية: يخزن القيمة `limit`.
  final int limit;

  /// العربية: ينشئ مثيلًا جديدًا من `SearchChatsParams`.
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

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
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
