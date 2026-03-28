/// مفاتيح التخزين المحلية والمشفرة المستخدمة عبر المصادقة والتفضيلات والكاش.
/// Local storage keys and prefixes shared by auth, preferences, and caching layers.
class StorageConstants {
  StorageConstants._();

  /// مفتاح رمز الوصول المستخدم في جلسة المستخدم الحالية.
  /// Access token key used for the current user session.
  static const String accessToken = 'access_token';

  /// مفتاح رمز التحديث الذي يطيل عمر الجلسة.
  /// Refresh token key used to extend the session.
  static const String refreshToken = 'refresh_token';

  /// مفتاح معرف المستخدم الحالي.
  /// Current user id key.
  static const String userId = 'user_id';

  /// مفتاح البريد الإلكتروني المرتبط بالمستخدم.
  /// User email key.
  static const String userEmail = 'user_email';

  /// مفتاح دور الحساب المعتمد في الهيدر أو المنطق المحلي.
  /// Account role key used by headers and local logic.
  static const String accountRole = 'account_role';

  /// مفتاح معرف العقار الحالي في سياق المالك أو الإدارة.
  /// Current property id key used in owner/admin flows.
  static const String propertyId = 'property_id';

  /// مفتاح اسم العقار المعروض في الواجهة أو السجلات.
  /// Property name key shown in UI or logs.
  static const String propertyName = 'property_name';

  /// مفتاح عملة العقار أو المساحة المالية المرتبطة به.
  /// Property currency key used for monetary context.
  static const String propertyCurrency = 'property_currency';

  /// مفتاح أول تشغيل للتطبيق.
  /// First-launch flag key.
  static const String firstLaunch = 'first_launch';

  /// مفتاح اللغة المختارة من المستخدم.
  /// Selected language key.
  static const String language = 'language';

  /// مفتاح الثيم المختار.
  /// Selected theme key.
  static const String theme = 'theme';

  /// مفتاح تفعيل الإشعارات.
  /// Notification enabled flag key.
  static const String notificationsEnabled = 'notifications_enabled';

  /// مفتاح تفعيل المصادقة الحيوية.
  /// Biometric authentication flag key.
  static const String biometricEnabled = 'biometric_enabled';

  /// مفتاح تفعيل تذكر بيانات الدخول.
  /// Remember-me flag key.
  static const String rememberMe = 'remember_me';

  /// مفتاح سجل البحث المحفوظ محليًا.
  /// Saved search history key.
  static const String searchHistory = 'search_history';

  /// مفتاح العقارات الأخيرة التي تمت مشاهدتها.
  /// Recently viewed properties key.
  static const String recentProperties = 'recent_properties';

  /// بادئة مفاتيح كاش العقارات.
  /// Cache key prefix for properties.
  static const String propertyCachePrefix = 'property_';

  /// بادئة مفاتيح كاش المستخدمين.
  /// Cache key prefix for users.
  static const String userCachePrefix = 'user_';

  /// بادئة مفاتيح كاش الحجوزات.
  /// Cache key prefix for bookings.
  static const String bookingCachePrefix = 'booking_';

  /// بادئة مفاتيح كاش الصور.
  /// Cache key prefix for images.
  static const String imageCachePrefix = 'image_';

  /// بادئة مفاتيح الكاش الخاصة بحالة الإتاحة.
  /// Cache key prefix for availability data.
  static const String availabilityCachePrefix = 'availability_';

  /// اسم قاعدة البيانات الرئيسية.
  /// Main database name.
  static const String mainDatabase = 'yemen_booking.db';

  /// اسم قاعدة بيانات الكاش.
  /// Cache database name.
  static const String cacheDatabase = 'yemen_booking_cache.db';

  /// اسم جدول المفضلة.
  /// Favorites table name.
  static const String favoritesTable = 'favorites';

  /// اسم جدول الرسائل.
  /// Messages table name.
  static const String messagesTable = 'messages';

  /// اسم جدول الإشعارات.
  /// Notifications table name.
  static const String notificationsTable = 'notifications';

  /// مفتاح المنطقة الزمنية المحفوظة للمستخدم.
  /// Stored user timezone key.
  static const String userTimezone = 'user_timezone';

  /// مفتاح فرق المنطقة الزمنية المحفوظ.
  /// Stored user timezone offset key.
  static const String userTimezoneOffset = 'user_timezone_offset';

  /// مفتاح آخر وقت تمت فيه مراجعة المنطقة الزمنية.
  /// Timestamp for the last timezone check.
  static const String lastTimezoneCheck = 'last_timezone_check';
}
