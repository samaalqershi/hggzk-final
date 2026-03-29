import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../entities/amenity.dart';

/// 📦 Repository interface للمرافق
abstract class AmenitiesRepository {
  /// إنشاء مرفق جديد
  /// العربية: ينشئ amenity.
  Future<Either<Failure, String>> createAmenity({
    required String name,
    String? nameEn,
    required String description,
    String? descriptionEn,
    required String icon,
    String? propertyTypeId,
    bool isDefaultForType,
  });

  /// تحديث مرفق
  Future<Either<Failure, bool>> updateAmenity({
    required String amenityId,
    String? name,
    String? nameEn,
    String? description,
    String? descriptionEn,
    String? icon,
  });

  /// حذف مرفق
  Future<Either<Failure, bool>> deleteAmenity(String amenityId);

  /// جلب جميع المرافق
  Future<Either<Failure, PaginatedResult<Amenity>>> getAllAmenities({
    int? pageNumber,
    int? pageSize,
    String? searchTerm,
    String? propertyId,
    bool? isAssigned,
    bool? isFree,
    String? propertyTypeId,
  });

  /// إسناد مرفق لعقار
  Future<Either<Failure, bool>> assignAmenityToProperty({
    required String amenityId,
    required String propertyId,
    bool isAvailable = true,
    double? extraCost,
    String? description,
  });

  /// جلب إحصائيات المرافق
  Future<Either<Failure, AmenityStats>> getAmenityStats();

  /// تفعيل/تعطيل مرفق
  Future<Either<Failure, bool>> toggleAmenityStatus(String amenityId);

  /// جلب المرافق الأكثر استخداماً
  Future<Either<Failure, List<Amenity>>> getPopularAmenities({
    int limit = 10,
  });

  /// ربط مرفق بنوع عقار
  Future<Either<Failure, bool>> assignAmenityToPropertyType({
    required String amenityId,
    required String propertyTypeId,
    bool isDefault = false,
  });
}
