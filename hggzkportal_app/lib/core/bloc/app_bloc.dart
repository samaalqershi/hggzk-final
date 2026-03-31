import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hggzkportal/core/bloc/theme/theme_bloc.dart';
import 'package:hggzkportal/injection_container.dart';
import 'package:hggzkportal/core/localization/locale_manager.dart';
import 'package:hggzkportal/core/bloc/locale/locale_cubit.dart';

// Core Blocs
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../services/notification_service.dart';
// Removed notifications, payment

// Feature Blocs
import '../../features/chat/presentation/bloc/chat_bloc.dart';
// Removed home, search, booking, property, review, favorites, splash, onboarding
// Removed additional imports of removed features

/// يجمع الـ blocs الأساسية والوظيفية في نقطة واحدة حتى يبقى إنشاءها وضبطها متسقًا.
/// Central registry for the app's core and feature blocs so creation and disposal stay consistent.
class AppBloc {
  /// Shared auth bloc used by the portal shell and most authenticated flows.
  /// bloc المصادقة المشترك المستخدم داخل غلاف البورتال ومعظم المسارات
  /// المصادقة.
  static late final AuthBloc authBloc;

  /// Shared settings bloc that survives across page changes in the shell.
  /// bloc الإعدادات المشترك الذي يبقى حيًا عبر تنقل الصفحات داخل الغلاف.
  static late final SettingsBloc settingsBloc;

  /// Shared theme bloc that keeps the portal appearance synchronized.
  /// bloc الثيم المشترك الذي يحافظ على اتساق مظهر البورتال.
  static late final ThemeBloc theme;

  /// Shared locale cubit that drives runtime language switching.
  /// cubit اللغة المشترك الذي يدير تبديل اللغة أثناء التشغيل.
  static late final LocaleCubit locale;

  /// Shared chat bloc used by shell-level chat experiences.
  /// bloc الدردشة المشترك المستخدم في تجارب الدردشة على مستوى الغلاف.
  static late final ChatBloc chatBloc;

  /// Creates the long-lived bloc instances after dependency injection is ready.
  /// ينشئ الـ blocs طويلة العمر بعد اكتمال تسجيل الاعتماديات.
  static void initialize() {
    // Core Application Blocs
    theme = ThemeBloc(prefs: sl());
    locale = LocaleCubit(LocaleManager.defaultLocale);
    settingsBloc = sl();

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
      registerOwnerUseCase: sl(),
      deleteOwnerAccountUseCase: sl(),
      portalSocialLoginUseCase: sl(),
      completeOwnerProfileUseCase: sl(),
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
      getAdminUsersUseCase: sl(),
      updateUserStatusUseCase: sl(),
      getChatSettingsUseCase: sl(),
      updateChatSettingsUseCase: sl(),
      getCurrentUserUseCase: sl(),
      webSocketService: sl(),
      localStorageService: sl(),
    );
    try {
      sl<NotificationService>()
          .bindChatEventSink((event) => chatBloc.add(event));
    } catch (_) {}
  }

  /// Exposes the blocs to the widget tree through a stable provider list.
  /// يعرّف قائمة مزوّدي الـ blocs التي يستهلكها MultiBlocProvider في شجرة الواجهات.
  static final List<BlocProvider> providers = [
    BlocProvider(
      create: (_) => theme,
    ),
    BlocProvider<LocaleCubit>(
      create: (context) => locale,
    ),
    BlocProvider<SettingsBloc>(
      create: (context) => settingsBloc,
    ),
    BlocProvider<AuthBloc>(
      create: (context) => authBloc,
    ),
    BlocProvider<ChatBloc>(
      create: (context) => chatBloc,
    ),
  ];

  /// Closes the shared blocs when the app is shutting down to avoid leaks.
  /// يغلق الـ blocs المشتركة عند إنهاء التطبيق حتى لا تبقى موارد معلقة.
  static void dispose() {
    authBloc.close();
    settingsBloc.close();
    chatBloc.close();
  }

  /// Dispatches startup events that need to run before the first meaningful screen.
  /// يرسل أحداث الإقلاع التي يجب أن تعمل قبل عرض أول شاشة مفيدة.
  static void initializeEvents() {
    authBloc.add(const CheckAuthStatusEvent());
  }

  /// Returns a shared bloc instance with type-safe access for call sites that need it.
  /// يعيد مثيل bloc مشتركًا بطريقة آمنة نوعيًا عندما تحتاجه بعض الطبقات مباشرة.
  static T getBloc<T>() {
    if (T == SettingsBloc) {
      return settingsBloc as T;
    }
    if (T == AuthBloc) {
      return authBloc as T;
    }
    if (T == ChatBloc) {
      return chatBloc as T;
    }
    throw ArgumentError('Bloc type $T is not registered in AppBloc');
  }

  /// المثيل الأحادي الداخلي الذي يضمن وجود غلاف واحد فقط حول إدارة الـ blocs.
  /// Internal singleton instance that guarantees only one wrapper exists for
  /// bloc management.
  static final AppBloc _instance = AppBloc._internal();

  /// Returns the singleton AppBloc wrapper used by the portal bootstrap.
  /// يعيد الغلاف الأحادي لـ AppBloc المستخدم في تهيئة البورتال.
  factory AppBloc() {
    return _instance;
  }

  /// Private singleton constructor that prevents creating extra wrappers.
  /// مُنشئ خاص يمنع إنشاء أغلفة إضافية.
  AppBloc._internal();
}

/// Convenience access to the service locator from within AppBloc helpers.
/// وصول مساعد إلى محدد الخدمات داخل ملحقات AppBloc.
extension ServiceLocatorExtension on AppBloc {
  /// Reads a registered dependency from GetIt using the requested type.
  /// يقرأ اعتمادًا مسجلًا من GetIt بحسب النوع المطلوب.
  static T sl<T extends Object>() {
    return GetIt.instance<T>();
  }
}
