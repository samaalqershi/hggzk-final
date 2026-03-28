// lib/features/admin_audit_logs/domain/repositories/audit_logs_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../entities/audit_log.dart';

/// يحدد حدود الوصول لبيانات سجل التدقيق داخل طبقة المجال.
/// Defines the domain boundary for accessing audit-log data.
abstract class AuditLogsRepository {
  /// يجلب السجلات العامة مع الفلاتر والصفحات المحددة في الاستعلام.
  /// Fetches the general logs using the filters and paging defined in the
  /// query.
  Future<Either<Failure, PaginatedResult<AuditLog>>> getAuditLogs(
      AuditLogsQuery query);

  /// يجلب السجلات المتعلقة بنشاط العملاء فقط.
  /// Fetches logs related to customer activity only.
  Future<Either<Failure, PaginatedResult<AuditLog>>> getCustomerActivityLogs(
      CustomerActivityLogsQuery query);

  /// يجلب السجلات المتعلقة بنشاط العقار المحدد.
  /// Fetches logs related to the specified property.
  Future<Either<Failure, PaginatedResult<AuditLog>>> getPropertyActivityLogs(
      PropertyActivityLogsQuery query);

  /// يجلب السجلات المتعلقة بنشاط المشرفين داخل النظام.
  /// Fetches logs related to administrator activity in the system.
  Future<Either<Failure, PaginatedResult<AuditLog>>> getAdminActivityLogs(
      AdminActivityLogsQuery query);

  /// يصدّر السجلات المطابقة للاستعلام في شكل قائمة كاملة غير مقسمة.
  /// Exports the logs that match the query as a complete, non-paginated list.
  Future<Either<Failure, List<AuditLog>>> exportAuditLogs(AuditLogsQuery query);

  /// يجلب تفاصيل سجل واحد بالمعرف حتى تعرضها شاشة التفاصيل.
  /// Fetches a single log by id so a detail screen can render it.
  Future<Either<Failure, AuditLog>> getAuditLogDetails(String auditLogId);
}
