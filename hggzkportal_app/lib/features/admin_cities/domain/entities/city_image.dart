import 'package:equatable/equatable.dart';

/// Describes the semantic bucket assigned to a city media asset.
///
/// يحدد الفئة الدلالية التي ينتمي إليها ملف الوسائط الخاص بالمدينة.
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

/// Tracks the lifecycle of a city image while it is being uploaded or processed.
///
/// يتابع حالة صورة المدينة أثناء الرفع أو المعالجة أو الحذف.
enum ProcessingStatus {
  uploading,
  processing,
  ready,
  failed,
  deleted,
}

/// Distinguishes between still images and playable video assets.
///
/// يميز بين الصور الثابتة والملفات المرئية القابلة للتشغيل.
enum MediaType {
  image,
  video,
}

/// Immutable view of a city media asset with metadata needed by the admin UI.
///
/// تمثيل ثابت لملف وسائط المدينة مع البيانات الوصفية التي تحتاجها الواجهة الإدارية.
class CityImage extends Equatable {
  /// Stable identifier used to update, reorder, or delete the media item.
  ///
  /// معرّف ثابت يُستخدم لتحديث عنصر الوسائط أو ترتيبه أو حذفه.
  final String id;

  /// Canonical URL returned by the backend for the primary media file.
  ///
  /// الرابط المعتمد الذي يعيده الخادم للملف الرئيسي للوسائط.
  final String url;

  /// Original filename or backend-generated label shown in admin tools.
  ///
  /// اسم الملف الأصلي أو التسمية التي ينتجها الخادم وتظهر في أدوات الإدارة.
  final String filename;

  /// Raw file size in bytes, useful for validation and display.
  ///
  /// حجم الملف بالبايت، ويُستخدم في التحقق والعرض.
  final int size;

  /// MIME type reported for the media item.
  ///
  /// نوع MIME الذي أبلغ به الخادم لهذا الملف.
  final String mimeType;

  /// Pixel width reported for the asset when available.
  ///
  /// العرض بالبكسل عندما تكون هذه المعلومة متاحة.
  final int width;

  /// Pixel height reported for the asset when available.
  ///
  /// الارتفاع بالبكسل عندما تكون هذه المعلومة متاحة.
  final int height;

  /// Optional caption or accessibility description for the asset.
  ///
  /// وصف اختياري أو نص بديل يساعد على الوصولية.
  final String? alt;

  /// Time when the asset was uploaded or first registered.
  ///
  /// وقت رفع الملف أو تسجيله أول مرة.
  final DateTime uploadedAt;

  /// User or system identity that created the upload record.
  ///
  /// هوية المستخدم أو النظام الذي أنشأ سجل الرفع.
  final String uploadedBy;

  /// Ordering value used to present the city gallery in a predictable sequence.
  ///
  /// قيمة الترتيب المستخدمة لعرض معرض المدينة بشكل ثابت.
  final int order;

  /// Marks the image that should act as the primary cover asset.
  ///
  /// يحدد الصورة التي يجب أن تعمل كغلاف رئيسي.
  final bool isPrimary;

  /// Owning city identifier when the image is bound to a persisted city record.
  ///
  /// معرّف المدينة المالكة عندما يكون الملف مرتبطًا بسجل مدينة محفوظ.
  final String? cityId;

  /// High-level category used by filters and presentation rules.
  ///
  /// الفئة العامة التي تعتمد عليها المرشحات وقواعد العرض.
  final ImageCategory category;

  /// Free-form labels used to organize assets by theme or usage.
  ///
  /// وسوم مرنة لتنظيم الملفات حسب الموضوع أو الاستخدام.
  final List<String> tags;

  /// Current backend processing stage of the asset.
  ///
  /// المرحلة الحالية لمعالجة الملف في الخادم.
  final ProcessingStatus processingStatus;

  /// URLs for the available thumbnail sizes.
  ///
  /// روابط الصور المصغرة المتاحة بأحجام مختلفة.
  final ImageThumbnails thumbnails;

  /// Declares whether the asset is a still image or a video.
  ///
  /// يحدد ما إذا كان الملف صورة ثابتة أم فيديو.
  final MediaType mediaType;

  /// Optional preview image generated for video assets.
  ///
  /// صورة معاينة اختيارية تُولد لملفات الفيديو.
  final String? videoThumbnail;

  /// Video length in seconds when the backend provides duration metadata.
  ///
  /// مدة الفيديو بالثواني عندما يوفّرها الخادم.
  final int? duration;

  /// Creates a city image snapshot with all display metadata intact.
  ///
  /// ينشئ نسخة ثابتة من صورة المدينة مع كامل البيانات اللازمة للعرض.
  const CityImage({
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
    this.cityId,
    required this.category,
    this.tags = const [],
    required this.processingStatus,
    required this.thumbnails,
    this.mediaType = MediaType.image,
    this.videoThumbnail,
    this.duration,
  });

  /// Indicates that the backend has finished processing and the asset is usable.
  ///
  /// يوضح أن الخادم أنهى المعالجة ويمكن استخدام الملف.
  bool get isReady => processingStatus == ProcessingStatus.ready;

  /// Indicates that the asset should be treated as a video in the UI.
  ///
  /// يوضح أن الملف يجب التعامل معه على أنه فيديو داخل الواجهة.
  bool get isVideo => mediaType == MediaType.video;

  /// Indicates that the asset should be treated as a static image.
  ///
  /// يوضح أن الملف يجب التعامل معه على أنه صورة ثابتة.
  bool get isImage => mediaType == MediaType.image;

  /// Returns the file size formatted in megabytes for admin display.
  ///
  /// يعرض حجم الملف بصيغة ميغابايت مناسبة لواجهة الإدارة.
  String get sizeInMB => (size / (1024 * 1024)).toStringAsFixed(2);

  /// Chooses the most appropriate thumbnail source for the current asset type.
  ///
  /// يختار أفضل مصدر للمعاينة بحسب نوع الملف الحالي.
  String get displayThumbnail {
    if (isVideo && videoThumbnail != null) return videoThumbnail!;
    return thumbnails.medium;
  }

  /// Formats the duration as `mm:ss` for compact playback previews.
  ///
  /// ينسّق مدة الفيديو بصيغة `mm:ss` لعرض معاينة مختصرة.
  String get durationFormatted {
    if (duration == null) return '';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// يحدد الحقول التي تدخل في المقارنة القيمة-بالقيمة لصورة المدينة
  /// حتى تتعامل طبقات الحالة مع التحديثات المتطابقة بوصفها عنصرًا واحدًا.
  /// Defines the value-based comparison fields for a city image so state
  /// layers can treat matching updates as the same item.
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
        cityId,
        category,
        tags,
        processingStatus,
        thumbnails,
        mediaType,
        duration,
        videoThumbnail,
      ];
}

/// Holds the different thumbnail resolutions returned by the media pipeline.
///
/// يحتفظ بمقاسات الصور المصغرة المختلفة التي يعيدها خط معالجة الوسائط.
class ImageThumbnails extends Equatable {
  /// Small thumbnail used in dense lists and compact cards.
  ///
  /// الصورة المصغرة الصغيرة المستخدمة في القوائم والبطاقات المدمجة.
  final String small;

  /// Medium thumbnail intended for standard admin previews.
  ///
  /// الصورة المصغرة المتوسطة المخصصة لمعاينات الإدارة المعتادة.
  final String medium;

  /// Large thumbnail used when the UI needs more detail.
  ///
  /// الصورة المصغرة الكبيرة المستخدمة عندما تحتاج الواجهة إلى تفاصيل أكثر.
  final String large;

  /// High-definition thumbnail for large screens or zoomed preview flows.
  ///
  /// الصورة عالية الدقة للشاشات الكبيرة أو لمسارات المعاينة المكبرة.
  final String hd;

  /// Creates a thumbnail bundle with explicit URLs for every resolution.
  ///
  /// ينشئ حزمة صور مصغرة بروابط محددة لكل دقة.
  const ImageThumbnails({
    required this.small,
    required this.medium,
    required this.large,
    required this.hd,
  });

  /// يحدد روابط الصور المصغرة التي يجب فحصها عند مقارنة حزمة المعاينات
  /// أو إعادة استخدامها بين عناصر واجهة الإدارة.
  /// Defines the thumbnail URLs that should be compared when reusing or
  /// deduplicating preview bundles in the admin UI.
  @override
  List<Object> get props => [small, medium, large, hd];
}
