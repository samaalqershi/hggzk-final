import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/models/paginated_result.dart';
import '../models/amenity_model.dart';

/// يعرّف عقد الوصول البعيد لميزات المرافق الإدارية، بما في ذلك الإنشاء
/// والتعديل والحذف والإحصاءات وتخصيص المرافق للعقارات وأنواعها.
/// Defines the remote contract for admin amenities, including creation,
/// updates, deletion, statistics, and assigning amenities to properties and
/// property types.
abstract class AmenitiesRemoteDataSource {
  /// ينشئ مرفقًا جديدًا داخل كتالوج الإدارة مع بيانات العرض والتصنيف.
  /// Creates a new amenity in the admin catalog with its display and
  /// classification data.
  Future<String> createAmenity({
    required String name,
    String? nameEn,
    required String description,
    String? descriptionEn,
    required String icon,
    String? propertyTypeId,
    bool isDefaultForType = false,
  });

  /// يحدّث بيانات مرفق موجود مثل الاسم أو الوصف أو الأيقونة دون تغيير
  /// الهوية الأساسية له.
  /// Updates an existing amenity's mutable data such as name, description, or
  /// icon without changing its identity.
  Future<bool> updateAmenity({
    required String amenityId,
    String? name,
    String? nameEn,
    String? description,
    String? descriptionEn,
    String? icon,
  });

  /// يحذف مرفقًا من الخادم عندما لا توجد تبعيات تمنع إزالته.
  /// Deletes an amenity from the backend when no dependency blocks removal.
  Future<bool> deleteAmenity(String amenityId);

  /// يجلب قائمة مرافق مجزأة وفق البحث والارتباطات والحالة لتغذية جداول
  /// الإدارة الكبيرة.
  /// Fetches a paginated amenity list filtered by search, assignment, and
  /// status so large admin tables can render efficiently.
  Future<PaginatedResult<AmenityModel>> getAllAmenities({
    int? pageNumber,
    int? pageSize,
    String? searchTerm,
    String? propertyId,
    bool? isAssigned,
    bool? isFree,
    String? propertyTypeId,
  });

  /// يربط مرفقًا بعقار محدد مع إمكانية ضبط التكلفة الإضافية والوصف
  /// التشغيلي.
  /// Assigns an amenity to a specific property while allowing an optional
  /// extra cost and operational description.
  Future<bool> assignAmenityToProperty({
    required String amenityId,
    required String propertyId,
    bool isAvailable = true,
    double? extraCost,
    String? description,
  });

  /// يجلب مؤشرات المرافق التراكمية التي تعرضها لوحة الإدارة في البطاقات
  /// والإحصاءات السريعة.
  /// Retrieves the aggregate amenity metrics shown in admin dashboard cards
  /// and quick stats.
  Future<AmenityStatsModel> getAmenityStats();

  /// يبدّل حالة المرفق النشط من دون تغيير بياناته الأخرى.
  /// Toggles whether the amenity is active without altering its other data.
  Future<bool> toggleAmenityStatus(String amenityId);

  /// يعيد أشهر المرافق المستخدمة حتى يمكن عرضها في واجهات التصفية أو
  /// التوصية.
  /// Returns the most popular amenities so they can be surfaced in filters or
  /// recommendation views.
  Future<List<AmenityModel>> getPopularAmenities({int limit = 10});

  /// يربط مرفقًا بنوع عقار محدد مع إمكانية تحديده كقيمة افتراضية لذلك
  /// النوع.
  /// Assigns an amenity to a property type and can mark it as the default for
  /// that type.
  Future<bool> assignAmenityToPropertyType({
    required String amenityId,
    required String propertyTypeId,
    bool isDefault = false,
  });
}

/// ينفذ التواصل الفعلي مع واجهات المرافق الإدارية في الخادم ويحوّل
/// الاستجابات إلى نماذج قابلة للاستخدام.
/// Implements the actual admin-amenity backend calls and converts responses
/// into usable models.
class AmenitiesRemoteDataSourceImpl implements AmenitiesRemoteDataSource {
  /// عميل الشبكة المشترك الذي يرسل طلبات المرافق إلى الخادم ويستقبل
  /// استجاباته.
  /// Shared network client that sends amenity requests to the backend and
  /// receives its responses.
  final ApiClient apiClient;

  /// المسار الأساسي الذي تعرض عبره واجهة الإدارة جميع عمليات المرافق.
  /// Base endpoint through which the admin API exposes amenity operations.
  static const String _baseEndpoint = '/api/admin/amenities';

  /// يربط مصدر البيانات البعيد بعميل الشبكة المحقون من طبقة الاعتماد.
  /// Binds the remote datasource to the injected network client from the DI
  /// layer.
  AmenitiesRemoteDataSourceImpl({required this.apiClient});

  @override

  /// يرسل بيانات المرفق الجديد إلى الخادم ثم يعيد المعرف الذي تم
  /// الاعتماد عليه بعد الحفظ.
  /// Sends the new amenity payload to the backend and returns the identifier
  /// accepted after persistence.
  Future<String> createAmenity({
    required String name,
    String? nameEn,
    required String description,
    String? descriptionEn,
    required String icon,
    String? propertyTypeId,
    bool isDefaultForType = false,
  }) async {
    try {
      final response = await apiClient.post(
        _baseEndpoint,
        data: {
          'name': name,
          if (nameEn != null) 'nameEn': nameEn,
          'description': description,
          if (descriptionEn != null) 'descriptionEn': descriptionEn,
          'icon': icon,
          if (propertyTypeId != null) 'propertyTypeId': propertyTypeId,
          if (propertyTypeId != null) 'isDefaultForType': isDefaultForType,
        },
      );

      if (response.data['isSuccess'] == true ||
          response.data['success'] == true) {
        return (response.data['data'] ?? response.data['id'] ?? '').toString();
      } else {
        throw ApiException(
            message: response.data['message'] ?? 'فشل إنشاء المرفق');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override

  /// يطبق التعديل الجزئي على مرفق موجود ويعيد نجاح العملية أو فشلها.
  /// Applies a partial update to an existing amenity and returns whether the
  /// operation succeeded.
  Future<bool> updateAmenity({
    required String amenityId,
    String? name,
    String? nameEn,
    String? description,
    String? descriptionEn,
    String? icon,
  }) async {
    try {
      final response = await apiClient.put(
        '$_baseEndpoint/$amenityId',
        data: {
          if (name != null) 'name': name,
          if (nameEn != null) 'nameEn': nameEn,
          if (description != null) 'description': description,
          if (descriptionEn != null) 'descriptionEn': descriptionEn,
          if (icon != null) 'icon': icon,
        },
      );

      if (response.data['isSuccess'] == true ||
          response.data['success'] == true) {
        return true;
      } else {
        throw ApiException(
            message: response.data['message'] ?? 'فشل تحديث المرفق');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override

  /// يحذف المرفق بالمعرف المرسل مع إبراز سبب التعارض عندما يرفض الخادم
  /// الإزالة.
  /// Deletes the amenity by id while surfacing conflict reasons when the
  /// backend refuses removal.
  Future<bool> deleteAmenity(String amenityId) async {
    try {
      final response = await apiClient.delete('$_baseEndpoint/$amenityId');

      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if (map['isSuccess'] == true || map['success'] == true) return true;
        // Surface backend reason on conflict
        if (response.statusCode == 409 ||
            map['errorCode'] == 'AMENITY_DELETE_CONFLICT') {
          throw ApiException(
              message:
                  map['message'] ?? 'لا يمكن حذف المرفق لارتباطه ببيانات أخرى',
              statusCode: 409,
              code: 'AMENITY_DELETE_CONFLICT');
        }
      }
      if (response.statusCode == 200 || response.statusCode == 204) return true;
      throw ApiException(message: response.data['message'] ?? 'فشل حذف المرفق');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override

  /// يجلب مجموعة مرافق مع دعم الترقيم والبحث وتصفية الارتباطات مع
  /// العقارات أو أنواعها.
  /// Fetches a amenity collection with pagination, search, and property or
  /// property-type linkage filters.
  Future<PaginatedResult<AmenityModel>> getAllAmenities({
    int? pageNumber,
    int? pageSize,
    String? searchTerm,
    String? propertyId,
    bool? isAssigned,
    bool? isFree,
    String? propertyTypeId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (pageNumber != null) queryParams['pageNumber'] = pageNumber;
      if (pageSize != null) queryParams['pageSize'] = pageSize;
      if (searchTerm != null && searchTerm.isNotEmpty) {
        queryParams['searchTerm'] = searchTerm;
      }
      if (propertyId != null) queryParams['propertyId'] = propertyId;
      if (isAssigned != null) queryParams['isAssigned'] = isAssigned;
      if (isFree != null) queryParams['isFree'] = isFree;
      if (propertyTypeId != null)
        queryParams['propertyTypeId'] = propertyTypeId;

      final response = await apiClient.get(
        _baseEndpoint,
        queryParameters: queryParams,
      );

      if (response.data != null) {
        // Handle both old and new response formats
        final root =
            response.data['items'] == null && response.data['data'] is Map
                ? response.data['data']
                : response.data;

        // Try to get items from different possible locations
        List itemsList = [];
        if (root['items'] != null) {
          itemsList = root['items'] as List;
        } else if (response.data['data'] is List) {
          itemsList = response.data['data'] as List;
        } else if (root is List) {
          itemsList = root;
        }

        final items =
            itemsList.map((json) => AmenityModel.fromJson(json)).toList();

        return PaginatedResult<AmenityModel>(
          items: items,
          totalCount: root['total'] ?? root['totalCount'] ?? items.length,
          pageNumber: root['page'] ?? root['pageNumber'] ?? 1,
          pageSize: root['limit'] ?? root['pageSize'] ?? items.length,
        );
      } else {
        throw ApiException(message: 'استجابة غير صالحة من الخادم');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override

  /// يربط المرفق بعقار ويحمّل الخادم تفاصيل التكلفة الإضافية والوصف
  /// الاختياري.
  /// Assigns the amenity to a property and sends the backend the optional
  /// extra cost and description details.
  Future<bool> assignAmenityToProperty({
    required String amenityId,
    required String propertyId,
    bool isAvailable = true,
    double? extraCost,
    String? description,
  }) async {
    try {
      final response = await apiClient.post(
        '$_baseEndpoint/$amenityId/assign/property/$propertyId',
        data: {
          'isAvailable': isAvailable,
          if (extraCost != null) 'extraCost': extraCost,
          if (description != null) 'description': description,
        },
      );

      if (response.data['isSuccess'] == true) {
        return true;
      } else {
        throw ApiException(
            message: response.data['message'] ?? 'فشل إسناد المرفق');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override

  /// يسترجع الإحصائيات الإجمالية للمرافق مثل العدد النشط والتخصيصات
  /// والإيرادات المرتبطة.
  /// Retrieves the aggregate amenity statistics such as active count,
  /// assignments, and associated revenue.
  Future<AmenityStatsModel> getAmenityStats() async {
    try {
      final response = await apiClient.get('$_baseEndpoint/stats');

      if (response.data['isSuccess'] == true ||
          response.data['success'] == true) {
        return AmenityStatsModel.fromJson(response.data['data']);
      } else {
        throw ApiException(
            message: response.data['message'] ?? 'فشل جلب الإحصائيات');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override

  /// يرسل طلب تبديل لحالة المرفق النشط ويعيد نتيجة العملية النهائية.
  /// Sends a toggle request for the amenity's active state and returns the
  /// final outcome.
  Future<bool> toggleAmenityStatus(String amenityId) async {
    try {
      final response = await apiClient.post(
        '$_baseEndpoint/$amenityId/toggle-status',
      );

      if (response.data['isSuccess'] == true ||
          response.data['success'] == true) {
        return true;
      } else {
        throw ApiException(
            message: response.data['message'] ?? 'فشل تغيير الحالة');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override

  /// يجلب قائمة المرافق الشائعة التي يبرزها الخادم عادةً في الواجهات
  /// الإدارية أو الاقتراحات.
  /// Fetches the popular amenities that the backend usually highlights in
  /// admin views or suggestions.
  Future<List<AmenityModel>> getPopularAmenities({int limit = 10}) async {
    try {
      final response = await apiClient.get(
        '$_baseEndpoint/popular',
        queryParameters: {'limit': limit},
      );

      if (response.data['isSuccess'] == true ||
          response.data['success'] == true) {
        return (response.data['data'] as List? ?? [])
            .map((json) => AmenityModel.fromJson(json))
            .toList();
      } else {
        throw ApiException(
            message: response.data['message'] ?? 'فشل جلب المرافق الشائعة');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override

  /// يربط المرفق بنوع عقار ويحدد هل يكون هذا الربط هو الافتراضي لذلك
  /// النوع.
  /// Assigns the amenity to a property type and specifies whether that
  /// relationship should be the default for the type.
  Future<bool> assignAmenityToPropertyType({
    required String amenityId,
    required String propertyTypeId,
    bool isDefault = false,
  }) async {
    try {
      final response = await apiClient.post(
        '$_baseEndpoint/$amenityId/assign/property-type/$propertyTypeId',
        data: {
          'isDefault': isDefault,
        },
      );

      if (response.data['isSuccess'] == true ||
          response.data['success'] == true) {
        return true;
      } else {
        throw ApiException(
            message: response.data['message'] ?? 'فشل ربط المرفق بنوع العقار');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
