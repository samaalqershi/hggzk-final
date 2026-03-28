import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// يجمّع إعدادات الواجهة وحالة الجلسة الخفيفة في مكان واحد بدل تشتتها داخل الشاشات.
/// Centralizes UI preferences and lightweight session state away from the screens.
class LocalStorageService {
  /// واجهة التخزين المشتركة التي نعتمد عليها في القراءة والكتابة.
  /// SharedPreferences instance used for all reads and writes.
  final SharedPreferences _prefs;

  /// يربط الخدمة بالمخزن المهيأ من الحاوية حتى تبقى قابلة للاختبار.
  /// Binds the service to the injected preferences instance so it stays testable.
  LocalStorageService(this._prefs);

  /// مفاتيح البيانات التي يحتاجها التطبيق بين الجلسات.
  /// Keys for the data the app needs to preserve between sessions.
  static const String _themeKey = 'app_theme';
  static const String _languageKey = 'app_language';
  static const String _onboardingKey = 'onboarding_completed';
  static const String _fcmTokenKey = 'fcm_token';
  static const String _lastSyncKey = 'last_sync';
  static const String _searchHistoryKey = 'search_history';
  static const String _filtersKey = 'search_filters';
  static const String _recentPropertiesKey = 'recent_properties';
  static const String _draftBookingKey = 'draft_booking';
  static const String _selectedCityKey = 'selected_city';
  static const String _selectedCurrencyKey = 'selected_currency';

  /// يحفظ الثيم حتى يبقى شكل التطبيق متسقًا بعد الإغلاق والفتح.
  /// Persists the selected theme so the app stays visually consistent.
  Future<bool> saveTheme(String theme) async {
    return await _prefs.setString(_themeKey, theme);
  }

  /// يعيد الثيم المحفوظ أو يترك التطبيق على افتراضيه إذا لم يُخزّن شيء.
  /// Returns the saved theme or lets the app fall back to its default.
  String? getTheme() {
    return _prefs.getString(_themeKey);
  }

  /// يحفظ لغة الواجهة حتى لا يفقد المستخدم اختياره عند إعادة التشغيل.
  /// Persists the UI language so the chosen locale survives relaunches.
  Future<bool> saveLanguage(String languageCode) async {
    return await _prefs.setString(_languageKey, languageCode);
  }

  /// يعيد لغة الواجهة مع العربية كخيار آمن عند غياب أي إعداد مخزن.
  /// Returns the selected language and falls back to Arabic when nothing exists.
  String getLanguage() {
    return _prefs.getString(_languageKey) ?? 'ar';
  }

  /// يسجل إتمام شاشة الترحيب حتى لا تظهر مرة أخرى بلا داعٍ.
  /// Marks onboarding as completed so the first-run flow does not repeat.
  Future<bool> setOnboardingCompleted(bool completed) async {
    return await _prefs.setBool(_onboardingKey, completed);
  }

  /// يحدد ما إذا كان التطبيق ما زال بحاجة إلى مسار التعريف الأولي.
  /// Reports whether the first-run onboarding flow is still required.
  bool isOnboardingCompleted() {
    return _prefs.getBool(_onboardingKey) ?? false;
  }

  /// يحفظ المدينة الأخيرة كي تعود نتائج البحث إلى نفس السياق الجغرافي.
  /// Stores the latest city so search results can return to the same location.
  Future<bool> saveSelectedCity(String cityName) async {
    return await _prefs.setString(_selectedCityKey, cityName);
  }

  /// يعيد المدينة المختارة أو قيمة فارغة عندما لم يحدد المستخدم مدينة.
  /// Returns the selected city or an empty string when nothing has been chosen.
  String getSelectedCity() {
    return _prefs.getString(_selectedCityKey) ?? '';
  }

  /// يحفظ العملة المختارة حتى تعرض جميع الشاشات نفس وحدة السعر.
  /// Persists the chosen currency so all screens show the same money unit.
  Future<bool> saveSelectedCurrency(String currencyCode) async {
    return await _prefs.setString(_selectedCurrencyKey, currencyCode);
  }

  /// يعيد العملة المحفوظة أو ريالًا يمنيًا عندما لا يوجد اختيار سابق.
  /// Returns the saved currency or falls back to YER when nothing was stored.
  String getSelectedCurrency() {
    return _prefs.getString(_selectedCurrencyKey) ?? 'YER';
  }

  /// يحفظ توكن FCM محليًا ليستفيد منه التطبيق بعد إعادة التشغيل أو المزامنة.
  /// Stores the FCM token locally for later bootstrap or synchronization.
  Future<bool> saveFcmToken(String token) async {
    return await _prefs.setString(_fcmTokenKey, token);
  }

  /// يعيد توكن FCM المحفوظ إذا كان الجهاز قد سجّل نفسه سابقًا.
  /// Returns the stored FCM token when the device has already registered.
  String? getFcmToken() {
    return _prefs.getString(_fcmTokenKey);
  }

  /// يسجل وقت آخر مزامنة حتى يمكن تقييم حداثة البيانات لاحقًا.
  /// Persists the last sync time for later freshness checks.
  Future<bool> saveLastSyncTime(DateTime time) async {
    return await _prefs.setString(_lastSyncKey, time.toIso8601String());
  }

  /// يعيد وقت آخر مزامنة إن كان محفوظًا.
  /// Returns the saved sync timestamp when available.
  DateTime? getLastSyncTime() {
    final timeString = _prefs.getString(_lastSyncKey);
    if (timeString != null) {
      return DateTime.tryParse(timeString);
    }
    return null;
  }

  /// يحفظ سجل البحث ليظهر كاقتراحات لاحقة ويخفف إعادة الكتابة.
  /// Persists search history for suggestions and faster re-entry.
  Future<bool> saveSearchHistory(List<String> history) async {
    return await _prefs.setStringList(_searchHistoryKey, history);
  }

  /// يعيد سجل البحث بنفس ترتيب التخزين.
  /// Returns the saved search history in its stored order.
  List<String> getSearchHistory() {
    return _prefs.getStringList(_searchHistoryKey) ?? [];
  }

  /// يضيف آخر استعلام إلى المقدمة مع إزالة التكرار حتى يبقى السجل مختصرًا.
  /// Moves the newest query to the front and removes duplicates to keep history short.
  Future<bool> addToSearchHistory(String query) async {
    final history = getSearchHistory();
    history.remove(query); // Remove if exists
    history.insert(0, query); // Add to beginning
    if (history.length > 10) {
      history.removeLast(); // Keep only last 10
    }
    return await saveSearchHistory(history);
  }

  /// يمسح سجل البحث عندما يريد المستخدم بدء الاقتراحات من جديد.
  /// Clears the history when the user wants to restart suggestions from scratch.
  Future<bool> clearSearchHistory() async {
    return await _prefs.remove(_searchHistoryKey);
  }

  /// يحفظ الفلاتر بصيغة JSON حتى نستعيد نفس حالة البحث لاحقًا.
  /// Stores search filters as JSON so the same search state can be restored later.
  Future<bool> saveSearchFilters(Map<String, dynamic> filters) async {
    final jsonString = json.encode(filters);
    return await _prefs.setString(_filtersKey, jsonString);
  }

  /// يعيد الفلاتر المحفوظة بعد فك JSON إلى خريطة قابلة للاستخدام مباشرة.
  /// Returns the stored filters after JSON decoding into a usable map.
  Map<String, dynamic>? getSearchFilters() {
    final jsonString = _prefs.getString(_filtersKey);
    if (jsonString != null) {
      try {
        return json.decode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// يحفظ آخر العقارات التي شاهدها المستخدم حتى تعود في السجل السريع.
  /// Persists recently viewed properties so they remain available in quick access.
  Future<bool> saveRecentProperties(List<String> propertyIds) async {
    return await _prefs.setStringList(_recentPropertiesKey, propertyIds);
  }

  /// يعيد قائمة العقارات الأخيرة كما هي محفوظة.
  /// Returns the saved list of recently viewed properties.
  List<String> getRecentProperties() {
    return _prefs.getStringList(_recentPropertiesKey) ?? [];
  }

  /// يضع العقار الأحدث في المقدمة ويمنع تضخم السجل.
  /// Moves the newest property to the front and keeps the history bounded.
  Future<bool> addToRecentProperties(String propertyId) async {
    final properties = getRecentProperties();
    properties.remove(propertyId);
    properties.insert(0, propertyId);
    if (properties.length > 20) {
      properties.removeLast();
    }
    return await saveRecentProperties(properties);
  }

  /// يحفظ مسودة الحجز كي يعود المستخدم إليها بدل إعادة إدخال البيانات.
  /// Stores a booking draft so the user can resume instead of re-entering data.
  Future<bool> saveDraftBooking(Map<String, dynamic> bookingData) async {
    final jsonString = json.encode(bookingData);
    return await _prefs.setString(_draftBookingKey, jsonString);
  }

  /// يعيد مسودة الحجز إذا كانت موجودة وقابلة للفك.
  /// Returns the stored booking draft when present and readable.
  Map<String, dynamic>? getDraftBooking() {
    final jsonString = _prefs.getString(_draftBookingKey);
    if (jsonString != null) {
      try {
        return json.decode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// يحذف المسودة بعد الإرسال أو عند إلغاء الحجز.
  /// Removes the draft after submission or when the flow is canceled.
  Future<bool> clearDraftBooking() async {
    return await _prefs.remove(_draftBookingKey);
  }

  // Generic methods
  /// يحفظ أي قيمة مدعومة داخل التفضيلات ويحوّل المعقد منها إلى JSON.
  /// Stores supported values in preferences and JSON-encodes complex ones.
  Future<bool> saveData(String key, dynamic value) async {
    if (value is String) {
      return await _prefs.setString(key, value);
    } else if (value is int) {
      return await _prefs.setInt(key, value);
    } else if (value is double) {
      return await _prefs.setDouble(key, value);
    } else if (value is bool) {
      return await _prefs.setBool(key, value);
    } else if (value is List<String>) {
      return await _prefs.setStringList(key, value);
    } else {
      final jsonString = json.encode(value);
      return await _prefs.setString(key, jsonString);
    }
  }

  /// يعيد القيمة الخام المخزنة تحت المفتاح المطلوب دون تفسير إضافي.
  /// Exposes the raw value stored under the requested key so callers can read it without depending on implementation details.
  dynamic getData(String key) {
    return _prefs.get(key);
  }

  /// يحذف القيمة المرتبطة بالمفتاح من التخزين المحلي.
  /// Removes the value associated with the key from local storage.
  Future<bool> removeData(String key) async {
    return await _prefs.remove(key);
  }

  /// يمسح جميع القيم المخزنة عندما تحتاج الواجهة إلى إعادة ضبط
  /// التخزين المحلي بالكامل.
  /// Clears every stored value when the local cache needs a full reset.
  Future<bool> clearAll() async {
    return await _prefs.clear();
  }

  /// يتحقق من وجود مفتاح معين قبل محاولة قراءته أو تعديله.
  /// Checks whether a key exists before reading or updating it.
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  // Static convenience methods for compatibility
  /// بقايا توافق قديمة، ولا ينبغي استخدامها في المسارات الجديدة لأن
  /// الخدمة تعتمد على نسخة instance الحقيقية.
  /// Legacy compatibility shim; new code should use the instance API.
  static String? getString(String key) {
    // This is a placeholder - in reality you'd need a singleton instance
    throw UnimplementedError('Use instance methods instead');
  }

  /// بقايا توافق قديمة مماثلة، ويجب استبدالها بالاستدعاء عبر الكائن.
  /// Another legacy compatibility shim that should be replaced by the
  /// instance method call.
  static Future<bool> remove(String key) async {
    // This is a placeholder - in reality you'd need a singleton instance
    throw UnimplementedError('Use instance methods instead');
  }
}
