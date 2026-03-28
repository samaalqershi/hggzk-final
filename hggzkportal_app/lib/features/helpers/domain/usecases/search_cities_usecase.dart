import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../entities/search_result.dart';
import '../repositories/helpers_repository.dart';

/// يعرّف الكلاس `SearchCitiesUseCase`.
/// Describes the `SearchCitiesUseCase` class.
class SearchCitiesUseCase {
  /// Holds the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final HelpersRepository repository;

  /// ينشئ مثيلاً من `SearchCitiesUseCase`.
  /// Builds an instance of `SearchCitiesUseCase`.
  SearchCitiesUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  Future<Either<Failure, PaginatedResult<SearchResult>>> call({
    String? searchTerm,
    String? country,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    return await repository.searchCities(
      searchTerm: searchTerm,
      country: country,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
