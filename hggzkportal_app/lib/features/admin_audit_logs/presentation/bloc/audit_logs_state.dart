// lib/features/admin_audit_logs/presentation/bloc/audit_logs_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/audit_log.dart';

/// Base state for the audit-log feature, covering list loading and one-off actions.
/// الحالة الأساسية لميزة سجلات التدقيق، وتشمل تحميل القائمة والعمليات الفردية.
abstract class AuditLogsState extends Equatable {
  /// Creates the shared state base for audit-log screens.
  /// ينشئ الأساس المشترك لحالات شاشات سجلات التدقيق.
  const AuditLogsState();

  @override

  /// Comparison keys shared by every audit-log state.
  /// مفاتيح المقارنة المشتركة بين جميع حالات سجلات التدقيق.
  List<Object?> get props => [];
}

/// Initial state shown before any audit-log data has been requested.
/// الحالة الابتدائية المعروضة قبل طلب أي بيانات لسجلات التدقيق.
class AuditLogsInitial extends AuditLogsState {}

/// State emitted while audit logs are being fetched.
/// الحالة الصادرة أثناء جلب سجلات التدقيق.
class AuditLogsLoading extends AuditLogsState {}

/// State that holds the current audit-log page, selection, and pagination context.
/// حالة تحمل صفحة سجلات التدقيق الحالية واختيار السجل وسياق التصفح.
class AuditLogsLoaded extends AuditLogsState {
  /// The audit logs currently visible in the list.
  /// سجلات التدقيق الظاهرة حاليًا في القائمة.
  final List<AuditLog> auditLogs;

  /// The total number of matching audit logs reported by the backend.
  /// العدد الإجمالي لسجلات التدقيق المطابقة الذي يبلغه الخادم.
  final int totalCount;

  /// The page number currently represented by this state.
  /// رقم الصفحة الممثلة حاليًا في هذه الحالة.
  final int currentPage;

  /// The page size used for the current dataset.
  /// حجم الصفحة المستخدم لمجموعة البيانات الحالية.
  final int pageSize;

  /// Whether the current list has reached the final page.
  /// ما إذا كانت القائمة الحالية وصلت إلى الصفحة الأخيرة.
  final bool hasReachedMax;

  /// Whether a load-more operation is currently running.
  /// ما إذا كانت عملية تحميل المزيد تعمل حاليًا.
  final bool isLoadingMore;

  /// The log selected by the user for detailed viewing, if any.
  /// السجل الذي اختاره المستخدم لعرض تفاصيله إن وجد.
  final AuditLog? selectedLog;

  /// The query that produced the current list and should be reused for refreshes.
  /// الاستعلام الذي أنشأ القائمة الحالية ويجب إعادة استخدامه في التحديث.
  final AuditLogsQuery currentQuery;

  /// Whether the bloc is currently loading the selected log's full details.
  /// ما إذا كان البلوك يحمّل تفاصيل السجل المختار حاليًا.
  final bool loadingDetails;

  /// Creates a loaded state with the current list and paging context.
  /// ينشئ حالة تحميل تتضمن القائمة الحالية وسياق التصفح.
  const AuditLogsLoaded({
    required this.auditLogs,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.hasReachedMax,
    this.isLoadingMore = false,
    this.selectedLog,
    required this.currentQuery,
    this.loadingDetails = false,
  });

  /// Returns a new loaded state while preserving any unchanged values.
  /// يعيد حالة تحميل جديدة مع الحفاظ على أي قيم لم تتغير.
  AuditLogsLoaded copyWith({
    List<AuditLog>? auditLogs,
    int? totalCount,
    int? currentPage,
    int? pageSize,
    bool? hasReachedMax,
    bool? isLoadingMore,
    AuditLog? selectedLog,
    AuditLogsQuery? currentQuery,
    bool? loadingDetails,
  }) {
    return AuditLogsLoaded(
      auditLogs: auditLogs ?? this.auditLogs,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      selectedLog: selectedLog ?? this.selectedLog,
      currentQuery: currentQuery ?? this.currentQuery,
      loadingDetails: loadingDetails ?? this.loadingDetails,
    );
  }

  @override

  /// Comparison keys that represent the visible list and its current UI context.
  /// مفاتيح المقارنة التي تمثل القائمة الظاهرة وسياق واجهتها الحالي.
  List<Object?> get props => [
        auditLogs,
        totalCount,
        currentPage,
        pageSize,
        hasReachedMax,
        isLoadingMore,
        selectedLog,
        currentQuery,
        loadingDetails,
      ];
}

/// State emitted when loading or processing audit logs fails.
/// الحالة الصادرة عند فشل تحميل سجلات التدقيق أو معالجتها.
class AuditLogsError extends AuditLogsState {
  /// The message that should be surfaced to the user.
  /// الرسالة التي ينبغي عرضها للمستخدم.
  final String message;

  /// Creates an error state with a readable message.
  /// ينشئ حالة خطأ مع رسالة قابلة للقراءة.
  const AuditLogsError({required this.message});

  @override

  /// Comparison key for the error message.
  /// مفتاح المقارنة لرسالة الخطأ.
  List<Object?> get props => [message];
}

/// State emitted while an export operation is in progress.
/// الحالة الصادرة أثناء تنفيذ عملية التصدير.
class AuditLogsExporting extends AuditLogsState {}

/// State emitted after audit logs have been exported successfully.
/// الحالة الصادرة بعد تصدير سجلات التدقيق بنجاح.
class AuditLogsExported extends AuditLogsState {
  /// The exported audit logs ready for file generation or sharing.
  /// سجلات التدقيق المصدّرة الجاهزة لإنشاء ملف أو مشاركته.
  final List<AuditLog> exportedLogs;

  /// Creates a state that carries the exported audit-log data.
  /// ينشئ حالة تحمل بيانات سجلات التدقيق المصدّرة.
  const AuditLogsExported({required this.exportedLogs});

  @override

  /// Comparison key for the exported data payload.
  /// مفتاح المقارنة لحمولة البيانات المصدّرة.
  List<Object?> get props => [exportedLogs];
}
