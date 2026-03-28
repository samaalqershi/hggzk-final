import 'package:flutter/foundation.dart';

/// واجهة صغيرة لتوحيد كيفية عرض الرسائل المؤقتة أو تسجيلها.
/// Small helper that centralizes how transient messages are surfaced or logged.
class MessageService {
  /// يسجل رسالة الخطأ في وضع التطوير بدل إنشاء اعتماد على UI.
  /// Logs error messages in development without coupling the service to widgets.
  static void showError(String message) {
    debugPrint('Error: $message');
  }

  /// يسجل رسالة النجاح بنفس الأسلوب البسيط والموحد.
  /// Logs success messages using the same lightweight convention.
  static void showSuccess(String message) {
    debugPrint('Success: $message');
  }
}
