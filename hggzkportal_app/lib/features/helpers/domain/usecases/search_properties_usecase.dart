import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../entities/search_result.dart';
import '../repositories/helpers_repository.dart';

/// يعرّف الكلاس `SearchPropertiesUseCase`.
/// Describes the `SearchPropertiesUseCase` class.
class SearchPropertiesUseCase {
  /// Holds the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final HelpersRepository repository;

  /// ينشئ مثيلاً من `SearchPropertiesUseCase`.
  /// Builds an instance of `SearchPropertiesUseCase`.
  SearchPropertiesUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  Future<Either<Failure, PaginatedResult<SearchResult>>> call({
    String? searchTerm,
    String? typeId,
    String? city,
    bool? isApproved,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    return await repository.searchProperties(
      searchTerm: searchTerm,
      typeId: typeId,
      city: city,
      isApproved: isApproved,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
