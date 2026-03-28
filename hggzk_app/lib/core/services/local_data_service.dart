import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hggzk/features/home/data/models/property_type_model.dart';
import 'package:hggzk/features/home/data/models/unit_type_model.dart';
import 'package:hggzk/features/search/data/models/search_filter_model.dart';

/// مخزن محلي للبيانات المرجعية التي يمكن إعادة بنائها من الكاش بسرعة.
/// Local cache for property types, unit types, and dynamic fields.
class LocalDataService {
  /// مفاتيح الكاش التي تفصل بين كل مجموعة بيانات مخزنة.
  /// Cache keys that keep each data group separate.
  static const String _propertyTypesKey = 'cached_property_types';
  static const String _unitTypesKey = 'cached_unit_types';
  static const String _dynamicFieldsKey = 'cached_dynamic_fields';
  static const String _lastSyncKey = 'last_data_sync';
  static const String _dataVersionKey = 'data_version';

  /// واجهة التفضيلات التي تُحفظ عبرها النسخ المحلية للبيانات.
  /// SharedPreferences handle used for the cached payloads.
  final SharedPreferences _prefs;

  /// يربط المخزن المحلي بمثيل التفضيلات الجاهز من طبقة الحقن.
  /// Binds the local cache to the SharedPreferences instance from DI.
  LocalDataService(this._prefs);

  /// يخزن أنواع العقارات ليتمكن التطبيق من عرضها بدون طلب شبكة جديد.
  /// Caches property types so they can be reused without another network call.
  Future<bool> savePropertyTypes(List<PropertyTypeModel> propertyTypes) async {
    try {
      final jsonList = propertyTypes.map((pt) => pt.toJson()).toList();
      final jsonString = json.encode(jsonList);

      await _prefs.setString(_propertyTypesKey, jsonString);
      await _updateLastSync();
      await _incrementDataVersion();

      return true;
    } catch (e) {
      print('Error saving property types: $e');
      return false;
    }
  }

  /// يعيد أنواع العقارات التي سبق تخزينها محليًا.
  /// Exposes the property types that were previously cached so callers can read it without depending on implementation details.
  List<PropertyTypeModel> getPropertyTypes() {
    try {
      final jsonString = _prefs.getString(_propertyTypesKey);
      if (jsonString == null) return [];

      final jsonList = json.decode(jsonString) as List;
      return jsonList.map((json) => PropertyTypeModel.fromJson(json)).toList();
    } catch (e) {
      print('Error loading property types: $e');
      return [];
    }
  }

  /// يخزن أنواع الوحدات حتى يتوفر بديل محلي عند انقطاع الشبكة.
  /// Caches unit types so the app can still operate offline.
  Future<bool> saveUnitTypes(List<UnitTypeModel> unitTypes) async {
    try {
      final jsonList = unitTypes.map((ut) => ut.toJson()).toList();
      final jsonString = json.encode(jsonList);

      await _prefs.setString(_unitTypesKey, jsonString);
      await _updateLastSync();
      await _incrementDataVersion();

      return true;
    } catch (e) {
      print('Error saving unit types: $e');
      return false;
    }
  }

  /// يعيد أنواع الوحدات المخزنة سابقًا.
  /// Exposes the stored unit types so callers can read it without depending on implementation details.
  List<UnitTypeModel> getUnitTypes() {
    try {
      final jsonString = _prefs.getString(_unitTypesKey);
      if (jsonString == null) return [];

      final jsonList = json.decode(jsonString) as List;
      return jsonList.map((json) => UnitTypeModel.fromJson(json)).toList();
    } catch (e) {
      print('Error loading unit types: $e');
      return [];
    }
  }

  /// يصفّي أنواع الوحدات المخزنة حسب نوع العقار المطلوب.
  /// Filters the cached unit types by the requested property type.
  List<UnitTypeModel> getUnitTypesByPropertyType(String propertyTypeId) {
    final allUnitTypes = getUnitTypes();
    return allUnitTypes
        .where((unitType) => unitType.propertyTypeId == propertyTypeId)
        .toList();
  }

  /// يخزن الحقول الديناميكية المرتبطة بكل نوع وحدة.
  /// Caches the dynamic fields associated with each unit type.
  Future<bool> saveDynamicFields(List<UnitTypeFieldModel> fields) async {
    try {
      final jsonList = fields.map((field) => field.toJson()).toList();
      final jsonString = json.encode(jsonList);

      await _prefs.setString(_dynamicFieldsKey, jsonString);
      await _updateLastSync();
      await _incrementDataVersion();

      return true;
    } catch (e) {
      print('Error saving dynamic fields: $e');
      return false;
    }
  }

  /// يعيد الحقول الديناميكية المخزنة محليًا.
  /// Exposes the cached dynamic fields so callers can read it without depending on implementation details.
  List<UnitTypeFieldModel> getDynamicFields() {
    try {
      final jsonString = _prefs.getString(_dynamicFieldsKey);
      if (jsonString == null) return [];

      final jsonList = json.decode(jsonString) as List;
      return jsonList.map((json) => UnitTypeFieldModel.fromJson(json)).toList();
    } catch (e) {
      print('Error loading dynamic fields: $e');
      return [];
    }
  }

  /// يقتطع الحقول الديناميكية الخاصة بنوع وحدة واحد فقط.
  /// Returns only the dynamic fields for a single unit type.
  List<UnitTypeFieldModel> getDynamicFieldsByUnitType(String unitTypeId) {
    final allFields = getDynamicFields();
    return allFields.where((field) => field.unitTypeId == unitTypeId).toList();
  }

  /// يختار الحقول التي تظهر في واجهة التصفية فقط.
  /// Returns only the fields that should be shown in the filter UI.
  List<UnitTypeFieldModel> getFilterableFieldsByUnitType(String unitTypeId) {
    final allFields = getDynamicFields();
    return allFields
        .where((field) =>
            field.unitTypeId == unitTypeId &&
            field.isSearchable &&
            field.isPublic)
        .toList();
  }

  /// يحفظ المجموعات الثلاث معًا حتى تبقى نسخ الكاش متسقة.
  /// Saves all groups together so the cache stays consistent.
  Future<bool> saveAllData({
    required List<PropertyTypeModel> propertyTypes,
    required List<UnitTypeModel> unitTypes,
    required List<UnitTypeFieldModel> dynamicFields,
  }) async {
    try {
      await Future.wait([
        savePropertyTypes(propertyTypes),
        saveUnitTypes(unitTypes),
        saveDynamicFields(dynamicFields),
      ]);

      await _updateLastSync();
      await _incrementDataVersion();

      return true;
    } catch (e) {
      print('Error saving all data: $e');
      return false;
    }
  }

  /// يتحقق بسرعة من وجود أي مجموعة بيانات محلية جاهزة.
  /// Checks whether the app already has cached lookup data.
  bool hasCachedData() {
    return _prefs.containsKey(_propertyTypesKey) &&
        _prefs.containsKey(_unitTypesKey) &&
        _prefs.containsKey(_dynamicFieldsKey);
  }

  /// يعيد آخر وقت تم فيه تحديث الكاش المحلي.
  /// Exposes the timestamp of the last cache refresh so callers can read it without depending on implementation details.
  DateTime? getLastSyncTime() {
    final timeString = _prefs.getString(_lastSyncKey);
    if (timeString != null) {
      return DateTime.tryParse(timeString);
    }
    return null;
  }

  /// يعيد رقم الإصدار المحلي الذي يتغير كلما تم تحديث الكاش.
  /// Exposes the local data version that increments on each cache update so callers can read it without depending on implementation details.
  int getDataVersion() {
    return _prefs.getInt(_dataVersionKey) ?? 0;
  }

  /// يمسح الكاش بالكامل عند الحاجة إلى إعادة بناء البيانات من البداية.
  /// Clears the full cache when the app needs to rebuild its local dataset.
  Future<bool> clearAllData() async {
    try {
      await Future.wait([
        _prefs.remove(_propertyTypesKey),
        _prefs.remove(_unitTypesKey),
        _prefs.remove(_dynamicFieldsKey),
        _prefs.remove(_lastSyncKey),
        _prefs.remove(_dataVersionKey),
      ]);
      return true;
    } catch (e) {
      print('Error clearing data: $e');
      return false;
    }
  }

  /// يتحقق من صلاحية البيانات المحفوظة ضمن نافذة 24 ساعة.
  /// Checks whether cached data is still valid within a 24-hour window.
  bool isDataValid() {
    final lastSync = getLastSyncTime();
    if (lastSync == null) return false;

    final now = DateTime.now();
    final difference = now.difference(lastSync);

    // البيانات صالحة لمدة 24 ساعة
    return difference.inHours < 24;
  }

  /// يعيد إحصائيات الكاش حتى تفهم الطبقات العليا ما هو المتاح محليًا.
  /// Returns cache statistics so higher layers know what is available locally.
  Map<String, dynamic> getDataStats() {
    final propertyTypes = getPropertyTypes();
    final unitTypes = getUnitTypes();
    final dynamicFields = getDynamicFields();
    final lastSync = getLastSyncTime();
    final dataVersion = getDataVersion();

    return {
      'propertyTypesCount': propertyTypes.length,
      'unitTypesCount': unitTypes.length,
      'dynamicFieldsCount': dynamicFields.length,
      'lastSyncTime': lastSync?.toIso8601String(),
      'dataVersion': dataVersion,
      'isDataValid': isDataValid(),
      'hasCachedData': hasCachedData(),
    };
  }

  // Private methods
  /// يحدّث وقت آخر مزامنة بعد حفظ البيانات.
  /// Updates the last sync timestamp after data is saved.
  Future<void> _updateLastSync() async {
    await _prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  /// يزيد نسخة البيانات كلما تغيّر محتوى الكاش.
  /// Increments the data version whenever the cache content changes.
  Future<void> _incrementDataVersion() async {
    final currentVersion = getDataVersion();
    await _prefs.setInt(_dataVersionKey, currentVersion + 1);
  }
}
