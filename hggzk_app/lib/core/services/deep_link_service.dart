import 'dart:async';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// يجمع روابط Firebase والروابط الأصلية للنظام ويحوّلها إلى بيانات مسار واضحة.
/// Collects Firebase and native app links and converts them into typed routing data.
class DeepLinkService {
  /// موفر روابط Firebase عندما يأتي الرابط من قناة قصيرة أو مشتركة.
  /// Firebase link provider used for short or shared links.
  late FirebaseDynamicLinks _dynamicLinks;

  /// موفر الروابط الأصلية الذي يقرأ الـ schemes والروابط الشاملة.
  /// `app_links` instance used for custom schemes and universal links.
  late AppLinks _appLinks;

  /// الاشتراك الفعّال في تدفق الروابط أثناء تشغيل التطبيق.
  /// Active subscription to the app-link stream while the app is running.
  StreamSubscription? _linkSubscription;

  /// يبث الروابط بعد تحليلها إلى بنية داخلية موحدة.
  /// Broadcasts parsed links as a unified internal payload.
  final _deepLinkController = StreamController<DeepLinkData>.broadcast();

  /// يعيد تدفق الروابط الذي تستهلكه طبقات التوجيه الأعلى.
  /// Exposes the deep-link stream consumed by higher routing layers.
  Stream<DeepLinkData> get deepLinkStream => _deepLinkController.stream;

  /// يجهز مزودي الروابط فور إنشاء الخدمة.
  /// Initializes the link providers as soon as the service is created.
  DeepLinkService() {
    _dynamicLinks = FirebaseDynamicLinks.instance;
    _appLinks = AppLinks();
  }

  /// يفعّل المستمعين حتى لا تضيع أي روابط تصل عند الإقلاع أو في الخلفية.
  /// Wires listeners so links arriving at startup or in the background are not lost.
  Future<void> initialize() async {
    // Handle Firebase Dynamic Links
    await _initDynamicLinks();

    // Handle custom scheme links
    await _initAppLinks();
  }

  /// يقرأ رابط Firebase الأولي ثم يستمع لأي روابط لاحقة من نفس القناة.
  /// Reads the initial Firebase link and then listens for later arrivals.
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

  /// يلتقط الروابط المخصصة من النظام مثل schemes والروابط المباشرة.
  /// Hooks into the OS link stream for custom schemes and direct links.
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

  /// يحول رابط Firebase إلى بيانات داخلية قابلة للتوجيه.
  /// Converts a Firebase dynamic link into a typed internal payload.
  void _handleDynamicLink(PendingDynamicLinkData dynamicLink) {
    final Uri deepLink = dynamicLink.link;
    debugPrint('Received dynamic link: $deepLink');

    final data = _parseDeepLink(deepLink.toString());
    if (data != null) {
      _deepLinkController.add(data);
    }
  }

  /// يحلل الرابط القادم من scheme مخصص أو universal link ثم يمرره للتوجيه.
  /// Parses links from custom schemes or universal links and forwards them to routing.
  void _handleDeepLink(String link) {
    debugPrint('Received deep link: $link');

    final data = _parseDeepLink(link);
    if (data != null) {
      _deepLinkController.add(data);
    }
  }

  /// يفسر الرابط ويستخرج نوع الوجهة والمعرفات والمعاملات المرافقة.
  /// Parses the link and extracts the target type, identifiers, and query parameters.
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

  /// ينشئ رابط مشاركة قصيرًا مع بيانات وصفية تصلح للعرض الاجتماعي.
  /// Builds a short shareable dynamic link with social metadata.
  Future<Uri> createDynamicLink({
    required String path,
    Map<String, String>? queryParameters,
    String? title,
    String? description,
    String? imageUrl,
  }) async {
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse('https://hggzk.com$path').replace(
        queryParameters: queryParameters,
      ),
      uriPrefix: 'https://hggzk.page.link',
      androidParameters: const AndroidParameters(
        packageName: 'com.hggzk.app',
        minimumVersion: 1,
      ),
      iosParameters: const IOSParameters(
        bundleId: 'com.hggzk.app',
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

  /// يكوّن رابط مشاركة جاهزًا لصفحة العقار.
  /// Creates a share link that opens a property page.
  Future<Uri> createPropertyShareLink({
    required String propertyId,
    String? propertyName,
    String? propertyImage,
  }) async {
    return await createDynamicLink(
      path: '/property/$propertyId',
      title: propertyName ?? 'عقار مميز على hggzk',
      description: 'شاهد هذا العقار المميز على تطبيق hggzk',
      imageUrl: propertyImage,
    );
  }

  /// يكوّن رابط مشاركة مباشر لصفحة الحجز.
  /// Creates a share link that opens a booking page.
  Future<Uri> createBookingShareLink({
    required String bookingId,
  }) async {
    return await createDynamicLink(
      path: '/booking/$bookingId',
      title: 'حجزي على hggzk',
      description: 'تفاصيل الحجز على تطبيق hggzk',
    );
  }

  // Create search link
  /// ينشئ رابط بحث يفتح صفحة الاستكشاف مع المرشحات المرسلة معه.
  /// Creates a search link that opens discovery with the supplied filters.
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
      title: 'ابحث عن عقارات في hggzk',
      description: 'اكتشف أفضل العقارات والفنادق في اليمن',
    );
  }

  /// يوقف الاستماع للروابط ويغلق القناة الداخلية عند التخلص من الخدمة.
  /// Cancels link listening and closes the internal broadcast controller.
  void dispose() {
    _linkSubscription?.cancel();
    _deepLinkController.close();
  }
}

/// يمثل النتيجة المفسرة للرابط العميق بعد تحليل المسار والمعاملات.
/// Represents the parsed deep-link result after path and parameter analysis.
class DeepLinkData {
  /// نوع الوجهة التي يجب أن يذهب إليها التطبيق.
  /// Target destination type for the app.
  final DeepLinkType type;

  /// المعرف المرتبط بالوجهة عندما يكون الرابط موجهاً إلى عنصر محدد.
  /// Identifier for the target when the link points to a specific item.
  final String? id;

  /// المعاملات المرافقة التي قد يحتاجها المسار النهائي.
  /// Query parameters forwarded to the final route.
  final Map<String, String>? parameters;

  /// ينشئ بنية البيانات المفسرة للروابط العميقة.
  /// Creates the parsed deep-link data structure.
  DeepLinkData({
    required this.type,
    this.id,
    this.parameters,
  });
}

/// يحدد أنواع الوجهات التي يمكن للروابط العميقة الوصول إليها.
/// Enumerates the destination types supported by deep links.
enum DeepLinkType {
  property,
  booking,
  search,
  profile,
  promotion,
  resetPassword,
  verifyEmail,
}
