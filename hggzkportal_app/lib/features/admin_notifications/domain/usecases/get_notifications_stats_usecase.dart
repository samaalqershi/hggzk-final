import 'package:dartz/dartz.dart';
import 'package:hggzkportal/features/admin_notifications/domain/repositories/admin_notifications_repository.dart';
import '../../../../../core/error/failures.dart';
class GetAdminNotificationsStatsUseCase {
  /// العربية: يخزن القيمة `repository`.
  final AdminNotificationsRepository repository;
  GetAdminNotificationsStatsUseCase(this.repository);
  Future<Either<Failure, Map<String, int>>> call(
          {DateTime? startDate, DateTime? endDate}) =>
      repository.getStats(startDate: startDate, endDate: endDate);
}
