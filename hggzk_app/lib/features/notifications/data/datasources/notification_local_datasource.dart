import 'dart:convert';
import 'package:hggzk/core/services/local_storage_service.dart';
import '../models/notification_model.dart';

/// يعرّف عمليات التخزين المحلي الخاصة بالإشعارات وتفضيلات عرضها.
/// Defines local-storage operations for notifications and notification
/// preferences.
abstract class NotificationLocalDataSource {
  /// يعيد الإشعارات المخزنة محليًا لاستخدامها عند عدم توفر الشبكة.
  /// Returns locally cached notifications for offline or fallback use.
  Future<List<NotificationModel>> getCachedNotifications();

  /// يخزن قائمة الإشعارات الحالية في الكاش المحلي.
  /// Caches the current notification list locally.
  Future<void> cacheNotifications(List<NotificationModel> notifications);

  /// يمسح كاش الإشعارات عند الحاجة إلى إعادة بناء البيانات.
  /// Clears the notifications cache when a refresh needs a clean start.
  Future<void> clearCache();

  /// يعيد تفضيلات الإشعارات المخزنة على الجهاز.
  /// Returns the notification settings stored on the device.
  Future<Map<String, bool>> getNotificationSettings();

  /// يحفظ تفضيلات الإشعارات محليًا.
  /// Saves notification settings locally.
  Future<void> saveNotificationSettings(Map<String, bool> settings);
}

/// ينفذ تخزين الإشعارات وتفضيلاتها عبر خدمة التخزين المحلية المشتركة.
/// Implements notification caching and preference storage through the shared
/// local-storage service.
class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  /// خدمة التخزين المحلية المستخدمة للقراءة والحفظ.
  /// Local-storage service used for reads and writes.
  final LocalStorageService localStorage;

  /// ينشئ المصدر المحلي مع خدمة التخزين المعتمدة.
  /// Creates the local data source with the configured storage service.
  NotificationLocalDataSourceImpl({required this.localStorage});

  /// Reads cached notifications from local storage and falls back to an empty
  /// list when the stored payload is missing or invalid.
  /// يقرأ الإشعارات المخزنة محليًا ويعود إلى قائمة فارغة عندما تكون الحمولة
  /// المخزنة مفقودة أو غير صالحة.
  @override
  Future<List<NotificationModel>> getCachedNotifications() async {
    final raw = localStorage.getData('notifications_cache')?.toString();
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = raw is String ? raw : raw.toString();
      final List<dynamic> list = decoded is String
          ? (decoded.startsWith('[')
              ? (jsonDecode(decoded) as List<dynamic>)
              : <dynamic>[])
          : <dynamic>[];
      return list
          .whereType<Map>()
          .map((e) =>
              NotificationModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Serializes the current notification list and stores it under the shared
  /// cache key.
  /// ينسّق قائمة الإشعارات الحالية ويحفظها تحت مفتاح الكاش المشترك.
  @override
  Future<void> cacheNotifications(List<NotificationModel> notifications) async {
    try {
      final data = notifications.map((n) => n.toJson()).toList();
      await localStorage.saveData('notifications_cache', data);
    } catch (_) {}
  }

  /// Removes the cached notification list so the next refresh starts cleanly.
  /// يزيل قائمة الإشعارات المخزنة حتى يبدأ التحديث التالي من نقطة نظيفة.
  @override
  Future<void> clearCache() async {
    try {
      await localStorage.removeData('notifications_cache');
    } catch (_) {}
  }

  /// Reads the stored notification settings and normalizes them into a typed
  /// boolean map.
  /// يقرأ إعدادات الإشعارات المخزنة ويحوّلها إلى خريطة منطقية typed.
  @override
  Future<Map<String, bool>> getNotificationSettings() async {
    final raw = localStorage.getData('notification_settings');
    if (raw is Map<String, dynamic>) {
      return raw.map((key, value) => MapEntry(key, value == true));
    }
    if (raw is String && raw.isNotEmpty) {
      try {
        final Map<String, dynamic> m = jsonDecode(raw) as Map<String, dynamic>;
        return m.map((key, value) => MapEntry(key, value == true));
      } catch (_) {}
    }
    return {};
  }

  /// Saves notification settings while preserving any existing keys that are
  /// not part of the current update.
  /// يحفظ إعدادات الإشعارات مع الإبقاء على أي مفاتيح موجودة ليست جزءًا من
  /// التحديث الحالي.
  @override
  Future<void> saveNotificationSettings(Map<String, bool> settings) async {
    try {
      final existing = await getNotificationSettings();
      // Merge to preserve any keys not present in current update
      final merged = Map<String, bool>.from(existing)..addAll(settings);
      await localStorage.saveData('notification_settings', merged);
    } catch (_) {
      await localStorage.saveData('notification_settings', settings);
    }
  }
}
