import 'dart:convert';
import 'package:hggzk/core/services/local_storage_service.dart';
import '../models/city_model.dart';
import '../models/currency_model.dart';

/// Provides the data-source behavior for `ReferenceLocalDataSource`.
/// العربية: يوفر سلوك مصدر البيانات الخاص بـ `ReferenceLocalDataSource`.
abstract class ReferenceLocalDataSource {
  /// Processes `cacheCities`.
  /// العربية: يعالج `cacheCities`.
  Future<void> cacheCities(List<CityModel> cities);

  /// Processes `cacheCurrencies`.
  /// العربية: يعالج `cacheCurrencies`.
  Future<void> cacheCurrencies(List<CurrencyModel> currencies);

  /// Exposes the cached cities.
  /// العربية: يعيد cached cities.
  List<CityModel> getCachedCities();

  /// Exposes the cached currencies.
  /// العربية: يعيد cached currencies.
  List<CurrencyModel> getCachedCurrencies();

  /// Processes `isCitiesCacheFresh`.
  /// العربية: يعالج `isCitiesCacheFresh`.
  bool isCitiesCacheFresh();

  /// Processes `isCurrenciesCacheFresh`.
  /// العربية: يعالج `isCurrenciesCacheFresh`.
  bool isCurrenciesCacheFresh();
}

/// Describes `ReferenceLocalDataSourceImpl`.
/// العربية: يمثل `ReferenceLocalDataSourceImpl`.
class ReferenceLocalDataSourceImpl implements ReferenceLocalDataSource {
  /// Keeps the `localStorage` value.
  /// العربية: يخزن القيمة `localStorage`.
  final LocalStorageService localStorage;

  /// Keeps the `citiesKey` value.
  /// العربية: يخزن القيمة `citiesKey`.
  static const String _citiesKey = 'reference_cities';

  /// Keeps the `currenciesKey` value.
  /// العربية: يخزن القيمة `currenciesKey`.
  static const String _currenciesKey = 'reference_currencies';

  /// Keeps the `citiesTsKey` value.
  /// العربية: يخزن القيمة `citiesTsKey`.
  static const String _citiesTsKey = 'reference_cities_ts';

  /// Keeps the `currenciesTsKey` value.
  /// العربية: يخزن القيمة `currenciesTsKey`.
  static const String _currenciesTsKey = 'reference_currencies_ts';

  /// Builds a new `ReferenceLocalDataSourceImpl` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `ReferenceLocalDataSourceImpl`.
  ReferenceLocalDataSourceImpl({required this.localStorage});

  /// Processes `cacheCities`.
  /// العربية: يعالج `cacheCities`.
  @override
  Future<void> cacheCities(List<CityModel> cities) async {
    await localStorage.saveData(
        _citiesKey, jsonEncode(cities.map((e) => e.toJson()).toList()));
    await localStorage.saveData(
        _citiesTsKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Processes `cacheCurrencies`.
  /// العربية: يعالج `cacheCurrencies`.
  @override
  Future<void> cacheCurrencies(List<CurrencyModel> currencies) async {
    await localStorage.saveData(
        _currenciesKey, jsonEncode(currencies.map((e) => e.toJson()).toList()));
    await localStorage.saveData(
        _currenciesTsKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Exposes the cached cities.
  /// العربية: يعيد cached cities.
  @override
  List<CityModel> getCachedCities() {
    final jsonStr = localStorage.getData(_citiesKey);
    if (jsonStr is String) {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => CityModel.fromJson(e)).toList();
    }
    return const <CityModel>[];
  }

  /// Exposes the cached currencies.
  /// العربية: يعيد cached currencies.
  @override
  List<CurrencyModel> getCachedCurrencies() {
    final jsonStr = localStorage.getData(_currenciesKey);
    if (jsonStr is String) {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => CurrencyModel.fromJson(e)).toList();
    }
    return const <CurrencyModel>[];
  }

  /// Processes `isCitiesCacheFresh`.
  /// العربية: يعالج `isCitiesCacheFresh`.
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

  /// Processes `isCurrenciesCacheFresh`.
  /// العربية: يعالج `isCurrenciesCacheFresh`.
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
