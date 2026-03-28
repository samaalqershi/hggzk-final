import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/amenity.dart';
import '../repositories/amenities_repository.dart';

/// يقرأ قائمة المرافق مع الفلاتر والصفحات حتى تبقى شاشة الإدارة قابلة
/// للبحث والتقسيم إلى صفحات.
/// Loads the amenity list with filters and paging so the admin screen remains
/// searchable and paginated.
class GetAllAmenitiesUseCase
    implements UseCase<PaginatedResult<Amenity>, GetAllAmenitiesParams> {
  /// المستودع الذي يجلب بيانات المرافق من المصدر المعتمد.
  /// The repository that fetches amenity data from the trusted source.
  final AmenitiesRepository repository;

  /// Creates the list-loading use case with the amenities repository.
  GetAllAmenitiesUseCase(this.repository);

  @override

  /// يمرر معايير البحث والتقسيم كما هي إلى المستودع ليعيد صفحة النتائج
  /// المناسبة.
  /// Forwards the search and paging criteria to the repository so it returns
  /// the correct result page.
  Future<Either<Failure, PaginatedResult<Amenity>>> call(
      GetAllAmenitiesParams params) async {
    return await repository.getAllAmenities(
      pageNumber: params.pageNumber,
      pageSize: params.pageSize,
      searchTerm: params.searchTerm,
      propertyId: params.propertyId,
      isAssigned: params.isAssigned,
      isFree: params.isFree,
      propertyTypeId: params.propertyTypeId,
    );
  }
}

/// يجمع فلاتر جلب المرافق في طلب واحد حتى تبقى الواجهة والخادم متفقين على
/// نفس معايير البحث.
/// Collects amenity-fetch filters in one request object so the UI and server
/// agree on the same search criteria.
class GetAllAmenitiesParams extends Equatable {
  /// رقم الصفحة المطلوب تحميلها من قائمة المرافق.
  /// The page number that should be loaded from the amenity list.
  final int? pageNumber;

  /// حجم الصفحة المطلوب حتى يعرف المستودع عدد السجلات التي يعيدها.
  /// The requested page size so the repository knows how many records to
  /// return.
  final int? pageSize;

  /// نص البحث الاختياري لتصفية المرافق بالاسم أو الوصف.
  /// Optional search text used to filter amenities by name or description.
  final String? searchTerm;

  /// معرّف العقار عندما نريد المرافق المرتبطة بعقار محدد فقط.
  /// The property identifier when only amenities bound to one property are
  /// needed.
  final String? propertyId;

  /// يحدد ما إذا كنا نريد المرافق المرتبطة بالفعل بعقار.
  /// Indicates whether only amenities already assigned to a property should be
  /// returned.
  final bool? isAssigned;

  /// يحدد ما إذا كنا نريد المرافق المجانية فقط.
  /// Indicates whether only free amenities should be returned.
  final bool? isFree;

  /// معرّف نوع العقار لتضييق النتائج على نوع واحد.
  /// The property-type identifier used to narrow results to one type.
  final String? propertyTypeId;

  /// Creates the parameter object that controls amenity pagination and
  /// filtering.
  const GetAllAmenitiesParams({
    this.pageNumber = 1,
    this.pageSize = 10,
    this.searchTerm,
    this.propertyId,
    this.isAssigned,
    this.isFree,
    this.propertyTypeId,
  });

  @override

  /// تعتمد المساواة على كل فلتر لأن أي تغيير فيها ينتج استعلامًا مختلفًا.
  /// Equality depends on every filter because any change produces a different
  /// query.
  List<Object?> get props => [
        pageNumber,
        pageSize,
        searchTerm,
        propertyId,
        isAssigned,
        isFree,
        propertyTypeId,
      ];
}
