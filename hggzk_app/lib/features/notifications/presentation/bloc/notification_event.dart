import 'package:equatable/equatable.dart';

/// يمثل جميع الأحداث التي يمكن أن ترسلها واجهات الإشعارات إلى الـ bloc.
/// Represents every event the notifications UI can send to the bloc.
abstract class NotificationEvent extends Equatable {
  /// ينشئ حدثًا مجردًا لميزة الإشعارات.
  /// Creates an abstract event for the notifications feature.
  const NotificationEvent();
  /// يعيد الحقول التي تدخل في مقارنة الأحداث.
  /// Returns the fields that participate in event equality.
  @override
  List<Object?> get props => [];
}

/// يطلب تحميل قائمة الإشعارات مع معايير الصفحة الحالية.
/// Requests loading the notifications list with the current paging criteria.
class LoadNotificationsEvent extends NotificationEvent {
  /// رقم الصفحة المطلوب تحميلها.
  /// Page number that should be loaded.
  final int page;
  /// عدد العناصر المطلوب في الصفحة الواحدة.
  /// Number of items requested per page.
  final int limit;
  /// نوع الإشعار المستخدم كتصفية اختيارية.
  /// Optional notification type used as a filter.
  final String? type;
  /// يحدد ما إذا كان الطلب يمثل تحديثًا كاملًا للقائمة.
  /// Indicates whether the request should refresh the list from scratch.
  final bool refresh;
  /// ينشئ حدث تحميل الإشعارات مع معايير الصفحة والتصفية.
  /// Creates the load-notifications event with paging and filter parameters.
  const LoadNotificationsEvent({
    this.page = 1,
    this.limit = 20,
    this.type,
    this.refresh = false,
  });
  /// يعيد الحقول المستخدمة في مقارنة طلبات التحميل.
  /// Returns the fields used to compare load requests.
  @override
  List<Object?> get props => [page, limit, type, refresh];
}

/// يطلب تعليم إشعار واحد على أنه مقروء.
/// Requests marking one notification as read.
class MarkNotificationAsReadEvent extends NotificationEvent {
  /// معرّف الإشعار المراد تحديث حالته.
  /// Identifier of the notification whose state should change.
  final String notificationId;
  /// ينشئ حدث تعليم الإشعار كمقروء.
  /// Creates the mark-as-read event for one notification.
  const MarkNotificationAsReadEvent({required this.notificationId});
  /// يعيد الحقول المستخدمة في مقارنة هذا الحدث.
  /// Returns the fields used when comparing this event.
  @override
  List<Object> get props => [notificationId];
}

/// يطلب تعليم جميع الإشعارات الحالية على أنها مقروءة.
/// Requests marking all current notifications as read.
class MarkAllNotificationsAsReadEvent extends NotificationEvent {
  /// ينشئ حدث تعليم جميع الإشعارات كمقروءة.
  /// Creates the mark-all-as-read event.
  const MarkAllNotificationsAsReadEvent();
}

/// يطلب إخفاء إشعار واحد من القائمة الحالية.
/// Requests dismissing one notification from the current list.
class DismissNotificationEvent extends NotificationEvent {
  /// معرّف الإشعار المراد إخفاؤه.
  /// Identifier of the notification that should be dismissed.
  final String notificationId;
  /// ينشئ حدث إخفاء إشعار معين.
  /// Creates the dismiss-notification event.
  const DismissNotificationEvent({required this.notificationId});
  /// يعيد الحقول المستخدمة في مقارنة هذا الحدث.
  /// Returns the fields used to compare this event.
  @override
  List<Object> get props => [notificationId];
}

/// يطلب تحميل إعدادات الإشعارات الحالية.
/// Requests loading the current notification settings.
class LoadNotificationSettingsEvent extends NotificationEvent {
  /// ينشئ حدث تحميل إعدادات الإشعارات.
  /// Creates the load-notification-settings event.
  const LoadNotificationSettingsEvent();
}

/// يطلب حفظ مجموعة جديدة من تفضيلات الإشعارات.
/// Requests saving a new set of notification preferences.
class UpdateNotificationSettingsEvent extends NotificationEvent {
  /// خريطة التفضيلات الجديدة المطلوب حفظها.
  /// Map of the new preferences that should be stored.
  final Map<String, bool> settings;
  /// ينشئ حدث تحديث إعدادات الإشعارات.
  /// Creates the update-notification-settings event.
  const UpdateNotificationSettingsEvent({required this.settings});
  /// يعيد الحقول المستخدمة في مقارنة هذا الحدث.
  /// Returns the fields used to compare this event.
  @override
  List<Object> get props => [settings];
}

/// يطلب تحميل العدد الحالي للإشعارات غير المقروءة.
/// Requests loading the current unread notifications count.
class LoadUnreadCountEvent extends NotificationEvent {
  /// ينشئ حدث تحميل العدد غير المقروء.
  /// Creates the load-unread-count event.
  const LoadUnreadCountEvent();
}
