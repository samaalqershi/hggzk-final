import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// وصول مركزي إلى `NavigatorState` وعمليات التنقل خارج الشاشات نفسها.
/// Central access point for navigation from non-widget or shared contexts.
class NavigationService {
  /// مفتاح التنقل الأعلى الذي تستخدمه الشاشات والـ services المشتركة.
  /// Primary navigator key used by widgets and shared services.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// مفتاح الجذر الذي يسمح بتوجيه المستخدم من أي سياق داخل التطبيق.
  /// Root navigator key that can drive navigation from anywhere in the app.
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  /// يدفع مسارًا جديدًا على مكدس التنقل الحالي.
  /// Pushes a named route onto the current navigation stack.
  static Future<T?>? navigateTo<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState
        ?.pushNamed<T>(routeName, arguments: arguments);
  }

  /// يرسل المستخدم إلى صفحة الدخول مع تنظيف المسار السابق عند الحاجة.
  /// Sends the user to the login screen and clears the stack when required.
  static void goToLogin() {
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      context.go('/login');
      return;
    }
    navigatorKey.currentState
        ?.pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
