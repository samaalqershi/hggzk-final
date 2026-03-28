import 'package:equatable/equatable.dart';

/// Represents one image attached to a review submission.
/// يمثل صورة واحدة مرفقة بمراجعة.
class ReviewImage extends Equatable {
  /// Unique identifier of the review image.
  /// المعرّف الفريد لصورة المراجعة.
  final String id;

  /// Public image URL used by the UI.
  /// رابط الصورة العام الذي تستخدمه الواجهة.
  final String url;

  /// Optional thumbnail URL for compact layouts.
  /// رابط مصغّر اختياري للتخطيطات المضغوطة.
  final String thumbnailUrl;

  /// Optional caption displayed with the image.
  /// وصف اختياري يظهر مع الصورة.
  final String? caption;

  /// Order used when rendering the review gallery.
  /// الترتيب المستخدم عند عرض معرض المراجعة.
  final int displayOrder;

  /// Optional file size in bytes.
  /// حجم الملف الاختياري بالبايت.
  final int? sizeBytes;

  /// Optional MIME or backend-provided type label.
  /// نوع اختياري بصيغة MIME أو وسم يعيده الخادم.
  final String? type;

  /// Optional upload timestamp returned by the backend.
  /// وقت رفع اختياري يعيده الخادم.
  final DateTime? uploadedAt;

  /// Builds an immutable review-image record.
  /// ينشئ سجل صورة مراجعة ثابتًا.
  const ReviewImage({
    required this.id,
    required this.url,
    required this.thumbnailUrl,
    this.caption,
    required this.displayOrder,
    this.sizeBytes,
    this.type,
    this.uploadedAt,
  });

  /// Keeps equality aligned with the image payload.
  /// يحافظ على ثبات المقارنة مع حمولة الصورة.
  @override
  List<Object?> get props => [
        id,
        url,
        thumbnailUrl,
        caption,
        displayOrder,
        sizeBytes,
        type,
        uploadedAt,
      ];
}
