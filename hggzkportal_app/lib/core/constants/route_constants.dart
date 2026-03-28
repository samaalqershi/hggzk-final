/// مرجع موحد للمسارات حتى لا تتكرر السلاسل النصية بين الراوتر والواجهات.
/// Single source of truth for route strings so navigation stays consistent across the portal.
class RouteConstants {
  RouteConstants._();

  /// شاشة البداية التي تفتح قبل أي قرار تنقل آخر.
  /// Splash screen shown before any other navigation decision.
  static const String splash = '/';

  /// مسار التهيئة الأولى للمستخدم الجديد قبل تسجيل الدخول.
  /// First-run onboarding flow for new users before authentication.
  static const String onboarding = '/onboarding';

  /// شاشة الدخول الأساسية لحسابات البوابة.
  /// Main login screen for portal accounts.
  static const String login = '/login';

  /// شاشة إنشاء حساب جديد داخل البوابة.
  /// Registration screen for creating a new portal account.
  static const String register = '/register';

  /// مسار استعادة كلمة المرور عندما ينسى المستخدم بياناته.
  /// Password recovery flow when the user forgets credentials.
  static const String forgotPassword = '/forgot-password';

  /// شاشة إعادة تعيين كلمة المرور بعد التحقق المناسب.
  /// Password reset screen after successful verification.
  static const String resetPassword = '/reset-password';

  /// شاشة تأكيد البريد بعد طلب التحقق.
  /// Email verification screen after requesting confirmation.
  static const String verifyEmail = '/verify-email';

  /// الغلاف الرئيسي للتطبيق الذي تستقر عليه بقية المسارات.
  /// Root shell route that hosts the rest of the portal experience.
  static const String main = '/main';

  /// الصفحة الرئيسية داخل الغلاف العام.
  /// Main home route inside the application shell.
  static const String home = '/home';

  /// شاشة البحث الرئيسية داخل البوابة.
  /// Main search route for the portal.
  static const String search = '/search';

  /// صفحة نتائج البحث المتقدمة بعد تطبيق المرشحات.
  /// Search results page after filters are applied.
  static const String searchResults = '/search/results';

  /// صفحة فلاتر البحث التي تضبط معايير الاستكشاف.
  /// Search filters page used to refine discovery criteria.
  static const String searchFilters = '/search/filters';

  /// مسار تفاصيل العقار الذي يعتمد على المعرّف الديناميكي.
  /// Property details route that accepts a dynamic id.
  static const String propertyDetails = '/property/:id';

  /// معرض صور العقار.
  /// Property gallery route.
  static const String propertyGallery = '/property/:id/gallery';

  /// صفحة تقييمات العقار.
  /// Property reviews route.
  static const String propertyReviews = '/property/:id/reviews';

  /// صفحة موقع العقار على الخريطة.
  /// Property map route.
  static const String propertyMap = '/property/:id/map';

  /// شاشة تعبئة بيانات الحجز.
  /// Booking form route.
  static const String bookingForm = '/booking/form';

  /// شاشة ملخص الحجز قبل الدفع.
  /// Booking summary route shown before payment.
  static const String bookingSummary = '/booking/summary';

  /// مسار الدفع داخل رحلة الحجز.
  /// Booking payment route.
  static const String bookingPayment = '/booking/payment';

  /// شاشة تأكيد نجاح الحجز.
  /// Booking confirmation route.
  static const String bookingConfirmation = '/booking/confirmation';

  /// صفحة الحجوزات الخاصة بالمستخدم.
  /// User's bookings list route.
  static const String myBookings = '/bookings';

  /// صفحة تفاصيل حجز محدد.
  /// Specific booking details route.
  static const String bookingDetails = '/booking/:id';

  /// صفحة الملف الشخصي للمستخدم.
  /// User profile route.
  static const String profile = '/profile';

  /// صفحة تعديل بيانات الملف الشخصي.
  /// Edit profile route.
  static const String editProfile = '/profile/edit';

  /// مسار تغيير كلمة المرور من داخل الحساب.
  /// Change-password route inside the profile area.
  static const String changePassword = '/profile/change-password';

  /// صفحة العناصر المفضلة لدى المستخدم.
  /// Favorites route for saved items.
  static const String favorites = '/favorites';

  /// صفحة وسائل الدفع المحفوظة.
  /// Saved payment methods route.
  static const String paymentMethods = '/payment/methods';

  /// شاشة إضافة وسيلة دفع جديدة.
  /// Add new payment method route.
  static const String addPaymentMethod = '/payment/add-method';

  /// صفحة سجل المدفوعات والحركات المالية.
  /// Payment history route.
  static const String paymentHistory = '/payment/history';

  /// صفحة قائمة المحادثات.
  /// Conversations list route.
  static const String conversations = '/chat/conversations';

  /// مسار محادثة واحدة حسب المعرف.
  /// Single conversation route by id.
  static const String chat = '/chat/:conversationId';

  /// صفحة إعدادات المحادثات والإشعارات المرتبطة بها.
  /// Chat settings route.
  static const String chatSettings = '/chat/settings';

  /// صفحة قائمة الإشعارات.
  /// Notifications list route.
  static const String notifications = '/notifications';

  /// صفحة إعدادات الإشعارات.
  /// Notification settings route.
  static const String notificationSettings = '/notifications/settings';

  /// صفحة الإعدادات العامة للتطبيق.
  /// General app settings route.
  static const String settings = '/settings';

  /// صفحة تغيير اللغة.
  /// Language settings route.
  static const String languageSettings = '/settings/language';

  /// صفحة سياسة الخصوصية.
  /// Privacy policy route.
  static const String privacyPolicy = '/settings/privacy-policy';

  /// صفحة معلومات حول التطبيق.
  /// About screen route.
  static const String about = '/settings/about';

  /// صفحة الشروط والأحكام.
  /// Terms route.
  static const String terms = '/terms';

  /// صفحة ويب عامة لعرض المستندات القانونية.
  /// Legal documents webview route.
  static const String legalWebView = '/legal/webview';

  /// صفحة الدعم والمساعدة.
  /// Support route.
  static const String support = '/support';

  /// يبني رابط تفاصيل العقار باستخدام المعرّف في المسار الديناميكي.
  /// Builds a property-details route using the id in the dynamic path.
  static String buildPropertyDetailsRoute(String id) => '/property/$id';

  /// يبني رابط تفاصيل الحجز باستخدام المعرّف في المسار الديناميكي.
  /// Builds a booking-details route using the id in the dynamic path.
  static String buildBookingDetailsRoute(String id) => '/booking/$id';

  /// يبني رابط محادثة محددة باستخدام معرف المحادثة.
  /// Builds a specific chat route using the conversation id.
  static String buildChatRouteWithId(String conversationId) =>
      '/chat/$conversationId';
}
