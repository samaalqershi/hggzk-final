import 'package:hggzkportal/core/error/exceptions.dart';
import 'package:hggzkportal/core/network/api_client.dart';
import 'package:dio/dio.dart';

import '../models/city_model.dart';
import '../models/currency_model.dart';

/// يعرّف الكلاس المجرد `ReferenceRemoteDataSource`.
/// Describes the abstract `ReferenceRemoteDataSource` class.
abstract class ReferenceRemoteDataSource {
  /// Exposes the cities.
  /// العربية: يعيد cities.
  Future<List<CityModel>> getCities();

  /// ينفذ العملية `getCurrencies`.
  /// Runs the `getCurrencies` operation.
  Future<List<CurrencyModel>> getCurrencies();
}

/// يعرّف الكلاس `ReferenceRemoteDataSourceImpl`.
/// Describes the `ReferenceRemoteDataSourceImpl` class.
class ReferenceRemoteDataSourceImpl implements ReferenceRemoteDataSource {
  /// Holds the `apiClient` value.
  /// العربية: يخزن القيمة `apiClient`.
  final ApiClient apiClient;

  /// ينشئ مثيلاً من `ReferenceRemoteDataSourceImpl`.
  /// Builds an instance of `ReferenceRemoteDataSourceImpl`.
  ReferenceRemoteDataSourceImpl({required this.apiClient});

  /// ينفذ العملية `getCities`.
  /// Runs the `getCities` operation.
  @override
  Future<List<CityModel>> getCities() async {
    try {
      final response = await apiClient.get('/api/admin/system-settings/cities');
      if (response.statusCode == 200) {
        final data = response.data;
        final list = (data is Map<String, dynamic>) ? data['data'] : data;
        if (list is List) {
          return list.map((e) => CityModel.fromJson(e)).toList();
        }
      }
      throw const ServerException('Invalid response structure for cities');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }

  /// ينفذ العملية `getCurrencies`.
  /// Runs the `getCurrencies` operation.
  @override
  Future<List<CurrencyModel>> getCurrencies() async {
    try {
      final response =
          await apiClient.get('/api/common/system-settings/currencies');
      if (response.statusCode == 200) {
        final data = response.data;
        final list = (data is Map<String, dynamic>) ? data['data'] : data;
        if (list is List) {
          return list.map((e) => CurrencyModel.fromJson(e)).toList();
        }
      }
      throw const ServerException('Invalid response structure for currencies');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }
}
