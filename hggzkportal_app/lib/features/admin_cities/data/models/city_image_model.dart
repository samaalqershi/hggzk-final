// lib/features/admin_properties/data/models/city_image_model.dart

import 'package:hggzkportal/core/constants/api_constants.dart';
import 'package:hggzkportal/core/constants/app_constants.dart';
import '../../domain/entities/city_image.dart';

/// API-facing model for city media that normalizes URLs and metadata.
///
/// نموذج مخصص لوسائط المدن يطبع الروابط والبيانات الوصفية قبل العرض أو الحفظ.
class CityImageModel extends CityImage {
  /// Creates a transport model instance for a city media record.
  ///
  /// ينشئ نموذج نقل لسجل وسائط المدينة.
  const CityImageModel({
    required super.id,
    required super.url,
    required super.filename,
    required super.size,
    required super.mimeType,
    required super.width,
    required super.height,
    super.alt,
    required super.uploadedAt,
    required super.uploadedBy,
    required super.order,
    required super.isPrimary,
    super.cityId,
    required super.category,
    super.tags,
    required super.processingStatus,
    required super.thumbnails,
    super.mediaType,
    super.duration,
    super.videoThumbnail,
  });

  /// ينشئ رابطًا صالحًا لوسائط المدينة حتى لا تبقى الواجهة أمام مسار
  /// فارغ أو نسبي أو غير قابل للعرض.
  /// Builds a valid city-media URL so the UI never receives an empty, relative,
  /// or non-renderable path.
  static String _validateUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://via.placeholder.com/400x300?text=No+Image';
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      if (url.startsWith('/')) {
        return '${ApiConstants.imageBaseUrl}$url';
      }
      return 'https://via.placeholder.com/400x300?text=$url';
    }

    return url;
  }

  /// يحدد نوع الوسيط اعتمادًا على الحقل الصريح أو على MIME أو على اسم
  /// الملف عندما تكون البيانات ناقصة.
  /// Determines the media type from the explicit field, MIME type, or
  /// filename when the payload is incomplete.
  static MediaType _detectMediaType(Map<String, dynamic> json) {
    // Prefer an explicit mediaType when the backend already provides it.
    if (json['mediaType'] != null) {
      return _parseMediaType(json['mediaType'].toString());
    }

    // Fall back to the MIME type when the dedicated field is absent.
    final mimeType = json['mimeType']?.toString() ?? '';
    if (mimeType.startsWith('video/')) {
      return MediaType.video;
    }

    // Derive the type from the filename as a last portable fallback.
    final filename = json['filename']?.toString() ?? '';
    if (AppConstants.isVideoFile(filename)) {
      return MediaType.video;
    }

    return MediaType.image;
  }

  /// يبني نموذج وسائط المدينة من JSON الوارد من الخادم أو الكاش المحلي.
  /// Builds the city-media model from JSON received from the backend or the
  /// local cache.
  factory CityImageModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedTags = [];
    if (json['tags'] != null) {
      if (json['tags'] is List) {
        parsedTags = (json['tags'] as List).map((e) => e.toString()).toList();
      } else if (json['tags'] is String) {
        final tagsString = json['tags'] as String;
        if (tagsString.isNotEmpty) {
          parsedTags = tagsString
              .split(RegExp(r'[,\s]+'))
              .where((tag) => tag.isNotEmpty)
              .toList();
        }
      }
    }

    final url =
        _validateUrl(json['url'] ?? json['imageUrl'] ?? json['videoUrl']);
    final mediaType = _detectMediaType(json);
    final videoThumbnail = mediaType == MediaType.video
        ? _validateUrl(
            json['videoThumbnail'] ?? json['thumbnail'] ?? json['poster'])
        : null;

    return CityImageModel(
      id: (json['id'] ??
          json['imageId'] ??
          json['videoId'] ??
          DateTime.now().millisecondsSinceEpoch.toString()) as String,
      url: url,
      filename: (json['filename'] ?? json['name'] ?? 'media.jpg') as String,
      size: (json['size'] as num?)?.toInt() ?? 0,
      mimeType: (json['mimeType'] ?? json['type'] ?? 'image/jpeg') as String,
      width: (json['width'] as num?)?.toInt() ?? 0,
      height: (json['height'] as num?)?.toInt() ?? 0,
      alt: json['alt'] as String?,
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.tryParse(json['uploadedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      uploadedBy: (json['uploadedBy'] ?? json['ownerId'] ?? '') as String,
      order: (json['order'] as num?)?.toInt() ?? 0,
      isPrimary: (json['isPrimary'] as bool?) ?? false,
      cityId: json['cityId'] as String?,
      category: _parseImageCategory((json['category'] ?? 'gallery').toString()),
      tags: parsedTags,
      processingStatus: _parseProcessingStatus(
          (json['processingStatus'] ?? 'ready').toString()),
      thumbnails: _parseThumbnails(json['thumbnails'], videoThumbnail ?? url),
      mediaType: mediaType,
      duration: (json['duration'] as num?)?.toInt(),
      videoThumbnail: videoThumbnail,
    );
  }

  /// يطبع معلومات الصور المصغرة إلى شكل ثابت حتى تستطيع الواجهة عرض
  /// بدائل متعددة للوسيط نفسه.
  /// Normalizes thumbnail information into a stable shape so the UI can show
  /// multiple variants for the same media item.
  static ImageThumbnails _parseThumbnails(
      dynamic thumbnailsData, String fallbackUrl) {
    if (thumbnailsData == null) {
      return ImageThumbnailsModel(
        small: fallbackUrl,
        medium: fallbackUrl,
        large: fallbackUrl,
        hd: fallbackUrl,
      );
    }

    if (thumbnailsData is Map<String, dynamic>) {
      return ImageThumbnailsModel.fromJson(thumbnailsData, fallbackUrl);
    }

    if (thumbnailsData is String) {
      final validUrl = _validateUrl(thumbnailsData);
      return ImageThumbnailsModel(
        small: validUrl,
        medium: validUrl,
        large: validUrl,
        hd: validUrl,
      );
    }

    return ImageThumbnailsModel(
      small: fallbackUrl,
      medium: fallbackUrl,
      large: fallbackUrl,
      hd: fallbackUrl,
    );
  }

  /// Serializes the media record into the shape expected by the API layer.
  ///
  /// يحول سجل الوسائط إلى الصيغة التي تتوقعها طبقة الـ API.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'filename': filename,
      'size': size,
      'mimeType': mimeType,
      'width': width,
      'height': height,
      'alt': alt,
      'uploadedAt': uploadedAt.toIso8601String(),
      'uploadedBy': uploadedBy,
      'order': order,
      'isPrimary': isPrimary,
      'cityId': cityId,
      'category': _imageCategoryToString(category),
      'tags': tags,
      'processingStatus': _processingStatusToString(processingStatus),
      'thumbnails': (thumbnails as ImageThumbnailsModel).toJson(),
      'mediaType': _mediaTypeToString(mediaType),
      if (duration != null) 'duration': duration,
      if (videoThumbnail != null) 'videoThumbnail': videoThumbnail,
    };
  }

  /// يحول فئة الوسيط النصية إلى قيمة `ImageCategory` الداخلية.
  /// Converts the textual media category into the internal `ImageCategory`
  /// value.
  static ImageCategory _parseImageCategory(String value) {
    switch (value.toLowerCase()) {
      case 'exterior':
        return ImageCategory.exterior;
      case 'interior':
        return ImageCategory.interior;
      case 'amenity':
        return ImageCategory.amenity;
      case 'floor_plan':
      case 'floorplan':
        return ImageCategory.floorPlan;
      case 'documents':
        return ImageCategory.documents;
      case 'avatar':
        return ImageCategory.avatar;
      case 'cover':
        return ImageCategory.cover;
      case 'video':
        return ImageCategory.video;
      default:
        return ImageCategory.gallery;
    }
  }

  /// يحول فئة الصورة إلى النص المعتمد في طبقة النقل أو الحفظ.
  /// Converts the image category into the transport/persistence string value.
  static String _imageCategoryToString(ImageCategory category) {
    switch (category) {
      case ImageCategory.exterior:
        return 'exterior';
      case ImageCategory.interior:
        return 'interior';
      case ImageCategory.amenity:
        return 'amenity';
      case ImageCategory.floorPlan:
        return 'floor_plan';
      case ImageCategory.documents:
        return 'documents';
      case ImageCategory.avatar:
        return 'avatar';
      case ImageCategory.cover:
        return 'cover';
      case ImageCategory.gallery:
        return 'gallery';
      case ImageCategory.video:
        return 'video';
    }
  }

  /// يحول حالة معالجة الوسيط النصية إلى قيمة `ProcessingStatus`.
  /// Converts the textual processing state into a `ProcessingStatus` value.
  static ProcessingStatus _parseProcessingStatus(String value) {
    switch (value.toLowerCase()) {
      case 'uploading':
        return ProcessingStatus.uploading;
      case 'processing':
        return ProcessingStatus.processing;
      case 'ready':
        return ProcessingStatus.ready;
      case 'failed':
        return ProcessingStatus.failed;
      case 'deleted':
        return ProcessingStatus.deleted;
      default:
        return ProcessingStatus.processing;
    }
  }

  /// يعيد حالة المعالجة إلى النص الذي يفهمه الـ API عند الحفظ أو التحديث.
  /// Converts the processing state back into the string the API expects when
  /// saving or updating.
  static String _processingStatusToString(ProcessingStatus status) {
    switch (status) {
      case ProcessingStatus.uploading:
        return 'uploading';
      case ProcessingStatus.processing:
        return 'processing';
      case ProcessingStatus.ready:
        return 'ready';
      case ProcessingStatus.failed:
        return 'failed';
      case ProcessingStatus.deleted:
        return 'deleted';
    }
  }

  /// يحول نوع الوسيط النصي إلى `MediaType` داخلي ثابت.
  /// Converts a textual media-type value into the internal `MediaType` enum.
  static MediaType _parseMediaType(String value) {
    switch (value.toLowerCase()) {
      case 'video':
        return MediaType.video;
      case 'image':
      default:
        return MediaType.image;
    }
  }

  /// يعيد نوع الوسيط إلى النص الذي يحافظ على التوافق مع الخادم.
  /// Converts the media type back to the text used for backend compatibility.
  static String _mediaTypeToString(MediaType type) {
    switch (type) {
      case MediaType.video:
        return 'video';
      case MediaType.image:
        return 'image';
    }
  }
}

/// Serializes thumbnail variants for a city image.
///
/// يحول نسخ الصور المصغرة المختلفة الخاصة بصورة المدينة.
class ImageThumbnailsModel extends ImageThumbnails {
  /// Creates a thumbnail bundle for the API payload.
  ///
  /// ينشئ حزمة صور مصغرة لحمولة الـ API.
  const ImageThumbnailsModel({
    required super.small,
    required super.medium,
    required super.large,
    required super.hd,
  });

  /// يبني حزمة الصور المصغرة من JSON مع بديل آمن عند غياب القيم.
  /// Builds the thumbnail bundle from JSON with a safe fallback when values
  /// are missing.
  factory ImageThumbnailsModel.fromJson(Map<String, dynamic> json,
      [String? fallbackUrl]) {
    final fallback =
        fallbackUrl ?? 'https://via.placeholder.com/400x300?text=No+Image';
    return ImageThumbnailsModel(
      small:
          CityImageModel._validateUrl(json['small'] ?? json['s'] ?? fallback),
      medium:
          CityImageModel._validateUrl(json['medium'] ?? json['m'] ?? fallback),
      large:
          CityImageModel._validateUrl(json['large'] ?? json['l'] ?? fallback),
      hd: CityImageModel._validateUrl(json['hd'] ?? json['xl'] ?? fallback),
    );
  }

  /// Serializes every thumbnail variant into JSON.
  ///
  /// يحول كل نسخة من الصور المصغرة إلى JSON.
  Map<String, dynamic> toJson() {
    return {
      'small': small,
      'medium': medium,
      'large': large,
      'hd': hd,
    };
  }
}
