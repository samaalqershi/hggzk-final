import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Arabic: يجمع كل القيم المرتبطة بالاتصال بالخادم، والمفاتيح، والمهلات، ومسارات الـ API.
/// English: Collects all backend connection values, keys, timeouts, and API path helpers.
class ApiConstants {
  /// Arabic: يمنع إنشاء مثيل لأن هذا الصف مجرد حاوية ثوابت ومساعدات.
  /// English: Prevents instantiation because this class only exposes constants and helpers.
  ApiConstants._();

  /// Arabic: عنوان الخادم الجذري الذي تُبنى منه جميع المسارات الشبكية.
  /// English: Root backend URL used to build every network endpoint.
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    // defaultValue: 'https://api.hggzk.com/',
    defaultValue: 'http://192.168.0.101:5000/',
  );

  /// Arabic: المسار الموحد لخدمات الواجهة العامة فوق عنوان الخادم الجذري.
  /// English: Shared path for public/common API endpoints on top of the base URL.
  static String get commonBaseUrl =>
      baseUrl.endsWith('/') ? '${baseUrl}api/common' : '$baseUrl/api/common';

  /// Arabic: المسار الموحد لخدمات الإدارة فوق عنوان الخادم الجذري.
  /// English: Shared path for admin API endpoints on top of the base URL.
  static String get adminBaseUrl =>
      baseUrl.endsWith('/') ? '${baseUrl}api/admin' : '$baseUrl/api/admin';

  /// Arabic: عنوان الصور البديل القادم من متغيرات البيئة عندما يكون مضبوطًا.
  /// English: Optional image base URL provided through environment variables.
  static const String _imageBaseUrlFromEnv = String.fromEnvironment(
    'IMAGE_BASE_URL',
    defaultValue: '',
  );

  /// Arabic: عنوان الصور الفعلي بعد تنظيفه واختيار القيمة البيئية أو عنوان الخادم الجذري.
  /// English: Resolved image base URL after normalizing the environment override or falling back to the base URL.
  static final String imageBaseUrl = _imageBaseUrlFromEnv.trim().isNotEmpty
      ? _stripTrailingSlash(_imageBaseUrlFromEnv)
      : _stripTrailingSlash(baseUrl);

  /// Arabic: عنوان الاتصال اللحظي المستخدم مع طبقة الـ WebSocket.
  /// English: WebSocket endpoint used by the real-time communication layer.
  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: '',
  );

  /// Arabic: عنوان WebSocket النهائي بعد استخدام المتغير البيئي أو اشتقاقه من عنوان الخادم الأساسي.
  /// English: Final WebSocket URL after using the environment override or deriving it from the base URL.
  static String get resolvedSocketUrl {
    final configured = socketUrl.trim();
    if (configured.isNotEmpty) {
      return _stripTrailingSlash(configured);
    }

    final base = _stripTrailingSlash(baseUrl);
    if (base.startsWith('https://')) {
      return 'wss://${base.substring('https://'.length)}';
    }
    if (base.startsWith('http://')) {
      return 'ws://${base.substring('http://'.length)}';
    }
    return base;
  }

  /// Arabic: مفتاح Google Places الذي يُستخرج أولًا من البيئة ثم من القيم الاحتياطية الخاصة بالمنصة.
  /// English: Google Places key resolved from the environment first, then from platform-specific fallbacks.
  static String get googlePlacesApiKey {
    const String fromEnv = String.fromEnvironment(
      'GOOGLE_PLACES_API_KEY',
      defaultValue: '',
    );
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) return 'AIzaSyBUpSeBzpMhnKCDSJYmbrNwgsSY7PDlm-M';
    return defaultTargetPlatform == TargetPlatform.iOS
        ? 'AIzaSyD9O2NbSnvuV3L8Fknz1SqQehBxWLKkZKE'
        : 'AIzaSyBUpSeBzpMhnKCDSJYmbrNwgsSY7PDlm-M';
  }

  /// Arabic: الجذر الثابت لمسارات Google Places المستخدَمة في البحث والاقتراحات.
  /// English: Fixed base path for Google Places requests used by search and suggestions.
  static const String googlePlacesBaseUrl =
      'https://maps.googleapis.com/maps/api/place';

  /// Arabic: الحد الأقصى للوقت المسموح به لإنشاء الاتصال بالخادم.
  /// English: Maximum time allowed to establish a connection to the server.
  static const Duration connectTimeout = Duration(seconds: 60);

  /// Arabic: الحد الأقصى لانتظار الرد من الخادم قبل اعتبار الطلب متأخرًا.
  /// English: Maximum time to wait for a response before the request is considered stalled.
  static const Duration receiveTimeout = Duration(seconds: 1800);

  /// Arabic: الحد الأقصى لوقت إرسال البيانات، ويغطي الرفع والطلبات الطويلة.
  /// English: Maximum time allowed to send payloads, including uploads and long-running requests.
  static const Duration sendTimeout = Duration(seconds: 1800);

  /// Arabic: اسم ترويسة نوع المحتوى في طلبات HTTP.
  /// English: HTTP header name used for the request content type.
  static const String contentType = 'Content-Type';

  /// Arabic: القيمة القياسية لنوع المحتوى JSON.
  /// English: Standard JSON content type value.
  static const String applicationJson = 'application/json';

  /// Arabic: اسم ترويسة التفويض في الطلبات المحمية.
  /// English: Authorization header name used for protected requests.
  static const String authorization = 'Authorization';

  /// Arabic: بادئة التوكن المستخدمة مع ترويسة التفويض.
  /// English: Token prefix used with the Authorization header.
  static const String bearer = 'Bearer';

  /// Arabic: ترويسة لغة العرض التي يرسلها العميل للخادم.
  /// English: Accept-Language header used to send the preferred locale to the backend.
  static const String acceptLanguage = 'Accept-Language';

  /// Arabic: ترويسة تحدد دور الحساب عند الحاجة إلى تخصيص الاستجابة.
  /// English: Header that identifies the account role when the response depends on permissions.
  static const String xAccountRole = 'X-Account-Role';

  /// Arabic: ترويسة تشير إلى العقار المرتبط بالطلب الحالي.
  /// English: Header that identifies the property associated with the current request.
  static const String xPropertyId = 'X-Property-Id';

  /// Arabic: ترويسة تحمل عملة العقار لاستخدامها في الحسابات والتنسيق.
  /// English: Header that carries the property currency for calculations and formatting.
  static const String xPropertyCurrency = 'X-Property-Currency';

  /// Arabic: إصدار الـ API المستخدم في المسارات المهيكلة.
  /// English: API version segment used in versioned routes.
  static const String apiVersion = 'v1';

  /// Arabic: حجم الصفحة الافتراضي عندما لا يحدد العميل عدد العناصر.
  /// English: Default page size used when the caller does not provide a value.
  static const int defaultPageSize = 20;

  /// Arabic: الحد الأقصى لحجم الصفحة لحماية الخادم والواجهة من الأحجام الكبيرة.
  /// English: Upper bound for page size to protect both backend and UI from oversized requests.
  static const int maxPageSize = 100;

  /// Arabic: مسار إدارة الوحدات المستخدم في عمليات القائمة، الإضافة، والتحديث.
  /// English: Admin units endpoint used by list, create, and update flows.
  static String get units => baseUrl.endsWith('/')
      ? '${baseUrl}api/admin/Units'
      : '$baseUrl/api/admin/Units';

  /// Arabic: يزيل الشرطة المائلة الأخيرة حتى تبقى عمليات دمج المسارات مستقرة.
  /// English: Removes a trailing slash so URL concatenation remains stable and predictable.
  static String _stripTrailingSlash(String value) {
    final trimmed = value.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
