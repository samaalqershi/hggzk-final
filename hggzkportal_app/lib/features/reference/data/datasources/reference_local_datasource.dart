import 'dart:convert';
import 'package:hggzkportal/services/local_storage_service.dart';
import '../models/city_model.dart';
import '../models/currency_model.dart';

/// يعرّف الكلاس المجرد `ReferenceLocalDataSource`.
/// Describes the abstract `ReferenceLocalDataSource` class.
abstract class ReferenceLocalDataSource {
  /// Receives `cacheCities`.
  /// العربية: يعالج `cacheCities`.
  Future<void> cacheCities(List<CityModel> cities);

  /// ينفذ العملية `cacheCurrencies`.
  /// Runs the `cacheCurrencies` operation.
  Future<void> cacheCurrencies(List<CurrencyModel> currencies);

  /// ينفذ العملية `getCachedCities`.
  /// Runs the `getCachedCities` operation.
  List<CityModel> getCachedCities();

  /// ينفذ العملية `getCachedCurrencies`.
  /// Runs the `getCachedCurrencies` operation.
  List<CurrencyModel> getCachedCurrencies();

  /// ينفذ العملية `isCitiesCacheFresh`.
  /// Runs the `isCitiesCacheFresh` operation.
  bool isCitiesCacheFresh();

  /// ينفذ العملية `isCurrenciesCacheFresh`.
  /// Runs the `isCurrenciesCacheFresh` operation.
  bool isCurrenciesCacheFresh();
}

/// يعرّف الكلاس `ReferenceLocalDataSourceImpl`.
/// Describes the `ReferenceLocalDataSourceImpl` class.
class ReferenceLocalDataSourceImpl implements ReferenceLocalDataSource {
  /// Holds the `localStorage` value.
  /// العربية: يخزن القيمة `localStorage`.
  final LocalStorageService localStorage;

  /// يخزن العضو `_citiesKey`.
  /// Holds the `_citiesKey` member.
  static const String _citiesKey = 'reference_cities';

  /// يخزن العضو `_currenciesKey`.
  /// Holds the `_currenciesKey` member.
  static const String _currenciesKey = 'reference_currencies';

  /// يخزن العضو `_citiesTsKey`.
  /// Holds the `_citiesTsKey` member.
  static const String _citiesTsKey = 'reference_cities_ts';

  /// يخزن العضو `_currenciesTsKey`.
  /// Holds the `_currenciesTsKey` member.
  static const String _currenciesTsKey = 'reference_currencies_ts';

  /// ينشئ مثيلاً من `ReferenceLocalDataSourceImpl`.
  /// Builds an instance of `ReferenceLocalDataSourceImpl`.
  ReferenceLocalDataSourceImpl({required this.localStorage});

  /// ينفذ العملية `cacheCities`.
  /// Runs the `cacheCities` operation.
  @override
  Future<void> cacheCities(List<CityModel> cities) async {
    await localStorage.saveData(
        _citiesKey, jsonEncode(cities.map((e) => e.toJson()).toList()));
    await localStorage.saveData(
        _citiesTsKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// ينفذ العملية `cacheCurrencies`.
  /// Runs the `cacheCurrencies` operation.
  @override
  Future<void> cacheCurrencies(List<CurrencyModel> currencies) async {
    await localStorage.saveData(
        _currenciesKey, jsonEncode(currencies.map((e) => e.toJson()).toList()));
    await localStorage.saveData(
        _currenciesTsKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// ينفذ العملية `getCachedCities`.
  /// Runs the `getCachedCities` operation.
  @override
  List<CityModel> getCachedCities() {
    final jsonStr = localStorage.getData(_citiesKey);
    if (jsonStr is String) {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => CityModel.fromJson(e)).toList();
    }
    return const <CityModel>[];
  }

  /// ينفذ العملية `getCachedCurrencies`.
  /// Runs the `getCachedCurrencies` operation.
  @override
  List<CurrencyModel> getCachedCurrencies() {
    final jsonStr = localStorage.getData(_currenciesKey);
    if (jsonStr is String) {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => CurrencyModel.fromJson(e)).toList();
    }
    return const <CurrencyModel>[];
  }

  /// ينفذ العملية `isCitiesCacheFresh`.
  /// Runs the `isCitiesCacheFresh` operation.
  @override
  bool isCitiesCacheFresh() {
    final ts = localStorage.getData(_citiesTsKey);
    if (ts is int) {
      final diff = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(ts))
          .inHours;
      return diff < 24;
    }
    return false;
  }

  /// ينفذ العملية `isCurrenciesCacheFresh`.
  /// Runs the `isCurrenciesCacheFresh` operation.
  @override
  bool isCurrenciesCacheFresh() {
    final ts = localStorage.getData(_currenciesTsKey);
    if (ts is int) {
      final diff = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(ts))
          .inHours;
      return diff < 24;
    }
    return false;
  }
}
