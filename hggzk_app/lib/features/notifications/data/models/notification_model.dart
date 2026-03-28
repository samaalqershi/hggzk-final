import '../../domain/entities/notification.dart';

/// يحول JSON الإشعارات القادم من الخادم إلى كيان مجال موحد يمكن للواجهة
/// وطبقات المجال الاعتماد عليه.
/// Converts notification JSON payloads into a normalized domain entity used by
/// the UI and domain layers.
class NotificationModel extends NotificationEntity {
  /// ينشئ نموذج الإشعار مع كل الحقول اللازمة للعرض والتفاعل.
  /// Creates the notification model with the fields required for display and
  /// interaction.
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.type,
    super.data,
    required super.isRead,
    required super.createdAt,
    super.readAt,
  });

  /// يبني النموذج من JSON مع دعم اختلافات التسمية بين الحقول.
  /// Builds the model from JSON while tolerating naming differences across
  /// backend payloads.
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? json['Title'] ?? '',
      message: json['message'] ?? json['content'] ?? json['Content'] ?? '',
      type: json['type'] ?? '',
      data: json['data'],
      isRead: json['isRead'] ?? json['is_read'] ?? json['IsRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'])
          : json['read_at'] != null
              ? DateTime.parse(json['read_at'])
              : json['ReadAt'] != null
                  ? DateTime.tryParse(json['ReadAt'])
                  : null,
    );
  }

  /// يحول النموذج إلى JSON للحفظ المحلي أو النقل بين الطبقات.
  /// Converts the model to JSON for local caching or inter-layer transport.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }

  /// ينشئ نموذج بيانات من كيان المجال عند الحاجة إلى التخزين أو الإرسال.
  /// Creates a data model from the domain entity when caching or resending is
  /// needed.
  factory NotificationModel.fromEntity(NotificationEntity notification) {
    return NotificationModel(
      id: notification.id,
      title: notification.title,
      message: notification.message,
      type: notification.type,
      data: notification.data,
      isRead: notification.isRead,
      createdAt: notification.createdAt,
      readAt: notification.readAt,
    );
  }
}
