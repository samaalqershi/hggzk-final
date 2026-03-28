// lib/features/admin_audit_logs/presentation/bloc/audit_logs_event.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/audit_log.dart';

/// Base type for all audit-log commands sent into the bloc.
/// النوع الأساسي لكل أوامر سجلات التدقيق المرسلة إلى البلوك.
abstract class AuditLogsEvent extends Equatable {
  /// Creates the shared event base for the audit-log feature.
  /// ينشئ الأساس المشترك للأحداث الخاصة بميزة سجلات التدقيق.
  const AuditLogsEvent();

  @override

  /// Comparison keys shared by every audit-log event.
  /// مفاتيح المقارنة المشتركة بين كل أحداث سجلات التدقيق.
  List<Object?> get props => [];
}

/// Loads audit logs using a complete query object.
/// يحمّل سجلات التدقيق باستخدام كائن استعلام كامل.
class LoadAuditLogsEvent extends AuditLogsEvent {
  /// The query used to fetch the current audit-log page.
  /// الاستعلام المستخدم لجلب صفحة سجلات التدقيق الحالية.
  final AuditLogsQuery query;

  /// Creates a load request for a specific audit-log query.
  /// ينشئ طلب تحميل لاستعلام محدد لسجلات التدقيق.
  const LoadAuditLogsEvent({required this.query});

  @override

  /// Comparison key for the active query.
  /// مفتاح المقارنة للاستعلام النشط.
  List<Object?> get props => [query];
}

/// Requests the next page of audit logs after the current list.
/// يطلب الصفحة التالية من سجلات التدقيق بعد القائمة الحالية.
class LoadMoreAuditLogsEvent extends AuditLogsEvent {
  /// Creates a load-more request with no payload.
  /// ينشئ طلب تحميل المزيد من دون بيانات إضافية.
  const LoadMoreAuditLogsEvent();

  @override

  /// No payload is needed because the bloc already knows the active query.
  /// لا توجد حمولة لأن البلوك يعرف الاستعلام النشط أصلًا.
  List<Object?> get props => [];
}

/// Replays the most recent audit-log query from the bloc state.
/// يعيد تنفيذ آخر استعلام لسجلات التدقيق من حالة البلوك.
class RefreshAuditLogsEvent extends AuditLogsEvent {
  /// Creates a refresh request with no extra payload.
  /// ينشئ طلب تحديث من دون بيانات إضافية.
  const RefreshAuditLogsEvent();

  @override

  /// No payload is needed because refresh uses the cached query.
  /// لا توجد حمولة لأن التحديث يستخدم الاستعلام المخزن.
  List<Object?> get props => [];
}

/// Applies filter criteria before loading a new audit-log query.
/// يطبّق معايير التصفية قبل تحميل استعلام جديد لسجلات التدقيق.
class FilterAuditLogsEvent extends AuditLogsEvent {
  /// Limits results to one user when provided.
  /// يقصر النتائج على مستخدم واحد عند توفره.
  final String? userId;

  /// Filters logs created on or after this date.
  /// يفلتر السجلات المنشأة في هذا التاريخ أو بعده.
  final DateTime? from;

  /// Filters logs created on or before this date.
  /// يفلتر السجلات المنشأة في هذا التاريخ أو قبله.
  final DateTime? to;

  /// Optional operation name such as create, update, delete, or export.
  /// اسم عملية اختياري مثل create أو update أو delete أو export.
  final String? operationType;

  /// Free-text search term used to narrow the log list.
  /// نص بحث حر يُستخدم لتضييق قائمة السجلات.
  final String? searchTerm;

  /// Creates a filter request with optional user, date, operation, and search criteria.
  /// ينشئ طلب تصفية مع معايير اختيارية للمستخدم والتاريخ ونوع العملية والبحث.
  const FilterAuditLogsEvent({
    this.userId,
    this.from,
    this.to,
    this.operationType,
    this.searchTerm,
  });

  @override

  /// Comparison keys for the active filter set.
  /// مفاتيح المقارنة لمجموعة الفلاتر النشطة.
  List<Object?> get props => [userId, from, to, operationType, searchTerm];
}

/// Exports the current audit-log result set using the provided query.
/// يصدّر مجموعة نتائج سجلات التدقيق الحالية باستخدام الاستعلام المعطى.
class ExportAuditLogsEvent extends AuditLogsEvent {
  /// The query that defines which logs should be exported.
  /// الاستعلام الذي يحدد السجلات المطلوب تصديرها.
  final AuditLogsQuery query;

  /// Creates an export request for the supplied query.
  /// ينشئ طلب تصدير للاستعلام المعطى.
  const ExportAuditLogsEvent({required this.query});

  @override

  /// Comparison key for the export query.
  /// مفتاح المقارنة لاستعلام التصدير.
  List<Object?> get props => [query];
}

/// Marks a single audit log as selected for detail panels or side drawers.
/// يحدد سجل تدقيق واحدًا ليظهر في لوحات التفاصيل أو الأدراج الجانبية.
class SelectAuditLogEvent extends AuditLogsEvent {
  /// The audit log selected by the user.
  /// سجل التدقيق الذي اختاره المستخدم.
  final AuditLog auditLog;

  /// Creates a selection request for the provided audit log.
  /// ينشئ طلب اختيار لسجل التدقيق المعطى.
  const SelectAuditLogEvent({required this.auditLog});

  @override

  /// Comparison key for the selected log.
  /// مفتاح المقارنة للسجل المختار.
  List<Object?> get props => [auditLog];
}

/// Requests the full detail record for one audit-log identifier.
/// يطلب سجل التفاصيل الكامل لمعرّف واحد من سجلات التدقيق.
class LoadAuditLogDetailsEvent extends AuditLogsEvent {
  /// The identifier of the audit log whose details should be fetched.
  /// معرّف سجل التدقيق الذي يجب جلب تفاصيله.
  final String auditLogId;

  /// Creates a detail-loading request for the given audit-log id.
  /// ينشئ طلب تحميل تفاصيل لمعرّف سجل التدقيق المعطى.
  const LoadAuditLogDetailsEvent({required this.auditLogId});

  @override

  /// Comparison key for the target audit-log id.
  /// مفتاح المقارنة لمعرّف سجل التدقيق المستهدف.
  List<Object?> get props => [auditLogId];
}

/// Clears all audit-log filters and returns the bloc to its default query.
/// يمسح جميع فلاتر سجلات التدقيق ويعيد البلوك إلى استعلامه الافتراضي.
class ClearFiltersEvent extends AuditLogsEvent {
  /// Creates a filter-clear request with no payload.
  /// ينشئ طلب مسح للفلاتر من دون بيانات إضافية.
  const ClearFiltersEvent();

  @override

  /// No payload is needed because clearing filters always means the same action.
  /// لا توجد حمولة لأن مسح الفلاتر يعني دائمًا نفس العملية.
  List<Object?> get props => [];
}
