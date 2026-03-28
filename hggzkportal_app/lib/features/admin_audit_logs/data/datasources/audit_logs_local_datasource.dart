// lib/features/admin_audit_logs/data/datasources/audit_logs_local_datasource.dart

import 'package:hive/hive.dart';
import '../../domain/entities/audit_log.dart';
import '../models/audit_log_model.dart';

/// يعرّف واجهة التخزين المحلي لسجلّات التدقيق كي تبقى آخر نتيجة قابلة
/// للاسترجاع حتى عند غياب الاتصال.
/// Defines the local storage boundary for audit logs so the latest result
/// remains recoverable even when the connection is unavailable.
abstract class AuditLogsLocalDataSource {
  /// يخزن لقطة من السجلّات محليًا لاستخدامها كخطة بديلة عند انقطاع الشبكة.
  /// Stores a snapshot of the logs locally so it can be used as a fallback
  /// when the network drops.
  Future<void> cacheAuditLogs(List<AuditLog> logs);

  /// يعيد السجلّات المخزنة محليًا كما كانت عند آخر مزامنة ناجحة.
  /// Returns the locally stored logs exactly as they were at the last
  /// successful sync.
  Future<List<AuditLog>> getCachedAuditLogs();

  /// يمسح كل السجلّات المخزنة عندما نحتاج إلى إعادة بناء الكاش من الصفر.
  /// Clears all stored logs when the cache must be rebuilt from scratch.
  Future<void> clearCache();
}

/// ينفذ تخزين سجلّات التدقيق عبر `Hive` حتى تبقى البيانات خفيفة وسريعة
/// القراءة في وضع عدم الاتصال.
/// Implements audit-log storage with `Hive` so the data remains lightweight
/// and quick to read offline.
class AuditLogsLocalDataSourceImpl implements AuditLogsLocalDataSource {
  /// اسم الصندوق الذي يحتفظ بلقطة السجلّات المؤرشفة.
  /// Name of the Hive box that stores the archived logs snapshot.
  static const String _boxName = 'audit_logs_cache';

  /// المفتاح الذي تُحفظ تحته قائمة السجلّات المسلسلة.
  /// Key under which the serialized list of logs is stored.
  static const String _logsKey = 'cached_logs';

  @override

  /// يحوّل الكيانات إلى JSON ثم يخزنها داخل صندوق `Hive` المحلي.
  /// Converts entities to JSON and stores them inside the local `Hive` box.
  Future<void> cacheAuditLogs(List<AuditLog> logs) async {
    final box = await Hive.openBox(_boxName);
    final jsonList =
        logs.map((log) => AuditLogModel.fromEntity(log).toJson()).toList();
    await box.put(_logsKey, jsonList);
  }

  @override

  /// يقرأ JSON المخزن محليًا ثم يعيده إلى كيانات تدقيق قابلة للاستخدام.
  /// Reads the locally stored JSON and converts it back into usable audit-log
  /// entities.
  Future<List<AuditLog>> getCachedAuditLogs() async {
    final box = await Hive.openBox(_boxName);
    final jsonList = box.get(_logsKey, defaultValue: <dynamic>[]) as List;
    return jsonList
        .map((json) => AuditLogModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  @override

  /// يزيل صندوق الكاش بالكامل حتى لا تبقى بيانات قديمة أو متعارضة.
  /// Clears the entire cache box so stale or conflicting data does not stay
  /// behind.
  Future<void> clearCache() async {
    final box = await Hive.openBox(_boxName);
    await box.clear();
  }
}
