import 'package:equatable/equatable.dart';

/// يمثل إشعارًا واحدًا كما تحتاجه طبقة العرض، مع بيانات النص والحالة
/// والوقت والحمولة الإضافية.
/// Represents one notification as required by the presentation layer,
/// including message text, status, timestamps, and optional payload.
class NotificationEntity extends Equatable {
  /// المعرّف الفريد للإشعار.
  /// Unique notification identifier.
  final String id;

  /// العنوان المختصر الظاهر في البطاقة أو القائمة.
  /// Short title shown in the card or list.
  final String title;

  /// نص الرسالة أو المحتوى التفصيلي للإشعار.
  /// Main notification message or detailed content.
  final String message;

  /// نوع الإشعار المستخدم للتصنيف والتصفية.
  /// Notification type used for categorization and filtering.
  final String type;

  /// حمولة إضافية اختيارية مرتبطة بالإشعار.
  /// Optional extra payload attached to the notification.
  final String? data;

  /// يحدد ما إذا كان الإشعار قد قُرئ بالفعل.
  /// Indicates whether the notification has already been read.
  final bool isRead;

  /// وقت إنشاء الإشعار.
  /// Timestamp when the notification was created.
  final DateTime createdAt;

  /// وقت قراءة الإشعار إن كان قد قُرئ.
  /// Timestamp when the notification was read, if applicable.
  final DateTime? readAt;

  /// ينشئ كيان الإشعار كما يعتمد عليه المجال والواجهة.
  /// Creates the notification entity consumed by domain and presentation
  /// layers.
  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.data,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  /// يعيد الحقول التي تحدد هوية الإشعار عند المقارنة بين الكيانات.
  /// Returns the fields that define notification identity during entity
  /// comparison.
  @override
  List<Object?> get props => [
        id,
        title,
        message,
        type,
        data,
        isRead,
        createdAt,
        readAt,
      ];
}
