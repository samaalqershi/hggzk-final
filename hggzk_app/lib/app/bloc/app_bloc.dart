import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hggzk/app/dependency_injection/injection_container.dart';
import 'package:hggzk/core/bloc/theme/theme_bloc.dart';
import 'package:hggzk/core/services/notification_service.dart';
import 'package:hggzk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hggzk/features/auth/presentation/bloc/auth_event.dart';
import 'package:hggzk/features/auth/presentation/bloc/auth_state.dart';
import 'package:hggzk/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:hggzk/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:hggzk/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:hggzk/features/home/presentation/bloc/home_bloc.dart';
import 'package:hggzk/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:hggzk/features/notifications/presentation/bloc/notification_event.dart';
import 'package:hggzk/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:hggzk/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:hggzk/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:hggzk/features/property/presentation/bloc/property_bloc.dart';
import 'package:hggzk/features/reference/presentation/bloc/reference_bloc.dart';
import 'package:hggzk/features/review/presentation/bloc/review_bloc.dart';
import 'package:hggzk/features/search/presentation/bloc/search_bloc.dart';
import 'package:hggzk/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:hggzk/features/settings/presentation/bloc/settings_event.dart';
import 'package:hggzk/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:hggzk/features/splash/presentation/bloc/splash_event.dart';

/// حاوية مركزية تجمع كتل الحالة المشتركة كي لا تتكرر التهيئة في الواجهات.
/// Central registry for the blocs that must be shared across the app shell.
class AppBloc {
  /// يدير حالة الجلسة وما يرتبط بها من تسجيل دخول وتحديث ملف المستخدم.
  /// Owns session state such as login, profile refresh, and account actions.
  static late final AuthBloc authBloc;

  /// يحفظ تفضيلات المستخدم مثل اللغة والثيم والإعدادات العامة.
  /// Owns user preferences such as language, theme, and app settings.
  static late final SettingsBloc settingsBloc;

  /// يتولى عدّ الإشعارات، تعليمها كمقروءة، وإدارة الإعدادات المرتبطة بها.
  /// Processes the unread counts, read state, dismissals, and notification preferences flow and keeps the behavior aligned with the surrounding feature.
  static late final NotificationBloc notificationBloc;

  /// ينسق عمليات الدفع وسجل المعاملات على مستوى التطبيق.
  /// Coordinates payment processing and payment history flows.
  static late final PaymentBloc paymentBloc;

  /// يحافظ على وضع الثيم الفعّال ويغذي الواجهة بالتحديثات.
  /// Tracks the active theme mode and broadcasts visual changes.
  static late final ThemeBloc theme;

  /// يحمّل بيانات الصفحة الرئيسية مثل الأقسام والأنواع والمرشحات المحفوظة.
  /// Drives the home feed, section data, and persisted search selections.
  static late final HomeBloc homeBloc;

  /// يدير البحث، الاقتراحات، وحفظ الفلاتر المستخدمة في الاستكشاف.
  /// Controls property search, suggestions, and filter persistence.
  static late final SearchBloc searchBloc;

  /// ينسق رحلة الحجز من التحقق من التوفر حتى الإلغاء والتحديث.
  /// Manages the booking lifecycle from availability checks to cancellation.
  static late final BookingBloc bookingBloc;

  /// يدير المحادثات والرسائل والمرفقات والحالات اللحظية للدردشة.
  /// Owns conversations, messages, attachments, and realtime chat state.
  static late final ChatBloc chatBloc;

  /// يغطي شاشة تفاصيل العقار وما يتبعها من وحدات ومراجعات ومفضلة.
  /// Powers property details, units, reviews, and favorite actions.
  static late final PropertyBloc propertyBloc;

  /// يعالج إنشاء المراجعات وعرض ملخص التقييمات ووسائطها.
  /// Processes the review submission, summaries, and review media uploads flow and keeps the behavior aligned with the surrounding feature.
  static late final ReviewBloc reviewBloc;

  /// يدير قائمة المفضلة وما إذا كان العقار محفوظًا أم لا.
  /// Keeps the favorites list and property favorite status in sync.
  static late final FavoritesBloc favoritesBloc;

  /// يجهز بيانات الإقلاع الأولي التي تحتاجها الشاشة الافتتاحية.
  /// Loads the startup data required during the splash flow.
  static late final SplashBloc splashBloc;

  /// يدير مسار الترحيب الأولي حتى يعرف التطبيق ما إذا كان ينبغي إظهاره.
  /// Tracks onboarding progress so the app can route first-run users correctly.
  static late final OnboardingBloc onboardingBloc;

  /// ينشئ جميع الكتل بعد اكتمال حقن الاعتماديات حتى تبقى القرارات مركزية.
  /// Instantiates every shared bloc after dependency injection is ready.
  static void initialize() {
    // Core Application Blocs
    theme = ThemeBloc(prefs: sl());

    authBloc = AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      resetPasswordUseCase: sl(),
      checkAuthStatusUseCase: sl(),
      getCurrentUserUseCase: sl(),
      updateProfileUseCase: sl(),
      uploadUserImageUseCase: sl(),
      changePasswordUseCase: sl(),
      deleteAccountUseCase: sl(),
      socialLoginUseCase: sl(),
    );

    settingsBloc = SettingsBloc(
      getSettingsUseCase: sl(),
      updateLanguageUseCase: sl(),
      updateThemeUseCase: sl(),
      updateNotificationSettingsUseCase: sl(),
      localDataSource: sl(),
      biometricAuthService: sl(),
      updateBiometricUseCase: sl(),
    );

    notificationBloc = NotificationBloc(
      getNotificationsUseCase: sl(),
      markAsReadUseCase: sl(),
      dismissNotificationUseCase: sl(),
      updateNotificationSettingsUseCase: sl(),
    );

    paymentBloc = PaymentBloc(
      processPaymentUseCase: sl(),
      getPaymentHistoryUseCase: sl(),
    );

    // Feature Blocs
    homeBloc = HomeBloc(
      getSectionsUseCase: sl(),
      getSectionDataUseCase: sl(),
      getPropertyTypesUseCase: sl(),
      getUnitTypesWithFieldsUseCase: sl(),
      getPropertyTypesWithUnitsUseCase: sl(),
      homeRepository: sl(),
      dataSyncService: sl(),
      filterStorageService: sl(),
    );

    searchBloc = SearchBloc(
      searchPropertiesUseCase: sl(),
      getSearchFiltersUseCase: sl(),
      getSearchSuggestionsUseCase: sl(),
      searchRepository: sl(),
      sharedPreferences: sl(),
      dataSyncService: sl(),
      filterStorageService: sl(),
    );

    bookingBloc = BookingBloc(
      createBookingUseCase: sl(),
      getBookingDetailsUseCase: sl(),
      cancelBookingUseCase: sl(),
      getUserBookingsUseCase: sl(),
      getUserBookingsSummaryUseCase: sl(),
      addServicesToBookingUseCase: sl(),
      checkAvailabilityUseCase: sl(),
      processPaymentUseCase: sl(),
      updateBookingUseCase: sl(),
    );

    chatBloc = ChatBloc(
      getConversationsUseCase: sl(),
      getMessagesUseCase: sl(),
      sendMessageUseCase: sl(),
      createConversationUseCase: sl(),
      deleteConversationUseCase: sl(),
      archiveConversationUseCase: sl(),
      unarchiveConversationUseCase: sl(),
      deleteMessageUseCase: sl(),
      editMessageUseCase: sl(),
      addReactionUseCase: sl(),
      removeReactionUseCase: sl(),
      markAsReadUseCase: sl(),
      uploadAttachmentUseCase: sl(),
      searchChatsUseCase: sl(),
      getAvailableUsersUseCase: sl(),
      updateUserStatusUseCase: sl(),
      getChatSettingsUseCase: sl(),
      updateChatSettingsUseCase: sl(),
      getCurrentUserUseCase: sl(),
      webSocketService: sl(),
      getAdminUsersUseCase: sl(),
      localStorageService: sl(),
    );
    try {
      sl<NotificationService>()
          .bindChatEventSink((event) => chatBloc.add(event));
    } catch (_) {}

    propertyBloc = PropertyBloc(
      getPropertyDetailsUseCase: sl(),
      getPropertyUnitsUseCase: sl(),
      getPropertyReviewsUseCase: sl(),
      addToFavoritesUseCase: sl(),
      removeFromFavoritesUseCase: sl(),
      checkPropertyAvailabilityUseCase: sl(),
    );

    reviewBloc = ReviewBloc(
      createReviewUseCase: sl(),
      getPropertyReviewsUseCase: sl(),
      getPropertyReviewsSummaryUseCase: sl(),
      uploadReviewImagesUseCase: sl(),
    );

    favoritesBloc = FavoritesBloc(
      getFavoritesUseCase: sl(),
      addToFavoritesUseCase: sl(),
      removeFromFavoritesUseCase: sl(),
      checkFavoriteStatusUseCase: sl(),
    );

    splashBloc = SplashBloc(
      dataSyncService: sl(),
      getPropertyTypesUseCase: sl(),
      getCitiesUseCase: sl(),
      getCurrenciesUseCase: sl(),
    );

    onboardingBloc = OnboardingBloc(
      localStorage: sl(),
      getCitiesUseCase: sl(),
      getCurrenciesUseCase: sl(),
    );
  }

  /// List of all BlocProviders for the application
  /// This list is used in MultiBlocProvider to provide all blocs to the widget tree
  static final List<BlocProvider> providers = [
    BlocProvider(
      create: (_) => theme,
    ),
    // Core Application Blocs
    BlocProvider<SplashBloc>(
      create: (context) => sl<SplashBloc>()..add(const PreloadAppDataEvent()),
    ),
    BlocProvider<OnboardingBloc>(
      create: (context) =>
          sl<OnboardingBloc>()..add(const CheckFirstRunEvent()),
    ),
    // Reference Bloc
    BlocProvider<ReferenceBloc>(
      create: (context) => sl<ReferenceBloc>(),
    ),
    BlocProvider<AuthBloc>(
      create: (context) => authBloc,
    ),
    BlocProvider<SettingsBloc>(
      create: (context) => settingsBloc..add(LoadSettingsEvent()),
    ),
    BlocProvider<NotificationBloc>(
      create: (context) => notificationBloc,
    ),
    BlocProvider<PaymentBloc>(
      create: (context) => paymentBloc,
    ),

    // Feature Blocs
    BlocProvider<HomeBloc>(
      create: (context) => homeBloc,
    ),
    BlocProvider<SearchBloc>(
      create: (context) => searchBloc,
    ),
    BlocProvider<BookingBloc>(
      create: (context) => bookingBloc,
    ),
    BlocProvider<ChatBloc>(
      create: (context) => chatBloc,
    ),
    BlocProvider<PropertyBloc>(
      create: (context) => propertyBloc,
    ),
    BlocProvider<ReviewBloc>(
      create: (context) => reviewBloc,
    ),
    BlocProvider<FavoritesBloc>(
      create: (context) => favoritesBloc,
    ),
  ];

  /// يغلق كتل الحالة المشتركة عند انتهاء التطبيق أو إعادة ضبط
  /// الجذر حتى لا تبقى مستمعات أو تيارات معلقة.
  /// Closes the shared blocs when the app or root scope is torn down
  /// so streams and listeners do not leak.
  static void dispose() {
    // Core Application Blocs
    authBloc.close();
    settingsBloc.close();
    notificationBloc.close();
    paymentBloc.close();

    // Feature Blocs
    homeBloc.close();
    searchBloc.close();
    bookingBloc.close();
    chatBloc.close();
    propertyBloc.close();
    reviewBloc.close();
    favoritesBloc.close();
  }

  /// يطلق الأحداث الأولية التي تجعل الكتل جاهزة قبل أن تبدأ الواجهات
  /// بالاعتماد على حالاتها.
  /// Dispatches the startup events that prime the blocs before the UI
  /// reads their state.
  static void initializeEvents() {
    // Check authentication status on app start
    authBloc.add(const CheckAuthStatusEvent());

    // Load settings
    settingsBloc.add(LoadSettingsEvent());

    // Load notifications if user is authenticated
    authBloc.stream.listen((state) {
      if (state is AuthAuthenticated) {
        notificationBloc.add(const LoadNotificationsEvent());
      }
    });
  }

  /// يعيد الكتلة المطلوبة بحسب النوع حتى يظل الوصول إليها مضبوطًا
  /// دون تمرير النسخ يدويًا عبر كل شاشة.
  /// Returns a bloc instance by type so screens can access shared
  /// state without threading references everywhere.
  static T getBloc<T>() {
    switch (T) {
      case AuthBloc:
        return authBloc as T;
      case SettingsBloc:
        return settingsBloc as T;
      case NotificationBloc:
        return notificationBloc as T;
      case PaymentBloc:
        return paymentBloc as T;
      case HomeBloc:
        return homeBloc as T;
      case SearchBloc:
        return searchBloc as T;
      case BookingBloc:
        return bookingBloc as T;
      case ChatBloc:
        return chatBloc as T;
      case PropertyBloc:
        return propertyBloc as T;
      case ReviewBloc:
        return reviewBloc as T;
      case FavoritesBloc:
        return favoritesBloc as T;
      default:
        throw ArgumentError('Bloc type $T is not registered in AppBloc');
    }
  }
}
