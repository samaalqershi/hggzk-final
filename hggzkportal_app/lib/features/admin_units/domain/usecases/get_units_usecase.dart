import 'package:dartz/dartz.dart' hide Unit;
import 'package:equatable/equatable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/models/paginated_result.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/unit.dart';
import '../repositories/units_repository.dart';

/// يمثل هذا الكلاس GetUnitsUseCase البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for GetUnitsUseCase in the admin unit workflow.
class GetUnitsUseCase
    implements UseCase<PaginatedResult<Unit>, GetUnitsParams> {
  /// يحتفظ هذا الحقل بقيمة repository التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the repository value used by the admin unit workflow.
  final UnitsRepository repository;

  /// ينشئ هذا المُنشئ مثيلاً من GetUnitsUseCase.
  /// This constructor creates an instance of GetUnitsUseCase.
  GetUnitsUseCase(this.repository);

  /// ينفذ هذا الأسلوب عملية call ضمن مسار إدارة الوحدات.
  /// This method performs the call operation in the admin unit workflow.
  @override
  Future<Either<Failure, PaginatedResult<Unit>>> call(
      GetUnitsParams params) async {
    return await repository.getUnits(
      pageNumber: params.pageNumber,
      pageSize: params.pageSize,
      propertyId: params.propertyId,
      unitTypeId: params.unitTypeId,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      searchQuery: params.searchQuery,
      pricingMethod: params.pricingMethod,
      checkInDate: params.checkInDate,
      checkOutDate: params.checkOutDate,
      numberOfGuests: params.numberOfGuests,
      hasActiveBookings: params.hasActiveBookings,
      location: params.location,
      sortBy: params.sortBy,
      latitude: params.latitude,
      longitude: params.longitude,
      radiusKm: params.radiusKm,
    );
  }
}

/// يمثل هذا الكلاس GetUnitsParams البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for GetUnitsParams in the admin unit workflow.
class GetUnitsParams extends Equatable {
  /// This field keeps the pageNumber value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة pageNumber التي يعتمد عليها مسار إدارة الوحدات.
  final int? pageNumber;

  /// يحتفظ هذا الحقل بقيمة pageSize التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the pageSize value used by the admin unit workflow.
  final int? pageSize;

  /// يحتفظ هذا الحقل بقيمة propertyId التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the propertyId value used by the admin unit workflow.
  final String? propertyId;

  /// يحتفظ هذا الحقل بقيمة unitTypeId التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the unitTypeId value used by the admin unit workflow.
  final String? unitTypeId;

  /// يحتفظ هذا الحقل بقيمة minPrice التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the minPrice value used by the admin unit workflow.
  final double? minPrice;

  /// يحتفظ هذا الحقل بقيمة maxPrice التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the maxPrice value used by the admin unit workflow.
  final double? maxPrice;

  /// يحتفظ هذا الحقل بقيمة searchQuery التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the searchQuery value used by the admin unit workflow.
  final String? searchQuery;

  /// يحتفظ هذا الحقل بقيمة pricingMethod التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the pricingMethod value used by the admin unit workflow.
  final String? pricingMethod;

  /// يحتفظ هذا الحقل بقيمة checkInDate التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the checkInDate value used by the admin unit workflow.
  final DateTime? checkInDate;

  /// يحتفظ هذا الحقل بقيمة checkOutDate التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the checkOutDate value used by the admin unit workflow.
  final DateTime? checkOutDate;

  /// يحتفظ هذا الحقل بقيمة numberOfGuests التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the numberOfGuests value used by the admin unit workflow.
  final int? numberOfGuests;

  /// يحتفظ هذا الحقل بقيمة hasActiveBookings التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the hasActiveBookings value used by the admin unit workflow.
  final bool? hasActiveBookings;

  /// يحتفظ هذا الحقل بقيمة location التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the location value used by the admin unit workflow.
  final String? location;

  /// يحتفظ هذا الحقل بقيمة sortBy التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the sortBy value used by the admin unit workflow.
  final String? sortBy;

  /// يحتفظ هذا الحقل بقيمة latitude التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the latitude value used by the admin unit workflow.
  final double? latitude;

  /// يحتفظ هذا الحقل بقيمة longitude التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the longitude value used by the admin unit workflow.
  final double? longitude;

  /// يحتفظ هذا الحقل بقيمة radiusKm التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the radiusKm value used by the admin unit workflow.
  final double? radiusKm;

  /// ينشئ هذا المُنشئ مثيلاً من GetUnitsParams.
  /// This constructor creates an instance of GetUnitsParams.
  const GetUnitsParams({
    this.pageNumber,
    this.pageSize,
    this.propertyId,
    this.unitTypeId,
    this.minPrice,
    this.maxPrice,
    this.searchQuery,
    this.pricingMethod,
    this.checkInDate,
    this.checkOutDate,
    this.numberOfGuests,
    this.hasActiveBookings,
    this.location,
    this.sortBy,
    this.latitude,
    this.longitude,
    this.radiusKm,
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [
        pageNumber,
        pageSize,
        propertyId,
        unitTypeId,
        minPrice,
        maxPrice,
        searchQuery,
        pricingMethod,
        checkInDate,
        checkOutDate,
        numberOfGuests,
        hasActiveBookings,
        location,
        sortBy,
        latitude,
        longitude,
        radiusKm,
      ];
}
