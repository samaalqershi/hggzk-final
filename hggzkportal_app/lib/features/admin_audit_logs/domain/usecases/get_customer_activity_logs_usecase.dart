// lib/features/admin_audit_logs/domain/usecases/get_customer_activity_logs_usecase.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/audit_log.dart';
import '../repositories/audit_logs_repository.dart';

/// يجلب نشاط العملاء في صفحات حتى تعرضه شاشة المراقبة أو التحليل.
/// Loads customer activity in pages so monitoring or analytics screens can
/// present it efficiently.
class GetCustomerActivityLogsUseCase
    implements UseCase<PaginatedResult<AuditLog>, CustomerActivityLogsQuery> {
  /// المستودع الذي يزوّد هذا النوع من السجلات.
  /// The repository that supplies this log category.
  final AuditLogsRepository repository;

  /// Creates the customer-activity use case with the audit repository.
  GetCustomerActivityLogsUseCase({required this.repository});

  @override

  /// يمرر معايير الترقيم الخاصة بالعملاء ثم يعيد الصفحة المطابقة.
  /// Passes the customer-specific paging criteria and returns the matching
  /// page.
  Future<Either<Failure, PaginatedResult<AuditLog>>> call(
      CustomerActivityLogsQuery params) async {
    return await repository.getCustomerActivityLogs(params);
  }
}
