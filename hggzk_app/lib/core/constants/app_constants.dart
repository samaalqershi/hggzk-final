/// القيم الثابتة التي تضبط سلوك الواجهة والتنسيق والحدود التشغيلية للتطبيق.
/// Shared constants that control UI behavior, formatting, and runtime limits.
class AppConstants {
  /// يمنع إنشاء مثيل لأن القيم هنا ثابتة على مستوى المشروع.
  /// Prevents instantiation because all values are project-wide constants.
  AppConstants._();

  /// معلومات التعريف الأساسية للتطبيق.
  /// Basic app identity values.
  static const String appName = 'hggzk';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  /// مدد تشغيلية موحدة حتى تتطابق تجربة الاستخدام بين الشاشات.
  /// Standard durations used to keep interactions consistent across screens.
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration debounceTime = Duration(milliseconds: 500);
  static const Duration snackBarDuration = Duration(seconds: 3);

  /// حدود تمنع تجاوز الحجم أو العدد المسموح به داخل التدفقات الأساسية.
  /// Limits that cap upload sizes and validation thresholds.
  static const int maxImageUploadSize = 10 * 1024 * 1024; // 10MB
  static const int maxImagesPerProperty = 20;
  static const int maxReviewImages = 5;
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int otpLength = 6;

  /// صيغ العرض القياسية للتواريخ والأرقام داخل الواجهة.
  /// Shared display formats for dates, times, and currencies.
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String currencyCode = 'YER';
  static const String currencySymbol = '﷼';

  /// نقطة البداية الافتراضية للخريطة عندما لا يملك العقار إحداثياته.
  /// Default map coordinates used when a property lacks its own location.
  static const double defaultLatitude = 15.3694;
  static const double defaultLongitude = 44.1910;
  static const double defaultZoom = 12.0;

  /// أزمنة وقيود الكاش التي تمنع بقاء البيانات قديمة أكثر من اللازم.
  /// Cache freshness and size limits.
  static const Duration cacheValidDuration = Duration(hours: 24);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB

  /// أنماط التحقق المستخدمة في النماذج وواجهات الإدخال.
  /// Validation patterns reused across forms.
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phonePattern = r'^7[0-9]{8}$';
  static const String namePattern = r'^[a-zA-Z\u0600-\u06FF\s]+$';

  // ═══════════════════════════════════════════════════════════════════
  // Google OAuth Client IDs
  // يجب أن تتطابق مع GoogleClientIds في Backend
  // ═══════════════════════════════════════════════════════════════════
  static const String googleWebClientId =
      '333370677136-el3bpb5fn4tt8qrcr52v8r59h4fko283.apps.googleusercontent.com';
  // static const String googleAndroidClientId =
  //     '90807496145-is1cdvm5lmm2cpcd346ivh22rcf43orr.apps.googleusercontent.com';
  static const String googleAndroidClientId =
      '333370677136-834ocmm2shmri6v2b7cjpph58nttt9k4.apps.googleusercontent.com';
  static const String googleIosClientId =
      '333370677136-63cqitbsjos82f52h772s15pcdjdoci3.apps.googleusercontent.com';

  // ═══════════════════════════════════════════════════════════════════
  // Facebook OAuth
  // ═══════════════════════════════════════════════════════════════════
  static const String facebookAppId =
      '813515171745768'; // TODO: استبدل بـ App ID الحقيقي

  /// معرف خدمة Apple Sign-In الذي يطابق إعدادات الخادم.
  /// Apple Sign-In service identifier that matches the backend setup.
  static const String appleServiceId = 'com.hggzk.app.signin';
  static const String appleRedirectUri =
      'https://api.hggzk.com/callbacks/sign_in_with_apple/hggzk';
}
