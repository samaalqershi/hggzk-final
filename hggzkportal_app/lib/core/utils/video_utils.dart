// lib/core/utils/video_utils.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:hggzkportal/core/utils/media_file_safety.dart';

class VideoUtils {
  static Future<String?> generateVideoThumbnail(String videoPath) async {
    try {
      final stableFile = await MediaFileSafety.ensureStableReadableCopy(
        videoPath,
        namespace: 'video_utils',
      );
      if (stableFile == null) return null;
      if (!MediaFileSafety.canRunHeavyProcessing) {
        debugPrint(
          '[VideoUtils] skip thumbnail generation in ${MediaFileSafety.lifecycleState.name} for ${stableFile.path}',
        );
        return null;
      }

      final tempDir = await getTemporaryDirectory();
      final thumbnailDir = Directory('${tempDir.path}/video_thumbnails');
      await thumbnailDir.create(recursive: true);

      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: stableFile.path,
        thumbnailPath: thumbnailDir.path,
        imageFormat: ImageFormat.PNG,
        maxHeight: 400,
        quality: 75,
      );
      return thumbnailPath;
    } catch (e) {
      debugPrint('Error generating video thumbnail: $e');
      return null;
    }
  }

  static Future<int?> getVideoDuration(String videoPath) async {
    try {
      // This would require FFmpeg or similar
      // For now, return null
      return null;
    } catch (e) {
      debugPrint('Error getting video duration: $e');
      return null;
    }
  }

  static bool isValidVideoFile(String filePath) {
    final normalizedPath = filePath.trim();
    if (normalizedPath.isEmpty) return false;

    final file = File(normalizedPath);
    if (!file.existsSync()) return false;

    final sizeInBytes = MediaFileSafety.safeFileLengthSync(normalizedPath);
    const maxSize = 100 * 1024 * 1024; // 100MB

    return sizeInBytes > 0 && sizeInBytes <= maxSize;
  }
}
