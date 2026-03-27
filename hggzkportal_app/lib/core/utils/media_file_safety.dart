import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

class MediaFileSafety {
  static AppLifecycleState get lifecycleState =>
      WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;

  static bool get canRunHeavyProcessing =>
      lifecycleState == AppLifecycleState.resumed;

  static Future<File?> resolveReadableFile(String filePath) async {
    final normalizedPath = filePath.trim();
    if (normalizedPath.isEmpty) return null;

    final file = File(normalizedPath);

    try {
      if (!await file.exists()) return null;
      final stat = await file.stat();
      if (stat.type != FileSystemEntityType.file) return null;
      if (stat.size <= 0) return null;
      return file;
    } catch (_) {
      return null;
    }
  }

  static Future<File?> ensureStableReadableCopy(
    String filePath, {
    required String namespace,
  }) async {
    final sourceFile = await resolveReadableFile(filePath);
    if (sourceFile == null) return null;

    try {
      final tempDir = await getTemporaryDirectory();
      final stagingDir = Directory('${tempDir.path}/stable_media/$namespace');
      await stagingDir.create(recursive: true);

      if (sourceFile.path.startsWith(stagingDir.path)) {
        return sourceFile;
      }

      final extension = _extractExtension(sourceFile.path);
      final stagedPath =
          '${stagingDir.path}/${DateTime.now().microsecondsSinceEpoch}${extension.isEmpty ? '' : '.$extension'}';

      final stagedFile = await sourceFile.copy(stagedPath);
      return await resolveReadableFile(stagedFile.path);
    } catch (_) {
      return sourceFile;
    }
  }

  static int safeFileLengthSync(String filePath) {
    final normalizedPath = filePath.trim();
    if (normalizedPath.isEmpty) return 0;

    try {
      final file = File(normalizedPath);
      if (!file.existsSync()) return 0;
      return file.lengthSync();
    } catch (_) {
      return 0;
    }
  }

  static String basename(String filePath) {
    final normalizedPath = filePath.trim();
    if (normalizedPath.isEmpty) return 'file';

    final separator = Platform.pathSeparator;
    final parts = normalizedPath.split(separator);
    final last = parts.isNotEmpty ? parts.last : normalizedPath;
    return last.isEmpty ? 'file' : last;
  }

  static String _extractExtension(String filePath) {
    final name = basename(filePath);
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex == name.length - 1) {
      return '';
    }
    return name.substring(dotIndex + 1).toLowerCase();
  }
}
