/// Arabic: يجمع الثوابت العامة التي تعتمدها الواجهة والخدمات في حدود الرفع والصيغ والتحقق.
/// English: Groups the shared constants used by UI and services for upload limits, formatting, and validation.
class AppConstants {
  /// Arabic: يمنع إنشاء مثيل من هذا الصف لأنه حاوية ثوابت تطبيقية فقط.
  /// English: Prevents instantiation because this class is a pure application-constants container.
  AppConstants._();

  /// Arabic: الاسم التجاري الظاهر في الواجهات، والرؤوس، وسجلات التشخيص.
  /// English: Branding name shown in the UI, headers, and diagnostic logs.
  static const String appName = 'hggzk portal';

  /// Arabic: نسخة التطبيق المعتمدة في واجهات العرض أو تقارير الدعم.
  /// English: Application version surfaced in UI and support diagnostics.
  static const String appVersion = '1.0.0';

  /// Arabic: رقم البناء المستخدم لتعقب النسخ المنشورة.
  /// English: Build number used to track deployed releases.
  static const String appBuildNumber = '1';

  /// Arabic: مدة عرض شاشة البداية قبل الانتقال للواجهة التالية.
  /// English: Duration the splash screen remains visible before navigation continues.
  static const Duration splashDuration = Duration(seconds: 2);

  /// Arabic: مدة افتراضية للحركات العامة داخل التطبيق.
  /// English: Default duration for common in-app animations.
  static const Duration animationDuration = Duration(milliseconds: 300);

  /// Arabic: فترة التجميع المستخدمة لتقليل تكرار الاستدعاءات المتتالية.
  /// English: Debounce window used to reduce repeated back-to-back calls.
  static const Duration debounceTime = Duration(milliseconds: 500);

  /// Arabic: مدة ظهور رسائل الإشعار السريع قبل اختفائها تلقائيًا.
  /// English: Auto-dismiss duration for snackbar messages.
  static const Duration snackBarDuration = Duration(seconds: 3);

  /// Arabic: الحد الأقصى لحجم صورة واحدة قبل الرفع إلى الخادم.
  /// English: Maximum size allowed for a single uploaded image.
  static const int maxImageUploadSize = 10 * 1024 * 1024;

  /// Arabic: أقصى عدد من الصور المسموح ربطها بعقار واحد.
  /// English: Maximum number of images that can be linked to one property.
  static const int maxImagesPerProperty = 20;

  /// Arabic: الحد الأقصى لعدد صور المراجعة حتى تبقى المرفقات خفيفة.
  /// English: Maximum number of images allowed per review attachment.
  static const int maxReviewImages = 5;

  /// Arabic: الحد الأقصى لحجم ملف الفيديو المرفوع.
  /// English: Maximum size allowed for a single uploaded video.
  static const int maxVideoUploadSize = 100 * 1024 * 1024;

  /// Arabic: أقصى عدد من الفيديوهات المسموح بها لكل عقار.
  /// English: Maximum number of videos allowed for one property.
  static const int maxVideosPerProperty = 5;

  /// Arabic: أطول مدة فيديو يقبلها النظام في الرفع والمعالجة.
  /// English: Longest video duration accepted by upload and processing flows.
  static const Duration maxVideoDuration = Duration(minutes: 5);

  /// Arabic: أقل مدة فيديو منطقية نحتفظ بها كتحقق مبدئي.
  /// English: Minimum video duration kept as a basic validation guard.
  static const int minVideoDuration = 1; // seconds

  /// Arabic: الامتدادات المدعومة للصور في أدوات الاختيار والتحقق.
  /// English: Supported image extensions used by file pickers and validation.
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp'
  ];

  /// Arabic: الامتدادات المدعومة للفيديو في أدوات الاختيار والتحقق.
  /// English: Supported video extensions used by file pickers and validation.
  static const List<String> supportedVideoFormats = [
    'mp4',
    'mov',
    'avi',
    'mkv',
    'webm'
  ];

  /// Arabic: الاسم القياسي الذي يستخدمه النظام عندما تكون الوسائط صورة.
  /// English: Canonical label returned when the media item is an image.
  static const String imageMediaType = 'image';

  /// Arabic: الاسم القياسي الذي يستخدمه النظام عندما تكون الوسائط فيديو.
  /// English: Canonical label returned when the media item is a video.
  static const String videoMediaType = 'video';

  /// Arabic: أقل طول مسموح لكلمة المرور عبر نماذج المصادقة.
  /// English: Minimum password length enforced across authentication forms.
  static const int minPasswordLength = 8;

  /// Arabic: أكبر طول مسموح لكلمة المرور قبل رفضها.
  /// English: Maximum password length accepted by validation.
  static const int maxPasswordLength = 50;

  /// Arabic: عدد خانات رمز التحقق لمرة واحدة.
  /// English: Number of digits expected for the one-time password.
  static const int otpLength = 6;

  /// Arabic: الصيغة المعتمدة لعرض التاريخ في الواجهات والتقارير.
  /// English: Date format used in UI and reports.
  static const String dateFormat = 'dd/MM/yyyy';

  /// Arabic: الصيغة المعتمدة لعرض الوقت بصيغة 24 ساعة.
  /// English: Time format used for 24-hour display.
  static const String timeFormat = 'HH:mm';

  /// Arabic: الصيغة التي تجمع التاريخ والوقت في قيمة واحدة.
  /// English: Combined date and time format used in summaries and logs.
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  /// Arabic: رمز العملة الافتراضي المستخدم في القيم المالية.
  /// English: Default currency code used for monetary values.
  static const String currencyCode = 'YER';

  /// Arabic: الرمز النصي الظاهر قبل القيم المالية.
  /// English: Currency symbol shown alongside formatted amounts.
  static const String currencySymbol = '﷼';

  /// Arabic: خط العرض الافتراضي عندما لا تتوفر إحداثيات حقيقية.
  /// English: Default latitude used when a record does not provide coordinates.
  static const double defaultLatitude = 15.3694;

  /// Arabic: خط الطول الافتراضي عندما لا تتوفر إحداثيات حقيقية.
  /// English: Default longitude used when a record does not provide coordinates.
  static const double defaultLongitude = 44.1910;

  /// Arabic: مستوى التكبير الافتراضي للخرائط عند استخدام الموقع الاحتياطي.
  /// English: Default zoom level used for fallback map locations.
  static const double defaultZoom = 12.0;

  /// Arabic: مدة صلاحية البيانات المؤقتة قبل اعتبارها قديمة.
  /// English: Cache lifetime before stored data is considered stale.
  static const Duration cacheValidDuration = Duration(hours: 24);

  /// Arabic: الحد الأقصى لحجم التخزين المؤقت المحلي.
  /// English: Maximum size allowed for local cache storage.
  static const int maxCacheSize = 100 * 1024 * 1024;

  /// Arabic: النمط المستخدم للتحقق من صحة البريد الإلكتروني.
  /// English: Pattern used to validate email addresses.
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';

  /// Arabic: النمط المستخدم لرقم الهاتف المحلي.
  /// English: Pattern used for the local phone number format.
  static const String phonePattern = r'^7[0-9]{8}$';

  /// Arabic: النمط الذي يسمح بالحروف اللاتينية والعربية والمسافات في الأسماء.
  /// English: Pattern that allows Latin, Arabic, and whitespace characters in names.
  static const String namePattern = r'^[a-zA-Z\u0600-\u06FF\s]+$';

  /// Arabic: معرّف عميل Google Web المستخدم في تسجيل الدخول عبر الويب.
  /// English: Google Web client ID used for web sign-in.
  static const String googleWebClientId =
      '333370677136-el3bpb5fn4tt8qrcr52v8r59h4fko283.apps.googleusercontent.com';

  /// Arabic: معرّف عميل Google Android المستخدم في تسجيل الدخول من أجهزة أندرويد.
  /// English: Google Android client ID used for Android sign-in.
  static const String googleAndroidClientId =
      '333370677136-b608ri9a47bd5gvgfvi32je5r7708pei.apps.googleusercontent.com';

  /// Arabic: معرّف عميل Google iOS المستخدم في تسجيل الدخول من أجهزة آبل.
  /// English: Google iOS client ID used for iOS sign-in.
  static const String googleIosClientId =
      '333370677136-l7um2umk1iveeada4ur8ahac1kbu0dfj.apps.googleusercontent.com';

  /// Arabic: معرّف تطبيق فيسبوك المستخدم في تدفق تسجيل الدخول الخارجي.
  /// English: Facebook application ID used by the external sign-in flow.
  static const String facebookAppId = '813515171745768';

  /// Arabic: معرّف خدمة Apple Sign-In المرتبط بهذا التطبيق.
  /// English: Apple Sign-In service identifier associated with this app.
  static const String appleServiceId = 'com.hggzkportal.app.signin';

  /// Arabic: عنوان إعادة التوجيه بعد إتمام تسجيل الدخول عبر Apple.
  /// English: Redirect URI used after completing Apple Sign-In.
  static const String appleRedirectUri =
      'https://api.hggzk.com/callbacks/sign_in_with_apple/hggzkportal';

  /// Arabic: يحدد ما إذا كان امتداد الملف ينتمي إلى صيغ الفيديو المدعومة.
  /// English: Checks whether the file extension belongs to the supported video formats.
  static bool isVideoFile(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return supportedVideoFormats.contains(extension);
  }

  /// Arabic: يحدد ما إذا كان امتداد الملف ينتمي إلى صيغ الصور المدعومة.
  /// English: Checks whether the file extension belongs to the supported image formats.
  static bool isImageFile(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return supportedImageFormats.contains(extension);
  }

  /// Arabic: يحول مسار الملف إلى نوع الوسائط القياسي الذي تتوقعه مسارات الرفع والمعالجة.
  /// English: Normalizes a file path into the canonical media label expected by upload and processing flows.
  static String getMediaType(String filePath) {
    if (isVideoFile(filePath)) return videoMediaType;
    if (isImageFile(filePath)) return imageMediaType;
    return imageMediaType; // default
  }
}
