// lib/features/admin_properties/domain/entities/unit_image.dart

import 'package:equatable/equatable.dart';

/// يمثل هذا التعداد ImageCategory القيم التي تضبط سلوك إدارة الوحدات.
/// This enum represents the values that drive ImageCategory in the admin unit workflow.
enum ImageCategory {
  exterior,
  interior,
  amenity,
  floorPlan,
  documents,
  avatar,
  cover,
  gallery,
  video,
}

/// يمثل هذا التعداد ProcessingStatus القيم التي تضبط سلوك إدارة الوحدات.
/// This enum represents the values that drive ProcessingStatus in the admin unit workflow.
enum ProcessingStatus {
  uploading,
  processing,
  ready,
  failed,
  deleted,
}

/// يمثل هذا التعداد MediaType القيم التي تضبط سلوك إدارة الوحدات.
/// This enum represents the values that drive MediaType in the admin unit workflow.
enum MediaType {
  image,
  video,
}

/// يمثل هذا الكلاس UnitImage البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitImage in the admin unit workflow.
class UnitImage extends Equatable {
  /// This field keeps the id value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة id التي يعتمد عليها مسار إدارة الوحدات.
  final String id;

  /// يحتفظ هذا الحقل بقيمة url التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the url value used by the admin unit workflow.
  final String url;

  /// يحتفظ هذا الحقل بقيمة filename التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the filename value used by the admin unit workflow.
  final String filename;

  /// يحتفظ هذا الحقل بقيمة size التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the size value used by the admin unit workflow.
  final int size;

  /// يحتفظ هذا الحقل بقيمة mimeType التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the mimeType value used by the admin unit workflow.
  final String mimeType;

  /// يحتفظ هذا الحقل بقيمة width التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the width value used by the admin unit workflow.
  final int width;

  /// يحتفظ هذا الحقل بقيمة height التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the height value used by the admin unit workflow.
  final int height;

  /// يحتفظ هذا الحقل بقيمة alt التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the alt value used by the admin unit workflow.
  final String? alt;

  /// يحتفظ هذا الحقل بقيمة uploadedAt التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the uploadedAt value used by the admin unit workflow.
  final DateTime uploadedAt;

  /// يحتفظ هذا الحقل بقيمة uploadedBy التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the uploadedBy value used by the admin unit workflow.
  final String uploadedBy;

  /// يحتفظ هذا الحقل بقيمة order التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the order value used by the admin unit workflow.
  final int order;

  /// يحتفظ هذا الحقل بقيمة isPrimary التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the isPrimary value used by the admin unit workflow.
  final bool isPrimary;

  /// يحتفظ هذا الحقل بقيمة is360 التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the is360 value used by the admin unit workflow.
  final bool is360;

  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the unitId value used by the admin unit workflow.
  final String? unitId;

  /// يحتفظ هذا الحقل بقيمة category التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the category value used by the admin unit workflow.
  final ImageCategory category;

  /// يحتفظ هذا الحقل بقيمة tags التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the tags value used by the admin unit workflow.
  final List<String> tags;

  /// يحتفظ هذا الحقل بقيمة processingStatus التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the processingStatus value used by the admin unit workflow.
  final ProcessingStatus processingStatus;

  /// يحتفظ هذا الحقل بقيمة thumbnails التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the thumbnails value used by the admin unit workflow.
  final ImageThumbnails thumbnails;

  /// يحتفظ هذا الحقل بقيمة mediaType التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the mediaType value used by the admin unit workflow.
  final MediaType mediaType; // إضافة نوع الوسائط
  /// يحتفظ هذا الحقل بقيمة videoThumbnail التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the videoThumbnail value used by the admin unit workflow.
  final String? videoThumbnail; // إضافة thumbnail للفيديو
  /// يحتفظ هذا الحقل بقيمة duration التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the duration value used by the admin unit workflow.
  final int? duration; // مدة الفيديو بالثواني

  /// ينشئ هذا المُنشئ مثيلاً من UnitImage.
  /// This constructor creates an instance of UnitImage.
  const UnitImage({
    required this.id,
    required this.url,
    required this.filename,
    required this.size,
    required this.mimeType,
    required this.width,
    required this.height,
    this.alt,
    required this.uploadedAt,
    required this.uploadedBy,
    required this.order,
    required this.isPrimary,
    this.is360 = false,
    this.unitId,
    required this.category,
    this.tags = const [],
    required this.processingStatus,
    required this.thumbnails,
    this.mediaType = MediaType.image,
    this.videoThumbnail,
    this.duration,
  });

  /// يعيد هذا getter قيمة isReady المشتقة من الحالة الحالية.
  /// This getter derives the isReady value from the current state.
  bool get isReady => processingStatus == ProcessingStatus.ready;

  /// يعيد هذا getter قيمة isVideo المشتقة من الحالة الحالية.
  /// This getter derives the isVideo value from the current state.
  bool get isVideo => mediaType == MediaType.video;

  /// يعيد هذا getter قيمة isImage المشتقة من الحالة الحالية.
  /// This getter derives the isImage value from the current state.
  bool get isImage => mediaType == MediaType.image;

  /// يعيد هذا getter قيمة sizeInMB المشتقة من الحالة الحالية.
  /// This getter derives the sizeInMB value from the current state.
  String get sizeInMB => (size / (1024 * 1024)).toStringAsFixed(2);

  /// يعيد هذا getter قيمة displayThumbnail المشتقة من الحالة الحالية.
  /// This getter derives the displayThumbnail value from the current state.
  String get displayThumbnail {
    if (isVideo && videoThumbnail != null) return videoThumbnail!;
    return thumbnails.medium;
  }

  /// يعيد هذا getter قيمة durationFormatted المشتقة من الحالة الحالية.
  /// This getter derives the durationFormatted value from the current state.
  String get durationFormatted {
    if (duration == null) return '';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [
        id,
        url,
        filename,
        size,
        mimeType,
        width,
        height,
        alt,
        uploadedAt,
        uploadedBy,
        order,
        isPrimary,
        is360,
        unitId,
        category,
        tags,
        processingStatus,
        thumbnails,
        mediaType,
        duration,
        videoThumbnail,
      ];
}

/// يمثل هذا الكلاس ImageThumbnails البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for ImageThumbnails in the admin unit workflow.
class ImageThumbnails extends Equatable {
  /// This field keeps the small value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة small التي يعتمد عليها مسار إدارة الوحدات.
  final String small;

  /// يحتفظ هذا الحقل بقيمة medium التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the medium value used by the admin unit workflow.
  final String medium;

  /// يحتفظ هذا الحقل بقيمة large التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the large value used by the admin unit workflow.
  final String large;

  /// يحتفظ هذا الحقل بقيمة hd التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the hd value used by the admin unit workflow.
  final String hd;

  /// ينشئ هذا المُنشئ مثيلاً من ImageThumbnails.
  /// This constructor creates an instance of ImageThumbnails.
  const ImageThumbnails({
    required this.small,
    required this.medium,
    required this.large,
    required this.hd,
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object> get props => [small, medium, large, hd];
}
