import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/unit_model.dart';

/// يمثل هذا الكلاس المجرد UnitsLocalDataSource العقد المشترك لمسار إدارة الوحدات.
/// This abstract class defines the shared contract for UnitsLocalDataSource in the admin unit workflow.
abstract class UnitsLocalDataSource {
  /// This member returns cached units.
  /// يعيد cached units.
  Future<List<UnitModel>> getCachedUnits();

  /// ينفذ هذا الأسلوب عملية cacheUnits ضمن مسار إدارة الوحدات.
  /// This method performs the cacheUnits operation in the admin unit workflow.
  Future<void> cacheUnits(List<UnitModel> units);

  /// ينفذ هذا الأسلوب عملية getCachedUnit ضمن مسار إدارة الوحدات.
  /// This method performs the getCachedUnit operation in the admin unit workflow.
  Future<UnitModel?> getCachedUnit(String unitId);

  /// ينفذ هذا الأسلوب عملية cacheUnit ضمن مسار إدارة الوحدات.
  /// This method performs the cacheUnit operation in the admin unit workflow.
  Future<void> cacheUnit(UnitModel unit);

  /// ينفذ هذا الأسلوب عملية clearCache ضمن مسار إدارة الوحدات.
  /// This method performs the clearCache operation in the admin unit workflow.
  Future<void> clearCache();
}

/// يمثل هذا الكلاس UnitsLocalDataSourceImpl البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitsLocalDataSourceImpl in the admin unit workflow.
class UnitsLocalDataSourceImpl implements UnitsLocalDataSource {
  /// This field keeps the sharedPreferences value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة sharedPreferences التي يعتمد عليها مسار إدارة الوحدات.
  final SharedPreferences sharedPreferences;

  /// يحتفظ هذا الحقل بقيمة CACHED_UNITS_KEY التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the CACHED_UNITS_KEY value used by the admin unit workflow.
  static const String CACHED_UNITS_KEY = 'CACHED_UNITS';

  /// يحتفظ هذا الحقل بقيمة CACHED_UNIT_PREFIX التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the CACHED_UNIT_PREFIX value used by the admin unit workflow.
  static const String CACHED_UNIT_PREFIX = 'CACHED_UNIT_';

  /// ينشئ هذا المُنشئ مثيلاً من UnitsLocalDataSourceImpl.
  /// This constructor creates an instance of UnitsLocalDataSourceImpl.
  UnitsLocalDataSourceImpl({required this.sharedPreferences});

  /// ينفذ هذا الأسلوب عملية getCachedUnits ضمن مسار إدارة الوحدات.
  /// This method performs the getCachedUnits operation in the admin unit workflow.
  @override
  Future<List<UnitModel>> getCachedUnits() async {
    final jsonString = sharedPreferences.getString(CACHED_UNITS_KEY);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => UnitModel.fromJson(json)).toList();
    }
    return [];
  }

  /// ينفذ هذا الأسلوب عملية cacheUnits ضمن مسار إدارة الوحدات.
  /// This method performs the cacheUnits operation in the admin unit workflow.
  @override
  Future<void> cacheUnits(List<UnitModel> units) async {
    final jsonList = units.map((unit) => unit.toJson()).toList();
    await sharedPreferences.setString(
      CACHED_UNITS_KEY,
      json.encode(jsonList),
    );
  }

  /// ينفذ هذا الأسلوب عملية getCachedUnit ضمن مسار إدارة الوحدات.
  /// This method performs the getCachedUnit operation in the admin unit workflow.
  @override
  Future<UnitModel?> getCachedUnit(String unitId) async {
    final jsonString =
        sharedPreferences.getString('$CACHED_UNIT_PREFIX$unitId');
    if (jsonString != null) {
      return UnitModel.fromJson(json.decode(jsonString));
    }
    return null;
  }

  /// ينفذ هذا الأسلوب عملية cacheUnit ضمن مسار إدارة الوحدات.
  /// This method performs the cacheUnit operation in the admin unit workflow.
  @override
  Future<void> cacheUnit(UnitModel unit) async {
    await sharedPreferences.setString(
      '$CACHED_UNIT_PREFIX${unit.id}',
      json.encode(unit.toJson()),
    );
  }

  /// ينفذ هذا الأسلوب عملية clearCache ضمن مسار إدارة الوحدات.
  /// This method performs the clearCache operation in the admin unit workflow.
  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(CACHED_UNITS_KEY);
    // Remove all cached individual units
    final keys = sharedPreferences.getKeys();
    for (final key in keys) {
      if (key.startsWith(CACHED_UNIT_PREFIX)) {
        await sharedPreferences.remove(key);
      }
    }
  }
}
