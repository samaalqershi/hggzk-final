import 'package:hggzk/core/network/api_client.dart';
import 'package:hggzk/core/error/exceptions.dart';
import 'package:hggzk/core/localization/app_localizations.dart';
import 'package:dio/dio.dart';

import '../models/city_model.dart';
import '../models/currency_model.dart';

/// Provides the data-source behavior for `ReferenceRemoteDataSource`.
/// العربية: يوفر سلوك مصدر البيانات الخاص بـ `ReferenceRemoteDataSource`.
abstract class ReferenceRemoteDataSource {
  /// Exposes the cities.
  /// العربية: يعيد cities.
  Future<List<CityModel>> getCities();

  /// Exposes the currencies.
  /// العربية: يعيد currencies.
  Future<List<CurrencyModel>> getCurrencies();
}

/// Describes `ReferenceRemoteDataSourceImpl`.
/// العربية: يمثل `ReferenceRemoteDataSourceImpl`.
class ReferenceRemoteDataSourceImpl implements ReferenceRemoteDataSource {
  /// Keeps the `apiClient` value.
  /// العربية: يخزن القيمة `apiClient`.
  final ApiClient apiClient;

  /// Builds a new `ReferenceRemoteDataSourceImpl` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `ReferenceRemoteDataSourceImpl`.
  ReferenceRemoteDataSourceImpl({required this.apiClient});

  /// Exposes the cities.
  /// العربية: يعيد cities.
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
      throw ServerException(
        AppLocalizations.translateSync('core.reference.invalidCitiesResponse'),
      );
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? AppLocalizations.translateSync('core.reference.networkError'),
      );
    }
  }

  /// Exposes the currencies.
  /// العربية: يعيد currencies.
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
      throw ServerException(
        AppLocalizations.translateSync(
          'core.reference.invalidCurrenciesResponse',
        ),
      );
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? AppLocalizations.translateSync('core.reference.networkError'),
      );
    }
  }
}
