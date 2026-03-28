import 'dart:io';

// معلومات رفع الصورة لعرض حالة الرفع في الواجهة
/// يعرّف الكلاس `ImageUploadInfo`.
/// Describes the `ImageUploadInfo` class.
class ImageUploadInfo {
  /// Holds the `id` value.
  /// العربية: يخزن القيمة `id`.
  final String id;

  /// يخزن العضو `file`.
  /// Holds the `file` member.
  final File? file;

  /// يخزن العضو `progress`.
  /// Holds the `progress` member.
  final double progress;

  /// يخزن العضو `isCompleted`.
  /// Holds the `isCompleted` member.
  final bool isCompleted;

  /// يخزن العضو `isFailed`.
  /// Holds the `isFailed` member.
  final bool isFailed;

  /// يخزن العضو `error`.
  /// Holds the `error` member.
  final String? error;

  /// ينشئ مثيلاً من `ImageUploadInfo`.
  /// Builds an instance of `ImageUploadInfo`.
  const ImageUploadInfo({
    required this.id,
    this.file,
    this.progress = 0.0,
    this.isCompleted = false,
    this.isFailed = false,
    this.error,
  });

  /// ينفذ العملية `copyWith`.
  /// Runs the `copyWith` operation.
  ImageUploadInfo copyWith({
    String? id,
    File? file,
    double? progress,
    bool? isCompleted,
    bool? isFailed,
    String? error,
  }) {
    return ImageUploadInfo(
      id: id ?? this.id,
      file: file ?? this.file,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      isFailed: isFailed ?? this.isFailed,
      error: error ?? this.error,
    );
  }
}
