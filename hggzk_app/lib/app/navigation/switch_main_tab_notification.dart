import 'package:flutter/widgets.dart';

/// Requests the main shell to switch tabs.
/// يطلب من الغلاف الرئيسي الانتقال إلى تبويب آخر.
class SwitchMainTabNotification extends Notification {
  /// Target tab index.
  /// فهرس التبويب المطلوب.
  final int index;

  /// Creates a tab switch notification.
  /// ينشئ إشعارًا لتبديل التبويب.
  const SwitchMainTabNotification(this.index);
}
