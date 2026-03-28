// lib/features/admin_audit_logs/domain/entities/audit_log.dart

import 'package:equatable/equatable.dart';

/// يمثل حدثًا واحدًا في سجل التدقيق مع ما يصفه من كيان ومستخدم وتغييرات
/// وسياق زمني.
/// Represents one audit trail entry with the entity it touches, the user who
/// caused it, the recorded changes, and its time context.
class AuditLog extends Equatable {
  /// المعرف الفريد لسجل التدقيق نفسه.
  /// The unique identifier of the audit-log entry itself.
  final String id;

  /// اسم الجدول أو الكيان الذي تعرض لتغيير.
  /// The table or entity name that was affected.
  final String tableName;

  /// نوع العملية المنفذة مثل create أو update أو delete.
  /// The operation type performed, such as create, update, or delete.
  final String action;

  /// المعرف الذي يربط السجل بالصف الأصلي أو الكيان المتأثر.
  /// The identifier that ties the log to the affected row or entity.
  final String recordId;

  /// الاسم المقروء للعنصر الذي تم تسجيله في هذا الحدث.
  /// The human-readable name of the record captured by this log.
  final String recordName;

  /// معرّف المستخدم الذي نفذ العملية.
  /// The identifier of the user who performed the action.
  final String userId;

  /// اسم المستخدم الظاهر في السجل.
  /// The username shown in the log entry.
  final String username;

  /// وصف نصي مختصر للتغيير أو الحدث كما حفظه النظام.
  /// A short textual description of the change or event as stored by the
  /// system.
  final String changes;

  /// الوقت الذي حدث فيه الفعل وسُجل في قاعدة التدقيق.
  /// The time the action occurred and was stored in the audit trail.
  final DateTime timestamp;

  /// ملاحظات إضافية قد يضيفها النظام أو المشرف لتوضيح السبب.
  /// Additional notes that the system or admin may store to clarify context.
  final String notes;

  /// القيم القديمة قبل التعديل عندما يكون الفعل تحديثًا.
  /// The previous values before a change when the action is an update.
  final Map<String, dynamic>? oldValues;

  /// القيم الجديدة بعد التعديل عندما يكون الفعل تحديثًا.
  /// The new values after a change when the action is an update.
  final Map<String, dynamic>? newValues;

  /// بيانات وصفية إضافية مرتبطة بالسجل مثل مصدر العملية أو نوع الواجهة.
  /// Extra metadata linked to the entry, such as the source of the action or
  /// the UI context.
  final Map<String, dynamic>? metadata;

  /// يوضح ما إذا كانت العملية أبطأ من المعيار الذي يهم فريق الإدارة.
  /// Indicates whether the operation was slower than the threshold that
  /// matters to the admin team.
  final bool isSlowOperation;

  /// Creates one audit-log entry with the full captured context.
  const AuditLog({
    required this.id,
    required this.tableName,
    required this.action,
    required this.recordId,
    required this.recordName,
    required this.userId,
    required this.username,
    required this.changes,
    required this.timestamp,
    required this.notes,
    this.oldValues,
    this.newValues,
    this.metadata,
    required this.isSlowOperation,
  });
  @override

  /// تعتمد المساواة على محتوى السجل كله لأن أي تغيير في هذا السياق يعني
  /// حدثًا مختلفًا.
  /// Equality depends on the full log content because any change in this
  /// context means a different event.
  List<Object?> get props => [
        id,
        tableName,
        action,
        recordId,
        recordName,
        userId,
        username,
        changes,
        timestamp,
        notes,
        oldValues,
        newValues,
        metadata,
        isSlowOperation,
      ];

  /// يحدد ما إذا كان السجل يمثل عملية إنشاء.
  /// Indicates whether the entry represents a create operation.
  bool get isCreate => action.toLowerCase() == 'create';

  /// يحدد ما إذا كان السجل يمثل عملية تعديل.
  /// Indicates whether the entry represents an update operation.
  bool get isUpdate => action.toLowerCase() == 'update';

  /// يحدد ما إذا كان السجل يمثل عملية حذف.
  /// Indicates whether the entry represents a delete operation.
  bool get isDelete => action.toLowerCase() == 'delete';

  /// يعيد اسم الأيقونة النصي الأنسب للعملية حتى تعرضه الواجهة أو الخرائط
  /// الرسومية.
  /// Returns the most suitable icon name for the action so the UI or icon
  /// mapping layer can display it.
  String get actionIcon {
    switch (action.toLowerCase()) {
      case 'create':
        return 'add_circle';
      case 'update':
        return 'edit';
      case 'delete':
        return 'delete';
      case 'login':
        return 'login';
      case 'logout':
        return 'logout';
      default:
        return 'info';
    }
  }

  /// يعيد رمز اللون النصي الذي يعبّر عن نوع العملية في واجهات الإدارة.
  /// Returns the text color token that represents the operation type in admin
  /// interfaces.
  String get actionColor {
    switch (action.toLowerCase()) {
      case 'create':
        return '#00FF88';
      case 'update':
        return '#00D4FF';
      case 'delete':
        return '#FF3366';
      case 'login':
        return '#4FACFE';
      case 'logout':
        return '#FFB800';
      default:
        return '#667EEA';
    }
  }
}

/// يصف معايير البحث والتصفية العامة لسجلات التدقيق عبر النظام بالكامل.
/// Describes the general search and filtering criteria for audit logs across
/// the whole system.
class AuditLogsQuery extends Equatable {
  /// رقم الصفحة المطلوب استرجاعها.
  /// The page number to retrieve.
  final int? pageNumber;

  /// حجم الصفحة المطلوب في النتيجة.
  /// The requested page size for the result.
  final int? pageSize;

  /// تصفية السجلات بحسب المستخدم الذي نفذها.
  /// Filters logs by the user who performed them.
  final String? userId;

  /// بداية النطاق الزمني المطلوب.
  /// The start of the requested time range.
  final DateTime? from;

  /// نهاية النطاق الزمني المطلوب.
  /// The end of the requested time range.
  final DateTime? to;

  /// نص بحث حر لتضييق النتائج.
  /// Free-text search used to narrow the results.
  final String? searchTerm;

  /// نوع العملية المطلوب مثل create أو update.
  /// The operation type requested, such as create or update.
  final String? operationType;

  /// يفلتر السجلات حسب نوع الكيان مثل `Booking`.
  /// Filters logs by the entity type, such as `Booking`.
  final String? entityType;

  /// يربط السجلات بمعرف السجل نفسه داخل النظام.
  /// Matches logs by the record identifier inside the system.
  final String? recordId;

  /// يضم السجلات المرتبطة بحجز معين أو كيان رئيسي مشابه.
  /// Includes logs related to a specific booking or similar parent entity.
  final String? relatedToBookingId;

  /// Creates a reusable audit query with optional paging and filters.
  const AuditLogsQuery({
    this.pageNumber,
    this.pageSize,
    this.userId,
    this.from,
    this.to,
    this.searchTerm,
    this.operationType,
    this.entityType,
    this.recordId,
    this.relatedToBookingId,
  });

  /// يحول معايير البحث إلى خريطة قابلة للإرسال إلى طبقة البيانات.
  /// Converts the query into a map that can be sent to the data layer.
  Map<String, dynamic> toMap() {
    return {
      if (pageNumber != null) 'pageNumber': pageNumber,
      if (pageSize != null) 'pageSize': pageSize,
      if (userId != null) 'userId': userId,
      if (from != null) 'from': from!.toIso8601String(),
      if (to != null) 'to': to!.toIso8601String(),
      if (searchTerm != null) 'searchTerm': searchTerm,
      if (operationType != null) 'operationType': operationType,
      if (entityType != null) 'entityType': entityType,
      if (recordId != null) 'recordId': recordId,
      if (relatedToBookingId != null) 'relatedToBookingId': relatedToBookingId,
    };
  }

  @override

  /// تعتمد المساواة على كل فلتر لأن اختلاف أي منها ينتج استعلامًا جديدًا.
  /// Equality depends on every filter because changing any of them creates a
  /// new query.
  List<Object?> get props => [
        pageNumber,
        pageSize,
        userId,
        from,
        to,
        searchTerm,
        operationType,
        entityType,
        recordId,
        relatedToBookingId,
      ];
}

/// يصف استعلامًا أخف مخصصًا لسجلات النشاط الخاصة بالعملاء.
/// Describes a lighter query dedicated to customer activity logs.
class CustomerActivityLogsQuery extends Equatable {
  /// رقم الصفحة المطلوب.
  /// The requested page number.
  final int? pageNumber;

  /// حجم الصفحة المطلوب.
  /// The requested page size.
  final int? pageSize;

  /// Creates a paging-only query for customer activity logs.
  const CustomerActivityLogsQuery({
    this.pageNumber,
    this.pageSize,
  });

  /// يحول الترقيم إلى خريطة استعلام بسيطة للخدمة المعنية.
  /// Converts paging into a simple query map for the target service.
  Map<String, dynamic> toMap() {
    return {
      if (pageNumber != null) 'pageNumber': pageNumber,
      if (pageSize != null) 'pageSize': pageSize,
    };
  }

  @override

  /// تعتمد المساواة على بيانات الترقيم فقط.
  /// Equality depends only on the paging values.
  List<Object?> get props => [pageNumber, pageSize];
}

/// يصف استعلامًا مخصصًا لسجلات النشاط الخاصة بعقار واحد.
/// Describes a query dedicated to activity logs for a single property.
class PropertyActivityLogsQuery extends Equatable {
  /// معرّف العقار الذي نريد سجلاته.
  /// The property identifier whose logs are requested.
  final String? propertyId;

  /// رقم الصفحة المطلوب.
  /// The requested page number.
  final int? pageNumber;

  /// حجم الصفحة المطلوب.
  /// The requested page size.
  final int? pageSize;

  /// Creates a query object for property-specific audit logs.
  const PropertyActivityLogsQuery({
    this.propertyId,
    this.pageNumber,
    this.pageSize,
  });

  /// يحول الفلاتر الخاصة بالعقار إلى خريطة قابلة للاستهلاك من الطبقة الدنيا.
  /// Converts the property-specific filters into a map consumable by the lower
  /// layer.
  Map<String, dynamic> toMap() {
    return {
      if (propertyId != null) 'propertyId': propertyId,
      if (pageNumber != null) 'pageNumber': pageNumber,
      if (pageSize != null) 'pageSize': pageSize,
    };
  }

  @override

  /// تعتمد المساواة على العقار والترقيم لأنهما يحددان الاستعلام بالكامل.
  /// Equality depends on the property and paging values because they fully
  /// define the query.
  List<Object?> get props => [propertyId, pageNumber, pageSize];
}

/// يصف استعلامًا مخصصًا لسجلات النشاط الخاصة بالمشرفين.
/// Describes a query dedicated to admin activity logs.
class AdminActivityLogsQuery extends Equatable {
  /// رقم الصفحة المطلوب بشكل صريح.
  /// The page number requested explicitly.
  final int pageNumber;

  /// حجم الصفحة المطلوب بشكل صريح.
  /// The page size requested explicitly.
  final int pageSize;

  /// Creates a paging query for administrator activity logs.
  const AdminActivityLogsQuery({
    required this.pageNumber,
    required this.pageSize,
  });

  /// يحول الترقيم إلى خريطة جاهزة للإرسال إلى الخدمة.
  /// Converts paging into a map ready for service consumption.
  Map<String, dynamic> toMap() {
    return {
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };
  }

  @override

  /// تعتمد المساواة على ترقيم الصفحة وحجمها لأنهما يحددان نافذة البيانات.
  /// Equality depends on the page number and size because they define the
  /// data window.
  List<Object?> get props => [pageNumber, pageSize];
}
