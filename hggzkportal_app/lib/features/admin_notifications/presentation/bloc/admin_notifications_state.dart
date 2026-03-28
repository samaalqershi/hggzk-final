import '../../domain/entities/admin_notification.dart';
abstract class AdminNotificationsState {
  /// العربية: يخزن القيمة `stats`.
  final Map<String, int>? stats;
  final String? statsError;
  const AdminNotificationsState({this.stats, this.statsError});
}
class AdminNotificationsInitial extends AdminNotificationsState {
  /// العربية: ينشئ مثيلًا جديدًا من `AdminNotificationsInitial`.
  const AdminNotificationsInitial({super.stats, super.statsError});
}
class AdminNotificationsLoading extends AdminNotificationsState {
  /// العربية: ينشئ مثيلًا جديدًا من `AdminNotificationsLoading`.
  const AdminNotificationsLoading({super.stats, super.statsError});
}
class AdminNotificationsSubmitting extends AdminNotificationsState {
  final String action; // create, broadcast, resend, delete
  const AdminNotificationsSubmitting(this.action,
      {super.stats, super.statsError});
}
class AdminSystemNotificationsLoaded extends AdminNotificationsState {
  /// العربية: يخزن القيمة `items`.
  final List<AdminNotificationEntity> items;
  final int totalCount;
  const AdminSystemNotificationsLoaded({
    required this.items,
    required this.totalCount,
    super.stats,
    super.statsError,
  });
}
class AdminUserNotificationsLoaded extends AdminNotificationsState {
  /// العربية: يخزن القيمة `items`.
  final List<AdminNotificationEntity> items;
  final int totalCount;
  const AdminUserNotificationsLoaded({
    required this.items,
    required this.totalCount,
    super.stats,
    super.statsError,
  });
}
class AdminNotificationsSuccess extends AdminNotificationsState {
  /// العربية: يخزن القيمة `message`.
  final String message;
  const AdminNotificationsSuccess(
    this.message, {
    super.stats,
    super.statsError,
  });
}
class AdminNotificationsError extends AdminNotificationsState {
  /// العربية: يخزن القيمة `message`.
  final String message;
  const AdminNotificationsError(
    this.message, {
    super.stats,
    super.statsError,
  });
}
