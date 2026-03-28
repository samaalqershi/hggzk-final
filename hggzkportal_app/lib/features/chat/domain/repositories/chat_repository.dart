import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';
import '../entities/attachment.dart';

/// يعرّف الكلاس المجرد `ChatRepository`.
/// Describes the abstract `ChatRepository` class.
abstract class ChatRepository {
  // Conversations
  /// ينفذ العملية `createConversation`.
  /// Runs the `createConversation` operation.
  Future<Either<Failure, Conversation>> createConversation({
    required List<String> participantIds,
    required String conversationType,
    String? title,
    String? description,
    String? propertyId,
  });

  /// ينفذ العملية `getConversations`.
  /// Runs the `getConversations` operation.
  Future<Either<Failure, List<Conversation>>> getConversations({
    required int pageNumber,
    required int pageSize,
  });

  /// ينفذ العملية `getConversationById`.
  /// Runs the `getConversationById` operation.
  Future<Either<Failure, Conversation>> getConversationById(
      String conversationId);

  /// ينفذ العملية `archiveConversation`.
  /// Runs the `archiveConversation` operation.
  Future<Either<Failure, void>> archiveConversation(String conversationId);

  /// ينفذ العملية `unarchiveConversation`.
  /// Runs the `unarchiveConversation` operation.
  Future<Either<Failure, void>> unarchiveConversation(String conversationId);

  /// ينفذ العملية `deleteConversation`.
  /// Runs the `deleteConversation` operation.
  Future<Either<Failure, void>> deleteConversation(String conversationId);

  // Messages
  /// ينفذ العملية `getMessages`.
  /// Runs the `getMessages` operation.
  Future<Either<Failure, List<Message>>> getMessages({
    required String conversationId,
    required int pageNumber,
    required int pageSize,
    String? beforeMessageId,
  });

  /// ينفذ العملية `sendMessage`.
  /// Runs the `sendMessage` operation.
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String messageType,
    String? content,
    Location? location,
    String? replyToMessageId,
    List<String>? attachmentIds,
  });

  /// ينفذ العملية `editMessage`.
  /// Runs the `editMessage` operation.
  Future<Either<Failure, Message>> editMessage({
    required String messageId,
    required String content,
  });

  /// ينفذ العملية `deleteMessage`.
  /// Runs the `deleteMessage` operation.
  Future<Either<Failure, void>> deleteMessage(String messageId);

  /// ينفذ العملية `markAsRead`.
  /// Runs the `markAsRead` operation.
  Future<Either<Failure, void>> markAsRead({
    required String conversationId,
    required List<String> messageIds,
  });

  // Reactions
  /// ينفذ العملية `addReaction`.
  /// Runs the `addReaction` operation.
  Future<Either<Failure, void>> addReaction({
    required String messageId,
    required String reactionType,
  });

  /// ينفذ العملية `removeReaction`.
  /// Runs the `removeReaction` operation.
  Future<Either<Failure, void>> removeReaction({
    required String messageId,
    required String reactionType,
  });

  // Attachments
  /// ينفذ العملية `uploadAttachment`.
  /// Runs the `uploadAttachment` operation.
  Future<Either<Failure, Attachment>> uploadAttachment({
    required String conversationId,
    required String filePath,
    required String messageType,
    String? thumbnailPath,
    ProgressCallback? onSendProgress,
  });

  /// ينفذ العملية `uploadMultipleAttachments`.
  /// Runs the `uploadMultipleAttachments` operation.
  Future<Either<Failure, List<Attachment>>> uploadMultipleAttachments({
    required String conversationId,
    required List<String> filePaths,
    required String messageType,
    ProgressCallback? onSendProgress,
  });

  // Search
  /// ينفذ العملية `searchChats`.
  /// Runs the `searchChats` operation.
  Future<Either<Failure, SearchResult>> searchChats({
    required String query,
    String? conversationId,
    String? messageType,
    String? senderId,
    DateTime? dateFrom,
    DateTime? dateTo,
    required int page,
    required int limit,
  });

  // Users
  /// ينفذ العملية `getAvailableUsers`.
  /// Runs the `getAvailableUsers` operation.
  Future<Either<Failure, List<ChatUser>>> getAvailableUsers({
    String? userType,
    String? propertyId,
  });

  /// ينفذ العملية `getAdminUsers`.
  /// Runs the `getAdminUsers` operation.
  Future<Either<Failure, List<ChatUser>>> getAdminUsers();

  /// ينفذ العملية `updateUserStatus`.
  /// Runs the `updateUserStatus` operation.
  Future<Either<Failure, void>> updateUserStatus(String status);

  // Settings
  /// ينفذ العملية `getChatSettings`.
  /// Runs the `getChatSettings` operation.
  Future<Either<Failure, ChatSettings>> getChatSettings();

  /// ينفذ العملية `updateChatSettings`.
  /// Runs the `updateChatSettings` operation.
  Future<Either<Failure, ChatSettings>> updateChatSettings({
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? showReadReceipts,
    bool? showTypingIndicator,
    String? theme,
    String? fontSize,
    bool? autoDownloadMedia,
    bool? backupMessages,
  });

  // Cache
  /// ينفذ العملية `cacheConversations`.
  /// Runs the `cacheConversations` operation.
  Future<void> cacheConversations(List<Conversation> conversations);

  /// ينفذ العملية `getCachedConversations`.
  /// Runs the `getCachedConversations` operation.
  Future<List<Conversation>?> getCachedConversations();

  /// ينفذ العملية `cacheMessages`.
  /// Runs the `cacheMessages` operation.
  Future<void> cacheMessages(String conversationId, List<Message> messages);

  /// ينفذ العملية `getCachedMessages`.
  /// Runs the `getCachedMessages` operation.
  Future<List<Message>?> getCachedMessages(String conversationId);

  /// ينفذ العملية `clearChatCache`.
  /// Runs the `clearChatCache` operation.
  Future<void> clearChatCache();
}

/// يعرّف الكلاس `SearchResult`.
/// Describes the `SearchResult` class.
class SearchResult {
  /// Holds the `messages` value.
  /// العربية: يخزن القيمة `messages`.
  final List<Message> messages;

  /// يخزن العضو `conversations`.
  /// Holds the `conversations` member.
  final List<Conversation> conversations;

  /// يخزن العضو `totalCount`.
  /// Holds the `totalCount` member.
  final int totalCount;

  /// يخزن العضو `hasMore`.
  /// Holds the `hasMore` member.
  final bool hasMore;

  /// يخزن العضو `nextPageNumber`.
  /// Holds the `nextPageNumber` member.
  final int? nextPageNumber;

  /// ينشئ مثيلاً من `SearchResult`.
  /// Builds an instance of `SearchResult`.
  const SearchResult({
    required this.messages,
    required this.conversations,
    required this.totalCount,
    required this.hasMore,
    this.nextPageNumber,
  });
}
