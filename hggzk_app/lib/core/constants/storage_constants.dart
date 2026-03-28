/// مفاتيح التخزين المحلي والمخزن الآمن التي تعتمد عليها الذاكرة الدائمة للتطبيق.
/// Keys used by secure storage, shared preferences, and local caches.
class StorageConstants {
  /// يمنع إنشاء مثيل لأن هذا الملف يجمع أسماء المفاتيح فقط.
  /// Prevents instantiation because this class only exposes key names.
  StorageConstants._();

  /// مفاتيح الجلسة الحساسة التي يجب حفظها في مخزن آمن.
  /// Sensitive session keys that belong in secure storage.
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';

  /// مفاتيح التفضيلات العامة التي يمكن قراءتها بسرعة من `SharedPreferences`.
  /// General preferences stored in shared preferences for quick access.
  static const String firstLaunch = 'first_launch';
  static const String language = 'language';
  static const String theme = 'theme';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String biometricEnabled = 'biometric_enabled';
  static const String rememberMe = 'remember_me';
  static const String searchHistory = 'search_history';
  static const String recentProperties = 'recent_properties';
  static const String accountRole = 'account_role';
  static const String propertyId = 'property_id';
  static const String propertyName = 'property_name';
  static const String propertyCurrency = 'property_currency';

  /// بادئات تستخدم لبناء مفاتيح الكاش بحسب النوع أو الجهة المالكة.
  /// Prefixes used to build cache keys by entity type.
  static const String propertyCachePrefix = 'property_';
  static const String userCachePrefix = 'user_';
  static const String bookingCachePrefix = 'booking_';
  static const String imageCachePrefix = 'image_';

  /// أسماء قواعد البيانات المحلية التي يستخدمها التطبيق عند التخزين الدائم.
  /// Local database file names used by the app.
  static const String mainDatabase = 'hggzk.db';
  static const String cacheDatabase = 'hggzk_cache.db';

  /// أسماء الجداول المحلية التي تعتمد عليها المزايا المخزنة مؤقتًا.
  /// Table names used by the local persistence layer.
  static const String favoritesTable = 'favorites';
  static const String messagesTable = 'messages';
  static const String notificationsTable = 'notifications';
  static const String userTimezone = 'user_timezone';
  static const String userTimezoneOffset = 'user_timezone_offset';
  static const String lastTimezoneCheck = 'last_timezone_check';
}
