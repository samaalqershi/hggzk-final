import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:hggzkportal/core/utils/media_file_safety.dart';

/// Describes the file paths and metadata produced after media preprocessing.
/// يصف المسارات والبيانات الوصفية الناتجة بعد معالجة الوسائط مسبقًا.
class MediaPreprocessResult {
  /// File path that should be uploaded to the backend.
  /// مسار الملف الذي يجب رفعه إلى الخادم.
  final String uploadPath;

  /// Optional thumbnail created for video uploads.
  /// صورة مصغرة اختيارية تُنشأ لرفع الفيديو.
  final String? thumbnailPath;

  /// Image width after preprocessing, when available.
  /// عرض الصورة بعد المعالجة إذا كان متاحًا.
  final int? width;

  /// Image height after preprocessing, when available.
  /// ارتفاع الصورة بعد المعالجة إذا كان متاحًا.
  final int? height;

  /// Video duration in seconds when it can be determined.
  /// مدة الفيديو بالثواني عندما يمكن تحديدها.
  final int? durationSeconds;

  /// Captures the normalized output path and any derived metadata.
  /// يلتقط المسار الموحد وأي بيانات وصفية مشتقة.
  const MediaPreprocessResult({
    required this.uploadPath,
    this.thumbnailPath,
    this.width,
    this.height,
    this.durationSeconds,
  });
}

/// Normalizes media before upload so the chat and admin flows can work with
/// stable file paths, thumbnails, and metadata.
/// يوحد الوسائط قبل الرفع حتى تعمل مسارات الشات والإدارة مع ملفات ولقطات
/// وبيانات مستقرة.
class MediaPipeline {
  /// Prepares media for upload by stabilizing the source file, compressing
  /// images, and extracting video thumbnails when possible.
  /// يجهز الوسائط للرفع عبر تثبيت الملف المصدر وضغط الصور واستخراج صورة
  /// مصغرة للفيديو عند الإمكان.
  Future<MediaPreprocessResult> preprocess({
    required String filePath,
    required String messageType,
  }) async {
    final normalizedType = messageType.trim().toLowerCase();
    final stableFile = await MediaFileSafety.ensureStableReadableCopy(
      filePath,
      namespace: normalizedType.isEmpty ? 'generic' : normalizedType,
    );
    if (stableFile == null) {
      _log('skip_invalid_source', {
        'messageType': normalizedType,
        'filePath': filePath,
        'lifecycle': MediaFileSafety.lifecycleState.name,
      });
      return MediaPreprocessResult(uploadPath: filePath);
    }

    final stablePath = stableFile.path;

    try {
      if (normalizedType == 'image') {
        // Compress image: resize to a reasonable bound and encode as JPEG
        if (!MediaFileSafety.canRunHeavyProcessing) {
          _log('skip_image_processing_in_background', {
            'filePath': stablePath,
            'lifecycle': MediaFileSafety.lifecycleState.name,
          });
          return MediaPreprocessResult(uploadPath: stablePath);
        }

        if (await stableFile.exists()) {
          final bytes = await stableFile.readAsBytes();
          final decoded = img.decodeImage(bytes);
          if (decoded != null) {
            // Limit longest side to 1920px to balance quality/size
            const int maxSide = 1920;
            final int w = decoded.width;
            final int h = decoded.height;
            img.Image imageForEncode = decoded;
            if (w > maxSide || h > maxSide) {
              imageForEncode = img.copyResize(
                decoded,
                width: w >= h ? maxSide : (w * maxSide ~/ h),
                height: h > w ? maxSide : (h * maxSide ~/ w),
                interpolation: img.Interpolation.average,
              );
            }
            final compressed = img.encodeJpg(imageForEncode, quality: 82);
            final tmpDir = await _ensureWorkingDirectory('image');
            final outPath =
                '${tmpDir.path}/cmp_${DateTime.now().microsecondsSinceEpoch}.jpg';
            final outFile = File(outPath);
            await outFile.writeAsBytes(compressed, flush: true);
            return MediaPreprocessResult(
              uploadPath: outPath,
              width: imageForEncode.width,
              height: imageForEncode.height,
            );
          }
        }
        // Fallback: original file if anything failed
        return MediaPreprocessResult(uploadPath: stablePath);
      }

      if (normalizedType == 'video') {
        if (!MediaFileSafety.canRunHeavyProcessing) {
          _log('skip_video_thumbnail_in_background', {
            'filePath': stablePath,
            'lifecycle': MediaFileSafety.lifecycleState.name,
          });
          return MediaPreprocessResult(uploadPath: stablePath);
        }

        final tmpDir = await _ensureWorkingDirectory('video');
        if (!MediaFileSafety.canRunHeavyProcessing) {
          return MediaPreprocessResult(uploadPath: stablePath);
        }
        final thumb = await VideoThumbnail.thumbnailFile(
          video: stablePath,
          thumbnailPath: tmpDir.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 512,
          quality: 75,
        );
        return MediaPreprocessResult(
          uploadPath: stablePath,
          thumbnailPath: thumb,
        );
      }

      // For images/doc/audio keep path as-is (safe default). Compression can be added later.
      return MediaPreprocessResult(uploadPath: stablePath);
    } catch (error, stackTrace) {
      _log(
        'preprocess_failed',
        {
          'messageType': normalizedType,
          'filePath': stablePath,
          'lifecycle': MediaFileSafety.lifecycleState.name,
          'error': error.toString(),
        },
        stackTrace: stackTrace,
      );
      return MediaPreprocessResult(uploadPath: stablePath);
    }
  }

  /// Creates a scratch directory used for temporary compressed media outputs.
  /// ينشئ مجلد عمل مؤقتًا لنتائج الوسائط المضغوطة.
  Future<Directory> _ensureWorkingDirectory(String namespace) async {
    final tempDir = await getTemporaryDirectory();
    final workingDir = Directory('${tempDir.path}/media_pipeline/$namespace');
    await workingDir.create(recursive: true);
    return workingDir;
  }

  /// Emits structured debug information for media-processing failures.
  /// يطبع معلومات تشخيصية منظمة عند فشل معالجة الوسائط.
  void _log(
    String event,
    Map<String, Object?> details, {
    StackTrace? stackTrace,
  }) {
    debugPrint('[MediaPipeline] $event | $details');
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }
}
