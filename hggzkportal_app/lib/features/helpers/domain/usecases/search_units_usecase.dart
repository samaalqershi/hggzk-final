import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../entities/search_result.dart';
import '../repositories/helpers_repository.dart';

/// يعرّف الكلاس `SearchUnitsUseCase`.
/// Describes the `SearchUnitsUseCase` class.
class SearchUnitsUseCase {
  /// Holds the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final HelpersRepository repository;

  /// ينشئ مثيلاً من `SearchUnitsUseCase`.
  /// Builds an instance of `SearchUnitsUseCase`.
  SearchUnitsUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  Future<Either<Failure, PaginatedResult<SearchResult>>> call({
    String? searchTerm,
    String? propertyId,
    String? unitTypeId,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    return await repository.searchUnits(
      searchTerm: searchTerm,
      propertyId: propertyId,
      unitTypeId: unitTypeId,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
