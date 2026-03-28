import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../../domain/entities/amenity.dart';
import '../../domain/repositories/amenities_repository.dart';
import '../datasources/amenities_remote_datasource.dart';

/// يربط عقد المرافق في الدومين بمصدر البيانات البعيد ويحوّل
/// الاستثناءات إلى فشل نطاقي قابل للاستهلاك في الطبقة العليا.
/// Bridges the amenities domain contract to the remote datasource and maps
/// exceptions into domain failures that upper layers can consume.
class AmenitiesRepositoryImpl implements AmenitiesRepository {
  /// مصدر البيانات البعيد المسؤول عن تنفيذ طلبات المرافق الفعلية.
  /// Remote datasource that performs the actual amenity requests.
  final AmenitiesRemoteDataSource remoteDataSource;

  /// يربط المستودع بمصدر البيانات المحقون من طبقة الاعتماد.
  /// Binds the repository to the injected datasource from the DI layer.
  AmenitiesRepositoryImpl({required this.remoteDataSource});

  @override

  /// ينشئ مرفقًا جديدًا عبر المصدر البعيد ثم يحوّل النتيجة إلى `Either`.
  /// Creates a new amenity through the remote source and wraps the result in
  /// an `Either`.
  Future<Either<Failure, String>> createAmenity({
    required String name,
    required String description,
    required String icon,
    String? propertyTypeId,
    bool isDefaultForType = false,
  }) async {
    try {
      final result = await remoteDataSource.createAmenity(
        name: name,
        description: description,
        icon: icon,
        propertyTypeId: propertyTypeId,
        isDefaultForType: isDefaultForType,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override

  /// يحدّث المرفق المطلوب ويعيد حالة النجاح أو سبب الفشل على شكل
  /// `Either`.
  /// Updates the requested amenity and returns success or failure as an
  /// `Either`.
  Future<Either<Failure, bool>> updateAmenity({
    required String amenityId,
    String? name,
    String? description,
    String? icon,
  }) async {
    try {
      final result = await remoteDataSource.updateAmenity(
        amenityId: amenityId,
        name: name,
        description: description,
        icon: icon,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override

  /// يحذف المرفق المطلوب ويترجم أي فشل في الشبكة إلى فشل نطاقي واضح.
  /// Deletes the requested amenity and translates network failures into a
  /// clear domain failure.
  Future<Either<Failure, bool>> deleteAmenity(String amenityId) async {
    try {
      final result = await remoteDataSource.deleteAmenity(amenityId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override

  /// يجلب قائمة المرافق المجزأة ثم يضمن أن الطبقة العليا تتعامل مع كيان
  /// النطاق وليس نموذج النقل.
  /// Fetches a paginated amenity list and ensures upper layers deal with the
  /// domain entity rather than the transport model.
  Future<Either<Failure, PaginatedResult<Amenity>>> getAllAmenities({
    int? pageNumber,
    int? pageSize,
    String? searchTerm,
    String? propertyId,
    bool? isAssigned,
    bool? isFree,
    String? propertyTypeId,
  }) async {
    try {
      final result = await remoteDataSource.getAllAmenities(
        pageNumber: pageNumber,
        pageSize: pageSize,
        searchTerm: searchTerm,
        propertyId: propertyId,
        isAssigned: isAssigned,
        isFree: isFree,
        propertyTypeId: propertyTypeId,
      );

      return Right(PaginatedResult<Amenity>(
        items: result.items,
        totalCount: result.totalCount,
        pageNumber: result.pageNumber,
        pageSize: result.pageSize,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override

  /// يربط المرفق بعقار ويعيد النتيجة النهائية في `Either` حتى يسهل على
  /// واجهات العرض التعامل معها.
  /// Assigns an amenity to a property and returns the final result inside an
  /// `Either` for easy UI consumption.
  Future<Either<Failure, bool>> assignAmenityToProperty({
    required String amenityId,
    required String propertyId,
    bool isAvailable = true,
    double? extraCost,
    String? description,
  }) async {
    try {
      final result = await remoteDataSource.assignAmenityToProperty(
        amenityId: amenityId,
        propertyId: propertyId,
        isAvailable: isAvailable,
        extraCost: extraCost,
        description: description,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override

  /// يجلب إحصاءات المرافق ويعيدها ككيان نطاقي جاهز للاستخدام.
  /// Fetches amenity statistics and returns them as a ready-to-use domain
  /// entity.
  Future<Either<Failure, AmenityStats>> getAmenityStats() async {
    try {
      final result = await remoteDataSource.getAmenityStats();
      return Right(AmenityStats(
        totalAmenities: result.totalAmenities,
        activeAmenities: result.activeAmenities,
        totalAssignments: result.totalAssignments,
        totalRevenue: result.totalRevenue,
        popularAmenities: result.popularAmenities,
        revenueByAmenity: result.revenueByAmenity,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override

  /// يبدّل حالة النشاط للمرفق ويعيد نتيجة العملية في `Either`.
  /// Toggles the amenity's active state and returns the result in an `Either`.
  Future<Either<Failure, bool>> toggleAmenityStatus(String amenityId) async {
    try {
      final result = await remoteDataSource.toggleAmenityStatus(amenityId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override

  /// يعيد أكثر المرافق شيوعًا بعد تحويلها إلى كيانات الدومين المناسبة.
  /// Returns the most popular amenities after converting them into the proper
  /// domain entities.
  Future<Either<Failure, List<Amenity>>> getPopularAmenities({
    int limit = 10,
  }) async {
    try {
      final result = await remoteDataSource.getPopularAmenities(limit: limit);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override

  /// يربط المرفق بنوع عقار مع خيار جعله الارتباط الافتراضي لذلك النوع.
  /// Assigns an amenity to a property type with an option to make it the
  /// default relationship for that type.
  Future<Either<Failure, bool>> assignAmenityToPropertyType({
    required String amenityId,
    required String propertyTypeId,
    bool isDefault = false,
  }) async {
    try {
      final result = await remoteDataSource.assignAmenityToPropertyType(
        amenityId: amenityId,
        propertyTypeId: propertyTypeId,
        isDefault: isDefault,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
