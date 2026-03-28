import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

/// Loads the paginated conversation list for the inbox screen.
///
/// This keeps paging concerns out of the UI layer and lets the repository
/// decide how the inbox is fetched and ordered.
/// يعزل هذا الكود تفاصيل الترقيم عن الواجهة ويترك للمستودع تحديد طريقة
/// الجلب والترتيب.
class GetConversationsUseCase
    implements UseCase<List<Conversation>, GetConversationsParams> {
  /// Repository used to retrieve conversation pages.
  final ChatRepository repository;

  /// Creates the use case around the chat repository.
  GetConversationsUseCase(this.repository);

  /// Requests one page of conversations using the supplied paging window.
  @override
  Future<Either<Failure, List<Conversation>>> call(
      GetConversationsParams params) async {
    return await repository.getConversations(
      pageNumber: params.pageNumber,
      pageSize: params.pageSize,
    );
  }
}

/// Paging controls for the inbox query.
class GetConversationsParams extends Equatable {
  /// Page index expected by the repository contract.
  final int pageNumber;

  /// Number of conversations requested per page.
  final int pageSize;

  /// Sets the initial page window for the inbox.
  const GetConversationsParams({
    this.pageNumber = 1,
    this.pageSize = 20,
  });

  /// Compares requests by their active page window.
  @override
  List<Object> get props => [pageNumber, pageSize];
}
