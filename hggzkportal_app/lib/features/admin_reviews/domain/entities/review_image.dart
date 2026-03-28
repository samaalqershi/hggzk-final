// lib/features/admin_reviews/domain/entities/review_image.dart

import 'package:equatable/equatable.dart';

/// يصنف الصور المرفقة بالتقييم بحسب الدور الذي تؤديه في العرض أو الإدارة،
/// مثل صور المرافق أو الغلاف أو المستندات.
/// Classifies review images by the role they play in display or moderation,
/// such as amenities, cover media, or supporting documents.
enum ImageCategory {
  exterior,
  interior,
  amenity,
  floorPlan,
  documents,
  avatar,
  cover,
  gallery,
}

/// يمثل صورة مرفقة بتقييم داخل لوحة الإدارة مع البيانات الأساسية اللازمة
/// للعرض، الترتيب، والوصول إلى الملف الأصلي.
/// Represents an image attached to a review inside the admin dashboard, with
/// the metadata needed for display, ordering, and access to the original file.
class ReviewImage extends Equatable {
  /// المعرّف الفريد للصورة داخل النظام.
  /// Unique identifier of the image record inside the system.
  final String id;

  /// معرّف التقييم الذي تنتمي إليه هذه الصورة.
  /// Identifier of the review that owns this image.
  final String reviewId;

  /// الاسم أو التسمية المعروضة للصورة داخل أدوات الإدارة.
  /// Display name or label used for the image inside admin tools.
  final String name;

  /// الرابط النهائي الذي يشير إلى الملف المخزن.
  /// Final URL that points to the stored file.
  final String url;

  /// حجم الملف بالبايت لاستخدامه في العرض أو التحقق.
  /// File size in bytes for display and validation purposes.
  final int sizeBytes;

  /// نوع الملف أو امتداده كما تم تسجيله عند الرفع.
  /// File type or extension recorded at upload time.
  final String type;

  /// الفئة الدلالية التي توضّح كيف ينبغي التعامل مع الصورة.
  /// Semantic category that explains how the image should be treated.
  final ImageCategory category;

  /// تعليق اختياري يشرح محتوى الصورة أو سياقها.
  /// Optional caption that explains the image content or context.
  final String caption;

  /// نص بديل يساعد على الوصولية أو فهم الصورة في الواجهات النصية.
  /// Alternative text that supports accessibility and text-based contexts.
  final String altText;

  /// وقت رفع الصورة أو إضافتها إلى التقييم.
  /// Time when the image was uploaded or attached to the review.
  final DateTime uploadedAt;

  /// ينشئ تمثيل صورة التقييم الذي تعتمد عليه طبقات الإدارة والعرض.
  /// Creates the review-image entity consumed by admin and presentation layers.
  const ReviewImage({
    required this.id,
    required this.reviewId,
    required this.name,
    required this.url,
    required this.sizeBytes,
    required this.type,
    required this.category,
    required this.caption,
    required this.altText,
    required this.uploadedAt,
  });

  /// يحدد الحقول التي تدخل في المقارنة القيمة-بالقيمة بين صور التقييم.
  /// Defines the value-based comparison fields for review images.
  @override
  List<Object> get props => [
        id,
        reviewId,
        name,
        url,
        sizeBytes,
        type,
        category,
        caption,
        altText,
        uploadedAt,
      ];
}
