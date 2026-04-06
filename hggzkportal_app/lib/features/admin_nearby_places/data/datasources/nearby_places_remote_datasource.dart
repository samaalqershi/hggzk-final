import 'package:dio/dio.dart';
import 'package:hggzkportal/core/network/api_client.dart';
import 'package:hggzkportal/core/network/api_exceptions.dart';
import '../models/nearby_place_model.dart';

abstract class NearbyPlacesRemoteDataSource {
  Future<List<NearbyPlaceModel>> getNearbyPlaces({
    String? propertyId,
    String? searchTerm,
    bool? isActive,
  });

  Future<NearbyPlaceModel> getNearbyPlaceById(String nearbyPlaceId);

  Future<String> createNearbyPlace(Map<String, dynamic> data);

  Future<bool> updateNearbyPlace(
      String nearbyPlaceId, Map<String, dynamic> data);

  Future<bool> deleteNearbyPlace(String nearbyPlaceId);

  Future<bool> toggleNearbyPlaceStatus(String nearbyPlaceId);
}

class NearbyPlacesRemoteDataSourceImpl implements NearbyPlacesRemoteDataSource {
  final ApiClient apiClient;
  static const String _baseEndpoint = '/api/admin/property-nearby-places';

  NearbyPlacesRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<NearbyPlaceModel>> getNearbyPlaces({
    String? propertyId,
    String? searchTerm,
    bool? isActive,
  }) async {
    try {
      final response = await apiClient.get(
        _baseEndpoint,
        queryParameters: {
          if (propertyId != null && propertyId.isNotEmpty)
            'propertyId': propertyId,
          if (searchTerm != null && searchTerm.isNotEmpty)
            'searchTerm': searchTerm,
          if (isActive != null) 'isActive': isActive,
        },
      );

      final data = response.data['data'] as List? ?? const [];
      return data
          .whereType<Map>()
          .map((item) =>
              NearbyPlaceModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<NearbyPlaceModel> getNearbyPlaceById(String nearbyPlaceId) async {
    try {
      final response = await apiClient.get('$_baseEndpoint/$nearbyPlaceId');
      return NearbyPlaceModel.fromJson(
        Map<String, dynamic>.from(response.data['data'] as Map),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<String> createNearbyPlace(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post(_baseEndpoint, data: data);
      if (response.data['isSuccess'] == true ||
          response.data['success'] == true) {
        return response.data['data']?.toString() ?? '';
      }

      throw ApiException(
          message: response.data['message'] ?? 'فشل إنشاء المكان القريب');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<bool> updateNearbyPlace(
      String nearbyPlaceId, Map<String, dynamic> data) async {
    try {
      final response =
          await apiClient.put('$_baseEndpoint/$nearbyPlaceId', data: data);
      return response.data['isSuccess'] == true ||
          response.data['success'] == true;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<bool> deleteNearbyPlace(String nearbyPlaceId) async {
    try {
      final response = await apiClient.delete('$_baseEndpoint/$nearbyPlaceId');
      return response.data['isSuccess'] == true ||
          response.data['success'] == true;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<bool> toggleNearbyPlaceStatus(String nearbyPlaceId) async {
    try {
      final response =
          await apiClient.patch('$_baseEndpoint/$nearbyPlaceId/toggle-status');
      return response.data['isSuccess'] == true ||
          response.data['success'] == true;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
