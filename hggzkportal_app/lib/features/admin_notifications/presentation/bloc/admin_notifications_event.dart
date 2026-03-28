abstract class AdminNotificationsEvent {
  /// العربية: ينشئ مثيلًا جديدًا من `AdminNotificationsEvent`.
  const AdminNotificationsEvent();
}
class LoadSystemNotificationsEvent extends AdminNotificationsEvent {
  /// العربية: يخزن القيمة `page`.
  final int page;
  final int pageSize;
  final String? type;
  final String? status;
  const LoadSystemNotificationsEvent(
      {this.page = 1, this.pageSize = 20, this.type, this.status});
}
class LoadUserNotificationsEvent extends AdminNotificationsEvent {
  /// العربية: يخزن القيمة `userId`.
  final String userId;
  final int page;
  final int pageSize;
  final bool? isRead;
  const LoadUserNotificationsEvent(
      {required this.userId, this.page = 1, this.pageSize = 20, this.isRead});
}
class CreateAdminNotificationEvent extends AdminNotificationsEvent {
  /// العربية: يخزن القيمة `type`.
  final String type;
  final String title;
  final String message;
  final String recipientId;
  const CreateAdminNotificationEvent(
      {required this.type,
      required this.title,
      required this.message,
      required this.recipientId});
}
class BroadcastAdminNotificationEvent extends AdminNotificationsEvent {
  /// العربية: يخزن القيمة `type`.
  final String type;
  final String title;
  final String message;
  final bool targetAll;
  final List<String>? userIds;
  final List<String>? roles;
  final DateTime? scheduledFor;
  final String? channelId;
  const BroadcastAdminNotificationEvent({
    required this.type,
    required this.title,
    required this.message,
    this.targetAll = false,
    this.userIds,
    this.roles,
    this.scheduledFor,
    this.channelId,
  });
}
class DeleteAdminNotificationEvent extends AdminNotificationsEvent {
  /// العربية: يخزن القيمة `notificationId`.
  final String notificationId;
  const DeleteAdminNotificationEvent(this.notificationId);
}
class ResendAdminNotificationEvent extends AdminNotificationsEvent {
  /// العربية: يخزن القيمة `notificationId`.
  final String notificationId;
  const ResendAdminNotificationEvent(this.notificationId);
}
class LoadAdminNotificationsStatsEvent extends AdminNotificationsEvent {
  /// العربية: ينشئ مثيلًا جديدًا من `LoadAdminNotificationsStatsEvent`.
  const LoadAdminNotificationsStatsEvent();
}
