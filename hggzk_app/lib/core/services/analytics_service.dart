import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hggzk/app/dependency_injection/injection_container.dart';
import 'package:hggzk/core/services/reference_service.dart';

/// يربط أحداث المنتج مع Firebase Analytics ويمنع تشتت منطق التتبع داخل الواجهات.
/// Connects product events to Firebase Analytics and keeps tracking logic out of the UI.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();

  /// يعيد المثيل الوحيد حتى تظل أحداث التحليلات موحدة عبر التطبيق كله.
  /// Returns the singleton so analytics remains consistent across the app.
  factory AnalyticsService() => _instance;

  /// ينشئ الحالة الداخلية للمثيل الوحيد المسؤول عن التحليلات.
  /// Creates the internal state for the singleton analytics instance.
  AnalyticsService._internal();

  /// موفر Firebase Analytics المستخدم لتسجيل الأحداث الفعلية.
  /// Firebase Analytics instance used for real event emission.
  late FirebaseAnalytics _analytics;

  /// مراقب التنقل الذي يربط تغييرات الصفحات بأحداث الشاشة.
  /// Navigation observer that turns route changes into screen tracking.
  late FirebaseAnalyticsObserver _observer;

  /// يعيد موفر Firebase Analytics بعد التهيئة.
  /// Returns the Firebase Analytics instance after initialization.
  FirebaseAnalytics get analytics => _analytics;

  /// يعيد مراقب التنقل الذي يحول تغيرات المسار إلى تتبع للشاشات.
  /// Returns the navigation observer that converts route changes into screen tracking.
  FirebaseAnalyticsObserver get observer => _observer;

  /// يهيئ Firebase Analytics ومراقب التنقل قبل تسجيل أول حدث.
  /// Initializes Firebase Analytics and its navigation observer before the first event.
  void initialize() {
    _analytics = FirebaseAnalytics.instance;
    _observer = FirebaseAnalyticsObserver(analytics: _analytics);
  }

  /// يربط جلسة التحليلات بالمستخدم الحالي عندما يتوفر معرّفه.
  /// Associates analytics events with the current user when an id is available.
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  /// يسجل خاصية مخصصة تفيد في التقسيم والتقارير اللاحقة.
  /// Saves a custom user property for later reporting and segmentation.
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  /// يفصل جلسة التحليلات عن المستخدم عند تسجيل الخروج.
  /// Detaches analytics from the user after logout.
  Future<void> resetAnalyticsData() async {
    await _analytics.setUserId(id: null);
  }

  /// يسجل ظهور الشاشة حتى يظهر مسار التنقل داخل Firebase.
  /// Records a screen view so Firebase can build the user journey.
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }

  /// يسجل طريقة تسجيل الدخول التي اختارها المستخدم.
  /// Records which login method the user chose.
  Future<void> logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  /// يسجل القناة أو الطريقة التي اكتمل بها إنشاء الحساب.
  /// Records how the user completed sign-up.
  Future<void> logSignUp({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  /// يسجل الخروج حتى يظل تسلسل الجلسة التحليلية كاملًا.
  /// Logs logout so the analytics session timeline stays complete.
  Future<void> logLogout() async {
    await _analytics.logEvent(name: 'logout');
  }

  // Property events
  /// يسجل مشاهدة صفحة العقار مع بياناته الأساسية لتغذية تقارير الفعالية.
  /// Logs property views with core metadata for funnel reporting.
  Future<void> logViewProperty({
    required String propertyId,
    required String propertyName,
    required String propertyType,
    required double price,
    String? location,
  }) async {
    final currency = ReferenceService.instance.getCachedCurrencies().isNotEmpty
        ? null
        : null; // placeholder, replaced below
    final userCurrency =
        sl<SharedPreferences>().getString('selected_currency') ?? 'YER';
    await _analytics.logViewItem(
      currency: userCurrency,
      value: price,
      items: [
        AnalyticsEventItem(
          itemId: propertyId,
          itemName: propertyName,
          itemCategory: propertyType,
          locationId: location,
          price: price,
        ),
      ],
    );
  }

  /// يسجل مشاهدة قائمة العقارات حتى نعرف أي القوائم تجذب الانتباه.
  /// Logs property list views so we can see which lists attract attention.
  Future<void> logViewPropertyList({
    required String listType,
    required List<Map<String, dynamic>> properties,
  }) async {
    await _analytics.logViewItemList(
      itemListId: listType,
      itemListName: listType,
      items: properties
          .map(
            (property) => AnalyticsEventItem(
              itemId: property['id'],
              itemName: property['name'],
              itemCategory: property['type'],
              price: property['price']?.toDouble() ?? 0,
            ),
          )
          .toList(),
    );
  }

  /// يسجل إضافة عقار إلى المفضلة لقياس نية الحفظ والعودة لاحقًا.
  /// Logs adding a property to favorites to measure save intent.
  Future<void> logAddToFavorites({
    required String propertyId,
    required String propertyName,
    required String propertyType,
    required double price,
  }) async {
    final userCurrency =
        sl<SharedPreferences>().getString('selected_currency') ?? 'YER';
    await _analytics.logAddToWishlist(
      currency: userCurrency,
      value: price,
      items: [
        AnalyticsEventItem(
          itemId: propertyId,
          itemName: propertyName,
          itemCategory: propertyType,
          price: price,
        ),
      ],
    );
  }

  /// يسجل إزالة العقار من المفضلة كإشارة على تغير الاهتمام.
  /// Logs removing a property from favorites as a change-in-interest signal.
  Future<void> logRemoveFromFavorites({
    required String propertyId,
    required String propertyName,
  }) async {
    await _analytics.logEvent(
      name: 'remove_from_favorites',
      parameters: {
        'property_id': propertyId,
        'property_name': propertyName,
      },
    );
  }

  /// يسجل مشاركة العقار حتى نعرف القنوات التي تدفع الانتشار.
  /// Logs property sharing so we can see which channels drive reach.
  Future<void> logShareProperty({
    required String propertyId,
    required String propertyName,
    required String method,
  }) async {
    await _analytics.logShare(
      contentType: 'property',
      itemId: propertyId,
      method: method,
    );
  }

  // Search events
  /// يسجل عمليات البحث حتى نفهم ما الذي يطلبه المستخدم فعلًا.
  /// Logs searches so we can understand what users are actively looking for.
  Future<void> logSearch({
    required String searchTerm,
    String? location,
    String? propertyType,
    DateTime? checkIn,
    DateTime? checkOut,
    int? numberOfGuests,
  }) async {
    await _analytics.logSearch(
      searchTerm: searchTerm,
      parameters: {
        if (location != null) 'location': location,
        if (propertyType != null) 'property_type': propertyType,
        if (checkIn != null) 'check_in': checkIn.toIso8601String(),
        if (checkOut != null) 'check_out': checkOut.toIso8601String(),
        if (numberOfGuests != null) 'guests': numberOfGuests,
      },
    );
  }

  /// يسجل الفلاتر المطبقة حتى نفهم كيف يضيّق المستخدمون البحث.
  /// Logs applied filters so we can understand how users narrow searches.
  Future<void> logApplyFilter({
    required Map<String, dynamic> filters,
  }) async {
    // Convert Map<String, dynamic> to Map<String, Object>
    final Map<String, Object> safeFilters = filters.map(
      (key, value) => MapEntry(key, value as Object),
    );
    await _analytics.logEvent(
      name: 'apply_filter',
      parameters: safeFilters,
    );
  }

  // Booking events
  /// يسجل بداية الدفع مع تفاصيل المنتج والحجز حتى تبقى رحلة التحويل قابلة للقياس.
  /// Logs checkout start with booking context so the conversion funnel stays measurable.
  Future<void> logBeginCheckout({
    required String propertyId,
    required String propertyName,
    required double totalPrice,
    required DateTime checkIn,
    required DateTime checkOut,
    required int numberOfNights,
  }) async {
    final userCurrency =
        sl<SharedPreferences>().getString('selected_currency') ?? 'YER';
    await _analytics.logBeginCheckout(
      currency: userCurrency,
      value: totalPrice,
      items: [
        AnalyticsEventItem(
          itemId: propertyId,
          itemName: propertyName,
          quantity: numberOfNights,
          price: totalPrice / numberOfNights,
        ),
      ],
    );
  }

  /// يسجل طريقة الدفع المضافة قبل إتمام الحجز.
  /// Logs the selected payment method before booking completion.
  Future<void> logAddPaymentInfo({
    required String paymentMethod,
  }) async {
    await _analytics.logEvent(
      name: 'add_payment_info',
      parameters: {
        'payment_method': paymentMethod,
      },
    );
  }

  /// يسجل اكتمال الحجز كحدث شراء نهائي داخل التحليلات.
  /// Logs booking completion as the final purchase event in analytics.
  Future<void> logBookingComplete({
    required String bookingId,
    required String propertyId,
    required String propertyName,
    required double totalPrice,
    required String paymentMethod,
    required int numberOfNights,
  }) async {
    final userCurrency =
        sl<SharedPreferences>().getString('selected_currency') ?? 'YER';
    await _analytics.logPurchase(
      transactionId: bookingId,
      currency: userCurrency,
      value: totalPrice,
      items: [
        AnalyticsEventItem(
          itemId: propertyId,
          itemName: propertyName,
          quantity: numberOfNights,
          price: totalPrice / numberOfNights,
        ),
      ],
    );
  }

  /// يسجل إلغاء الحجز حتى نفهم أين يتراجع المستخدم عن الدفع.
  /// Logs booking cancellation so we can see where users drop out.
  Future<void> logCancelBooking({
    required String bookingId,
    required String reason,
  }) async {
    final userCurrency =
        sl<SharedPreferences>().getString('selected_currency') ?? 'YER';
    await _analytics.logRefund(
      transactionId: bookingId,
      currency: userCurrency,
      value: 0,
      parameters: {'reason': reason},
    );
  }

  // Review events
  /// يسجل كتابة مراجعة كإشارة على رضا المستخدم بعد الإقامة.
  /// Logs review submission as a post-stay satisfaction signal.
  Future<void> logWriteReview({
    required String propertyId,
    required double rating,
  }) async {
    await _analytics.logEvent(
      name: 'write_review',
      parameters: {
        'property_id': propertyId,
        'rating': rating,
      },
    );
  }

  // Chat events
  /// يسجل بدء المحادثة لقياس الاهتمام قبل التحويل.
  /// Logs chat start to measure pre-conversion interest.
  Future<void> logStartChat({
    required String conversationId,
    required String propertyId,
  }) async {
    await _analytics.logEvent(
      name: 'start_chat',
      parameters: {
        'conversation_id': conversationId,
        'property_id': propertyId,
      },
    );
  }

  /// يسجل إرسال رسالة داخل المحادثة كإشارة على التفاعل المستمر.
  /// Logs message sending as a sign of ongoing engagement.
  Future<void> logSendMessage({
    required String conversationId,
    required String messageType,
  }) async {
    await _analytics.logEvent(
      name: 'send_message',
      parameters: {
        'conversation_id': conversationId,
        'message_type': messageType,
      },
    );
  }

  // Custom events
  /// يسجل حدثًا مخصصًا عندما تحتاج ميزة جديدة إلى تتبع خاص.
  /// Logs a custom event when a new feature needs dedicated tracking.
  Future<void> logCustomEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    // Convert Map<String, dynamic>? to Map<String, Object>?
    final Map<String, Object>? safeParams = parameters?.map(
      (key, value) => MapEntry(key, value as Object),
    );
    await _analytics.logEvent(
      name: name,
      parameters: safeParams,
    );
  }

  // App lifecycle events
  /// يسجل فتح التطبيق لقياس العودة والاستخدام اليومي.
  /// Logs app open events to measure retention and daily usage.
  Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  /// يسجل بدء الجولة التعريفية عندما يمر المستخدم بالمرة الأولى.
  /// Logs tutorial start for first-time onboarding analysis.
  Future<void> logTutorialBegin() async {
    await _analytics.logTutorialBegin();
  }

  /// يسجل اكتمال الجولة التعريفية كدليل على تجاوز أول عائق.
  /// Logs tutorial completion as a sign the first hurdle was cleared.
  Future<void> logTutorialComplete() async {
    await _analytics.logTutorialComplete();
  }
}
