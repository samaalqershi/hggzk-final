import 'dart:async';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Listens for incoming deep links from Firebase Dynamic Links and custom URL
/// schemes, then normalizes them into a single stream the app can consume.
/// يستمع للروابط العميقة من Firebase Dynamic Links ومن المسارات المخصصة ثم
/// يحولها إلى stream موحد يمكن للتطبيق استهلاكه.
class DeepLinkService {
  /// Firebase Dynamic Links client used for universal-link style entry points.
  /// عميل Firebase Dynamic Links المستخدم لروابط الدخول العامة.
  late FirebaseDynamicLinks _dynamicLinks;

  /// App Links client used for custom scheme and platform-level link events.
  /// عميل App Links المستخدم للمسارات المخصصة وأحداث الروابط على المنصة.
  late AppLinks _appLinks;

  /// Subscription to the custom-scheme link stream.
  /// اشتراك في stream الروابط المخصصة.
  StreamSubscription? _linkSubscription;

  /// Broadcast stream carrying normalized deep-link payloads.
  final _deepLinkController = StreamController<DeepLinkData>.broadcast();

  /// Stream consumed by navigation and routing features.
  /// الـ stream الذي تستهلكه طبقات التنقل والتوجيه.
  Stream<DeepLinkData> get deepLinkStream => _deepLinkController.stream;

  /// Wires up the link providers that can deliver deep-link events to the app.
  /// يربط مزودي الروابط الذين يمكنهم تسليم أحداث deep link للتطبيق.
  DeepLinkService() {
    _dynamicLinks = FirebaseDynamicLinks.instance;
    _appLinks = AppLinks();
  }

  /// Subscribes to both Firebase Dynamic Links and custom app links.
  /// يشترك في Firebase Dynamic Links وروابط التطبيق المخصصة معًا.
  Future<void> initialize() async {
    // Handle Firebase Dynamic Links
    await _initDynamicLinks();

    // Handle custom scheme links
    await _initAppLinks();
  }

  /// Starts the Firebase Dynamic Links listeners and processes any launch-time
  /// link that opened the app cold.
  /// يبدأ مستمعي Firebase Dynamic Links ويعالج رابط الإقلاع الأول إذا كان هو
  /// سبب فتح التطبيق.
  Future<void> _initDynamicLinks() async {
    // Handle initial dynamic link if app was closed
    final initialLink = await _dynamicLinks.getInitialLink();
    if (initialLink != null) {
      _handleDynamicLink(initialLink);
    }

    // Listen for dynamic links when app is in foreground/background
    _dynamicLinks.onLink.listen(
      _handleDynamicLink,
      onError: (error) {
        debugPrint('Dynamic Link Error: $error');
      },
    );
  }

  /// Starts the app-links listener used for custom URL schemes.
  /// يبدأ مستمع App Links المستخدم للمخططات المخصصة.
  Future<void> _initAppLinks() async {
    // Handle initial link if app was closed
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink.toString());
      }
    } on PlatformException {
      debugPrint('Failed to get initial link');
    }

    // Listen for links when app is in foreground/background
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri.toString());
      },
      onError: (error) {
        debugPrint('Link Stream Error: $error');
      },
    );
  }

  /// Converts a Firebase dynamic link into normalized deep-link data.
  /// يحول dynamic link من Firebase إلى بيانات deep link موحدة.
  void _handleDynamicLink(PendingDynamicLinkData dynamicLink) {
    final Uri deepLink = dynamicLink.link;
    debugPrint('Received dynamic link: $deepLink');

    final data = _parseDeepLink(deepLink.toString());
    if (data != null) {
      _deepLinkController.add(data);
    }
  }

  /// Converts a custom-scheme link into normalized deep-link data.
  /// يحول رابطًا مخصص المخطط إلى بيانات deep link موحدة.
  void _handleDeepLink(String link) {
    debugPrint('Received deep link: $link');

    final data = _parseDeepLink(link);
    if (data != null) {
      _deepLinkController.add(data);
    }
  }

  /// Interprets a URL and maps it to one of the portal's supported destinations.
  /// يفسر الرابط ويحوّله إلى إحدى الوجهات المدعومة في البوابة.
  DeepLinkData? _parseDeepLink(String link) {
    try {
      final uri = Uri.parse(link);
      final path = uri.path;
      final queryParams = uri.queryParameters;

      // Parse different link types
      if (path.contains('/property/')) {
        final propertyId = path.split('/property/').last;
        return DeepLinkData(
          type: DeepLinkType.property,
          id: propertyId,
          parameters: queryParams,
        );
      } else if (path.contains('/booking/')) {
        final bookingId = path.split('/booking/').last;
        return DeepLinkData(
          type: DeepLinkType.booking,
          id: bookingId,
          parameters: queryParams,
        );
      } else if (path.contains('/search')) {
        return DeepLinkData(
          type: DeepLinkType.search,
          parameters: queryParams,
        );
      } else if (path.contains('/profile/')) {
        final userId = path.split('/profile/').last;
        return DeepLinkData(
          type: DeepLinkType.profile,
          id: userId,
          parameters: queryParams,
        );
      } else if (path.contains('/promotion/')) {
        final promotionId = path.split('/promotion/').last;
        return DeepLinkData(
          type: DeepLinkType.promotion,
          id: promotionId,
          parameters: queryParams,
        );
      } else if (path.contains('/reset-password')) {
        return DeepLinkData(
          type: DeepLinkType.resetPassword,
          parameters: queryParams,
        );
      } else if (path.contains('/verify-email')) {
        return DeepLinkData(
          type: DeepLinkType.verifyEmail,
          parameters: queryParams,
        );
      }

      return null;
    } catch (e) {
      debugPrint('Error parsing deep link: $e');
      return null;
    }
  }

  /// Builds a shareable Firebase short link that points to a portal route.
  /// ينشئ رابط Firebase قصيرًا قابلًا للمشاركة ويشير إلى مسار داخل البوابة.
  Future<Uri> createDynamicLink({
    required String path,
    Map<String, String>? queryParameters,
    String? title,
    String? description,
    String? imageUrl,
  }) async {
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse('https://yemenbooking.com$path').replace(
        queryParameters: queryParameters,
      ),
      uriPrefix: 'https://yemenbooking.page.link',
      androidParameters: const AndroidParameters(
        packageName: 'com.bookncp.app',
        minimumVersion: 1,
      ),
      iosParameters: const IOSParameters(
        bundleId: 'com.bookncp.app',
        minimumVersion: '1.0.0',
        appStoreId: '123456789',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: title,
        description: description,
        imageUrl: imageUrl != null ? Uri.parse(imageUrl) : null,
      ),
    );

    final shortLink = await _dynamicLinks.buildShortLink(dynamicLinkParams);
    return shortLink.shortUrl;
  }

  /// Creates a shareable link that opens a property details route.
  /// ينشئ رابطًا قابلًا للمشاركة يفتح مسار تفاصيل العقار.
  Future<Uri> createPropertyShareLink({
    required String propertyId,
    String? propertyName,
    String? propertyImage,
  }) async {
    return await createDynamicLink(
      path: '/property/$propertyId',
      title: propertyName ?? 'عقار مميز على Yemen Booking',
      description: 'شاهد هذا العقار المميز على تطبيق Yemen Booking',
      imageUrl: propertyImage,
    );
  }

  /// Creates a shareable link that opens a booking reference route.
  /// ينشئ رابطًا قابلًا للمشاركة يفتح مسار الحجز.
  Future<Uri> createBookingShareLink({
    required String bookingId,
  }) async {
    return await createDynamicLink(
      path: '/booking/$bookingId',
      title: 'حجزي على Yemen Booking',
      description: 'تفاصيل الحجز على تطبيق Yemen Booking',
    );
  }

  /// Creates a link that rehydrates search filters from the shared URL.
  /// ينشئ رابطًا يعيد تحميل فلاتر البحث من الرابط المشترك.
  Future<Uri> createSearchLink({
    String? location,
    String? propertyType,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
  }) async {
    final queryParams = <String, String>{};

    if (location != null) queryParams['location'] = location;
    if (propertyType != null) queryParams['type'] = propertyType;
    if (checkIn != null) queryParams['checkin'] = checkIn.toIso8601String();
    if (checkOut != null) queryParams['checkout'] = checkOut.toIso8601String();
    if (guests != null) queryParams['guests'] = guests.toString();

    return await createDynamicLink(
      path: '/search',
      queryParameters: queryParams,
      title: 'ابحث عن عقارات في Yemen Booking',
      description: 'اكتشف أفضل العقارات والفنادق في اليمن',
    );
  }

  /// Cancels link subscriptions and closes the stream controller.
  /// يوقف اشتراكات الروابط ويغلق متحكم الـ stream.
  void dispose() {
    _linkSubscription?.cancel();
    _deepLinkController.close();
  }
}

/// Normalized data extracted from a deep link before routing decides what to
/// do with it.
/// بيانات موحدة تُستخرج من الرابط العميق قبل أن يقرر الراوتر ما الذي يجب فعله.
class DeepLinkData {
  /// The destination category identified from the URL.
  /// فئة الوجهة التي استُخرجت من الرابط.
  final DeepLinkType type;

  /// Optional entity id attached to the deep link.
  /// معرف اختياري للعنصر المرتبط بالرابط.
  final String? id;

  /// Raw query parameters preserved for navigation or screen prefill.
  /// معاملات الاستعلام الأصلية محفوظة للتنقل أو لملء الشاشة مسبقًا.
  final Map<String, String>? parameters;

  /// Creates a normalized deep-link payload.
  /// ينشئ حمولة deep link موحدة.
  DeepLinkData({
    required this.type,
    this.id,
    this.parameters,
  });
}

// Deep link types
/// Supported destinations that can be decoded from portal links.
/// الوجهات المدعومة التي يمكن استخراجها من روابط البوابة.
enum DeepLinkType {
  property,
  booking,
  search,
  profile,
  promotion,
  resetPassword,
  verifyEmail,
}
