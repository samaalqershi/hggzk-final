import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hggzk/core/localization/app_localizations.dart';
import 'package:hggzk/core/models/paginated_result.dart';
import '../../../../core/error/exceptions.dart';
import '../models/search_properties_response_model.dart';
import '../../../../core/models/result_dto.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/request_logger.dart';
import '../../../../core/utils/validators.dart';
import '../models/search_filter_model.dart';
import '../models/search_result_model.dart';

/// العربية: يوفر سلوك مصدر البيانات الخاص بـ `SearchRemoteDataSource`.
abstract class SearchRemoteDataSource {
  /// العربية: يعالج `searchProperties`.
  Future<ResultDto<SearchPropertiesResponseModel>> searchProperties({
    String? searchTerm,
    String? city,
    String? propertyTypeId,
    double? minPrice,
    double? maxPrice,
    int? minStarRating,
    List<String>? requiredAmenities,
    String? unitTypeId,
    List<String>? serviceIds,
    DateTime? checkIn,
    DateTime? checkOut,
    int? adults,
    int? children,
    int? guestsCount,
    Map<String, dynamic>? dynamicFieldFilters,
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? preferredCurrency,
    String? sortBy,
    bool previewOnly = false,
    int pageNumber = 1,
    int pageSize = 20,
  });

  /// العربية: يعيد search filters.
  Future<ResultDto<SearchFiltersModel>> getSearchFilters();

  /// العربية: يعيد search suggestions.
  Future<ResultDto<List<String>>> getSearchSuggestions({
    required String query,
    int limit = 10,
  });

  Future<ResultDto<PaginatedResult<SearchResultModel>>>
      getRecommendedProperties({
    String? userId,
    int limit = 10,
  });

  /// العربية: يعيد popular destinations.
  Future<ResultDto<List<String>>> getPopularDestinations({
    int limit = 10,
  });
}

/// العربية: يمثل `SearchRemoteDataSourceImpl`.
class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  /// العربية: يخزن القيمة `apiClient`.
  final ApiClient apiClient;

  /// العربية: ينشئ مثيلًا جديدًا من `SearchRemoteDataSourceImpl`.
  SearchRemoteDataSourceImpl({required this.apiClient});

  /// العربية: يعالج `searchProperties`.
  @override
  Future<ResultDto<SearchPropertiesResponseModel>> searchProperties({
    String? searchTerm,
    String? city,
    String? propertyTypeId,
    double? minPrice,
    double? maxPrice,
    int? minStarRating,
    List<String>? requiredAmenities,
    String? unitTypeId,
    List<String>? serviceIds,
    DateTime? checkIn,
    DateTime? checkOut,
    int? adults,
    int? children,
    int? guestsCount,
    Map<String, dynamic>? dynamicFieldFilters,
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? preferredCurrency,
    String? sortBy,
    bool previewOnly = false,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    const requestName = 'search.searchProperties';
    logRequestStart(requestName, details: {
      if (searchTerm != null) 'searchTerm': searchTerm,
      if (city != null) 'city': city,
      if (propertyTypeId != null) 'propertyTypeId': propertyTypeId,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (minStarRating != null) 'minStarRating': minStarRating,
      if (unitTypeId != null) 'unitTypeId': unitTypeId,
      if (serviceIds != null && serviceIds.isNotEmpty) 'serviceIds': serviceIds,
      if (checkIn != null) 'checkIn': checkIn.toIso8601String(),
      if (checkOut != null) 'checkOut': checkOut.toIso8601String(),
      if (adults != null) 'adults': adults,
      if (children != null) 'children': children,
      if (adults == null && children == null && guestsCount != null)
        'guestsCount': guestsCount,
      if (dynamicFieldFilters != null && dynamicFieldFilters.isNotEmpty)
        'dynamicFieldFilters': dynamicFieldFilters,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (radiusKm != null) 'radiusKm': radiusKm,
      if (preferredCurrency != null) 'preferredCurrency': preferredCurrency,
      if (sortBy != null) 'sortBy': sortBy,
      'previewOnly': previewOnly,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    });
    try {
      if (requiredAmenities != null &&
          requiredAmenities.isNotEmpty &&
          !Validators.areValidGuids(requiredAmenities)) {
        throw ServerException(
          AppLocalizations.translateSync('core.search.invalidAmenityGuids'),
        );
      }

      if (serviceIds != null &&
          serviceIds.isNotEmpty &&
          !Validators.areValidGuids(serviceIds)) {
        throw ServerException(
          AppLocalizations.translateSync('core.search.invalidServiceGuids'),
        );
      }

      final requestBody = <String, dynamic>{
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (searchTerm != null) 'searchTerm': searchTerm,
        if (city != null) 'city': city,
        if (propertyTypeId != null) 'propertyTypeId': propertyTypeId,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (minStarRating != null) 'minStarRating': minStarRating,
        if (unitTypeId != null) 'unitTypeId': unitTypeId,
        if (checkIn != null) 'checkIn': checkIn.toIso8601String(),
        if (checkOut != null) 'checkOut': checkOut.toIso8601String(),
        if (adults != null) 'adults': adults,
        if (children != null) 'children': children,
        if (adults == null && children == null && guestsCount != null)
          'guestsCount': guestsCount,
        if (requiredAmenities != null && requiredAmenities.isNotEmpty)
          'requiredAmenities': requiredAmenities,
        if (serviceIds != null && serviceIds.isNotEmpty)
          'serviceIds': serviceIds,
        if (dynamicFieldFilters != null && dynamicFieldFilters.isNotEmpty)
          'dynamicFieldFilters':
              _serializeDynamicFieldFilters(dynamicFieldFilters),
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (radiusKm != null) 'radiusKm': radiusKm,
        if (preferredCurrency != null) 'preferredCurrency': preferredCurrency,
        if (sortBy != null) 'sortBy': sortBy,
        'previewOnly': previewOnly,
      };

      debugPrint('🔧 [DataSource] FINAL requestBody: $requestBody');

      final response = await apiClient.post(
        '/api/client/properties/search',
        data: requestBody,
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.statusCode == 200) {
        return ResultDto.fromJson(
          response.data,
          (dataJson) => SearchPropertiesResponseModel.fromJson(
            dataJson,
          ),
        );
      } else {
        throw ServerException(
          response.data['message'] ??
              AppLocalizations.translateSync('core.search.failedSearch'),
        );
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ServerException(
        e.message ?? AppLocalizations.translateSync('core.search.networkError'),
      );
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ServerException(
        AppLocalizations.translateSync('core.search.unexpectedError'),
      );
    }
  }

  /// العربية: يعالج `serializeDynamicFieldFilters`.
  Map<String, String> _serializeDynamicFieldFilters(
    Map<String, dynamic> dynamicFieldFilters,
  ) {
    final serialized = <String, String>{};

    dynamicFieldFilters.forEach((key, value) {
      if (value == null) {
        return;
      }

      if (value is String && value.trim().isEmpty) {
        return;
      }

      if (value is Iterable) {
        final cleanedValues = value
            .map((item) => item?.toString().trim())
            .where((item) => item != null && item.isNotEmpty)
            .cast<String>()
            .toList();

        if (cleanedValues.isEmpty) {
          return;
        }

        serialized[key] = cleanedValues.join(',');
        return;
      }

      final normalizedValue = value.toString().trim();
      if (normalizedValue.isEmpty) {
        return;
      }

      serialized[key] = normalizedValue;
    });

    return serialized;
  }

  /// العربية: يعيد search filters.
  @override
  Future<ResultDto<SearchFiltersModel>> getSearchFilters() async {
    const requestName = 'search.getSearchFilters';
    logRequestStart(requestName);
    try {
      final response =
          await apiClient.get('/api/client/search-filters/filters');

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.statusCode == 200) {
        return ResultDto.fromJson(
          response.data,
          (json) => SearchFiltersModel.fromJson(json),
        );
      } else {
        throw ServerException(
          response.data['message'] ??
              AppLocalizations.translateSync('core.search.failedFilters'),
        );
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ServerException(
        e.message ?? AppLocalizations.translateSync('core.search.networkError'),
      );
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ServerException(
        AppLocalizations.translateSync('core.search.unexpectedError'),
      );
    }
  }

  /// العربية: يعيد search suggestions.
  @override
  Future<ResultDto<List<String>>> getSearchSuggestions({
    required String query,
    int limit = 10,
  }) async {
    const requestName = 'search.getSearchSuggestions';
    logRequestStart(requestName, details: {
      'query': query,
      'limit': limit,
    });
    try {
      final response = await apiClient.get(
        '/api/client/search/suggestions',
        queryParameters: {
          'query': query,
          'limit': limit,
        },
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.statusCode == 200) {
        return ResultDto.fromJson(
          response.data,
          (json) =>
              (json as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
        );
      } else {
        throw ServerException(
          response.data['message'] ??
              AppLocalizations.translateSync('core.search.failedSuggestions'),
        );
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ServerException(
        e.message ?? AppLocalizations.translateSync('core.search.networkError'),
      );
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ServerException(
        AppLocalizations.translateSync('core.search.unexpectedError'),
      );
    }
  }

  @override
  Future<ResultDto<PaginatedResult<SearchResultModel>>>
      getRecommendedProperties({
    String? userId,
    int limit = 10,
  }) async {
    const requestName = 'search.getRecommendedProperties';
    logRequestStart(requestName, details: {
      if (userId != null) 'userId': userId,
      'limit': limit,
    });
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
      };
      if (userId != null) queryParams['userId'] = userId;

      final response = await apiClient.get(
        '/api/client/search-filters/recommended-properties',
        queryParameters: queryParams,
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.statusCode == 200) {
        return ResultDto.fromJson(
          response.data,
          (json) => PaginatedResult.fromJson(
            json,
            (itemJson) => SearchResultModel.fromJson(itemJson),
          ),
        );
      } else {
        throw ServerException(
          response.data['message'] ??
              AppLocalizations.translateSync(
                'core.search.failedRecommendations',
              ),
        );
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ServerException(
        e.message ?? AppLocalizations.translateSync('core.search.networkError'),
      );
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ServerException(
        AppLocalizations.translateSync('core.search.unexpectedError'),
      );
    }
  }

  /// العربية: يعيد popular destinations.
  @override
  Future<ResultDto<List<String>>> getPopularDestinations({
    int limit = 10,
  }) async {
    const requestName = 'search.getPopularDestinations';
    logRequestStart(requestName, details: {'limit': limit});
    try {
      final response = await apiClient.get(
        '/api/client/search-filters/popular-destinations',
        queryParameters: {
          'limit': limit,
        },
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.statusCode == 200) {
        return ResultDto.fromJson(
          response.data,
          (dataJson) => (dataJson as List)
              .map<String>(
                  (e) => (e as Map<String, dynamic>)['cityName'] as String)
              .toList(),
        );
      } else {
        throw ServerException(
          response.data['message'] ??
              AppLocalizations.translateSync(
                'core.search.failedPopularDestinations',
              ),
        );
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ServerException(
        e.message ?? AppLocalizations.translateSync('core.search.networkError'),
      );
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ServerException(
        AppLocalizations.translateSync('core.search.unexpectedError'),
      );
    }
  }
}
