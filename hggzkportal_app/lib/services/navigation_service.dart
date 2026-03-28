import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Holds the root navigator key used by services that need to navigate or show
/// dialogs without a BuildContext from the current widget tree.
/// يحتفظ بمفتاح الـ navigator الجذر الذي تحتاجه الخدمات عندما تريد التنقل أو
/// إظهار الحوارات من خارج شجرة الودجت الحالية.
class NavigationService {
  /// Prevents direct instantiation because this service is used as a pure
  /// static navigation helper.
  /// يمنع الإنشاء المباشر لأن هذه الخدمة تُستخدم كأداة تنقل ساكنة فقط.
  NavigationService._();

  /// Root navigator used for app-wide `go`, `push`, and modal interactions.
  /// مفتاح الـ navigator الجذر المستخدم للتنقل العام والحوار من مستوى التطبيق.
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  /// Replaces the current route stack with the login screen when the session
  /// must be restarted.
  /// يستبدل المسار الحالي بشاشة الدخول عندما تحتاج الجلسة إلى إعادة البدء.
  static void goToLogin() {
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      context.go('/login');
    }
  }

  /// Jumps to the main portal shell after authentication or onboarding has
  /// completed.
  /// ينتقل مباشرة إلى الواجهة الرئيسية بعد اكتمال الدخول أو التهيئة.
  static void goToMain() {
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      context.go('/main');
    }
  }

  /// Shows a dialog from the root navigator so it can outlive nested widget
  /// contexts and still appear above the entire app.
  /// يعرض حوارًا من الـ navigator الجذر حتى يظل ظاهرًا فوق التطبيق كله حتى لو
  /// تغيرت الشجرة الداخلية.
  static Future<T?> showRootDialog<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    final overlay = rootNavigatorKey.currentState?.overlay;
    if (overlay == null) {
      return Future<T?>.value(null);
    }

    return showDialog<T>(
      context: overlay.context,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }
}
