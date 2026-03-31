import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hggzk/app/bloc/app_bloc.dart';
import 'package:hggzk/features/auth/presentation/bloc/auth_state.dart';
import 'package:hggzk/features/auth/presentation/bloc/auth_event.dart';
import 'package:hggzk/features/auth/presentation/pages/login_page.dart';
import 'package:hggzk/features/chat/presentation/widgets/conversation_loader.dart';
import 'package:hggzk/features/review/presentation/pages/reviews_list_page.dart';
import 'package:hggzk/features/review/presentation/pages/write_review_page.dart';
import 'package:hggzk/features/search/presentation/pages/search_page.dart';
import 'package:hggzk/app/presentation/pages/main_shell_page.dart';
import 'package:hggzk/features/splash/presentation/pages/splash_screen.dart';
import 'package:hggzk/features/onboarding/presentation/pages/select_city_currency_page.dart';
import 'package:hggzk/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:hggzk/features/property/presentation/pages/property_details_page.dart';
import 'package:hggzk/features/search/domain/entities/search_navigation_params.dart';
import 'package:hggzk/features/property/domain/entities/property_policy.dart';
import 'package:hggzk/core/services/local_storage_service.dart';
import 'package:hggzk/app/dependency_injection/injection_container.dart';
import 'package:hggzk/core/constants/storage_constants.dart';
import 'package:hggzk/features/auth/presentation/pages/register_page.dart';
import 'package:hggzk/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:hggzk/features/auth/presentation/pages/verify_email_modern_page.dart';
import 'package:hggzk/features/property/presentation/pages/property_gallery_page.dart';
import 'package:hggzk/features/booking/presentation/pages/booking_form_page.dart';
import 'package:hggzk/features/booking/presentation/pages/booking_summary_page.dart';
import 'package:hggzk/features/booking/presentation/pages/booking_payment_page.dart';
import 'package:hggzk/features/booking/presentation/pages/booking_confirmation_page.dart';
import 'package:hggzk/features/booking/presentation/pages/booking_details_page.dart';
import 'package:hggzk/features/property/domain/entities/property_detail.dart';
import 'package:hggzk/features/chat/presentation/pages/chat_page.dart';
import 'package:hggzk/features/chat/presentation/pages/new_conversation_page.dart';
import 'package:hggzk/features/chat/presentation/pages/conversations_page.dart';
import 'package:hggzk/features/chat/domain/entities/conversation.dart';
import 'package:hggzk/features/auth/presentation/pages/change_password_page.dart';
import 'package:hggzk/features/auth/presentation/pages/edit_profile_page.dart';
import 'package:hggzk/features/auth/presentation/pages/profile_page.dart';
import 'package:hggzk/features/settings/presentation/pages/settings_page.dart';
import 'package:hggzk/features/settings/presentation/pages/language_settings_page.dart';
import 'package:hggzk/features/settings/presentation/pages/in_app_webview_page.dart';
import 'package:hggzk/features/settings/presentation/pages/legal_documents_page.dart';
import 'package:hggzk/features/support/presentation/pages/support_page.dart';
import 'package:hggzk/app/router/navigation_service.dart';
import 'package:hggzk/features/notifications/presentation/pages/notifications_page.dart';
import 'package:hggzk/features/notifications/presentation/pages/notification_settings_page.dart';
import 'package:hggzk/features/notifications/presentation/bloc/notification_bloc.dart'
    as notif_bloc;
import 'package:hggzk/core/constants/route_constants.dart';
import 'package:hggzk/features/home/presentation/pages/all_sections_page.dart';
import 'package:hggzk/features/home/presentation/pages/section_details_page.dart';
import 'package:hggzk/features/home/domain/entities/section.dart';
import 'package:hggzk/features/property/presentation/pages/property_units_page.dart';
import 'package:hggzk/features/ai_assistant/presentation/pages/ai_chat_page.dart';

/// يجمع مسارات التطبيق وحراسها وقواعد التحويل في مكان واحد حتى تبقى
/// قرارات الملاحة متسقة مع حالة الجلسة والتهيئة الأولى.
/// Centralizes app routes, guards, and redirect rules so navigation
/// stays consistent with onboarding and authentication state.
class AppRouter {
  static final GoRouter _router = _buildRouter();

  /// يعيد نسخة الراوتر المشتركة بدل إعادة إنشائها مع كل rebuild للجذر.
  /// Returns the shared router instance instead of recreating it on every root rebuild.
  static GoRouter get router => _router;

  /// ينشئ الراوتر الفعلي مع ردود الفعل على تغيّر حالة المصادقة.
  /// Builds the actual `GoRouter` instance and ties it to auth state
  /// changes.
  static GoRouter _buildRouter() {
    final authBloc = AppBloc.authBloc;
    return GoRouter(
      navigatorKey: NavigationService.rootNavigatorKey,
      initialLocation: RouteConstants.splash,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        // Proactive route guard: if access token is expired, force logout silently
        try {
          final token = sl<LocalStorageService>()
              .getData(StorageConstants.accessToken) as String?;
          if (token != null &&
              token.isNotEmpty &&
              _isJwtExpiredRouter(token, skewSeconds: 10)) {
            AppBloc.authBloc.add(const LogoutEvent());
          }
        } catch (_) {}

        final authState = AppBloc.authBloc.state;
        final localStorage = sl<LocalStorageService>();
        final isFirstRun = !localStorage.isOnboardingCompleted();

        final goingToLogin = state.matchedLocation == RouteConstants.login;
        final goingToRegister =
            state.matchedLocation == RouteConstants.register;
        final goingToForgot =
            state.matchedLocation == RouteConstants.forgotPassword;
        final isSplash = state.matchedLocation == RouteConstants.splash;
        final isProtected =
            _protectedPaths.any((p) => state.matchedLocation.startsWith(p));

        if (isSplash) return null; // اترك السبلاش يقرر

        if (isFirstRun && !(goingToLogin || goingToRegister || goingToForgot)) {
          return RouteConstants.onboardingSelection;
        }

        if (authState is AuthUnauthenticated &&
            isProtected &&
            !(goingToLogin || goingToRegister || goingToForgot)) {
          final from = Uri.encodeComponent(state.uri.toString());
          return '${RouteConstants.login}?from=$from';
        }

        if (authState is AuthAuthenticated &&
            (goingToLogin || goingToRegister || goingToForgot)) {
          if (!authState.user.isEmailVerified) {
            return RouteConstants.verifyOtp;
          }
          return RouteConstants.main;
        }

        if (authState is AuthAuthenticated && isProtected) {
          if (!authState.user.isEmailVerified &&
              state.matchedLocation != RouteConstants.verifyOtp) {
            return RouteConstants.verifyOtp;
          }
        }

        return null;
      },
      routes: <RouteBase>[
        GoRoute(
          path: RouteConstants.splash,
          builder: (BuildContext context, GoRouterState state) {
            return const SplashScreen();
          },
        ),
        GoRoute(
          path: RouteConstants.verifyOtp,
          builder: (BuildContext context, GoRouterState state) {
            return const VerifyEmailModernPage();
          },
        ),
        // Notifications list
        GoRoute(
          path: RouteConstants.notifications,
          builder: (context, state) {
            return BlocProvider<notif_bloc.NotificationBloc>(
              create: (_) => sl<notif_bloc.NotificationBloc>(),
              child: const NotificationsPage(),
            );
          },
        ),
        // Notification settings (align with RouteConstants.notificationSettings)
        GoRoute(
          path: RouteConstants.notificationSettings,
          builder: (context, state) {
            return BlocProvider<notif_bloc.NotificationBloc>(
              create: (_) => sl<notif_bloc.NotificationBloc>(),
              child: const NotificationSettingsPage(),
            );
          },
        ),
        GoRoute(
          path: RouteConstants.onboardingSelection,
          builder: (BuildContext context, GoRouterState state) {
            return BlocProvider.value(
              value: context.read<OnboardingBloc>(),
              child: const SelectCityCurrencyPage(),
            );
          },
        ),
        GoRoute(
          path: RouteConstants.main,
          builder: (BuildContext context, GoRouterState state) {
            final tabParam = state.uri.queryParameters['tab'];
            final parsed = int.tryParse(tabParam ?? '');
            final initialTabIndex =
                (parsed != null && parsed >= 0 && parsed <= 3) ? parsed : 0;
            return MainScreen(initialTabIndex: initialTabIndex);
          },
        ),
        GoRoute(
          path: RouteConstants.login,
          builder: (BuildContext context, GoRouterState state) {
            return const Scaffold(
              body: Center(
                child: LoginPage(),
              ),
            );
          },
        ),
        GoRoute(
          path: RouteConstants.register,
          builder: (BuildContext context, GoRouterState state) {
            final params = state.extra is Map<String, dynamic>
                ? state.extra as Map<String, dynamic>
                : {"isFirst": false};
            return RegisterPage(
              isFirst: params["isFirst"] ?? false,
            );
          },
        ),
        GoRoute(
          path: RouteConstants.forgotPassword,
          builder: (BuildContext context, GoRouterState state) {
            return const ForgotPasswordPage();
          },
        ),
        GoRoute(
          path: RouteConstants.profile,
          builder: (BuildContext context, GoRouterState state) {
            return const ProfilePage();
          },
        ),
        GoRoute(
          path: RouteConstants.editProfile,
          builder: (BuildContext context, GoRouterState state) {
            return const EditProfilePage();
          },
        ),
        GoRoute(
          path: RouteConstants.changePassword,
          builder: (BuildContext context, GoRouterState state) {
            return const ChangePasswordPage();
          },
        ),
        GoRoute(
          path: RouteConstants.legal,
          builder: (BuildContext context, GoRouterState state) {
            return const LegalDocumentsPage(baseUrl: 'https://www.hggzk.com');
          },
        ),
        GoRoute(
          path: RouteConstants.legalWebView,
          builder: (BuildContext context, GoRouterState state) {
            final extra = state.extra is Map<String, dynamic>
                ? state.extra as Map<String, dynamic>
                : const <String, dynamic>{};
            final title = (extra['title'] as String?) ?? '';
            final url = (extra['url'] as String?) ?? 'https://www.hggzk.com';
            return InAppWebViewPage(title: title, url: url);
          },
        ),
        GoRoute(
          path: RouteConstants.settings,
          builder: (BuildContext context, GoRouterState state) {
            return const SettingsPage();
          },
        ),
        GoRoute(
          path: RouteConstants.languageSettings,
          builder: (BuildContext context, GoRouterState state) {
            return const LanguageSettingsPage();
          },
        ),
        // Support Route
        GoRoute(
          path: RouteConstants.support,
          builder: (BuildContext context, GoRouterState state) {
            return const SupportPage();
          },
        ),
        GoRoute(
          path: RouteConstants.helpAndSupport,
          builder: (BuildContext context, GoRouterState state) {
            return const SupportPage();
          },
        ),
        GoRoute(
          path: RouteConstants.aiAssistant,
          builder: (BuildContext context, GoRouterState state) {
            return const AiChatPage();
          },
        ),
        // Review Routes
        GoRoute(
          path: '/reviews/:propertyId',
          builder: (context, state) {
            final propertyId = state.pathParameters['propertyId']!;
            final propertyName = state.extra as String? ?? '';
            return ReviewsListPage(
              propertyId: propertyId,
              propertyName: propertyName,
            );
          },
        ),
        GoRoute(
          path: RouteConstants.search,
          builder: (BuildContext context, GoRouterState state) {
            final params = state.extra is Map<String, dynamic>
                ? SearchNavigationParams.fromMap(
                    state.extra as Map<String, dynamic>)
                : null;
            return Scaffold(
              body: Center(
                child: SearchPage(initialParams: params),
              ),
            );
          },
        ),
        GoRoute(
          path: RouteConstants.sections,
          builder: (BuildContext context, GoRouterState state) {
            return const AllSectionsPage();
          },
        ),
        GoRoute(
          path: '/section/:id',
          builder: (BuildContext context, GoRouterState state) {
            final id = state.pathParameters['id']!;
            final section =
                state.extra is Section ? state.extra as Section : null;
            return SectionDetailsPage(sectionId: id, section: section);
          },
        ),
        GoRoute(
          path: '/review/write',
          builder: (context, state) {
            final extras = state.extra as Map<String, dynamic>;
            return WriteReviewPage(
              bookingId: extras['bookingId'] as String,
              propertyId: extras['propertyId'] as String,
              propertyName: extras['propertyName'] as String,
            );
          },
        ),
        // Property details route
        GoRoute(
          path: RouteConstants.propertyDetails,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final extras = (state.extra as Map<String, dynamic>?) ?? {};

            DateTime? asDate(dynamic value) {
              if (value is DateTime) return value;
              if (value is String) return DateTime.tryParse(value);
              return null;
            }

            int? asInt(dynamic value) {
              if (value is int) return value;
              if (value is num) return value.toInt();
              if (value is String) return int.tryParse(value);
              return null;
            }

            return PropertyDetailsPage(
              propertyId: id,
              userId: null,
              unitId: extras['unitId'] as String?,
              checkInDate: asDate(extras['checkInDate']),
              checkOutDate: asDate(extras['checkOutDate']),
              adults: asInt(extras['adults']),
              children: asInt(extras['children']),
              guestsCount: asInt(extras['guestsCount']),
              unitTypeId: extras['unitTypeId'] as String?,
            );
          },
        ),
        // Property units route
        GoRoute(
          path: RouteConstants.propertyUnits,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final extras = (state.extra as Map<String, dynamic>?) ?? {};

            DateTime? asDate(dynamic value) {
              if (value is DateTime) return value;
              if (value is String) return DateTime.tryParse(value);
              return null;
            }

            int? asInt(dynamic value) {
              if (value is int) return value;
              if (value is num) return value.toInt();
              if (value is String) return int.tryParse(value);
              return null;
            }

            return PropertyUnitsPage(
              propertyId: id,
              propertyName: extras['propertyName'] as String? ?? '',
              checkInDate: asDate(extras['checkInDate']),
              checkOutDate: asDate(extras['checkOutDate']),
              guestsCount: asInt(extras['guestsCount']) ?? 1,
              units: extras['units'] as List<dynamic>? ?? [],
              propertyServices:
                  extras['propertyServices'] as List<PropertyService>? ?? [],
              propertyPolicies:
                  extras['propertyPolicies'] as List<PropertyPolicy>? ?? [],
            );
          },
        ),
        // Property gallery
        GoRoute(
          path: RouteConstants.propertyGallery,
          builder: (context, state) {
            final extras = (state.extra as Map<String, dynamic>?) ?? {};
            final images = (extras['images'] as List<PropertyImage>?) ??
                const <PropertyImage>[];
            final initialIndex = extras['initialIndex'] as int? ?? 0;
            return PropertyGalleryPage(
              images: images,
              initialIndex: initialIndex,
            );
          },
        ),
        // Property reviews alias
        GoRoute(
          path: RouteConstants.propertyReviews,
          builder: (context, state) {
            final propertyId = state.pathParameters['id']!;
            final propertyName = state.extra as String? ?? '';
            return ReviewsListPage(
              propertyId: propertyId,
              propertyName: propertyName,
            );
          },
        ),
        // Booking flow
        GoRoute(
          path: RouteConstants.bookingForm,
          builder: (context, state) {
            final extras = (state.extra as Map<String, dynamic>?) ?? {};
            return BookingFormPage(
              propertyId: (extras['propertyId'] as String?) ?? '',
              propertyName: (extras['propertyName'] as String?) ?? '',
              unitId: extras['unitId'] as String?,
              pricePerNight: (extras['pricePerNight'] as num?)?.toDouble(),
              currency: extras['currency'] as String?,
              unitName: extras['unitName'] as String?,
              unitImages: (extras['unitImages'] as List?)
                  ?.map((e) => e.toString())
                  .toList(),
              unitTypeName: extras['unitTypeName'] as String?,
              adultsCapacity: extras['adultsCapacity'] as int?,
              childrenCapacity: extras['childrenCapacity'] as int?,
              customFeatures: extras['customFeatures'] as String?,
              initialCheckIn: extras['checkInDate'] as DateTime?,
              initialCheckOut: extras['checkOutDate'] as DateTime?,
              initialAdults: extras['adults'] as int?,
              initialChildren: extras['children'] as int?,
              propertyServices: extras['services'] as List<PropertyService>?,
              propertyPolicies: extras['policies'] as List<PropertyPolicy>?,
              isEditMode: extras['isEditMode'] as bool? ?? false,
              bookingId: extras['bookingId'] as String?,
              initialSelectedServices:
                  (extras['initialSelectedServices'] as List?)
                      ?.map((e) => Map<String, dynamic>.from(e as Map))
                      .toList(),
            );
          },
        ),
        GoRoute(
          path: RouteConstants.bookingSummary,
          builder: (context, state) {
            final bookingData = (state.extra as Map<String, dynamic>?) ?? {};
            return BookingSummaryPage(bookingData: bookingData);
          },
        ),
        GoRoute(
          path: RouteConstants.bookingPayment,
          builder: (context, state) {
            final bookingData = (state.extra as Map<String, dynamic>?) ?? {};
            return BookingPaymentPage(bookingData: bookingData);
          },
        ),
        GoRoute(
          path: RouteConstants.bookingConfirmation,
          builder: (context, state) {
            return BookingConfirmationPage(
              booking: state.extra as dynamic,
            );
          },
        ),
        // إضافة مسار تفاصيل الحجز
        GoRoute(
          path: RouteConstants.bookingDetails,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return BookingDetailsPage(bookingId: id);
          },
        ),

        // قائمة المحادثات
        GoRoute(
          path: RouteConstants.conversations,
          builder: (context, state) {
            return const ConversationsPage();
          },
        ),

        // محادثة جديدة
        GoRoute(
          path: RouteConstants.newConversation,
          builder: (context, state) {
            return const NewConversationPage();
          },
        ),

        // صفحة المحادثة
        GoRoute(
          path: '/chat/:conversationId',
          builder: (context, state) {
            final conversationId = state.pathParameters['conversationId']!;
            final conversation = state.extra as Conversation?;

            if (conversation != null) {
              return ChatPage(conversation: conversation);
            }

            // إذا لم تمرر المحادثة كـ extra، قم بتحميلها
            return ConversationLoader(conversationId: conversationId);
          },
        ),
      ],
    );
  }

  static const List<String> _protectedPaths = <String>[
    RouteConstants.profile,
    '/review',
    '/reviews',
    '/booking',
    '/payment',
    '/chat',
    RouteConstants.aiAssistant,
  ];
}

/// يحوّل stream الحالة إلى `Listenable` حتى يستطيع GoRouter إعادة
/// تقييم شروط التوجيه عندما تتغير حالة المصادقة.
/// Converts a stream into a `Listenable` so `GoRouter` can re-run
/// redirects whenever auth state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  /// يربط stream المصدر بمستمع يحرّك إعادة التقييم تلقائيًا.
  /// Connects the source stream to a listener that triggers redirect
  /// reevaluation automatically.
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  /// يحتفظ بالاشتراك الفعال حتى يمكن إلغاؤه عند التخلص من الراوتر.
  /// Holds the active subscription so it can be cancelled on dispose.
  late final StreamSubscription<dynamic> _subscription;

  /// يلغي الاشتراك المسجّل حتى لا يبقى مستمع عالق بعد مغادرة الراوتر.
  /// Cancels the subscription so no listener survives past router
  /// disposal.
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Minimal JWT exp checker used by router redirect to proactively logout when expired
/// يتحقق من انتهاء صلاحية JWT داخل منطق الراوتر قبل محاولة فتح
/// مسار محمي.
/// Checks whether a JWT is expired before the router lets protected
/// routes proceed.
bool _isJwtExpiredRouter(String jwt, {int skewSeconds = 0}) {
  try {
    final parts = jwt.split('.');
    if (parts.length != 3) return false;
    final payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
    var normalized = payload;
    while (normalized.length % 4 != 0) {
      normalized += '=';
    }
    final decoded = utf8.decode(base64Url.decode(normalized));
    final map = jsonDecode(decoded) as Map<String, dynamic>;
    final exp = map['exp'];
    if (exp is int) {
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now()
          .isAfter(expiresAt.subtract(Duration(seconds: skewSeconds)));
    }
    return false;
  } catch (_) {
    return false;
  }
}
