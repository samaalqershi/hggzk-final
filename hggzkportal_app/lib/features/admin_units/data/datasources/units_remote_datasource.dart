import 'package:hggzkportal/core/error/exceptions.dart';
import 'package:hggzkportal/core/network/api_client.dart';
import 'package:dio/dio.dart';
import '../models/unit_analytics_model.dart';
import '../models/unit_model.dart';
import '../models/unit_type_model.dart';
import '../../domain/entities/unit_type.dart';
import 'package:hggzkportal/core/network/api_exceptions.dart' as api;

import 'package:hggzkportal/core/models/paginated_result.dart';

/// يمثل هذا الكلاس المجرد UnitsRemoteDataSource العقد المشترك لمسار إدارة الوحدات.
/// This abstract class defines the shared contract for UnitsRemoteDataSource in the admin unit workflow.
abstract class UnitsRemoteDataSource {
  /// This member returns units.
  /// يعيد units.
  Future<PaginatedResult<UnitModel>> getUnits({
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
  Future<UnitModel> getUnitDetails(String unitId);

  /// ينفذ هذا الأسلوب عملية getUnitAnalytics ضمن مسار إدارة الوحدات.
  /// This method performs the getUnitAnalytics operation in the admin unit workflow.
  Future<UnitAnalyticsModel> getUnitAnalytics(
    String unitId, {
    DateTime? fromDate,
    DateTime? toDate,
  });

  /// ينفذ هذا الأسلوب عملية createUnit ضمن مسار إدارة الوحدات.
  /// This method performs the createUnit operation in the admin unit workflow.
  Future<String> createUnit(Map<String, dynamic> unitData);

  /// ينفذ هذا الأسلوب عملية updateUnit ضمن مسار إدارة الوحدات.
  /// This method performs the updateUnit operation in the admin unit workflow.
  Future<bool> updateUnit(String unitId, Map<String, dynamic> unitData);

  /// ينفذ هذا الأسلوب عملية deleteUnit ضمن مسار إدارة الوحدات.
  /// This method performs the deleteUnit operation in the admin unit workflow.
  Future<bool> deleteUnit(String unitId);

  /// ينفذ هذا الأسلوب عملية getUnitTypesByProperty ضمن مسار إدارة الوحدات.
  /// This method performs the getUnitTypesByProperty operation in the admin unit workflow.
  Future<List<UnitTypeModel>> getUnitTypesByProperty(String propertyTypeId);

  /// ينفذ هذا الأسلوب عملية getUnitFields ضمن مسار إدارة الوحدات.
  /// This method performs the getUnitFields operation in the admin unit workflow.
  Future<List<UnitTypeField>> getUnitFields(String unitTypeId);

  /// ينفذ هذا الأسلوب عملية assignUnitToSections ضمن مسار إدارة الوحدات.
  /// This method performs the assignUnitToSections operation in the admin unit workflow.
  Future<bool> assignUnitToSections(String unitId, List<String> sectionIds);
}

/// يمثل هذا الكلاس UnitsRemoteDataSourceImpl البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitsRemoteDataSourceImpl in the admin unit workflow.
class UnitsRemoteDataSourceImpl implements UnitsRemoteDataSource {
  /// This field keeps the apiClient value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة apiClient التي يعتمد عليها مسار إدارة الوحدات.
  final ApiClient apiClient;

  /// ينشئ هذا المُنشئ مثيلاً من UnitsRemoteDataSourceImpl.
  /// This constructor creates an instance of UnitsRemoteDataSourceImpl.
  UnitsRemoteDataSourceImpl({required this.apiClient});

  /// ينفذ هذا الأسلوب عملية getUnits ضمن مسار إدارة الوحدات.
  /// This method performs the getUnits operation in the admin unit workflow.
  @override
  Future<PaginatedResult<UnitModel>> getUnits({
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
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (pageNumber != null) queryParams['pageNumber'] = pageNumber;
      if (pageSize != null) queryParams['pageSize'] = pageSize;
      if (propertyId != null) queryParams['propertyId'] = propertyId;

      final response = await apiClient.get(
        '/api/admin/Units/simple',
        queryParameters: queryParams,
      );

      return PaginatedResult<UnitModel>.fromJson(
        response.data is Map<String, dynamic>
            ? Map<String, dynamic>.from(response.data)
            : <String, dynamic>{
                'items': (response.data as List?) ?? const [],
                'pageNumber': pageNumber ?? 1,
                'pageSize': pageSize ?? ((response.data as List?)?.length ?? 0),
                'totalCount': ((response.data as List?)?.length ?? 0),
              },
        (json) => UnitModel.fromJson(json),
      );
    } on api.ApiException catch (e) {
      throw ServerException(e.message);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// ينفذ هذا الأسلوب عملية getUnitDetails ضمن مسار إدارة الوحدات.
  /// This method performs the getUnitDetails operation in the admin unit workflow.
  @override
  Future<UnitModel> getUnitDetails(String unitId) async {
    try {
      final response = await apiClient.get('/api/admin/Units/$unitId/details');
      return UnitModel.fromJson(response.data['data']);
    } on api.ApiException catch (e) {
      throw ServerException(e.message);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// ينفذ هذا الأسلوب عملية getUnitAnalytics ضمن مسار إدارة الوحدات.
  /// This method performs the getUnitAnalytics operation in the admin unit workflow.
  @override
  Future<UnitAnalyticsModel> getUnitAnalytics(
    String unitId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (fromDate != null) 'fromDate': fromDate.toIso8601String(),
        if (toDate != null) 'toDate': toDate.toIso8601String(),
      };

      final response = await apiClient.get(
        '/api/admin/Units/$unitId/analytics',
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is Map && data['data'] is Map) {
        return UnitAnalyticsModel.fromJson(
            Map<String, dynamic>.from(data['data']));
      }
      throw const ServerException('Invalid response format');
    } on api.ApiException catch (e) {
      throw ServerException(e.message);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// ينفذ هذا الأسلوب عملية createUnit ضمن مسار إدارة الوحدات.
  /// This method performs the createUnit operation in the admin unit workflow.
  @override
  Future<String> createUnit(Map<String, dynamic> unitData) async {
    try {
      // إضافة logging لمعرفة البيانات المرسلة
      print('=== Creating Unit with Data ===');
      print(unitData);

      final response = await apiClient.post('/api/admin/Units', data: unitData);

      // التحقق من استجابة السيرفر
      print('=== Server Response ===');
      print(response.data);

      // تحسين استخراج ID
      if (response.data is Map && response.data.containsKey('data')) {
        return response.data['data'].toString();
      } else if (response.data is String) {
        return response.data;
      } else {
        throw Exception('Invalid response format');
      }
    } on api.ApiException catch (e) {
      return Future.error(ServerException(e.message));
    } on DioException catch (e) {
      // تحسين معالجة الأخطاء
      print('=== DioException Details ===');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Request Data: ${e.requestOptions.data}');

      throw _handleDioError(e);
    }
  }

  /// ينفذ هذا الأسلوب عملية updateUnit ضمن مسار إدارة الوحدات.
  /// This method performs the updateUnit operation in the admin unit workflow.
  @override
  Future<bool> updateUnit(String unitId, Map<String, dynamic> unitData) async {
    try {
      final response =
          await apiClient.put('/api/admin/Units/$unitId', data: unitData);
      final data = response.data;
      if (data is Map) {
        final success = data['success'] == true;
        if (success) return true;
        final message = data['message'] ?? data['error'] ?? 'فشل تحديث الوحدة';
        throw ServerException(message);
      }
      // Unexpected shape: treat as failure with generic message
      throw ServerException('فشل تحديث الوحدة: رد غير متوقع من الخادم');
    } on api.ApiException catch (e) {
      throw ServerException(e.message);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// ينفذ هذا الأسلوب عملية deleteUnit ضمن مسار إدارة الوحدات.
  /// This method performs the deleteUnit operation in the admin unit workflow.
  @override
  Future<bool> deleteUnit(String unitId) async {
    try {
      final response = await apiClient.delete('/api/admin/Units/$unitId');
      if (response.data is Map && response.data['success'] == true) return true;
      final msg = (response.data is Map) ? response.data['message'] : null;
      throw ServerException(msg ?? 'Failed to delete unit');
    } on api.ApiException catch (e) {
      throw ServerException(e.message);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// ينفذ هذا الأسلوب عملية getUnitTypesByProperty ضمن مسار إدارة الوحدات.
  /// This method performs the getUnitTypesByProperty operation in the admin unit workflow.
  @override
  Future<List<UnitTypeModel>> getUnitTypesByProperty(
      String propertyTypeId) async {
    try {
      final response = await apiClient.get(
        '/api/admin/unit-types/property-type/$propertyTypeId',
      );
      final List<dynamic> items = response.data['items'] ?? [];
      return items.map((json) => UnitTypeModel.fromJson(json)).toList();
    } on api.ApiException catch (e) {
      throw ServerException(e.message);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// ينفذ هذا الأسلوب عملية getUnitFields ضمن مسار إدارة الوحدات.
  /// This method performs the getUnitFields operation in the admin unit workflow.
  @override
  Future<List<UnitTypeField>> getUnitFields(String unitTypeId) async {
    try {
      final response = await apiClient.get(
        '/api/admin/unit-type-fields/unit-type/$unitTypeId',
      );
      final List<dynamic> items = response.data ?? [];
      return items.map((json) => UnitTypeFieldModel.fromJson(json)).toList();
    } on api.ApiException catch (e) {
      throw ServerException(e.message);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// ينفذ هذا الأسلوب عملية assignUnitToSections ضمن مسار إدارة الوحدات.
  /// This method performs the assignUnitToSections operation in the admin unit workflow.
  @override
  Future<bool> assignUnitToSections(
      String unitId, List<String> sectionIds) async {
    try {
      final response = await apiClient.post(
        '/api/admin/units/$unitId/sections',
        data: {'sectionIds': sectionIds},
      );
      return response.data['success'] ?? false;
    } on api.ApiException catch (e) {
      throw ServerException(e.message);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// ينفذ هذا الأسلوب عملية _handleDioError ضمن مسار إدارة الوحدات.
  /// This method performs the _handleDioError operation in the admin unit workflow.
  Exception _handleDioError(DioException error) {
    if (error.response != null) {
      // إظهار تفاصيل الخطأ من السيرفر
      final responseData = error.response?.data;
      String message = 'حدث خطأ في الخادم';

      if (responseData is Map) {
        message = responseData['message'] ??
            responseData['error'] ??
            responseData['errors']?.toString() ??
            message;
      } else if (responseData is String) {
        message = responseData;
      }

      print('Server Error Message: $message');
      return ServerException(message);
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return const ServerException('انتهت مهلة الاتصال');
    } else if (error.type == DioExceptionType.connectionError) {
      return const ServerException('لا يوجد اتصال بالإنترنت');
    } else {
      return ServerException('حدث خطأ غير متوقع: ${error.message}');
    }
  }
}
