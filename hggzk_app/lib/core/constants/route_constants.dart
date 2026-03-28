/// جميع مسارات التنقل المركزية التي يعتمد عليها `GoRouter`.
/// Central route map used by the app shell, guards, and deep links.
class RouteConstants {
  /// يمنع إنشاء مثيل لأن هذا الملف مجرد مجموعة ثوابت وروابط بناء.
  /// Prevents instantiation because this class only exposes route constants.
  RouteConstants._();

  /// مسارات الدخول الأولي قبل ظهور الواجهة الرئيسية.
  /// Entry and boot routes shown before the main shell.
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String onboardingSelection = '/onboarding/select-city-currency';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String verifyOtp = '/verify-otp';

  /// الجذر الذي يحمل شريط التنقل الرئيسي بعد اكتمال التحقق.
  /// Root shell shown after authentication and onboarding are complete.
  static const String main = '/main';
  static const String home = '/home';
  static const String sections = '/sections';
  static const String search = '/search';
  static const String searchResults = '/search/results';
  static const String searchFilters = '/search/filters';

  /// مسارات تفاصيل العقار وما يتفرع عنها من صور ومراجعات وخريطة.
  /// Property detail routes and their nested screens.
  static const String propertyDetails = '/property/:id';
  static const String propertyUnits = '/property/:id/units';
  static const String propertyGallery = '/property/:id/gallery';
  static const String propertyReviews = '/property/:id/reviews';
  static const String propertyMap = '/property/:id/map';

  /// مسارات الحجز التي تبدأ بالنموذج وتنتهي بالتأكيد النهائي.
  /// Booking routes from form entry through confirmation.
  static const String bookingForm = '/booking/form';
  static const String bookingSummary = '/booking/summary';
  static const String bookingPayment = '/booking/payment';
  static const String bookingConfirmation = '/booking/confirmation';
  static const String myBookings = '/bookings';
  static const String bookingDetails = '/booking/:id';

  /// مسارات الحساب والإعدادات الشخصية والملفات المحفوظة.
  /// User account, profile, and saved items routes.
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/change-password';
  static const String favorites = '/favorites';
  static const String paymentMethods = '/payment/methods';
  static const String addPaymentMethod = '/payment/add-method';
  static const String paymentHistory = '/payment/history';
  static const String legal = '/legal';
  static const String legalWebView = '/legal/webview';

  /// مسارات المحادثات والصندوق الخاص بالرسائل.
  /// Chat inbox routes and conversation details.
  static const String conversations = '/conversations';
  static const String newConversation = '/conversations/new';
  static const String chat = '/chat/:conversationId';
  static const String chatSettings = '/chat/settings';

  /// مسارات مركز الإشعارات وإعداداته.
  /// Notification center and notification settings routes.
  static const String notifications = '/notifications';
  static const String notificationSettings = '/notifications/settings';

  /// مسارات الإعدادات العامة والمعلومات القانونية.
  /// General settings, policy, and support routes.
  static const String settings = '/settings';
  static const String languageSettings = '/settings/language';
  static const String privacyPolicy = '/settings/privacy-policy';
  static const String about = '/settings/about';
  static const String support = '/support';
  static const String helpAndSupport = '/help-support';
  static const String aiAssistant = '/ai-assistant';

  /// تولد المسارات الديناميكية التي تحتاج معرّفًا واحدًا في النهاية.
  /// Builds dynamic routes that append a single identifier segment.
  static String buildPropertyDetailsRoute(String id) => '/property/$id';
  static String buildPropertyUnitsRoute(String id) => '/property/$id/units';
  static String buildBookingDetailsRoute(String id) => '/booking/$id';
  static String buildChatRouteWithId(String conversationId) =>
      '/chat/$conversationId';
}
