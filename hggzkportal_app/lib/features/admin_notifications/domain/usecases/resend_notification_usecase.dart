import 'package:dartz/dartz.dart';
import 'package:hggzkportal/features/admin_notifications/domain/repositories/admin_notifications_repository.dart';
import '../../../../../core/error/failures.dart';
class ResendAdminNotificationUseCase {
  /// العربية: يخزن القيمة `repository`.
  final AdminNotificationsRepository repository;
  ResendAdminNotificationUseCase(this.repository);
  Future<Either<Failure, bool>> call(String notificationId) =>
      repository.resend(notificationId);
}
