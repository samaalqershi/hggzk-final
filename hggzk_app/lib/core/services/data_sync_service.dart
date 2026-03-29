import 'package:hggzk/core/services/local_data_service.dart';
import 'package:hggzk/core/services/connectivity_service.dart';
import 'package:hggzk/core/localization/app_localizations.dart';
import 'package:hggzk/features/home/data/models/property_type_model.dart';
import 'package:hggzk/features/home/data/models/unit_type_model.dart';
import 'package:hggzk/features/search/data/models/search_filter_model.dart';
import 'package:hggzk/features/reference/data/datasources/reference_remote_datasource.dart';
import 'package:hggzk/features/reference/data/models/city_model.dart';
import 'package:hggzk/features/reference/data/models/currency_model.dart';
import 'package:hggzk/features/home/data/datasources/home_remote_datasource.dart';

/// يقرر متى يعتمد التطبيق على الشبكة ومتى يعود إلى البيانات المحلية.
/// Chooses between remote data and local cache based on connectivity.
class DataSyncService {
  /// التخزين المحلي الذي يزوّد الطبقة ببيانات جاهزة عند انقطاع الشبكة.
  /// Local data store used when the device is offline or a remote request fails.
  final LocalDataService _localDataService;

  /// أداة التحقق من الاتصال قبل اختيار المصدر المناسب.
  /// Connectivity checker used before choosing the data source.
  final ConnectivityService _connectivityService;

  /// المصدر البعيد للبيانات الأساسية القادمة من الخادم.
  /// Remote source that fetches the authoritative backend data.
  final HomeRemoteDataSource _remoteDataSource;

  /// مصدر المرجعيات البعيدة عندما نحتاج مزامنة المدن أو العملات.
  /// Remote reference source used for cities, currencies, and similar lookup data.
  final ReferenceRemoteDataSource _referenceRemoteDataSource;

  /// يربط مزودات البيانات المتفرقة في خدمة واحدة واضحة.
  /// Ties the various data providers together behind a single service.
  DataSyncService({
    required LocalDataService localDataService,
    required ConnectivityService connectivityService,
    required HomeRemoteDataSource remoteDataSource,
    required ReferenceRemoteDataSource referenceRemoteDataSource,
  })  : _localDataService = localDataService,
        _connectivityService = connectivityService,
        _remoteDataSource = remoteDataSource,
        _referenceRemoteDataSource = referenceRemoteDataSource;

  /// يجلب أنواع العقارات من الشبكة ثم يحفظها محليًا كنسخة احتياطية.
  /// Fetches property types remotely and caches them locally as a fallback.
  Future<List<PropertyTypeModel>> getPropertyTypes() async {
    try {
      // نبدأ بالتحقق من الاتصال قبل اختيار المصدر.
      final isConnected = await _connectivityService.checkConnection();

      if (isConnected) {
        // نحاول جلب البيانات من المصدر البعيد أولًا.
        final remoteData = await _remoteDataSource.getPropertyTypes();

        // نحفظ النتيجة محليًا حتى تبقى متاحة عند الانقطاع.
        await _localDataService.savePropertyTypes(remoteData);

        return remoteData;
      } else {
        // نعود إلى البيانات المحفوظة عند غياب الاتصال.
        final localData = _localDataService.getPropertyTypes();

        if (localData.isNotEmpty) {
          return localData;
        } else {
          throw Exception(
            AppLocalizations.translateSync(
                'core.dataSync.noLocalPropertyTypes'),
          );
        }
      }
    } catch (e) {
      // عند الخطأ نحاول العودة إلى النسخة المحلية.
      final localData = _localDataService.getPropertyTypes();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }

  /// يجلب أنواع الوحدات الخاصة بنوع عقار محدد ويحتفظ بها محليًا.
  /// Fetches unit types for a given property type and keeps them cached.
  Future<List<UnitTypeModel>> getUnitTypes(
      {required String propertyTypeId}) async {
    try {
      // نتحقق من الاتصال قبل التنفيذ.
      final isConnected = await _connectivityService.checkConnection();

      if (isConnected) {
        // نجلب من الباك اند عندما تكون الشبكة متاحة.
        final remoteData = await _remoteDataSource.getUnitTypes(
            propertyTypeId: propertyTypeId);

        // نخزن النتيجة محليًا للاستعمال لاحقًا.
        await _localDataService.saveUnitTypes(remoteData);

        return remoteData;
      } else {
        // نستخدم النسخة المحلية عندما لا توجد شبكة.
        final localData =
            _localDataService.getUnitTypesByPropertyType(propertyTypeId);

        if (localData.isNotEmpty) {
          return localData;
        } else {
          throw Exception(
            AppLocalizations.translateSync('core.dataSync.noLocalUnitTypes'),
          );
        }
      }
    } catch (e) {
      // عند الخطأ نحاول الاستفادة من البيانات المحلية.
      final localData =
          _localDataService.getUnitTypesByPropertyType(propertyTypeId);
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }

  /// يعيد الحقول الديناميكية الخاصة بكل نوع وحدة من الكاش إن توفر.
  /// Returns unit-type dynamic fields from cache when available.
  Future<List<UnitTypeFieldModel>> getDynamicFieldsByUnitType(
      String unitTypeId) async {
    try {
      // نتحقق من الاتصال قبل اختيار مسار الجلب.
      final isConnected = await _connectivityService.checkConnection();

      if (isConnected) {
        // يفترض هذا المسار وجود API مباشر، وإلا نعود للكاش المحلي.
        final localData =
            _localDataService.getDynamicFieldsByUnitType(unitTypeId);

        if (localData.isNotEmpty) {
          return localData;
        } else {
          throw Exception(
            AppLocalizations.translateSync('core.dataSync.noDynamicFields'),
          );
        }
      } else {
        // نستخدم البيانات المحفوظة محليًا.
        final localData =
            _localDataService.getDynamicFieldsByUnitType(unitTypeId);

        if (localData.isNotEmpty) {
          return localData;
        } else {
          throw Exception(
            AppLocalizations.translateSync(
              'core.dataSync.noDynamicFieldsLocal',
            ),
          );
        }
      }
    } catch (e) {
      // عند الخطأ نحاول العودة إلى الكاش المحلي.
      final localData =
          _localDataService.getDynamicFieldsByUnitType(unitTypeId);
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }

  /// يعيد حقول التصفية الخاصة بنوع الوحدة نفسها مع fallback محلي.
  /// Returns filterable fields for the unit type with a local fallback.
  Future<List<UnitTypeFieldModel>> getFilterableFieldsByUnitType(
      String unitTypeId) async {
    try {
      // نتحقق من الاتصال قبل تحديد المصدر.
      final isConnected = await _connectivityService.checkConnection();

      if (isConnected) {
        // يمكن توصيل API مباشر هنا، وإلا نستخدم البيانات المحلية.
        final localData =
            _localDataService.getFilterableFieldsByUnitType(unitTypeId);

        if (localData.isNotEmpty) {
          return localData;
        } else {
          throw Exception(
            AppLocalizations.translateSync('core.dataSync.noFilterableFields'),
          );
        }
      } else {
        // نستخدم النسخة المحفوظة محليًا.
        final localData =
            _localDataService.getFilterableFieldsByUnitType(unitTypeId);

        if (localData.isNotEmpty) {
          return localData;
        } else {
          throw Exception(
            AppLocalizations.translateSync(
              'core.dataSync.noFilterableFieldsLocal',
            ),
          );
        }
      }
    } catch (e) {
      // عند الخطأ نحاول العودة إلى البيانات المحلية.
      final localData =
          _localDataService.getFilterableFieldsByUnitType(unitTypeId);
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }

  /// يحدّث مجموعات البيانات الأساسية دفعة واحدة عندما تكون الشبكة متاحة.
  /// Refreshes the core data sets in one pass when the network is available.
  Future<bool> syncAllData() async {
    try {
      // نتحقق من الاتصال قبل بدء المزامنة.
      final isConnected = await _connectivityService.checkConnection();

      if (!isConnected) {
        throw Exception(
          AppLocalizations.translateSync('core.dataSync.noInternet'),
        );
      }

      // نجلب البيانات الأساسية من المصدر البعيد.
      final propertyTypes = await _remoteDataSource.getPropertyTypes();

      // نجمع أنواع الوحدات لجميع أنواع العقارات.
      List<UnitTypeModel> allUnitTypes = [];
      for (final propertyType in propertyTypes) {
        try {
          final unitTypes = await _remoteDataSource.getUnitTypes(
            propertyTypeId: propertyType.id,
          );
          allUnitTypes.addAll(unitTypes);
        } catch (e) {
          print(
              'Error fetching unit types for property type ${propertyType.id}: $e');
        }
      }

      // نستخلص الحقول الديناميكية من جميع أنواع الوحدات.
      List<UnitTypeFieldModel> allDynamicFields = [];
      for (final unitType in allUnitTypes) {
        allDynamicFields.addAll(unitType.fields);
      }

      // نحفظ جميع البيانات محليًا بعد اكتمال الجلب.
      final success = await _localDataService.saveAllData(
        propertyTypes: propertyTypes,
        unitTypes: allUnitTypes,
        dynamicFields: allDynamicFields,
      );

      return success;
    } catch (e) {
      print('Error syncing all data: $e');
      return false;
    }
  }

  /// يزامن بيانات المرجعيات مثل المدن والعملات ويعيد عدد العناصر التي وصلت.
  /// Syncs reference data such as cities and currencies and returns item counts.
  Future<Map<String, int>> syncReferenceData() async {
    final Map<String, int> counts = {'cities': 0, 'currencies': 0};
    try {
      final isConnected = await _connectivityService.checkConnection();
      if (!isConnected) return counts;

      final List<CityModel> cities =
          await _referenceRemoteDataSource.getCities();
      final List<CurrencyModel> currencies =
          await _referenceRemoteDataSource.getCurrencies();
      // Note: LocalDataService currently does not persist cities/currencies; apps can access via ReferenceLocalDataSource
      counts['cities'] = cities.length;
      counts['currencies'] = currencies.length;
      return counts;
    } catch (e) {
      print('Error syncing reference data: $e');
      return counts;
    }
  }

  /// يقرر عند فتح التطبيق هل يجب تحديث البيانات المخزنة أم لا.
  /// Decides on app start whether stored data needs a refresh.
  Future<void> syncOnAppStart() async {
    try {
      // التحقق من صلاحية البيانات المحفوظة
      final isDataValid = _localDataService.isDataValid();
      final hasCachedData = _localDataService.hasCachedData();

      // إذا لم تكن هناك بيانات محفوظة أو انتهت صلاحيتها، قم بالمزامنة
      if (!hasCachedData || !isDataValid) {
        await syncAllData();
      }
    } catch (e) {
      print('Error syncing on app start: $e');
      // لا نريد أن نوقف التطبيق إذا فشلت المزامنة
    }
  }

  /// يعيد مؤشرات سريعة عن كمية البيانات وحداثتها وصلاحيتها.
  /// Returns quick indicators about data volume, freshness, and validity.
  Map<String, dynamic> getDataStats() {
    return _localDataService.getDataStats();
  }

  /// يمسح كل البيانات المحفوظة عندما نحتاج إعادة ضبط كاملة للكاش.
  /// Clears all saved data when a full cache reset is required.
  Future<bool> clearAllData() async {
    return await _localDataService.clearAllData();
  }

  /// يوضح ما إذا كانت هناك بيانات محلية يمكن البناء عليها.
  /// Reports whether there is cached data available.
  bool hasCachedData() {
    return _localDataService.hasCachedData();
  }

  /// يتحقق من أن البيانات المحلية ما زالت داخل نافذة صلاحيتها.
  /// Checks whether the local data is still within its validity window.
  bool isDataValid() {
    return _localDataService.isDataValid();
  }
}
