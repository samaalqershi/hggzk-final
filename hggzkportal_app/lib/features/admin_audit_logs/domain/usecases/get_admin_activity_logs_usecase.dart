// lib/features/admin_audit_logs/domain/usecases/get_admin_activity_logs_usecase.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/audit_log.dart';
import '../repositories/audit_logs_repository.dart';

/// يجلب صفحة من سجلات نشاط المشرفين حتى تعرضها لوحة الإدارة بشكل
/// مخصص لهذا النوع من الحركات.
/// Loads a page of administrator activity logs so the admin dashboard can
/// present that specific activity stream.
class GetAdminActivityLogsUseCase
    implements UseCase<PaginatedResult<AuditLog>, AdminActivityLogsQuery> {
  /// المستودع الذي يوفّر بيانات نشاط المشرفين.
  /// The repository that provides administrator activity data.
  final AuditLogsRepository repository;

  /// Creates the admin-activity use case with the audit repository.
  GetAdminActivityLogsUseCase({required this.repository});

  @override

  /// يمرر معايير الترقيم إلى المستودع ثم يعيد الصفحة المناسبة من
  /// السجلات.
  /// Passes the paging criteria to the repository and returns the matching
  /// log page.
  Future<Either<Failure, PaginatedResult<AuditLog>>> call(
      AdminActivityLogsQuery params) async {
    return await repository.getAdminActivityLogs(params);
  }
}
