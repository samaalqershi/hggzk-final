import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../entities/search_result.dart';
import '../repositories/helpers_repository.dart';

/// يعرّف الكلاس `SearchBookingsUseCase`.
/// Describes the `SearchBookingsUseCase` class.
class SearchBookingsUseCase {
  /// Holds the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final HelpersRepository repository;

  /// ينشئ مثيلاً من `SearchBookingsUseCase`.
  /// Builds an instance of `SearchBookingsUseCase`.
  SearchBookingsUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  Future<Either<Failure, PaginatedResult<SearchResult>>> call({
    String? searchTerm,
    String? userId,
    String? unitId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    return await repository.searchBookings(
      searchTerm: searchTerm,
      userId: userId,
      unitId: unitId,
      status: status,
      startDate: startDate,
      endDate: endDate,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
