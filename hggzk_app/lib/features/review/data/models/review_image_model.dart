import '../../domain/entities/review_image.dart';

/// Describes the data model `ReviewImageModel`.
/// العربية: يمثل نموذج البيانات `ReviewImageModel`.
class ReviewImageModel extends ReviewImage {
  /// Builds a new `ReviewImageModel` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `ReviewImageModel`.
  const ReviewImageModel({
    required super.id,
    required super.url,
    required super.thumbnailUrl,
    super.caption,
    required super.displayOrder,
    super.sizeBytes,
    super.type,
    super.uploadedAt,
  });

  /// Builds a new `ReviewImageModel.fromJson` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `ReviewImageModel.fromJson`.
  factory ReviewImageModel.fromJson(Map<String, dynamic> json) {
    return ReviewImageModel(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      thumbnailUrl:
          json['thumbnailUrl'] ?? json['thumbnail_url'] ?? json['url'] ?? '',
      caption: json['caption'],
      displayOrder: json['displayOrder'] ?? 0,
      sizeBytes: json['sizeBytes'],
      type: json['type'] ?? json['mimeType'] ?? json['mime_type'],
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'])
          : null,
    );
  }

  /// Converts this instance to a JSON representation.
  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'caption': caption,
      'displayOrder': displayOrder,
      'sizeBytes': sizeBytes,
      'type': type,
      'uploadedAt': uploadedAt?.toIso8601String(),
    };
  }

  /// Processes `toEntity`.
  /// العربية: يعالج `toEntity`.
  ReviewImage toEntity() {
    return ReviewImage(
      id: id,
      url: url,
      thumbnailUrl: thumbnailUrl,
      caption: caption,
      displayOrder: displayOrder,
      sizeBytes: sizeBytes,
      type: type,
      uploadedAt: uploadedAt,
    );
  }
}
