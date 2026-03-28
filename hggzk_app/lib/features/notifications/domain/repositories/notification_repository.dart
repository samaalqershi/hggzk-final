import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../entities/notification.dart';

/// يحدد العقد الذي تعتمد عليه طبقة المجال لإدارة الإشعارات وحالتها
/// وتفضيلاتها.
/// Defines the contract the domain layer uses to manage notifications, their
/// state, and related preferences.
abstract class NotificationRepository {
  /// يجلب صفحة من الإشعارات مع دعم التصفية.
  /// Fetches one page of notifications with optional filtering.
  Future<Either<Failure, PaginatedResult<NotificationEntity>>>
      getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
  });

  /// يعلّم إشعارًا معينًا على أنه مقروء.
  /// Marks a specific notification as read.
  Future<Either<Failure, void>> markAsRead(String notificationId);

  /// يعلّم جميع الإشعارات على أنها مقروءة.
  /// Marks all notifications as read.
  Future<Either<Failure, void>> markAllAsRead();

  /// يخفي إشعارًا من القائمة الحالية.
  /// Dismisses a notification from the current list.
  Future<Either<Failure, void>> dismissNotification(String notificationId);

  /// يجلب إعدادات الإشعارات الحالية.
  /// Fetches the current notification settings.
  Future<Either<Failure, Map<String, bool>>> getNotificationSettings();

  /// يحدّث إعدادات الإشعارات.
  /// Updates notification settings.
  Future<Either<Failure, void>> updateNotificationSettings(
      Map<String, bool> settings);

  /// يعيد عدد الإشعارات غير المقروءة.
  /// Returns the unread notification count.
  Future<Either<Failure, int>> getUnreadCount();
}
