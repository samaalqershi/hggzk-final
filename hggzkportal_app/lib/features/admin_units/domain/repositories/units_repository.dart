import 'package:dartz/dartz.dart' hide Unit;
import '../../../../../core/error/failures.dart';
import '../../../../../core/models/paginated_result.dart';
import '../entities/unit.dart';
import '../entities/unit_type.dart';
import '../entities/unit_analytics.dart';

/// يمثل هذا الكلاس المجرد UnitsRepository العقد المشترك لمسار إدارة الوحدات.
/// This abstract class defines the shared contract for UnitsRepository in the admin unit workflow.
abstract class UnitsRepository {
  /// This member returns units.
  /// يعيد units.
  Future<Either<Failure, PaginatedResult<Unit>>> getUnits({
    int? pageNumber,
    int? pageSize,
    String? propertyId,
    String? unitTypeId,
    double? minPrice,
    double? maxPrice,
    String? searchQuery,
    String? pricingMethod,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? numberOfGuests,
    bool? hasActiveBookings,
    String? location,
    String? sortBy,
    double? latitude,
    double? longitude,
    double? radiusKm,
  });

  /// ينفذ هذا الأسلوب عملية getUnitDetails ضمن مسار إدارة الوحدات.
  /// This method performs the getUnitDetails operation in the admin unit workflow.
  Future<Either<Failure, Unit>> getUnitDetails(String unitId);

  /// ينفذ هذا الأسلوب عملية getUnitAnalytics ضمن مسار إدارة الوحدات.
  /// This method performs the getUnitAnalytics operation in the admin unit workflow.
  Future<Either<Failure, UnitAnalytics>> getUnitAnalytics({
    required String unitId,
    DateTime? fromDate,
    DateTime? toDate,
  });

  /// ينفذ هذا الأسلوب عملية createUnit ضمن مسار إدارة الوحدات.
  /// This method performs the createUnit operation in the admin unit workflow.
  Future<Either<Failure, String>> createUnit({
    required String propertyId,
    required String unitTypeId,
    required String name,
    String? nameEn,
    required String description,
    required String customFeatures,
    String? customFeaturesEn,
    required String pricingMethod,
    List<Map<String, dynamic>>? fieldValues,
    List<String>? images,
    int? adultCapacity,
    int? childrenCapacity,
    bool? allowsCancellation,
    int? cancellationWindowDays,
    String? tempKey,
  });

  /// ينفذ هذا الأسلوب عملية updateUnit ضمن مسار إدارة الوحدات.
  /// This method performs the updateUnit operation in the admin unit workflow.
  Future<Either<Failure, bool>> updateUnit({
    required String unitId,
    String? name,
    String? nameEn,
    String? description,
    String? customFeatures,
    String? customFeaturesEn,
    String? pricingMethod,
    List<Map<String, dynamic>>? fieldValues,
    List<String>? images,
    int? adultCapacity,
    int? childrenCapacity,
    bool? allowsCancellation,
    int? cancellationWindowDays,
  });

  /// ينفذ هذا الأسلوب عملية deleteUnit ضمن مسار إدارة الوحدات.
  /// This method performs the deleteUnit operation in the admin unit workflow.
  Future<Either<Failure, bool>> deleteUnit(String unitId);

  /// ينفذ هذا الأسلوب عملية getUnitTypesByProperty ضمن مسار إدارة الوحدات.
  /// This method performs the getUnitTypesByProperty operation in the admin unit workflow.
  Future<Either<Failure, List<UnitType>>> getUnitTypesByProperty(
      String propertyTypeId);

  /// ينفذ هذا الأسلوب عملية getUnitFields ضمن مسار إدارة الوحدات.
  /// This method performs the getUnitFields operation in the admin unit workflow.
  Future<Either<Failure, List<UnitTypeField>>> getUnitFields(String unitTypeId);

  /// ينفذ هذا الأسلوب عملية assignUnitToSections ضمن مسار إدارة الوحدات.
  /// This method performs the assignUnitToSections operation in the admin unit workflow.
  Future<Either<Failure, bool>> assignUnitToSections(
    String unitId,
    List<String> sectionIds,
  );
}
