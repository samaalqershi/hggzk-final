import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../entities/search_result.dart';
import '../repositories/helpers_repository.dart';

/// يعرّف الكلاس `SearchUsersUseCase`.
/// Describes the `SearchUsersUseCase` class.
class SearchUsersUseCase {
  /// Holds the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final HelpersRepository repository;

  /// ينشئ مثيلاً من `SearchUsersUseCase`.
  /// Builds an instance of `SearchUsersUseCase`.
  SearchUsersUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  Future<Either<Failure, PaginatedResult<SearchResult>>> call({
    String? searchTerm,
    String? role,
    bool? isActive,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    return await repository.searchUsers(
      searchTerm: searchTerm,
      role: role,
      isActive: isActive,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
