// lib/features/admin_audit_logs/domain/usecases/export_audit_logs_usecase.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/audit_log.dart';
import '../repositories/audit_logs_repository.dart';

/// يجهّز تدفق تصدير سجلات التدقيق الكاملة عندما يحتاج المشرف إلى ملف أو
/// قائمة خارجية.
/// Prepares the full audit-log export flow when an admin needs a file or an
/// external list.
class ExportAuditLogsUseCase
    implements UseCase<List<AuditLog>, AuditLogsQuery> {
  /// المستودع الذي ينفذ عملية التصدير الفعلية.
  /// The repository that performs the actual export.
  final AuditLogsRepository repository;

  /// Creates the export use case with the backing repository.
  ExportAuditLogsUseCase({required this.repository});

  @override

  /// يمرر استعلام التصدير إلى المستودع ويعيد جميع السجلات المطابقة.
  /// Passes the export query to the repository and returns every matching log.
  Future<Either<Failure, List<AuditLog>>> call(AuditLogsQuery params) async {
    return await repository.exportAuditLogs(params);
  }
}
