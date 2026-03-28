// lib/features/admin_audit_logs/domain/usecases/get_audit_logs_usecase.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/audit_log.dart';
import '../repositories/audit_logs_repository.dart';

/// يجلب السجل العام للتدقيق مع كل الفلاتر المتاحة في الطبقة العليا.
/// Loads the general audit log with all filters available at the higher layer.
class GetAuditLogsUseCase
    implements UseCase<PaginatedResult<AuditLog>, AuditLogsQuery> {
  /// المستودع المسؤول عن جلب السجلات العامة.
  /// The repository responsible for fetching the general logs.
  final AuditLogsRepository repository;

  /// Creates the general audit-log use case with the backing repository.
  GetAuditLogsUseCase({required this.repository});

  @override

  /// يمرر استعلام التدقيق العام إلى المستودع ثم يعيد صفحة النتائج.
  /// Forwards the general audit query to the repository and returns the
  /// result page.
  Future<Either<Failure, PaginatedResult<AuditLog>>> call(
      AuditLogsQuery params) async {
    return await repository.getAuditLogs(params);
  }
}
