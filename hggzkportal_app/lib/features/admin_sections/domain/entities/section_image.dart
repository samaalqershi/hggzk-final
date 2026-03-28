import 'package:equatable/equatable.dart';

/// Content categories used to group section media.
///
/// الفئات المستخدمة لتجميع وسائط القسم.
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

/// Processing lifecycle for uploaded media.
///
/// دورة معالجة الوسائط المرفوعة.
enum ProcessingStatus {
  uploading,
  processing,
  ready,
  failed,
  deleted,
}

/// Distinguishes still images from video assets.
///
/// يميز الصور الثابتة عن ملفات الفيديو.
enum MediaType {
  image,
  video,
}

/// Represents one media asset attached to a section or one of its placements.
///
/// يمثل أصلًا وسائطيًا مرتبطًا بقسم أو بأحد مواضعه.
class SectionImage extends Equatable {
  /// Stable media identifier.
  ///
  /// المعرّف الثابت للوسيط.
  final String id;

  /// Canonical file URL used by the UI.
  ///
  /// رابط الملف القياسي المستخدم في الواجهة.
  final String url;

  /// Original file name supplied at upload time.
  ///
  /// اسم الملف الأصلي المرسل عند الرفع.
  final String filename;

  /// File size in bytes.
  ///
  /// حجم الملف بالبايت.
  final int size;

  /// MIME type reported by the upload pipeline.
  ///
  /// نوع MIME المعاد من خط الرفع.
  final String mimeType;

  /// Pixel width of the asset.
  ///
  /// العرض بالبكسل.
  final int width;

  /// Pixel height of the asset.
  ///
  /// الارتفاع بالبكسل.
  final int height;

  /// Optional alt text used by accessibility and SEO.
  ///
  /// النص البديل الاختياري المستخدم لإمكانية الوصول ومحركات البحث.
  final String? alt;

  /// Timestamp when the asset was uploaded.
  ///
  /// وقت رفع الوسيط.
  final DateTime uploadedAt;

  /// Identifier of the user who uploaded the asset.
  ///
  /// معرّف المستخدم الذي رفع الوسيط.
  final String uploadedBy;

  /// Display order inside the section gallery.
  ///
  /// ترتيب العرض داخل معرض القسم.
  final int order;

  /// Marks the asset as the primary visual.
  ///
  /// يميز الوسيط كصورة رئيسية.
  final bool isPrimary;

  /// Owning section when the asset is attached directly.
  ///
  /// القسم المالك عندما يكون الوسيط مرتبطًا مباشرة.
  final String? sectionId;

  /// Owning property-placement record when applicable.
  ///
  /// سجل موضع العقار المالك عند الاقتضاء.
  final String? propertyInSectionId;

  /// Owning unit-placement record when applicable.
  ///
  /// سجل موضع الوحدة المالك عند الاقتضاء.
  final String? unitInSectionId;

  /// Search and curation tags attached to the asset.
  ///
  /// وسوم البحث والتنظيم المرتبطة بالوسيط.
  final List<String> tags;

  /// Visual category for the media item.
  ///
  /// الفئة المرئية للوسيط.
  final ImageCategory category; // keep as string to avoid cross-feature enums
  /// Current processing state.
  ///
  /// الحالة الحالية للمعالجة.
  final ProcessingStatus processingStatus;

  /// Generated thumbnail URLs at different sizes.
  ///
  /// روابط الصور المصغرة بأحجام مختلفة.
  final ImageThumbnails thumbnails;

  /// Whether the asset is an image or a video.
  ///
  /// ما إذا كان الوسيط صورة أم فيديو.
  final MediaType mediaType; // image or video
  /// Optional poster image used when the asset is a video.
  ///
  /// صورة الغلاف الاختيارية عند كون الوسيط فيديو.
  final String? videoThumbnail;

  /// Video duration in seconds when the asset is a video.
  ///
  /// مدة الفيديو بالثواني عند كون الوسيط فيديو.
  final int? duration;

  /// Creates the media snapshot used by section galleries and cards.
  ///
  /// ينشئ لقطة الوسيط المستخدمة في معارض القسم والبطاقات.
  const SectionImage({
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
    this.sectionId,
    this.propertyInSectionId,
    this.unitInSectionId,
    this.tags = const [],
    this.category = ImageCategory.gallery,
    this.processingStatus = ProcessingStatus.ready,
    required this.thumbnails,
    this.mediaType = MediaType.image,
    this.videoThumbnail,
    this.duration,
  });

  /// Indicates whether the asset is ready for display.
  ///
  /// يحدد ما إذا كان الوسيط جاهزًا للعرض.
  bool get isReady => processingStatus == ProcessingStatus.ready;

  /// Indicates whether the asset represents a video.
  ///
  /// يحدد ما إذا كان الوسيط فيديو.
  bool get isVideo => mediaType == MediaType.video;

  /// Indicates whether the asset represents a still image.
  ///
  /// يحدد ما إذا كان الوسيط صورة ثابتة.
  bool get isImage => mediaType == MediaType.image;

  ///
  /// يعيد حجم الملف بالميغابايت للعرض.
  String get sizeInMB => (size / (1024 * 1024)).toStringAsFixed(2);

  ///
  /// يعيد الصورة المصغرة المستخدمة في المعاينات المختصرة.
  String get displayThumbnail {
    if (isVideo && videoThumbnail != null) return videoThumbnail!;
    return thumbnails.medium;
  }

  ///
  /// يعيد مدة الفيديو بصيغة `mm:ss` عند الحاجة.
  String get durationFormatted {
    if (duration == null) return '';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Keeps equality aligned with the media asset payload.
  ///
  /// يربط المقارنة بحمولة الوسيط.
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
        sectionId,
        propertyInSectionId,
        unitInSectionId,
        tags,
        category,
        processingStatus,
        thumbnails,
        mediaType,
        videoThumbnail,
        duration,
      ];
}

/// Holds the pre-generated thumbnail URLs used by the admin portal.
///
/// يحتفظ بروابط الصور المصغرة الجاهزة المستخدمة في بوابة الإدارة.
class ImageThumbnails extends Equatable {
  /// Small thumbnail URL.
  ///
  /// رابط الصورة المصغرة الصغيرة.
  final String small;

  /// Medium thumbnail URL.
  ///
  /// رابط الصورة المصغرة المتوسطة.
  final String medium;

  /// Large thumbnail URL.
  ///
  /// رابط الصورة المصغرة الكبيرة.
  final String large;

  /// High-definition thumbnail URL.
  ///
  /// رابط الصورة المصغرة عالية الدقة.
  final String hd;

  /// Creates the thumbnail bundle for a media asset.
  ///
  /// ينشئ حزمة الصور المصغرة الخاصة بالوسيط.
  const ImageThumbnails({
    required this.small,
    required this.medium,
    required this.large,
    required this.hd,
  });

  /// Keeps equality aligned with the thumbnail URLs.
  ///
  /// يربط المقارنة بروابط الصور المصغرة.
  @override
  List<Object> get props => [small, medium, large, hd];
}
