// lib/features/admin_audit_logs/domain/usecases/get_property_activity_logs_usecase.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/audit_log.dart';
import '../repositories/audit_logs_repository.dart';

/// يجلب نشاط عقار واحد مع الترقيم حتى تعرضه شاشة التفاصيل أو المراقبة.
/// Loads the activity for one property with paging so detail or monitoring
/// screens can present it.
class GetPropertyActivityLogsUseCase
    implements UseCase<PaginatedResult<AuditLog>, PropertyActivityLogsQuery> {
  /// المستودع الذي يوفّر سجلات العقار المحدد.
  /// The repository that provides logs for the selected property.
  final AuditLogsRepository repository;

  /// Creates the property-activity use case with the audit repository.
  GetPropertyActivityLogsUseCase({required this.repository});

  @override

  /// يمرر معرّف العقار ومعايير الصفحة إلى المستودع ثم يعيد النتيجة.
  /// Passes the property id and paging parameters to the repository and
  /// returns the resulting page.
  Future<Either<Failure, PaginatedResult<AuditLog>>> call(
      PropertyActivityLogsQuery params) async {
    return await repository.getPropertyActivityLogs(params);
  }
}
