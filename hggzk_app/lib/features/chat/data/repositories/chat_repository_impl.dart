import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/attachment.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_datasource.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// العربية: يوفر سلوك المستودع الخاص بـ `ChatRepositoryImpl`.
class ChatRepositoryImpl implements ChatRepository {
  /// العربية: يخزن القيمة `remoteDataSource`.
  final ChatRemoteDataSource remoteDataSource;

  /// العربية: يخزن القيمة `localDataSource`.
  final ChatLocalDataSource localDataSource;

  /// العربية: يخزن القيمة `internetConnectionChecker`.
  final InternetConnectionChecker internetConnectionChecker;

  /// العربية: ينشئ مثيلًا جديدًا من `ChatRepositoryImpl`.
  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.internetConnectionChecker,
  });

  /// العربية: ينشئ conversation.
  @override
  Future<Either<Failure, Conversation>> createConversation({
    required List<String> participantIds,
    required String conversationType,
    String? title,
    String? description,
    String? propertyId,
  }) async {
    try {
      // استدعاء API - الآن يُرجع ConversationModel كامل
      final conversationModel = await remoteDataSource.createConversation(
        participantIds: participantIds,
        conversationType: conversationType,
        title: title,
        description: description,
        propertyId: propertyId,
      );

      // حفظ في الكاش وإشعار عبر WebSocket إن لزم
      try {
        await localDataSource.cacheConversations([conversationModel]);
      } catch (_) {}
      try {
        // من الممكن لاحقًا استخدام خدمة FCM/WebSocket
      } catch (_) {}

      // تحويل من Model إلى Entity
      return Right(conversationModel);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  /// العربية: يعيد conversations.
  Future<Either<Failure, List<Conversation>>> getConversations({
    required int pageNumber,
    required int pageSize,
  }) async {
    try {
      if (await internetConnectionChecker.hasConnection) {
        final conversations = await remoteDataSource.getConversations(
          pageNumber: pageNumber,
          pageSize: pageSize,
        );
        await localDataSource.cacheConversations(conversations);
        return Right(conversations);
      } else {
        final cachedConversations =
            await localDataSource.getCachedConversations();
        if (cachedConversations != null && cachedConversations.isNotEmpty) {
          return Right(cachedConversations);
        }
        return Left(
          NetworkFailure(AppLocalizations.translateSync('common.noInternet')),
        );
      }
    } catch (e) {
      return ErrorHandler.handle(e);
    }
  }

  /// العربية: يعيد conversation by id.
  @override
  Future<Either<Failure, Conversation>> getConversationById(
      String conversationId) async {
    if (!await internetConnectionChecker.hasConnection) {
      final cached =
          await localDataSource.getCachedConversationById(conversationId);
      if (cached != null) {
        return Right(cached);
      }
      return Left(
        NetworkFailure(AppLocalizations.translateSync('common.noInternet')),
      );
    }

    try {
      final conversation =
          await remoteDataSource.getConversationById(conversationId);
      return Right(conversation);
    } catch (e) {
      return ErrorHandler.handle(e);
    }
  }

  /// العربية: يعالج `archiveConversation`.
  @override
  Future<Either<Failure, void>> archiveConversation(
      String conversationId) async {
    if (!await internetConnectionChecker.hasConnection) {
      return Left(
        NetworkFailure(AppLocalizations.translateSync('common.noInternet')),
      );
    }

    try {
      await remoteDataSource.archiveConversation(conversationId);
      return const Right(null);
    } catch (e) {
      return ErrorHandler.handle(e);
    }
  }

  /// العربية: يعالج `unarchiveConversation`.
  @override
  Future<Either<Failure, void>> unarchiveConversation(
      String conversationId) async {
    if (!await internetConnectionChecker.hasConnection) {
      return Left(
        NetworkFailure(AppLocalizations.translateSync('common.noInternet')),
      );
    }

    try {
      await remoteDataSource.unarchiveConversation(conversationId);
      return const Right(null);
    } catch (e) {
      return ErrorHandler.handle(e);
    }
  }

  /// العربية: يحذف conversation.
  @override
  Future<Either<Failure, void>> deleteConversation(
      String conversationId) async {
    if (!await internetConnectionChecker.hasConnection) {
      return Left(
        NetworkFailure(AppLocalizations.translateSync('common.noInternet')),
      );
    }

    try {
      await remoteDataSource.deleteConversation(conversationId);
      await localDataSource.deleteConversationCache(conversationId);
      return const Right(null);
    } catch (e) {
      return ErrorHandler.handle(e);
    }
  }

  /// العربية: يعيد messages.
  @override
  Future<Either<Failure, List<Message>>> getMessages({
    required String conversationId,
    required int pageNumber,
    required int pageSize,
    String? beforeMessageId,
  }) async {
    try {
      if (await internetConnectionChecker.hasConnection) {
        final messages = await remoteDataSource.getMessages(
          conversationId: conversationId,
          pageNumber: pageNumber,
          pageSize: pageSize,
          beforeMessageId: beforeMessageId,
        );

        if (pageNumber == 1) {
          await localDataSource.cacheMessages(conversationId, messages);
        }

        return Right(messages);
      } else {
        final cachedMessages =
            await localDataSource.getCachedMessages(conversationId);
        if (cachedMessages != null && cachedMessages.isNotEmpty) {
          return Right(cachedMessages);
        }
        return Left(
          NetworkFailure(AppLocalizations.translateSync('common.noInternet')),
        );
      }
    } catch (e) {
      return ErrorHandler.handle(e);
    }
  }

  /// العربية: يرسل message.
  @override
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String messageType,
    String? content,
    Location? location,
    String? replyToMessageId,
    List<String>? attachmentIds,
  }) async {
    if (!await internetConnectionChecker.hasConnection) {
      // Queue message for later sending
      await localDataSource.queueMessage(
        conversationId: conversationId,
        messageType: messageType,
        content: content,
        location: location,
        replyToMessageId: replyToMessageId,
        attachmentIds: attachmentIds,
      );
      return Left(
        NetworkFailure(AppLocalizations.translateSync('chat.errors.network')),
      );
    }

    try {
      final message = await remoteDataSource.sendMessage(
        conversationId: conversationId,
        messageType: messageType,
        content: content,
        location: location,
        replyToMessageId: replyToMessageId,
        attachmentIds: attachmentIds,
      );

      // Update local cache
      await localDataSource.addMessageToCache(conversationId, message);

      return Right(message);
    } catch (e) {
      return ErrorHandler.handle(e);
    }
  }

  /// العربية: يعالج `editMessage`.
  @override
  Future<Either<Failure, Message>> editMessage({
    required String messageId,
    required String content,
  }) async {
    if (!await internetConnectionChecker.hasConnection) {
      return Left(
        NetworkFailure(AppLocalizations.translateSync('common.noInternet')),
      );
    }

    try {
      final message = await remoteDataSource.editMessage(
        messageId: messageId,
        content: content,
      );
      return Right(message);
    } catch (e) {
      return ErrorHandler.handle(e);
    }
  }

  /// العربية: يحذف message.
  @override
  Future<Either<Failure, void>> deleteMessage(String messageId) async {
    if (!await internetConnectionChecker.hasConnection) {
      return Left(
        NetworkFailure(AppLocalizations.translateSync('common.noInternet')),
      );
    }

    try {
      await remoteDataSource.deleteMessage(messageId);
      return const Right(null);
    } catch (e) {
      return ErrorHandler.handle(e);
    }
  }

  /// العربية: يعالج `markAsRead`.
  @override
  Future<Either<Failure, void>> markAsRead({
    required String conversationId,
    required List<String> messageIds,
  }) async {
    if (!await internetConnectionChecker.hasConnection) {
      return Left(
        NetworkFailure(AppLocalizations.translateSync('common.noInternet')),
      );
    }

    try {
      await remoteDataSource.markAsRead(
        conversationId: conversationId,
        messageIds: messageIds,
      );
      return const Right(null);
    } catch (e) {
      return ErrorHandler.handle(e);
    }
  }

  /// العربية: يعالج `addReaction`.
  @override
  Future<Either<Failure, void>> addReaction({
    required String messageId,
    required String reactionType,
  }) async {
    if (!await internetConnectionChecker.hasConnection) {
      return Left(
        NetworkFailure(AppLocalizations.translateSync('common.noInternet')),
      );
    }

    try {
      await remoteDataSource.addReaction(
        messageId: messageId,
        reactionType: reactionType,
      );
      return const Right(null);
    } catch (e) {
      return ErrorHandler.handle(e);
    }
  }

  /// العربية: يزيل reaction.
  @override
  Future<Either<Failure, void>> removeReaction({
    required String messageId,
    required String reactionType,
  }) async {
    if (!await internetConnectionChecker.hasConnection) {
      return Left(
        NetworkFailure(AppLocalizations.translateSync('common.noInternet')),
      );
    }

    try {
      await remoteDataSource.removeReaction(
        messageId: messageId,
        reactionType: reactionType,
      );
      return const Right(null);
    } catch (e) {
      return ErrorHandler.handle(e);
    }
  }

  /// العربية: يعالج `uploadAttachment`.
  @override
  Future<Either<Failure, Attachment>> uploadAttachment({
    required String conversationId,
    required String filePath,
    required String messageType,
    ProgressCallback? onSendProgress,
  }) async {
    if (!await internetConnectionChecker.hasConnection) {
      return Left(
        NetworkFailure(AppLocalizations.translateSync('common.noInternet')),
      );
    }

    try {
      final attachment = await remoteDataSource.uploadAttachment(
        conversationId: conversationId,
        filePath: filePath,
        messageType: messageType,
        onSendProgress: onSendProgress,
      );
      return Right(attachment);
    } catch (e) {
      return ErrorHandler.handle(e);
    }
  }

  /// العربية: يعالج `uploadMultipleAttachments`.
  @override
  Future<Either<Failure, List<Attachment>>> uploadMultipleAttachments({
    required String conversationId,
    required List<String> filePaths,
    required String messageType,
    ProgressCallback? onSendProgress,
  }) async {
    if (!await internetConnectionChecker.hasConnection) {
      return Left(
        NetworkFailure(AppLocalizations.translateSync('common.noInternet')),
      );
    }

    try {
      final attachments = <Attachment>[];
      for (final filePath in filePaths) {
        final attachment = await remoteDataSource.uploadAttachment(
          conversationId: conversationId,
          filePath: filePath,
          messageType: messageType,
          onSendProgress: onSendProgress,
        );
        attachments.add(attachment);
      }
      return Right(attachments);
    } catch (e) {
      return ErrorHandler.handle(e);
    }
  }

  /// العربية: يعالج `searchChats`.
  @override
  Future<Either<Failure, SearchResult>> searchChats({
    required String query,
    String? conversationId,
    String? messageType,
    String? senderId,
    DateTime? dateFrom,
    DateTime? dateTo,
    required int page,
    required int limit,
  }) async {
    if (!await internetConnectionChecker.hasConnection) {
      return Left(
        NetworkFailure(AppLocalizations.translateSync('common.noInternet')),
      );
    }

    try {
      final result = await remoteDataSource.searchChats(
        query: query,
        conversationId: conversationId,
        messageType: messageType,
        senderId: senderId,
        dateFrom: dateFrom,
        dateTo: dateTo,
        page: page,
        limit: limit,
      );
      return Right(result);
    } catch (e) {
      return ErrorHandler.handle(e);
    }
  }

  /// العربية: يعيد available users.
  @override
  Future<Either<Failure, List<ChatUser>>> getAvailableUsers({
    String? userType,
    String? propertyId,
  }) async {
    if (!await internetConnectionChecker.hasConnection) {
      return Left(
        NetworkFailure(AppLocalizations.translateSync('common.noInternet')),
      );
    }

    try {
      final users = await remoteDataSource.getAvailableUsers(
        userType: userType,
        propertyId: propertyId,
      );
      return Right(users);
    } catch (e) {
      return ErrorHandler.handle(e);
    }
  }

  /// العربية: يعيد admin users.
  @override
  Future<Either<Failure, List<ChatUser>>> getAdminUsers() async {
    if (!await internetConnectionChecker.hasConnection) {
      return Left(
        NetworkFailure(AppLocalizations.translateSync('common.noInternet')),
      );
    }

    try {
      final users = await remoteDataSource.getAdminUsers();
      return Right(users);
    } catch (e) {
      return ErrorHandler.handle(e);
    }
  }

  /// العربية: يحدّث user status.
  @override
  Future<Either<Failure, void>> updateUserStatus(String status) async {
    if (!await internetConnectionChecker.hasConnection) {
      return Left(
        NetworkFailure(AppLocalizations.translateSync('common.noInternet')),
      );
    }

    try {
      await remoteDataSource.updateUserStatus(status);
      return const Right(null);
    } catch (e) {
      return ErrorHandler.handle(e);
    }
  }

  /// العربية: يعيد chat settings.
  @override
  Future<Either<Failure, ChatSettings>> getChatSettings() async {
    try {
      // Try to get from cache first
      final cachedSettings = await localDataSource.getCachedSettings();
      if (cachedSettings != null) {
        if (await internetConnectionChecker.hasConnection) {
          // Fetch fresh settings in background
          remoteDataSource.getChatSettings().then((settings) {
            localDataSource.cacheSettings(settings);
          }).catchError((_) {});
        }
        return Right(cachedSettings);
      }

      if (!await internetConnectionChecker.hasConnection) {
        return Left(
          NetworkFailure(AppLocalizations.translateSync('common.noInternet')),
        );
      }

      final settings = await remoteDataSource.getChatSettings();
      await localDataSource.cacheSettings(settings);
      return Right(settings);
    } catch (e) {
      return ErrorHandler.handle(e);
    }
  }

  /// العربية: يحدّث chat settings.
  @override
  Future<Either<Failure, ChatSettings>> updateChatSettings({
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? showReadReceipts,
    bool? showTypingIndicator,
    String? theme,
    String? fontSize,
    bool? autoDownloadMedia,
    bool? backupMessages,
  }) async {
    if (!await internetConnectionChecker.hasConnection) {
      return Left(
        NetworkFailure(AppLocalizations.translateSync('common.noInternet')),
      );
    }

    try {
      final settings = await remoteDataSource.updateChatSettings(
        notificationsEnabled: notificationsEnabled,
        soundEnabled: soundEnabled,
        showReadReceipts: showReadReceipts,
        showTypingIndicator: showTypingIndicator,
        theme: theme,
        fontSize: fontSize,
        autoDownloadMedia: autoDownloadMedia,
        backupMessages: backupMessages,
      );
      await localDataSource.cacheSettings(settings);
      return Right(settings);
    } catch (e) {
      return ErrorHandler.handle(e);
    }
  }

  /// العربية: يعالج `cacheConversations`.
  @override
  Future<void> cacheConversations(List<Conversation> conversations) async {
    await localDataSource.cacheConversations(
      conversations.map((c) => ConversationModel.fromEntity(c)).toList(),
    );
  }

  /// العربية: يعيد cached conversations.
  @override
  Future<List<Conversation>?> getCachedConversations() async {
    return await localDataSource.getCachedConversations();
  }

  /// العربية: يعالج `cacheMessages`.
  @override
  Future<void> cacheMessages(
      String conversationId, List<Message> messages) async {
    await localDataSource.cacheMessages(
      conversationId,
      messages.map((m) => MessageModel.fromEntity(m)).toList(),
    );
  }

  /// العربية: يعيد cached messages.
  @override
  Future<List<Message>?> getCachedMessages(String conversationId) async {
    return await localDataSource.getCachedMessages(conversationId);
  }

  /// العربية: يعالج `clearChatCache`.
  @override
  Future<void> clearChatCache() async {
    await localDataSource.clearAllCache();
  }
}
