import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../entities/search_result.dart';

/// يعرّف الكلاس المجرد `HelpersRepository`.
/// Describes the abstract `HelpersRepository` class.
abstract class HelpersRepository {
  /// Receives `searchUsers`.
  /// العربية: يعالج `searchUsers`.
  Future<Either<Failure, PaginatedResult<SearchResult>>> searchUsers({
    String? searchTerm,
    String? role,
    bool? isActive,
    int pageNumber = 1,
    int pageSize = 20,
  });

  /// ينفذ العملية `searchProperties`.
  /// Runs the `searchProperties` operation.
  Future<Either<Failure, PaginatedResult<SearchResult>>> searchProperties({
    String? searchTerm,
    String? typeId,
    String? city,
    bool? isApproved,
    int pageNumber = 1,
    int pageSize = 20,
  });

  /// ينفذ العملية `searchUnits`.
  /// Runs the `searchUnits` operation.
  Future<Either<Failure, PaginatedResult<SearchResult>>> searchUnits({
    String? searchTerm,
    String? propertyId,
    String? unitTypeId,
    int pageNumber = 1,
    int pageSize = 20,
  });

  /// ينفذ العملية `searchCities`.
  /// Runs the `searchCities` operation.
  Future<Either<Failure, PaginatedResult<SearchResult>>> searchCities({
    String? searchTerm,
    String? country,
    int pageNumber = 1,
    int pageSize = 20,
  });

  /// ينفذ العملية `searchBookings`.
  /// Runs the `searchBookings` operation.
  Future<Either<Failure, PaginatedResult<SearchResult>>> searchBookings({
    String? searchTerm,
    String? userId,
    String? unitId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int pageNumber = 1,
    int pageSize = 20,
  });
}
