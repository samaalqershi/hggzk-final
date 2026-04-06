import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../../core/localization/app_localizations.dart';
import '../models/chat_settings_model.dart';
import '../models/chat_user_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/error/exceptions.dart' hide ApiException;
import '../../../../core/utils/request_logger.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/attachment_model.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Remote contract for chat conversations, messages, users, and settings.
/// العقدة البعيدة للمحادثات والرسائل والمستخدمين والإعدادات.
abstract class ChatRemoteDataSource {
  /// Creates a conversation on the server.
  /// ينشئ محادثة على الخادم.
  Future<ConversationModel> createConversation({
    required List<String> participantIds,
    required String conversationType,
    String? title,
    String? description,
    String? propertyId,
  });

  /// Loads a page of conversations from the backend.
  /// يحمل صفحة من المحادثات من الخادم.
  Future<List<ConversationModel>> getConversations({
    required int pageNumber,
    required int pageSize,
  });

  /// Fetches one conversation snapshot by id.
  /// يجلب لقطة محادثة واحدة بواسطة المعرّف.
  Future<ConversationModel> getConversationById(String conversationId);

  /// Archives one conversation on the server.
  /// يؤرشف محادثة واحدة على الخادم.
  Future<void> archiveConversation(String conversationId);

  /// Restores an archived conversation on the server.
  /// يعيد محادثة مؤرشفة على الخادم.
  Future<void> unarchiveConversation(String conversationId);

  /// Deletes one conversation on the server.
  /// يحذف محادثة واحدة على الخادم.
  Future<void> deleteConversation(String conversationId);

  /// Loads a page of messages for one conversation.
  /// يحمل صفحة من الرسائل لمحادثة واحدة.
  Future<List<MessageModel>> getMessages({
    required String conversationId,
    required int pageNumber,
    required int pageSize,
    String? beforeMessageId,
  });

  /// Sends one outbound message.
  /// يرسل رسالة واحدة صادرة.
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String messageType,
    String? content,
    Location? location,
    String? replyToMessageId,
    List<String>? attachmentIds,
  });

  /// Updates an existing message on the server.
  /// يحدّث رسالة موجودة على الخادم.
  Future<MessageModel> editMessage({
    required String messageId,
    required String content,
  });

  /// Deletes one message from the server.
  /// يحذف رسالة واحدة من الخادم.
  Future<void> deleteMessage(String messageId);

  /// Marks the provided messages as read.
  /// يعلّم الرسائل المقدمة كمقروءة.
  Future<void> markAsRead({
    required String conversationId,
    required List<String> messageIds,
  });

  /// Adds a reaction to a message on the server.
  /// يضيف تفاعلًا إلى رسالة على الخادم.
  Future<void> addReaction({
    required String messageId,
    required String reactionType,
  });

  /// Removes a reaction from a message on the server.
  /// يزيل تفاعلًا من رسالة على الخادم.
  Future<void> removeReaction({
    required String messageId,
    required String reactionType,
  });

  /// Uploads one attachment for the given conversation.
  /// يرفع مرفقًا واحدًا للمحادثة المحددة.
  Future<AttachmentModel> uploadAttachment({
    required String conversationId,
    required String filePath,
    required String messageType,
    int? durationSeconds,
    ProgressCallback? onSendProgress,
  });

  /// Searches chats and messages on the backend.
  /// يبحث في المحادثات والرسائل على الخادم.
  Future<SearchResult> searchChats({
    required String query,
    String? conversationId,
    String? messageType,
    String? senderId,
    DateTime? dateFrom,
    DateTime? dateTo,
    required int page,
    required int limit,
  });

  /// Loads users that can join a conversation.
  /// يحمل المستخدمين الذين يمكنهم الانضمام إلى محادثة.
  Future<List<ChatUserModel>> getAvailableUsers({
    String? userType,
    String? propertyId,
  });

  /// Loads users with administrative permissions.
  /// يحمل المستخدمين ذوي الصلاحيات الإدارية.
  Future<List<ChatUserModel>> getAdminUsers();

  /// Updates the current user's presence status.
  /// يحدّث حالة حضور المستخدم الحالي.
  Future<void> updateUserStatus(String status);

  /// Loads the current chat preference snapshot.
  /// يحمل لقطة تفضيلات الدردشة الحالية.
  Future<ChatSettingsModel> getChatSettings();

  /// Persists one or more chat preferences.
  /// يحفظ تفضيلًا واحدًا أو أكثر من تفضيلات الدردشة.
  Future<ChatSettingsModel> updateChatSettings({
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? showReadReceipts,
    bool? showTypingIndicator,
    String? theme,
    String? fontSize,
    bool? autoDownloadMedia,
    bool? backupMessages,
  });
}

/// HTTP implementation of the chat remote data source.
/// تنفيذ HTTP لمصدر بيانات الدردشة البعيد.
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  /// Network client used for all chat API requests.
  /// عميل الشبكة المستخدم لجميع طلبات واجهة الدردشة.
  final ApiClient apiClient;

  /// Builds the remote data source around the shared API client.
  /// يبني مصدر البيانات البعيد حول عميل الـ API المشترك.
  ChatRemoteDataSourceImpl({required this.apiClient});

  ServerException _unexpectedChatException() {
    return ServerException(
      AppLocalizations.translateSync('common.unexpectedError'),
    );
  }

  /// Creates a conversation on the server and returns the new snapshot.
  /// ينشئ محادثة على الخادم ويعيد اللقطة الجديدة.
  @override
  Future<ConversationModel> createConversation({
    required List<String> participantIds,
    required String conversationType,
    String? title,
    String? description,
    String? propertyId,
  }) async {
    const requestName = 'chat.createConversation';

    // تنظيف المعرفات
    final cleanParticipantIds = participantIds
        .where((id) => id.isNotEmpty)
        .map((id) => id.trim())
        .toList();

    if (cleanParticipantIds.isEmpty) {
      throw ServerException(
          AppLocalizations.translateSync('chat.errors.validation'));
    }

    logRequestStart(requestName, details: {
      'participantIdsCount': cleanParticipantIds.length,
      'conversationType': conversationType,
      if (propertyId != null) 'propertyId': propertyId,
    });

    try {
      final response = await apiClient.post(
        '/api/common/chat/conversations',
        data: {
          'participantIds': cleanParticipantIds,
          'conversationType': conversationType,
          if (title != null && title.isNotEmpty) 'title': title,
          if (description != null && description.isNotEmpty)
            'description': description,
          if (propertyId != null && propertyId.isNotEmpty)
            'propertyId': propertyId,
        },
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.data['success'] == true && response.data['data'] != null) {
        return ConversationModel.fromJson(
            response.data['data'] as Map<String, dynamic>);
      }

      final errorMessage = response.data['message'] ??
          AppLocalizations.translateSync('chat.errors.unknown');
      throw ServerException(errorMessage);
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);

      // معالجة أفضل للأخطاء
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final data = e.response!.data;
        final message =
            data is Map ? (data['message'] ?? data['title'] ?? '') : '';

        if (statusCode == 400) {
          throw ServerException(
            message.isNotEmpty
                ? message
                : AppLocalizations.translateSync('chat.errors.validation'),
          );
        } else if (statusCode == 404) {
          throw ServerException(
            AppLocalizations.translateSync('chat.errors.notFound'),
          );
        } else if (statusCode == 500) {
          throw ServerException(
            AppLocalizations.translateSync('chat.errors.server'),
          );
        }
      }

      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw _unexpectedChatException();
    }
  }

  /// العربية: يعيد conversations.
  @override
  Future<List<ConversationModel>> getConversations({
    required int pageNumber,
    required int pageSize,
  }) async {
    const requestName = 'chat.getConversations';
    logRequestStart(requestName, details: {
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    });
    try {
      final response = await apiClient.get(
        '/api/common/chat/conversations',
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.data['conversations'] != null) {
        return (response.data['conversations'] as List)
            .map((json) => ConversationModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw _unexpectedChatException();
    }
  }

  /// العربية: يعيد conversation by id.
  @override
  Future<ConversationModel> getConversationById(String conversationId) async {
    const requestName = 'chat.getConversationById';
    logRequestStart(requestName, details: {
      'conversationId': conversationId,
    });
    try {
      final response = await apiClient.get(
        '/api/common/chat/conversations/$conversationId',
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.data['success'] == true && response.data['data'] != null) {
        return ConversationModel.fromJson(response.data['data']);
      }
      throw ServerException(
        response.data['message'] ??
            AppLocalizations.translateSync('chat.system.conversationNotFound'),
      );
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw _unexpectedChatException();
    }
  }

  /// العربية: يعالج `archiveConversation`.
  @override
  Future<void> archiveConversation(String conversationId) async {
    const requestName = 'chat.archiveConversation';
    logRequestStart(requestName, details: {'conversationId': conversationId});
    try {
      final response = await apiClient.post(
        '/api/common/chat/conversations/$conversationId/archive',
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.data['success'] != true) {
        throw ServerException(
          response.data['message'] ??
              AppLocalizations.translateSync('chat.errors.unknown'),
        );
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw _unexpectedChatException();
    }
  }

  /// العربية: يعالج `unarchiveConversation`.
  @override
  Future<void> unarchiveConversation(String conversationId) async {
    const requestName = 'chat.unarchiveConversation';
    logRequestStart(requestName, details: {'conversationId': conversationId});
    try {
      final response = await apiClient.post(
        '/api/common/chat/conversations/$conversationId/unarchive',
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.data['success'] != true) {
        throw ServerException(
          response.data['message'] ??
              AppLocalizations.translateSync('chat.errors.unknown'),
        );
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw _unexpectedChatException();
    }
  }

  /// العربية: يحذف conversation.
  @override
  Future<void> deleteConversation(String conversationId) async {
    const requestName = 'chat.deleteConversation';
    logRequestStart(requestName, details: {'conversationId': conversationId});
    try {
      final response = await apiClient.delete(
        '/api/common/chat/conversations/$conversationId',
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.data['success'] != true) {
        throw ServerException(
          response.data['message'] ??
              AppLocalizations.translateSync('chat.errors.unknown'),
        );
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw _unexpectedChatException();
    }
  }

  /// العربية: يعيد messages.
  @override
  Future<List<MessageModel>> getMessages({
    required String conversationId,
    required int pageNumber,
    required int pageSize,
    String? beforeMessageId,
  }) async {
    const requestName = 'chat.getMessages';
    logRequestStart(requestName, details: {
      'conversationId': conversationId,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      if (beforeMessageId != null) 'beforeMessageId': beforeMessageId,
    });
    try {
      final response = await apiClient.get(
        '/api/common/chat/conversations/$conversationId/messages',
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          if (beforeMessageId != null) 'beforeMessageId': beforeMessageId,
        },
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.data['messages'] != null) {
        return (response.data['messages'] as List)
            .map((json) => MessageModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw _unexpectedChatException();
    }
  }

  /// العربية: يرسل message.
  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String messageType,
    String? content,
    Location? location,
    String? replyToMessageId,
    List<String>? attachmentIds,
  }) async {
    const requestName = 'chat.sendMessage';
    logRequestStart(requestName, details: {
      'conversationId': conversationId,
      'messageType': messageType,
    });

    try {
      // تحقق من صحة البيانات
      if (messageType == 'text' && (content == null || content.isEmpty)) {
        throw ServerException(
          AppLocalizations.translateSync('chat.errors.validation'),
        );
      }

      // استخدم FormData لأن الـ backend يتوقع [FromForm]
      final formData = FormData.fromMap({
        'conversationId': conversationId,
        'messageType': messageType,
        if (content != null && content.isNotEmpty) 'content': content,
        if (location != null)
          'locationJson': jsonEncode({
            'latitude': location.latitude,
            'longitude': location.longitude,
            if (location.address != null) 'address': location.address,
          }),
        if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
        if (attachmentIds != null && attachmentIds.isNotEmpty)
          for (int i = 0; i < attachmentIds.length; i++)
            'attachmentIds[$i]': attachmentIds[i],
      });

      final response = await apiClient.post(
        '/api/common/chat/conversations/$conversationId/messages',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;

        // تحويل message_id إلى id للتوافق مع MessageModel
        if (data.containsKey('message_id')) {
          data['id'] = data['message_id'];
        }

        // التحقق من البيانات المطلوبة
        if (data['messageType'] == null ||
            data['messageType'].toString().isEmpty) {
          data['messageType'] = messageType; // استخدم القيمة المرسلة
        }

        if (messageType == 'text' && data['content'] == null) {
          data['content'] = content; // استخدم القيمة المرسلة
        }

        // تعيين status إذا كان فارغاً
        if (data['status'] == null || data['status'].toString().isEmpty) {
          data['status'] = 'sent';
        }

        return MessageModel.fromJson(data);
      }

      throw ServerException(
        AppLocalizations.translateSync('chat.errors.unknown'),
      );
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);

      if (e.response?.statusCode == 400) {
        final message = e.response?.data?['message'] ??
            AppLocalizations.translateSync('chat.errors.validation');
        throw ServerException(message);
      }

      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw _unexpectedChatException();
    }
  }

  /// العربية: يعالج `editMessage`.
  @override
  Future<MessageModel> editMessage({
    required String messageId,
    required String content,
  }) async {
    const requestName = 'chat.editMessage';
    logRequestStart(requestName, details: {'messageId': messageId});
    try {
      final response = await apiClient.put(
        '/api/common/chat/messages/$messageId',
        data: {
          'content': content,
        },
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.data['success'] == true && response.data['data'] != null) {
        return MessageModel.fromJson(response.data['data']);
      }
      throw ServerException(
        response.data['message'] ??
            AppLocalizations.translateSync('chat.errors.messageSendFailed'),
      );
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw _unexpectedChatException();
    }
  }

  /// العربية: يحذف message.
  @override
  Future<void> deleteMessage(String messageId) async {
    const requestName = 'chat.deleteMessage';
    logRequestStart(requestName, details: {'messageId': messageId});
    try {
      final response = await apiClient.delete(
        '/api/common/chat/messages/$messageId',
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.data['success'] != true) {
        throw ServerException(
          response.data['message'] ??
              AppLocalizations.translateSync('chat.errors.unknown'),
        );
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw _unexpectedChatException();
    }
  }

  /// العربية: يعالج `markAsRead`.
  @override
  Future<void> markAsRead({
    required String conversationId,
    required List<String> messageIds,
  }) async {
    const requestName = 'chat.markAsRead';
    logRequestStart(requestName, details: {
      'conversationId': conversationId,
      'messageIdsCount': messageIds.length,
    });
    try {
      for (final messageId in messageIds) {
        final response = await apiClient.put(
          '/api/common/chat/messages/$messageId/status',
          data: {
            'status': 'read',
          },
        );
        logRequestSuccess(requestName, statusCode: response.statusCode);
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw _unexpectedChatException();
    }
  }

  /// العربية: يعالج `addReaction`.
  @override
  Future<void> addReaction({
    required String messageId,
    required String reactionType,
  }) async {
    const requestName = 'chat.addReaction';
    logRequestStart(requestName, details: {
      'messageId': messageId,
      'reactionType': reactionType,
    });
    try {
      final response = await apiClient.post(
        '/api/common/chat/messages/$messageId/reactions',
        data: {
          'reactionType': reactionType,
        },
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.data['success'] != true) {
        throw ServerException(
          response.data['message'] ??
              AppLocalizations.translateSync('chat.errors.reactionAddFailed'),
        );
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw _unexpectedChatException();
    }
  }

  /// العربية: يزيل reaction.
  @override
  Future<void> removeReaction({
    required String messageId,
    required String reactionType,
  }) async {
    const requestName = 'chat.removeReaction';
    logRequestStart(requestName, details: {
      'messageId': messageId,
      'reactionType': reactionType,
    });
    try {
      final response = await apiClient.delete(
        '/api/common/chat/messages/$messageId/reactions/$reactionType',
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.data['success'] != true) {
        throw ServerException(
          response.data['message'] ??
              AppLocalizations.translateSync(
                  'chat.errors.reactionRemoveFailed'),
        );
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw _unexpectedChatException();
    }
  }

  /// العربية: يعالج `uploadAttachment`.
  @override
  Future<AttachmentModel> uploadAttachment({
    required String conversationId,
    required String filePath,
    required String messageType,
    int? durationSeconds,
    ProgressCallback? onSendProgress,
  }) async {
    const requestName = 'chat.uploadAttachment';
    logRequestStart(requestName, details: {
      'conversationId': conversationId,
      'filePath': filePath,
      'messageType': messageType,
      if (durationSeconds != null) 'durationSeconds': durationSeconds,
    });
    String? fileName;
    int? fileSize;
    try {
      final file = File(filePath);
      fileName = file.path.split('/').last;
      fileSize = await file.length();
      final thumbnailPath = messageType.toLowerCase() == 'video'
          ? await _generateVideoThumbnailForUpload(filePath)
          : null;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        if (thumbnailPath != null)
          'thumbnail': await MultipartFile.fromFile(
            thumbnailPath,
            filename:
                '${file.uri.pathSegments.isNotEmpty ? file.uri.pathSegments.last.split('.').first : 'video'}_thumb.jpg',
          ),
        'messageType': messageType,
        'conversationId': conversationId,
        if (durationSeconds != null) 'durationSeconds': durationSeconds,
      });

      final response = await apiClient.upload(
        '/api/common/chat/upload',
        formData: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          extra: {
            'suppressErrorToast': true,
          },
        ),
        onSendProgress: onSendProgress,
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final attachmentPayload =
            responseData['data'] ?? responseData['attachment'];
        if (attachmentPayload is Map<String, dynamic>) {
          return AttachmentModel.fromJson(attachmentPayload);
        }
      }
      throw ServerException(
        (responseData is Map<String, dynamic>
                ? responseData['message']
                : null) ??
            AppLocalizations.translateSync('chat.errors.unknown'),
      );
    } on ApiException catch (e, s) {
      logRequestError(
          requestName,
          {
            'message': e.message,
            'statusCode': e.statusCode,
            'type': e.type?.name,
            'data': e.data,
            'conversationId': conversationId,
            'filePath': filePath,
            'fileName': fileName,
            'fileSize': fileSize,
            'messageType': messageType,
          },
          stackTrace: s);
      throw ServerException(e.message);
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw _unexpectedChatException();
    }
  }

  Future<String?> _generateVideoThumbnailForUpload(String videoPath) async {
    try {
      return await VideoThumbnail.thumbnailFile(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 640,
        quality: 70,
        thumbnailPath: Directory.systemTemp.path,
      );
    } catch (_) {
      return null;
    }
  }

  /// العربية: يعالج `searchChats`.
  @override
  Future<SearchResult> searchChats({
    required String query,
    String? conversationId,
    String? messageType,
    String? senderId,
    DateTime? dateFrom,
    DateTime? dateTo,
    required int page,
    required int limit,
  }) async {
    const requestName = 'chat.searchChats';
    logRequestStart(requestName, details: {
      'query': query,
      if (conversationId != null) 'conversationId': conversationId,
      if (messageType != null) 'messageType': messageType,
      if (senderId != null) 'senderId': senderId,
      if (dateFrom != null) 'dateFrom': dateFrom.toIso8601String(),
      if (dateTo != null) 'dateTo': dateTo.toIso8601String(),
      'page': page,
      'limit': limit,
    });
    try {
      final response = await apiClient.get(
        '/api/common/chat/search',
        queryParameters: {
          'query': query,
          if (conversationId != null) 'conversationId': conversationId,
          if (messageType != null) 'messageType': messageType,
          if (senderId != null) 'senderId': senderId,
          if (dateFrom != null) 'dateFrom': dateFrom.toIso8601String(),
          if (dateTo != null) 'dateTo': dateTo.toIso8601String(),
          'page': page,
          'limit': limit,
        },
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      final data = response.data as Map<String, dynamic>;
      final messages = (data['messages'] as List? ?? const [])
          .map((j) => MessageModel.fromJson(j))
          .toList();
      final conversations = (data['conversations'] as List? ?? const [])
          .map((j) => ConversationModel.fromJson(j))
          .toList();
      final totalCount = (data['total'] ?? data['totalCount']) as int? ?? 0;
      final hasMore = (data['hasMore'] as bool?) ?? (data['nextPage'] != null);
      final nextPageNumber = data['nextPage'] ?? data['nextPageNumber'];

      return SearchResult(
        messages: messages,
        conversations: conversations,
        totalCount: totalCount,
        hasMore: hasMore,
        nextPageNumber: nextPageNumber as int?,
      );
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw _unexpectedChatException();
    }
  }

  /// العربية: يعيد available users.
  @override
  Future<List<ChatUserModel>> getAvailableUsers({
    String? userType,
    String? propertyId,
  }) async {
    const requestName = 'chat.getAvailableUsers';
    logRequestStart(requestName, details: {
      if (userType != null) 'userType': userType,
      if (propertyId != null) 'propertyId': propertyId,
    });
    try {
      final response = await apiClient.get(
        '/api/common/chat/users/available',
        queryParameters: {
          if (userType != null) 'userType': userType,
          if (propertyId != null) 'propertyId': propertyId,
        },
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.data is Map<String, dynamic> &&
          response.data['users'] != null) {
        return (response.data['users'] as List)
            .map((json) => ChatUserModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw _unexpectedChatException();
    }
  }

  /// العربية: يعيد admin users.
  @override
  Future<List<ChatUserModel>> getAdminUsers() async {
    const requestName = 'chat.getAdminUsers';
    logRequestStart(requestName);
    try {
      final response = await apiClient.get(
        '/api/common/chat/users/admins',
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.data is Map<String, dynamic> &&
          response.data['users'] != null) {
        return (response.data['users'] as List)
            .map((json) => ChatUserModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw _unexpectedChatException();
    }
  }

  /// العربية: يحدّث user status.
  @override
  Future<void> updateUserStatus(String status) async {
    const requestName = 'chat.updateUserStatus';
    logRequestStart(requestName, details: {'status': status});
    try {
      final response = await apiClient.put(
        '/api/common/chat/users/status',
        data: {
          'status': status,
        },
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      final raw = response.data;
      if (raw is Map<String, dynamic>) {
        final success = raw['success'];
        if (success == null || success == true) {
          return;
        }

        throw ServerException(
          raw['message'] ??
              AppLocalizations.translateSync('chat.errors.unknown'),
        );
      }

      if ((response.statusCode ?? 0) >= 200 &&
          (response.statusCode ?? 0) < 300) {
        return;
      }

      throw ServerException(
        AppLocalizations.translateSync('chat.errors.unknown'),
      );
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw _unexpectedChatException();
    }
  }

  /// العربية: يعيد chat settings.
  @override
  Future<ChatSettingsModel> getChatSettings() async {
    const requestName = 'chat.getChatSettings';
    logRequestStart(requestName);
    try {
      final response = await apiClient.get('/api/common/chat/settings');

      logRequestSuccess(requestName, statusCode: response.statusCode);

      dynamic raw = response.data;
      // قد يأتي الرد مباشرة كجسم DTO أو داخل غلاف success/data
      Map<String, dynamic>? dataMap;
      if (raw is Map<String, dynamic>) {
        if (raw.containsKey('data')) {
          // شكل: { success: true, data: {...} }
          final successVal = raw['success'];
          final inner = raw['data'];
          if (successVal == true && inner is Map<String, dynamic>) {
            dataMap = inner;
          }
        }
        // شكل مباشرة: { id:..., userId:..., notificationsEnabled:... }
        if (dataMap == null &&
            (raw.containsKey('id') ||
                raw.containsKey('userId') ||
                raw.containsKey('user_id'))) {
          dataMap = raw;
        }
      }

      if (dataMap != null) {
        return ChatSettingsModel.fromJson(dataMap);
      }

      // إذا وصل الرد بدون بيانات صالحة نعيد الافتراضي بدل رمي خطأ
      return const ChatSettingsModel(id: '', userId: '');
    } on DioException catch (e, s) {
      // معالجة متوقعة في حالة عدم وجود إعدادات (أول مرة) => إعادة افتراضي بدون تسجيل كخطأ حرج
      final msg = e.response?.data is Map
          ? (e.response?.data['message']?.toString() ?? '')
          : '';
      final normalizedMessage = msg.toLowerCase();
      final notFound = e.response?.statusCode == 404 || msg.contains('إعدادات');
      final settingsMissing = normalizedMessage.contains('settings');
      if (settingsMissing) {
        logRequestSuccess('$requestName.not_found_fallback',
            statusCode: e.response?.statusCode);
        return const ChatSettingsModel(id: '', userId: '');
      }
      if (notFound) {
        logRequestSuccess('$requestName.not_found_fallback',
            statusCode: e.response?.statusCode);
        return const ChatSettingsModel(id: '', userId: '');
      }
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } on ApiException catch (e, s) {
      final normalizedMessage = e.message.toLowerCase();
      final notFound = e.statusCode == 404 || e.message.contains('إعدادات');
      final settingsMissing = normalizedMessage.contains('settings');
      if (settingsMissing) {
        logRequestSuccess('$requestName.not_found_fallback',
            statusCode: e.statusCode);
        return const ChatSettingsModel(id: '', userId: '');
      }
      if (notFound) {
        logRequestSuccess('$requestName.not_found_fallback',
            statusCode: e.statusCode);
        return const ChatSettingsModel(id: '', userId: '');
      }
      logRequestError(requestName, e, stackTrace: s);
      rethrow;
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw _unexpectedChatException();
    }
  }

  /// العربية: يحدّث chat settings.
  @override
  Future<ChatSettingsModel> updateChatSettings({
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? showReadReceipts,
    bool? showTypingIndicator,
    String? theme,
    String? fontSize,
    bool? autoDownloadMedia,
    bool? backupMessages,
  }) async {
    const requestName = 'chat.updateChatSettings';
    logRequestStart(requestName);
    try {
      final response = await apiClient.put(
        '/api/common/chat/settings',
        data: {
          if (notificationsEnabled != null)
            'notificationsEnabled': notificationsEnabled,
          if (soundEnabled != null) 'soundEnabled': soundEnabled,
          if (showReadReceipts != null) 'showReadReceipts': showReadReceipts,
          if (showTypingIndicator != null)
            'showTypingIndicator': showTypingIndicator,
          if (theme != null) 'theme': theme,
          if (fontSize != null) 'fontSize': fontSize,
          if (autoDownloadMedia != null) 'autoDownloadMedia': autoDownloadMedia,
          if (backupMessages != null) 'backupMessages': backupMessages,
        },
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      dynamic raw = response.data;
      Map<String, dynamic>? dataMap;
      if (raw is Map<String, dynamic>) {
        if (raw.containsKey('data')) {
          final successVal = raw['success'];
          final inner = raw['data'];
          if ((successVal == null || successVal == true) &&
              inner is Map<String, dynamic>) {
            dataMap = inner;
          }
        }
        if (dataMap == null &&
            (raw.containsKey('id') ||
                raw.containsKey('userId') ||
                raw.containsKey('user_id'))) {
          dataMap = raw;
        }
      }

      if (dataMap != null) {
        return ChatSettingsModel.fromJson(dataMap);
      }

      final errorMessage = (raw is Map<String, dynamic>)
          ? (raw['message']?.toString() ??
              AppLocalizations.translateSync('chat.settings.updateFailed'))
          : AppLocalizations.translateSync('chat.settings.updateFailed');
      throw ServerException(errorMessage);
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ApiException.fromDioError(e);
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw _unexpectedChatException();
    }
  }
}
