import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/city_model.dart';

/// يعرّف العقدة المحلية التي تحفظ آخر لقطة لبيانات المدن حتى تتمكن لوحة
/// التحكم من استعادة الجداول بسرعة أو الاستمرار في القراءة عند تعذر الشبكة.
/// Defines the local boundary that preserves the latest city snapshot so the
/// admin dashboard can restore tables quickly or keep reading data when the
/// network is unavailable.
abstract class CitiesLocalDataSource {
  /// يعيد قائمة المدن المخزنة محليًا كما كانت عند آخر مزامنة ناجحة مع الخادم.
  /// Returns the locally cached city list exactly as it was after the last
  /// successful sync with the backend.
  Future<List<CityModel>> getCachedCities();

  /// يخزن اللقطة الحالية للمدن مع وقت كتابتها حتى يمكن لاحقًا التحقق من أن
  /// الكاش ما زال صالحًا قبل الاعتماد عليه.
  /// Persists the current city snapshot together with its write timestamp so
  /// callers can later verify that the cache is still safe to reuse.
  Future<void> cacheCities(List<CityModel> cities);

  /// يمسح الحمولة المحلية والطابع الزمني المرتبط بها عندما نريد فرض جلب جديد
  /// أو التخلص من نسخة قديمة.
  /// Clears the cached payload and its timestamp when a fresh fetch must be
  /// forced or an outdated snapshot should be discarded.
  Future<void> clearCache();

  /// يحدد ما إذا كانت النسخة المحلية لا تزال ضمن عمرها المسموح ويمكن
  /// استخدامها كبديل سريع عن الشبكة.
  /// Determines whether the local snapshot is still within its allowed age and
  /// can be used as a fast alternative to the network.
  Future<bool> isCacheValid();
}

/// يطبق تخزين كاش المدن باستخدام `SharedPreferences` حتى تبقى البيانات
/// خفيفة وسهلة الاسترجاع بين جلسات لوحة التحكم.
/// Implements city caching with `SharedPreferences` so the data remains
/// lightweight and easy to restore across dashboard sessions.
class CitiesLocalDataSourceImpl implements CitiesLocalDataSource {
  /// مخزن القيم المفتاحية الذي يحتفظ ببيانات المدن المسلسلة ووقت آخر تحديث.
  /// Key-value storage used to keep the serialized city payload and its last
  /// refresh timestamp.
  final SharedPreferences sharedPreferences;

  /// المفتاح الذي تُحفظ تحته قائمة المدن بعد تحويلها إلى JSON.
  /// Key that stores the city list after it has been serialized to JSON.
  static const String CACHED_CITIES_KEY = 'CACHED_CITIES';

  /// المفتاح الذي يسجل وقت آخر كتابة للكاش حتى يمكن تقييم صلاحيته لاحقًا.
  /// Key that records the last cache write time so freshness can be evaluated
  /// later.
  static const String CACHE_TIMESTAMP_KEY = 'CITIES_CACHE_TIMESTAMP';

  /// العمر الأقصى المقبول للكاش قبل اعتباره قديمًا ووجوب تحديثه.
  /// Maximum accepted cache age before the snapshot is treated as stale.
  static const Duration CACHE_DURATION = Duration(hours: 24);

  /// يربط التنفيذ المحلي بمثيل `SharedPreferences` الذي يدار على مستوى
  /// التطبيق.
  /// Binds the local implementation to the application-managed
  /// `SharedPreferences` instance.
  CitiesLocalDataSourceImpl({required this.sharedPreferences});

  /// يقرأ قائمة المدن المخزنة ويعيدها كما كانت في آخر مزامنة ناجحة.
  /// Reads the stored city list and returns it exactly as it was in the last
  /// successful sync.
  @override
  Future<List<CityModel>> getCachedCities() async {
    final jsonString = sharedPreferences.getString(CACHED_CITIES_KEY);

    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList
            .map((json) => CityModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        throw CacheException('Failed to decode cached cities');
      }
    } else {
      throw CacheException('No cached cities found');
    }
  }

  /// يحول لقطة المدن إلى JSON ثم يخزنها مع طابعها الزمني الحالي.
  /// Converts the city snapshot to JSON and stores it together with the
  /// current timestamp.
  @override
  Future<void> cacheCities(List<CityModel> cities) async {
    try {
      final jsonList = cities.map((city) => city.toJson()).toList();
      final jsonString = json.encode(jsonList);

      final success = await sharedPreferences.setString(
        CACHED_CITIES_KEY,
        jsonString,
      );

      if (success) {
        await sharedPreferences.setInt(
          CACHE_TIMESTAMP_KEY,
          DateTime.now().millisecondsSinceEpoch,
        );
      } else {
        throw CacheException('Failed to cache cities');
      }
    } catch (e) {
      throw CacheException('Failed to cache cities: ${e.toString()}');
    }
  }

  /// يمسح لقطة المدن والطابع الزمني المرتبط بها من التخزين المحلي.
  /// Clears the city snapshot and its associated timestamp from local
  /// storage.
  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(CACHED_CITIES_KEY);
    await sharedPreferences.remove(CACHE_TIMESTAMP_KEY);
  }

  /// يتحقق من أن النسخة المحلية ما زالت حديثة بما يكفي للاستخدام كبديل.
  /// Checks whether the local snapshot is still fresh enough to use as a
  /// fallback.
  @override
  Future<bool> isCacheValid() async {
    final timestamp = sharedPreferences.getInt(CACHE_TIMESTAMP_KEY);

    if (timestamp == null) {
      return false;
    }

    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();

    return now.difference(cacheTime) < CACHE_DURATION;
  }
}
