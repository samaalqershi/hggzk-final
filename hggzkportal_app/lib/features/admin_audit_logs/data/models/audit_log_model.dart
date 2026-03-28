// lib/features/admin_audit_logs/data/models/audit_log_model.dart

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/audit_log.dart';

part 'audit_log_model.g.dart';

/// يمثل الشكل البرمجي لسجل التدقيق كما يمر بين الـ API وكيان الدومين،
/// مع دعم مباشر للتوليد الآلي لـ JSON.
/// Represents the programmatic shape of an audit log as it flows between the
/// API and the domain entity, with direct JSON generation support.
@JsonSerializable()
class AuditLogModel extends AuditLog {
  /// ينشئ سجل تدقيق كاملًا مع كل البيانات اللازمة للمراجعة والتتبع.
  /// Creates a complete audit log with all data needed for review and
  /// tracing.
  const AuditLogModel({
    required String id,
    required String tableName,
    required String action,
    required String recordId,
    required String recordName,
    required String userId,
    required String username,
    required String changes,
    required DateTime timestamp,
    required String notes,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
    Map<String, dynamic>? metadata,
    required bool isSlowOperation,
  }) : super(
          id: id,
          tableName: tableName,
          action: action,
          recordId: recordId,
          recordName: recordName,
          userId: userId,
          username: username,
          changes: changes,
          timestamp: timestamp,
          notes: notes,
          oldValues: oldValues,
          newValues: newValues,
          metadata: metadata,
          isSlowOperation: isSlowOperation,
        );

  /// يبني نموذج السجل من خريطة JSON القادمة من الخادم أو من التخزين
  /// المحلي.
  /// Builds the log model from a JSON map received from the backend or local
  /// storage.
  factory AuditLogModel.fromJson(Map<String, dynamic> json) =>
      _$AuditLogModelFromJson(json);

  /// يحول السجل إلى JSON بحيث يمكن إرساله أو تخزينه كنسخة قابلة
  /// لإعادة البناء.
  /// Converts the log into JSON so it can be sent or stored as a rebuildable
  /// snapshot.
  Map<String, dynamic> toJson() => _$AuditLogModelToJson(this);

  /// يبني نموذج بيانات من كيان الدومين عندما تحتاج طبقة البيانات إلى
  /// نسخة قابلة للتحويل.
  /// Builds a data model from the domain entity when the data layer needs a
  /// transport-ready copy.
  factory AuditLogModel.fromEntity(AuditLog entity) {
    return AuditLogModel(
      id: entity.id,
      tableName: entity.tableName,
      action: entity.action,
      recordId: entity.recordId,
      recordName: entity.recordName,
      userId: entity.userId,
      username: entity.username,
      changes: entity.changes,
      timestamp: entity.timestamp,
      notes: entity.notes,
      oldValues: entity.oldValues,
      newValues: entity.newValues,
      metadata: entity.metadata,
      isSlowOperation: entity.isSlowOperation,
    );
  }
}
