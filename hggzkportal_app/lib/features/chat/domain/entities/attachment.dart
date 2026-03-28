import 'package:equatable/equatable.dart';
import 'dart:io';

/// يعرّف الكلاس `Attachment`.
/// Describes the `Attachment` class.
class Attachment extends Equatable {
  /// Holds the `id` value.
  /// العربية: يخزن القيمة `id`.
  final String id;

  /// يخزن العضو `conversationId`.
  /// Holds the `conversationId` member.
  final String conversationId;

  /// يخزن العضو `fileName`.
  /// Holds the `fileName` member.
  final String fileName;

  /// يخزن العضو `contentType`.
  /// Holds the `contentType` member.
  final String contentType; // MIME type
  /// يخزن العضو `fileSize`.
  /// Holds the `fileSize` member.
  final int fileSize;

  /// يخزن العضو `filePath`.
  /// Holds the `filePath` member.
  final String filePath;

  /// يخزن العضو `fileUrl`.
  /// Holds the `fileUrl` member.
  final String fileUrl;

  /// يخزن العضو `url`.
  /// Holds the `url` member.
  final String url;

  /// يخزن العضو `uploadedBy`.
  /// Holds the `uploadedBy` member.
  final String uploadedBy;

  /// يخزن العضو `createdAt`.
  /// Holds the `createdAt` member.
  final DateTime createdAt;

  /// يخزن العضو `thumbnailUrl`.
  /// Holds the `thumbnailUrl` member.
  final String? thumbnailUrl;

  /// يخزن العضو `metadata`.
  /// Holds the `metadata` member.
  final Map<String, dynamic>? metadata;
  // New optional fields used by UI
  /// يخزن العضو `duration`.
  /// Holds the `duration` member.
  final int? duration; // in seconds for audio/video
  /// يخزن العضو `downloadProgress`.
  /// Holds the `downloadProgress` member.
  final double? downloadProgress; // 0.0 - 1.0 (transient, not from backend)
  /// يخزن العضو `uploadProgress`.
  /// Holds the `uploadProgress` member.
  final double? uploadProgress; // 0.0 - 1.0 (transient)
  /// يخزن العضو `isUploading`.
  /// Holds the `isUploading` member.
  final bool isUploading;

  /// يخزن العضو `uploadError`.
  /// Holds the `uploadError` member.
  final String? uploadError;

  /// يخزن العضو `localFile`.
  /// Holds the `localFile` member.
  final File? localFile;

  /// يخزن العضو `width`.
  /// Holds the `width` member.
  final int? width;

  /// يخزن العضو `height`.
  /// Holds the `height` member.
  final int? height;

  /// يخزن العضو `blurhash`.
  /// Holds the `blurhash` member.
  final String? blurhash;

  /// ينشئ مثيلاً من `Attachment`.
  /// Builds an instance of `Attachment`.
  const Attachment({
    required this.id,
    required this.conversationId,
    required this.fileName,
    required this.contentType,
    required this.fileSize,
    required this.filePath,
    required this.fileUrl,
    required this.url,
    required this.uploadedBy,
    required this.createdAt,
    this.thumbnailUrl,
    this.metadata,
    this.duration,
    this.downloadProgress,
    this.uploadProgress,
    this.isUploading = false,
    this.uploadError,
    this.localFile,
    this.width,
    this.height,
    this.blurhash,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [
        id,
        conversationId,
        fileName,
        contentType,
        fileSize,
        filePath,
        fileUrl,
        url,
        uploadedBy,
        createdAt,
        thumbnailUrl,
        metadata,
        duration,
        downloadProgress,
        uploadProgress,
        isUploading,
        uploadError,
        localFile,
        width,
        height,
        blurhash,
      ];

  // Helper methods
  /// يعيد قيمة `fileExtension`.
  /// Exposes the `fileExtension` value.
  String get fileExtension => fileName.split('.').last.toLowerCase();

  /// يعيد قيمة `isImage`.
  /// Exposes the `isImage` value.
  bool get isImage => contentType.startsWith('image/');

  /// يعيد قيمة `isVideo`.
  /// Exposes the `isVideo` value.
  bool get isVideo => contentType.startsWith('video/');

  /// يعيد قيمة `isAudio`.
  /// Exposes the `isAudio` value.
  bool get isAudio => contentType.startsWith('audio/');

  /// يعيد قيمة `isDocument`.
  /// Exposes the `isDocument` value.
  bool get isDocument => !isImage && !isVideo && !isAudio;

  /// يعيد قيمة `formattedFileSize`.
  /// Exposes the `formattedFileSize` value.
  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024)
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024)
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// يعرّف الكلاس `ChatSettings`.
/// Describes the `ChatSettings` class.
class ChatSettings extends Equatable {
  /// Holds the `id` value.
  /// العربية: يخزن القيمة `id`.
  final String id;

  /// يخزن العضو `userId`.
  /// Holds the `userId` member.
  final String userId;

  /// يخزن العضو `notificationsEnabled`.
  /// Holds the `notificationsEnabled` member.
  final bool notificationsEnabled;

  /// يخزن العضو `soundEnabled`.
  /// Holds the `soundEnabled` member.
  final bool soundEnabled;

  /// يخزن العضو `showReadReceipts`.
  /// Holds the `showReadReceipts` member.
  final bool showReadReceipts;

  /// يخزن العضو `showTypingIndicator`.
  /// Holds the `showTypingIndicator` member.
  final bool showTypingIndicator;

  /// يخزن العضو `theme`.
  /// Holds the `theme` member.
  final String theme; // "light", "dark", "auto"
  /// يخزن العضو `fontSize`.
  /// Holds the `fontSize` member.
  final String fontSize; // "small", "medium", "large"
  /// يخزن العضو `autoDownloadMedia`.
  /// Holds the `autoDownloadMedia` member.
  final bool autoDownloadMedia;

  /// يخزن العضو `backupMessages`.
  /// Holds the `backupMessages` member.
  final bool backupMessages;

  /// ينشئ مثيلاً من `ChatSettings`.
  /// Builds an instance of `ChatSettings`.
  const ChatSettings({
    required this.id,
    required this.userId,
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.showReadReceipts = true,
    this.showTypingIndicator = true,
    this.theme = 'auto',
    this.fontSize = 'medium',
    this.autoDownloadMedia = true,
    this.backupMessages = false,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object> get props => [
        id,
        userId,
        notificationsEnabled,
        soundEnabled,
        showReadReceipts,
        showTypingIndicator,
        theme,
        fontSize,
        autoDownloadMedia,
        backupMessages,
      ];
}
