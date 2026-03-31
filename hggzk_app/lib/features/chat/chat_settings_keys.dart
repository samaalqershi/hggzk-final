/// Shared preference keys mirrored from chat settings so runtime services such
/// as notifications can react without waiting for the chat UI tree.
class ChatSettingsKeys {
  ChatSettingsKeys._();

  static const String notificationsEnabled = 'chat_notifications_enabled';
  static const String soundEnabled = 'chat_sound_enabled';
  static const String showReadReceipts = 'chat_show_read_receipts';
  static const String showTypingIndicator = 'chat_show_typing_indicator';
  static const String theme = 'chat_theme';
  static const String fontSize = 'chat_font_size';
  static const String autoDownloadMedia = 'chat_auto_download_media';
  static const String backupMessages = 'chat_backup_messages';
}
