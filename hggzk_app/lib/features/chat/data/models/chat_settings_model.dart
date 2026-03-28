import '../../domain/entities/attachment.dart';

/// العربية: يمثل نموذج البيانات `ChatSettingsModel`.
class ChatSettingsModel extends ChatSettings {
  /// العربية: ينشئ مثيلًا جديدًا من `ChatSettingsModel`.
  const ChatSettingsModel({
    required super.id,
    required super.userId,
    super.notificationsEnabled,
    super.soundEnabled,
    super.showReadReceipts,
    super.showTypingIndicator,
    super.theme,
    super.fontSize,
    super.autoDownloadMedia,
    super.backupMessages,
  });

  /// العربية: ينشئ مثيلًا جديدًا من `ChatSettingsModel.fromJson`.
  factory ChatSettingsModel.fromJson(Map<String, dynamic> json) {
    return ChatSettingsModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      notificationsEnabled:
          json['notificationsEnabled'] ?? json['notifications_enabled'] ?? true,
      soundEnabled: json['soundEnabled'] ?? json['sound_enabled'] ?? true,
      showReadReceipts:
          json['showReadReceipts'] ?? json['show_read_receipts'] ?? true,
      showTypingIndicator:
          json['showTypingIndicator'] ?? json['show_typing_indicator'] ?? true,
      theme: json['theme'] ?? 'auto',
      fontSize: json['fontSize'] ?? json['font_size'] ?? 'medium',
      autoDownloadMedia:
          json['autoDownloadMedia'] ?? json['auto_download_media'] ?? true,
      backupMessages:
          json['backupMessages'] ?? json['backup_messages'] ?? false,
    );
  }

  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'notifications_enabled': notificationsEnabled,
      'sound_enabled': soundEnabled,
      'show_read_receipts': showReadReceipts,
      'show_typing_indicator': showTypingIndicator,
      'theme': theme,
      'font_size': fontSize,
      'auto_download_media': autoDownloadMedia,
      'backup_messages': backupMessages,
    };
  }
}
