import 'dart:io' as io;
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hggzk/core/bloc/theme/theme_bloc.dart';
import 'package:hggzk/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:hggzk/features/search/presentation/bloc/search_bloc.dart';
import 'package:hggzk/features/splash/presentation/bloc/splash_bloc.dart';

// Core
import 'package:hggzk/core/network/api_client.dart';
import 'package:hggzk/core/network/network_info.dart';

// Services
import 'package:hggzk/core/services/local_storage_service.dart';
import 'package:hggzk/core/services/filter_storage_service.dart';
import 'package:hggzk/core/services/location_service.dart';
import 'package:hggzk/core/services/notification_service.dart';
import 'package:hggzk/core/services/analytics_service.dart';
import 'package:hggzk/core/services/deep_link_service.dart';
import 'package:hggzk/core/services/websocket_service.dart';
import 'package:hggzk/core/services/local_data_service.dart';
import 'package:hggzk/core/services/connectivity_service.dart';
import 'package:hggzk/core/services/data_sync_service.dart';
import 'package:hggzk/core/services/biometric_auth_service.dart';
// Reference Data
import 'package:hggzk/features/reference/data/datasources/reference_remote_datasource.dart';
import 'package:hggzk/features/reference/data/datasources/reference_local_datasource.dart';
import 'package:hggzk/features/reference/data/repositories/reference_repository_impl.dart';
import 'package:hggzk/features/reference/domain/repositories/reference_repository.dart';
import 'package:hggzk/features/reference/domain/usecases/get_cities_usecase.dart';
import 'package:hggzk/features/reference/domain/usecases/get_currencies_usecase.dart';

// Features - Auth
import 'package:hggzk/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:hggzk/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:hggzk/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:hggzk/features/auth/domain/repositories/auth_repository.dart';
import 'package:hggzk/features/auth/domain/usecases/login_usecase.dart';
import 'package:hggzk/features/auth/domain/usecases/register_usecase.dart';
import 'package:hggzk/features/auth/domain/usecases/logout_usecase.dart';
import 'package:hggzk/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:hggzk/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:hggzk/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:hggzk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hggzk/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:hggzk/features/auth/domain/usecases/upload_user_image_usecase.dart';
import 'package:hggzk/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:hggzk/features/auth/domain/usecases/social_login_usecase.dart';
import 'package:hggzk/features/auth/domain/usecases/verify_email_usecase.dart';
import 'package:hggzk/features/auth/domain/usecases/resend_email_verification_usecase.dart';
import 'package:hggzk/features/auth/presentation/bloc/verification/email_verification_bloc.dart';
import 'package:hggzk/features/auth/domain/usecases/delete_account_usecase.dart';

// Features - Settings
import 'package:hggzk/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:hggzk/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:hggzk/features/settings/domain/repositories/settings_repository.dart';
import 'package:hggzk/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:hggzk/features/settings/domain/usecases/update_language_usecase.dart';
import 'package:hggzk/features/settings/domain/usecases/update_theme_usecase.dart';
import 'package:hggzk/features/settings/domain/usecases/update_biometric_usecase.dart';
import 'package:hggzk/features/settings/domain/usecases/update_notification_settings_usecase.dart'
    as settings_notification;
import 'package:hggzk/features/settings/presentation/bloc/settings_bloc.dart';

// Features - Notifications
import 'package:hggzk/features/notifications/data/datasources/notification_local_datasource.dart';
import 'package:hggzk/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:hggzk/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:hggzk/features/notifications/domain/repositories/notification_repository.dart';
import 'package:hggzk/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:hggzk/features/notifications/domain/usecases/get_unread_count_usecase.dart';
import 'package:hggzk/features/notifications/domain/usecases/get_notification_settings_usecase.dart';

import 'package:hggzk/features/notifications/domain/usecases/dismiss_notification_usecase.dart';
import 'package:hggzk/features/notifications/domain/usecases/update_notification_settings_usecase.dart';
import 'package:hggzk/features/notifications/presentation/bloc/notification_bloc.dart';

// Features - Home
import 'package:hggzk/features/home/domain/repositories/home_repository.dart';
import 'package:hggzk/features/home/domain/usecases/get_sections_usecase.dart';
import 'package:hggzk/features/home/domain/usecases/get_section_data_usecase.dart';
import 'package:hggzk/features/home/domain/usecases/get_property_types_usecase.dart';
import 'package:hggzk/features/home/domain/usecases/get_unit_types_with_fields_usecase.dart';
import 'package:hggzk/features/home/domain/usecases/get_property_types_with_units_usecase.dart';
import 'package:hggzk/features/home/presentation/bloc/home_bloc.dart';
// Added implementations for Home feature
import 'package:hggzk/features/home/data/repositories/home_repository_impl.dart';
import 'package:hggzk/features/home/data/datasources/home_remote_datasource.dart';
import 'package:hggzk/features/home/data/datasources/home_local_datasource.dart';

// Features - Review
import 'package:hggzk/features/review/data/datasources/review_remote_datasource.dart';
import 'package:hggzk/features/review/data/repositories/review_repository_impl.dart';
import 'package:hggzk/features/review/domain/repositories/review_repository.dart';
import 'package:hggzk/features/review/domain/usecases/create_review_usecase.dart';
import 'package:hggzk/features/review/domain/usecases/get_property_reviews_usecase.dart';
import 'package:hggzk/features/review/domain/usecases/get_property_reviews_summary_usecase.dart';
import 'package:hggzk/features/review/domain/usecases/upload_review_images_usecase.dart';
import 'package:hggzk/features/review/presentation/bloc/review_bloc.dart';

// Features - Booking (imports added)
import 'package:hggzk/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:hggzk/features/booking/domain/usecases/create_booking_usecase.dart';
import 'package:hggzk/features/booking/domain/usecases/get_booking_details_usecase.dart';
import 'package:hggzk/features/booking/domain/usecases/cancel_booking_usecase.dart';
import 'package:hggzk/features/booking/domain/usecases/get_user_bookings_usecase.dart';
import 'package:hggzk/features/booking/domain/usecases/get_user_bookings_summary_usecase.dart';
import 'package:hggzk/features/booking/domain/usecases/add_services_to_booking_usecase.dart';
import 'package:hggzk/features/booking/domain/usecases/check_availability_usecase.dart';
import 'package:hggzk/features/booking/domain/usecases/get_unit_available_days_usecase.dart';
import 'package:hggzk/features/booking/domain/usecases/update_booking_usecase.dart';
import 'package:hggzk/features/booking/domain/repositories/booking_repository.dart';
import 'package:hggzk/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:hggzk/features/booking/data/datasources/booking_remote_datasource.dart';

// Features - Payment (imports added)
import 'package:hggzk/features/payment/data/datasources/payment_remote_datasource.dart';
import 'package:hggzk/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:hggzk/features/payment/domain/repositories/payment_repository.dart';
import 'package:hggzk/features/payment/domain/usecases/process_payment_usecase.dart';
import 'package:hggzk/features/payment/domain/usecases/get_payment_history_usecase.dart';
import 'package:hggzk/features/payment/presentation/bloc/payment_bloc.dart';

// Features - Chat
import 'package:hggzk/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:hggzk/features/chat/domain/repositories/chat_repository.dart';
import 'package:hggzk/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:hggzk/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:hggzk/features/chat/data/datasources/chat_local_datasource.dart';
import 'package:hggzk/features/chat/domain/usecases/get_conversations_usecase.dart';
import 'package:hggzk/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:hggzk/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:hggzk/features/chat/domain/usecases/create_conversation_usecase.dart';
import 'package:hggzk/features/chat/domain/usecases/delete_conversation_usecase.dart';
import 'package:hggzk/features/chat/domain/usecases/archive_conversation_usecase.dart';
import 'package:hggzk/features/chat/domain/usecases/unarchive_conversation_usecase.dart';
import 'package:hggzk/features/chat/domain/usecases/delete_message_usecase.dart';
import 'package:hggzk/features/chat/domain/usecases/edit_message_usecase.dart';
import 'package:hggzk/features/chat/domain/usecases/add_reaction_usecase.dart';
import 'package:hggzk/features/chat/domain/usecases/remove_reaction_usecase.dart';
import 'package:hggzk/features/chat/domain/usecases/mark_as_read_usecase.dart';
import 'package:hggzk/features/chat/domain/usecases/upload_attachment_usecase.dart';
import 'package:hggzk/features/chat/domain/usecases/search_chats_usecase.dart';
import 'package:hggzk/features/chat/domain/usecases/get_available_users_usecase.dart';
import 'package:hggzk/features/chat/domain/usecases/get_admin_users_usecase.dart';
import 'package:hggzk/features/chat/domain/usecases/update_user_status_usecase.dart';
import 'package:hggzk/features/chat/domain/usecases/get_chat_settings_usecase.dart';
import 'package:hggzk/features/chat/domain/usecases/update_chat_settings_usecase.dart';
// Alias notification MarkAsRead to avoid name conflict
import 'package:hggzk/features/notifications/domain/usecases/mark_as_read_usecase.dart'
    as notif;

// Features - Search
import 'package:hggzk/features/search/data/datasources/search_remote_datasource.dart';
import 'package:hggzk/features/search/data/repositories/search_repository_impl.dart';
import 'package:hggzk/features/search/domain/repositories/search_repository.dart';
import 'package:hggzk/features/search/domain/usecases/search_properties_usecase.dart';
import 'package:hggzk/features/search/domain/usecases/get_search_filters_usecase.dart'
    as search_usecases;
import 'package:hggzk/features/search/domain/usecases/get_search_suggestions_usecase.dart'
    as search_usecases;

// Features - Property
import 'package:hggzk/features/property/presentation/bloc/property_bloc.dart';
import 'package:hggzk/features/property/domain/repositories/property_repository.dart';
import 'package:hggzk/features/property/domain/usecases/get_property_details_usecase.dart';
import 'package:hggzk/features/property/domain/usecases/get_property_units_usecase.dart';
import 'package:hggzk/features/property/domain/usecases/get_property_reviews_usecase.dart'
    as property_reviews_usecase;
import 'package:hggzk/features/property/domain/usecases/add_to_favorites_usecase.dart';
import 'package:hggzk/features/property/domain/usecases/remove_from_favorites_usecase.dart';
import 'package:hggzk/features/property/data/datasources/property_remote_datasource.dart';
import 'package:hggzk/features/property/data/repositories/property_repository_impl_v2.dart';
import 'package:hggzk/features/property/domain/usecases/check_property_availability_usecase.dart';

// Features - Favorites
import 'package:hggzk/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:hggzk/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:hggzk/features/favorites/presentation/bloc/favorites_bloc.dart';
// Favorites feature use cases with prefixes to avoid name clashes with property AddToFavoritesUseCase
import 'package:hggzk/features/favorites/domain/usecases/get_favorites_usecase.dart'
    as fav_get;
import 'package:hggzk/features/favorites/domain/usecases/add_to_favorites_usecase.dart'
    as fav_add;
import 'package:hggzk/features/favorites/domain/usecases/remove_from_favorites_usecase.dart'
    as fav_remove;
import 'package:hggzk/features/favorites/domain/usecases/check_favorite_status_usecase.dart'
    as fav_check;

// Features - Support
import 'package:hggzk/features/support/domain/repositories/support_repository.dart';
import 'package:hggzk/features/support/data/repositories/support_repository_impl.dart';
import 'package:hggzk/features/support/presentation/cubit/support_cubit.dart';

import 'package:hggzk/features/reference/presentation/bloc/reference_bloc.dart';
import 'package:hggzk/features/reference/presentation/bloc/reference_event.dart';
import 'package:hggzk/features/reference/presentation/bloc/reference_state.dart';
import 'package:hggzk/features/onboarding/presentation/bloc/onboarding_state.dart';

/// يحتفظ بنسخة `GetIt` الوحيدة التي تسجل عليها الخدمة والاعتماديات
/// المشتركة حتى تظل نقطة الحقن مركزية في التطبيق.
/// Exposes the single `GetIt` instance used to register shared
/// dependencies from one central place.
final sl = GetIt.instance;

/// يجمع كل تسجيلات الاعتماديات في مكان واحد حتى يمكن تتبع طبقات
/// التطبيق ومعرفة كيف ترتبط البيانات والخدمات والـ blocs ببعضها.
/// Registers all application dependencies in one place so the wiring
/// between data sources, services, and blocs remains easy to trace.
Future<void> init() async {
  // Features - Auth
  _initAuth();

  // Features - Settings
  _initSettings();

  // Features - Notifications
  _initNotifications();

  // Features - Home
  _initHome();

  // Features - Review
  _initReview();

  // Features - Search
  _initSearch();

  // Features - Booking
  _initBooking();

  // Features - Payment
  _initPaymentFeature();

  // Features - Chat
  _initChat();

  // Features - Property
  _initPropertyFeature();

  // Features - Favorites
  _initFavoritesFeature();

  // Features - Support
  _initSupport();

  // Features - Theme
  _initTheme();

  // Features - Onboarding
  _initOnboarding();

  // Features - Reference Data
  _initReference();

  // Features - Splash
  _initSplash();

  // Core
  _initCore();

  // External
  await _initExternal();
}

/// يربط طبقة المصادقة بمصادرها و use cases و bloc حتى تكون رحلة
/// تسجيل الدخول والخروج والتحقق متماسكة في مكان واحد.
/// Wires the authentication layer so login, logout, verification, and
/// profile flows all resolve from one consistent composition root.
void _initAuth() {
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
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
    ),
  );

  sl.registerFactory(
    () => EmailVerificationBloc(
      verifyEmailUseCase: sl(),
      resendEmailVerificationUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UploadUserImageUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));
  sl.registerLazySingleton(() => SocialLoginUseCase(sl()));
  sl.registerLazySingleton(() => VerifyEmailUseCase(sl()));
  sl.registerLazySingleton(() => ResendEmailVerificationUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      internetConnectionChecker: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
}

/// يهيئ إعدادات المستخدم المحلية والبعيدة حتى تبقى اللغة والثيم
/// والتنبيهات قابلة للتبديل من نفس الحاوية.
/// Sets up the settings stack so language, theme, and notification
/// preferences come from one shared composition path.
void _initSettings() {
  // Bloc
  sl.registerFactory(
    () => SettingsBloc(
      getSettingsUseCase: sl(),
      updateLanguageUseCase: sl(),
      updateThemeUseCase: sl(),
      updateNotificationSettingsUseCase: sl(),
      localDataSource: sl(),
      biometricAuthService: sl(),
      updateBiometricUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetSettingsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateLanguageUseCase(sl()));
  sl.registerLazySingleton(() => UpdateThemeUseCase(sl()));
  sl.registerLazySingleton(() => UpdateBiometricUseCase(sl()));
  sl.registerLazySingleton(
      () => settings_notification.UpdateNotificationSettingsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(localStorage: sl()),
  );
}

/// يربط سيل الإشعارات بالمستودعات ومصادر البيانات والـ bloc الذي
/// يقرأ العدادات والحالات.
/// Composes the notifications feature so the repository, data sources,
/// and bloc all speak through the same wiring.
void _initNotifications() {
  // Bloc
  sl.registerFactory(
    () => NotificationBloc(
      getNotificationsUseCase: sl(),
      markAsReadUseCase: sl(),
      dismissNotificationUseCase: sl(),
      updateNotificationSettingsUseCase: sl(),
      getUnreadCountUseCase: sl(),
      getNotificationSettingsUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => notif.MarkAsReadUseCase(sl()));
  sl.registerLazySingleton(() => DismissNotificationUseCase(sl()));
  sl.registerLazySingleton(() => UpdateNotificationSettingsUseCase(sl()));
  sl.registerLazySingleton(() => GetUnreadCountUseCase(sl()));
  sl.registerLazySingleton(() => GetNotificationSettingsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(
      apiClient: sl(),
      localStorage: sl(),
      authLocalDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<NotificationLocalDataSource>(
    () => NotificationLocalDataSourceImpl(localStorage: sl()),
  );
}

/// يجمع ما تحتاجه الصفحة الرئيسية من مصادر بيانات وخدمات مزامنة
/// حتى تبقى الأقسام والأنواع والفلاتر متزامنة.
/// Wires the home feature so sections, types, and persisted filters
/// stay synchronized through one setup path.
void _initHome() {
  // Bloc
  sl.registerFactory(
    () => HomeBloc(
      getSectionsUseCase: sl(),
      getSectionDataUseCase: sl(),
      getPropertyTypesUseCase: sl(),
      getUnitTypesWithFieldsUseCase: sl(),
      getPropertyTypesWithUnitsUseCase: sl(),
      homeRepository: sl(),
      dataSyncService: sl(),
      filterStorageService: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetSectionsUseCase(sl()));
  sl.registerLazySingleton(() => GetSectionDataUseCase(sl()));
  // Stage 2 use cases
  sl.registerLazySingleton(() => GetPropertyTypesUseCase(sl()));
  sl.registerLazySingleton(() => GetUnitTypesWithFieldsUseCase(sl()));
  sl.registerLazySingleton(() => GetPropertyTypesWithUnitsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(apiClient: sl(), localStorage: sl()),
  );
  sl.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSourceImpl(localStorage: sl()),
  );
}

/// يجهز مسار المراجعات مع مصدرها وuse cases والـ bloc المسؤول عن
/// الإنشاء والملخصات والوسائط.
/// Prepares the review feature, including its source, use cases, and
/// bloc that drive creation, summaries, and media uploads.
void _initReview() {
  // Bloc
  sl.registerFactory(
    () => ReviewBloc(
      createReviewUseCase: sl(),
      getPropertyReviewsUseCase: sl(),
      getPropertyReviewsSummaryUseCase: sl(),
      uploadReviewImagesUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => CreateReviewUseCase(sl()));
  sl.registerLazySingleton(() => GetPropertyReviewsUseCase(sl()));
  sl.registerLazySingleton(() => GetPropertyReviewsSummaryUseCase(sl()));
  sl.registerLazySingleton(() => UploadReviewImagesUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSourceImpl(apiClient: sl()),
  );
}

/// يربط البحث بالمصدر البعيد وuse cases وتخزين الفلاتر حتى تبقى
/// الاقتراحات والحالة السابقة قابلة للاسترجاع.
/// Connects search to remote data, use cases, and filter persistence
/// so suggestions and saved browsing state can be restored.
void _initSearch() {
  // Bloc
  sl.registerFactory(
    () => SearchBloc(
      searchPropertiesUseCase: sl(),
      getSearchFiltersUseCase: sl(),
      getSearchSuggestionsUseCase: sl(),
      searchRepository: sl(),
      sharedPreferences: sl(),
      dataSyncService: sl(),
      filterStorageService: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SearchPropertiesUseCase(sl()));
  sl.registerLazySingleton(() => search_usecases.GetSearchFiltersUseCase(sl()));
  sl.registerLazySingleton(
      () => search_usecases.GetSearchSuggestionsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(remoteDataSource: sl()),
  );

  // Data source
  sl.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(apiClient: sl()),
  );
}

/// يكوّن مسار الحجز بالكامل من التحقق من التوفر إلى التحديث
/// والاسترداد والملخصات.
/// Composes the booking lifecycle end-to-end, from availability
/// checks to updates, summaries, and cancellation flows.
void _initBooking() {
  // Bloc
  sl.registerFactory(
    () => BookingBloc(
      createBookingUseCase: sl(),
      getBookingDetailsUseCase: sl(),
      cancelBookingUseCase: sl(),
      getUserBookingsUseCase: sl(),
      getUserBookingsSummaryUseCase: sl(),
      addServicesToBookingUseCase: sl(),
      checkAvailabilityUseCase: sl(),
      updateBookingUseCase: sl(),
      processPaymentUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => CreateBookingUseCase(sl()));
  sl.registerLazySingleton(() => GetBookingDetailsUseCase(sl()));
  sl.registerLazySingleton(() => CancelBookingUseCase(sl()));
  sl.registerLazySingleton(() => GetUserBookingsUseCase(sl()));
  sl.registerLazySingleton(() => GetUserBookingsSummaryUseCase(sl()));
  sl.registerLazySingleton(() => AddServicesToBookingUseCase(sl()));
  sl.registerLazySingleton(() => CheckAvailabilityUseCase(sl()));
  sl.registerLazySingleton(() => GetUnitAvailableDaysUseCase(sl()));
  sl.registerLazySingleton(() => UpdateBookingUseCase(sl()));

  // Repository
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(
      remoteDataSource: sl(),
      internetConnectionChecker: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(apiClient: sl()),
  );
}

/// يربط الدفع بالمستودع ومصدر البيانات والـ bloc حتى تتكامل
/// المعالجة التاريخية والسجل المالي.
/// Wires the payment feature so processing, history, and repository
/// access stay aligned.
void _initPaymentFeature() {
  // Bloc
  sl.registerFactory(
    () => PaymentBloc(
      processPaymentUseCase: sl(),
      getPaymentHistoryUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => ProcessPaymentUseCase(sl()));
  sl.registerLazySingleton(() => GetPaymentHistoryUseCase(sl()));

  // Repository
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(
      remoteDataSource: sl(),
      internetConnectionChecker: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(
      apiClient: sl(),
    ),
  );
}

/// يجهز كل ما يحتاجه الشات من مستودعات وdatasources وuse cases
/// والـ websocket للتزامن اللحظي.
/// Sets up chat repositories, data sources, use cases, and websocket
/// support for realtime syncing.
void _initChat() {
  // Bloc
  sl.registerFactory(
    () => ChatBloc(
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
      getAdminUsersUseCase: sl(),
      updateUserStatusUseCase: sl(),
      getChatSettingsUseCase: sl(),
      updateChatSettingsUseCase: sl(),
      getCurrentUserUseCase: sl(),
      webSocketService: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetConversationsUseCase(sl()));
  sl.registerLazySingleton(() => GetMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => CreateConversationUseCase(sl()));
  sl.registerLazySingleton(() => DeleteConversationUseCase(sl()));
  sl.registerLazySingleton(() => ArchiveConversationUseCase(sl()));
  sl.registerLazySingleton(() => UnarchiveConversationUseCase(sl()));
  sl.registerLazySingleton(() => DeleteMessageUseCase(sl()));
  sl.registerLazySingleton(() => EditMessageUseCase(sl()));
  sl.registerLazySingleton(() => AddReactionUseCase(sl()));
  sl.registerLazySingleton(() => RemoveReactionUseCase(sl()));
  sl.registerLazySingleton(() => MarkAsReadUseCase(sl()));
  sl.registerLazySingleton(() => UploadAttachmentUseCase(sl()));
  sl.registerLazySingleton(() => SearchChatsUseCase(sl()));
  sl.registerLazySingleton(() => GetAvailableUsersUseCase(sl()));
  sl.registerLazySingleton(() => GetAdminUsersUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetChatSettingsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateChatSettingsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      internetConnectionChecker: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<ChatLocalDataSource>(
    () => ChatLocalDataSourceImpl(),
  );

  // WebSocket Service
  sl.registerLazySingleton(() => ChatWebSocketService(
        authLocalDataSource: sl(),
      ));
}

/// يربط شاشة تفاصيل العقار بالعناصر التي تعتمد عليها مثل الوحدات
/// والمراجعات والمفضلة وفحص التوفر.
/// Composes the property feature around details, units, reviews,
/// favorites, and availability checks.
void _initPropertyFeature() {
  // Bloc
  sl.registerFactory(
    () => PropertyBloc(
      getPropertyDetailsUseCase: sl(),
      getPropertyUnitsUseCase: sl(),
      getPropertyReviewsUseCase: sl(),
      addToFavoritesUseCase: sl(),
      removeFromFavoritesUseCase: sl(),
      checkPropertyAvailabilityUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPropertyDetailsUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetPropertyUnitsUseCase(repository: sl()));
  sl.registerLazySingleton(() =>
      property_reviews_usecase.GetPropertyReviewsUseCase(repository: sl()));
  sl.registerLazySingleton(() => AddToFavoritesUseCase(repository: sl()));
  sl.registerLazySingleton(() => RemoveFromFavoritesUseCase(repository: sl()));
  sl.registerLazySingleton(
    () => CheckPropertyAvailabilityUseCase(repository: sl()),
  );

  // Repository
  sl.registerLazySingleton<PropertyRepository>(
    () => PropertyRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<PropertyRemoteDataSource>(
    () => PropertyRemoteDataSourceImpl(apiClient: sl()),
  );
}

/// يجهز قائمة المفضلة بما في ذلك القراءة والإضافة والإزالة والتحقق
/// من الحالة.
/// Prepares the favorites feature including listing, adding, removing,
/// and checking saved state.
void _initFavoritesFeature() {
  // Bloc
  sl.registerFactory(() => FavoritesBloc(
        getFavoritesUseCase: sl(),
        addToFavoritesUseCase: sl(),
        removeFromFavoritesUseCase: sl(),
        checkFavoriteStatusUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => fav_get.GetFavoritesUseCase(sl()));
  sl.registerLazySingleton(() => fav_add.AddToFavoritesUseCase(sl()));
  sl.registerLazySingleton(() => fav_remove.RemoveFromFavoritesUseCase(sl()));
  sl.registerLazySingleton(() => fav_check.CheckFavoriteStatusUseCase(sl()));

  // Repository
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(
      apiClient: sl(),
      networkInfo: sl(),
      localStorage: sl(),
    ),
  );
}

/// يربط شاشة الدعم بمستودعها بحيث تبقى الرسائل داخل التطبيق قابلة
/// للإرسال والاستقبال.
/// Wires the support feature so the in-app messaging flow stays
/// connected to its repository.
void _initSupport() {
  // Cubit
  sl.registerFactory(
    () => SupportCubit(
      repository: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<SupportRepository>(
    () => SupportRepositoryImpl(
      apiClient: sl(),
    ),
  );
}

/// يهيئ الثيم بحيث يبقى تغيير النمط مرئيًا ومستمرًا عبر التطبيق.
/// Sets up theme state so visual mode changes propagate across the app.
void _initTheme() {
  // Bloc
  sl.registerFactory(
    () => ThemeBloc(
      prefs: sl(),
    ),
  );
}

/// يجهز مسار أول تشغيل بحيث يعرف التطبيق متى يعرض شاشة البداية.
/// Prepares first-run onboarding so the app knows whether to show the
/// introductory flow.
void _initOnboarding() {
  // Bloc
  sl.registerFactory(
    () => OnboardingBloc(
      localStorage: sl(),
      getCitiesUseCase: sl(),
      getCurrenciesUseCase: sl(),
    ),
  );
}

/// يربط بيانات المدن والعملات التي يعتمد عليها البحث والحجز
/// والإعدادات الإقليمية.
/// Composes the reference data layer used by search, booking, and
/// region-specific settings.
void _initReference() {
  // Bloc
  sl.registerFactory(
    () => ReferenceBloc(
      getCitiesUseCase: sl(),
      getCurrenciesUseCase: sl(),
      localStorage: sl(),
    ),
  );
}

/// يجهز بيانات شاشة البداية التي تحتاجها القرارات الأولى بعد الإقلاع.
/// Prepares the splash feature and the boot-time state it needs for
/// the initial routing decision.
void _initSplash() {
  // Bloc
  sl.registerFactory(
    () => SplashBloc(
      dataSyncService: sl(),
      getPropertyTypesUseCase: sl(),
      getCitiesUseCase: sl(),
      getCurrenciesUseCase: sl(),
    ),
  );
}

/// يربط طبقة البنية التحتية الأساسية من الشبكة والتخزين والخدمات
/// المشتركة والتهيئة العامة.
/// Assembles the core infrastructure layer: networking, storage,
/// shared services, and foundational wiring.
void _initCore() {
  // Network
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // API Client
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));

  // Services
  sl.registerLazySingleton(() => LocalStorageService(sl()));
  sl.registerLazySingleton(() => BiometricAuthService());
  sl.registerLazySingleton(() => FilterStorageService(sl()));
  sl.registerLazySingleton(() => LocationService());
  sl.registerLazySingleton(() => NotificationService(
        apiClient: sl(),
        localStorage: sl(),
        authLocalDataSource: sl(),
      ));
  sl.registerLazySingleton(() => AnalyticsService());
  sl.registerLazySingleton(() => DeepLinkService());

  // Data Management Services
  sl.registerLazySingleton(() => LocalDataService(sl()));
  sl.registerLazySingleton(() => ConnectivityService());

  // Reference datasources and repository
  sl.registerLazySingleton<ReferenceRemoteDataSource>(
      () => ReferenceRemoteDataSourceImpl(apiClient: sl()));
  sl.registerLazySingleton<ReferenceLocalDataSource>(
      () => ReferenceLocalDataSourceImpl(localStorage: sl()));
  sl.registerLazySingleton<ReferenceRepository>(
      () => ReferenceRepositoryImpl(remote: sl(), local: sl()));

  // Reference use cases
  sl.registerLazySingleton(() => GetCitiesUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrenciesUseCase(sl()));

  // Data sync service
  sl.registerLazySingleton(() => DataSyncService(
        localDataService: sl(),
        connectivityService: sl(),
        remoteDataSource: sl(),
        referenceRemoteDataSource: sl(),
      ));

  // Removed generic WebSocketService registration; using ChatWebSocketService for chat feature
}

/// يحضر الاعتماديات الخارجية التي يجب أن تُنشأ بعد تهيئة التطبيق
/// مثل التخزين المشترك والـ dio وفاحص الاتصال.
/// Instantiates external dependencies that must exist after app setup,
/// such as shared preferences, Dio, and connectivity checks.
Future<void> _initExternal() async {
  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Dio
  sl.registerLazySingleton(() => Dio());

  // Internet Connection Checker (force IPv4 addresses to avoid IPv6 DNS issues)
  sl.registerLazySingleton(
      () => InternetConnectionChecker.createInstance(addresses: [
            AddressCheckOptions(
                address: io.InternetAddress.tryParse('1.1.1.1')!, port: 53),
            AddressCheckOptions(
                address: io.InternetAddress.tryParse('8.8.8.8')!, port: 53),
          ]));
}
