import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Presents user-facing snack bars from anywhere in the app, while keeping
/// duplicate messages from stacking on top of each other.
/// يعرض رسائل SnackBar من أي مكان في التطبيق مع منع تكدس الرسائل المكررة فوق
/// بعضها.
class MessageService {
  /// Hidden constructor so the service stays static-only.
  /// مُنشئ مخفي كي تبقى الخدمة ساكنة فقط.
  MessageService._();

  /// Global messenger key used to display snack bars outside the current page.
  /// مفتاح الرسائل العام المستخدم لإظهار الـ SnackBar خارج الصفحة الحالية.
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static const Duration _defaultDuration = Duration(seconds: 4);

  /// Last message shown so repeated events can be throttled.
  /// آخر رسالة عُرضت حتى يمكن تقليل التكرار السريع.
  static String? _lastMessage;

  /// Timestamp of the last shown message for duplicate suppression.
  /// وقت آخر عرض للرسالة لاستخدامه في منع التكرار.
  static DateTime? _lastShownAt;

  /// Suppresses near-duplicate messages that arrive within a very small time
  /// window.
  /// يمنع الرسائل شبه المكررة التي تصل خلال نافذة زمنية قصيرة جدًا.
  static bool _shouldSuppress(String message) {
    final now = DateTime.now();
    if (_lastMessage == message && _lastShownAt != null) {
      final since = now.difference(_lastShownAt!);
      if (since.inMilliseconds < 1200) return true; // throttle duplicates
    }
    _lastMessage = message;
    _lastShownAt = now;
    return false;
  }

  /// Builds and shows a SnackBar with adaptive duration so long messages stay
  /// readable without manually tuning every caller.
  /// يبني SnackBar ويعرضه بزمن يتكيف مع طول الرسالة حتى تبقى مقروءة دون أن
  /// يضبط كل مستدعي المدة يدويًا.
  static void _showSnackBar(
    String message, {
    Color? backgroundColor,
    SnackBarAction? action,
    Duration? duration,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    EdgeInsetsGeometry margin = const EdgeInsets.all(12),
  }) {
    debugPrint('📱 [MessageService._showSnackBar] Called with: "$message"');

    if (message.trim().isEmpty) {
      debugPrint(
          '⚠️ [MessageService._showSnackBar] Message is empty, returning');
      return;
    }

    if (_shouldSuppress(message)) {
      debugPrint(
          '⚠️ [MessageService._showSnackBar] Message suppressed (duplicate)');
      return;
    }

    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) {
      debugPrint(
          'MessageService: ScaffoldMessenger not ready. Message: $message');
      return;
    }

    // Calculate duration based on message length
    Duration calculatedDuration = duration ?? _defaultDuration;
    if (duration == null) {
      // For longer messages, show for longer
      final lines = message.split('\n').length;
      final charCount = message.length;

      if (lines > 1 || charCount > 80) {
        final seconds = 4 + (lines * 2) + (charCount ~/ 100);
        final clampedSeconds = math.max(4, math.min(12, seconds));
        calculatedDuration = Duration(seconds: clampedSeconds);
      }
    }

    messenger.clearSnackBars();

    debugPrint(
        '✅ [MessageService._showSnackBar] Showing SnackBar with duration: ${calculatedDuration.inSeconds}s');

    messenger.showSnackBar(
      SnackBar(
        content: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Text(
            message,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: behavior,
        margin: margin,
        duration: calculatedDuration,
        action: action,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );

    debugPrint('✅ [MessageService._showSnackBar] SnackBar shown successfully');
  }

  /// Shows an error-colored message to signal something that needs attention.
  /// يعرض رسالة بلون خطأ للإشارة إلى حالة تحتاج انتباهًا.
  static void showError(String message) {
    debugPrint('🔴 [MessageService.showError] Called with message: "$message"');
    _showSnackBar(
      message,
      backgroundColor: const Color(0xFFDC2626),
    );
  }

  /// Shows a success-colored message after the user completes an action.
  /// يعرض رسالة نجاح بعد إتمام المستخدم لعملية ما.
  static void showSuccess(String message) {
    _showSnackBar(
      message,
      backgroundColor: const Color(0xFF059669),
    );
  }

  /// Shows a neutral informational message for non-critical feedback.
  /// يعرض رسالة معلومات محايدة للتغذية الراجعة غير الحرجة.
  static void showInfo(String message) {
    _showSnackBar(
      message,
      backgroundColor: const Color(0xFF0284C7),
    );
  }

  /// Shows a warning-colored message when the user should slow down or review
  /// something before continuing.
  /// يعرض رسالة تحذير عندما يحتاج المستخدم إلى التمهل أو المراجعة قبل
  /// المتابعة.
  static void showWarning(String message) {
    _showSnackBar(
      message,
      backgroundColor: const Color(0xFFF59E0B),
    );
  }
}
