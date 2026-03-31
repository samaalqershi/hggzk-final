import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_manager.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/websocket_service.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';
import '../../chat_settings_keys.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/search_chats_usecase.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/attachment.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/get_conversations_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/create_conversation_usecase.dart';
import '../../domain/usecases/delete_conversation_usecase.dart';
import '../../domain/usecases/archive_conversation_usecase.dart';
import '../../domain/usecases/unarchive_conversation_usecase.dart';
import '../../domain/usecases/delete_message_usecase.dart';
import '../../domain/usecases/edit_message_usecase.dart';
import '../../domain/usecases/add_reaction_usecase.dart';
import '../../domain/usecases/remove_reaction_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';
import '../../domain/usecases/upload_attachment_usecase.dart';
import '../../domain/usecases/get_available_users_usecase.dart';
import '../../domain/usecases/get_admin_users_usecase.dart';
import '../../domain/usecases/update_user_status_usecase.dart';
import '../../domain/usecases/get_chat_settings_usecase.dart';
import '../../domain/usecases/update_chat_settings_usecase.dart';
part 'chat_event.dart';
part 'chat_state.dart';

/// Coordinates inbox loading, message history, realtime updates, and
/// composer actions for the chat feature.
/// ينسق تحميل الصندوق وسجل الرسائل والتحديثات اللحظية وأفعال المحرر في
/// ميزة الدردشة.
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  static const String _localThumbnailMetadataKey = 'localThumbnailPath';

  /// Loads the paginated list of conversations.
  /// يحمل قائمة المحادثات المرقمة.
  final GetConversationsUseCase getConversationsUseCase;

  /// Loads the messages for a single conversation.
  /// يحمل رسائل محادثة واحدة.
  final GetMessagesUseCase getMessagesUseCase;

  /// Sends outbound messages through the domain layer.
  /// يرسل الرسائل الصادرة عبر طبقة المجال.
  final SendMessageUseCase sendMessageUseCase;

  /// Creates new conversations for selected participants.
  /// ينشئ محادثات جديدة للمشاركين المختارين.
  final CreateConversationUseCase createConversationUseCase;

  /// Deletes conversations from the active list.
  /// يحذف المحادثات من القائمة النشطة.
  final DeleteConversationUseCase deleteConversationUseCase;

  /// Archives conversations without deleting them.
  /// يؤرشف المحادثات دون حذفها.
  final ArchiveConversationUseCase archiveConversationUseCase;

  /// Restores archived conversations back into the inbox.
  /// يعيد المحادثات المؤرشفة إلى الصندوق الوارد.
  final UnarchiveConversationUseCase unarchiveConversationUseCase;

  /// Deletes a single message from a conversation.
  /// يحذف رسالة واحدة من المحادثة.
  final DeleteMessageUseCase deleteMessageUseCase;

  /// Updates the text of an existing message.
  /// يحدّث نص رسالة موجودة.
  final EditMessageUseCase editMessageUseCase;

  /// Adds a reaction to a message.
  /// يضيف تفاعلًا إلى رسالة.
  final AddReactionUseCase addReactionUseCase;

  /// Removes a reaction from a message.
  /// يزيل تفاعلًا من رسالة.
  final RemoveReactionUseCase removeReactionUseCase;

  /// Marks messages as read after the user views them.
  /// يعلّم الرسائل كمقروءة بعد أن يراها المستخدم.
  final MarkAsReadUseCase markAsReadUseCase;

  /// Uploads media and file attachments before sending.
  /// يرفع الوسائط والملفات قبل الإرسال.
  final UploadAttachmentUseCase uploadAttachmentUseCase;

  /// Searches across conversations and messages.
  /// يبحث عبر المحادثات والرسائل.
  final SearchChatsUseCase searchChatsUseCase;

  /// Loads users that can be added to a thread.
  /// يحمل المستخدمين الذين يمكن إضافتهم إلى سلسلة.
  final GetAvailableUsersUseCase getAvailableUsersUseCase;

  /// Loads admin-capable users for staff workflows.
  /// يحمل المستخدمين ذوي الصلاحيات الإدارية لمسارات الطاقم.
  final GetAdminUsersUseCase getAdminUsersUseCase;

  /// Updates the local user's chat presence.
  /// يحدّث حالة حضور المستخدم في الدردشة.
  final UpdateUserStatusUseCase updateUserStatusUseCase;

  /// Loads the persisted chat preferences.
  /// يحمل تفضيلات الدردشة المخزنة.
  final GetChatSettingsUseCase getChatSettingsUseCase;

  /// Persists partial or full chat preference updates.
  /// يحفظ تحديثات تفضيلات الدردشة الجزئية أو الكاملة.
  final UpdateChatSettingsUseCase updateChatSettingsUseCase;

  /// Resolves the active authenticated user.
  /// يحدد المستخدم المصادق عليه الحالي.
  final GetCurrentUserUseCase getCurrentUserUseCase;

  /// Bridges websocket streams into bloc events.
  /// يربط تيارات websocket بأحداث الـ bloc.
  final ChatWebSocketService webSocketService;

  /// Persists runtime chat preferences so other services can react immediately.
  /// يحفظ تفضيلات الشات وقت التشغيل حتى تتفاعل الخدمات الأخرى مباشرة.
  final LocalStorageService localStorageService;

  // Active websocket subscriptions.
  /// Subscription that forwards incoming chat messages.
  StreamSubscription? _webSocketMessagesSubscription;

  /// Subscription that forwards typing indicator updates.
  StreamSubscription? _webSocketTypingSubscription;

  /// Subscription that forwards presence updates.
  StreamSubscription? _webSocketPresenceSubscription;

  /// Subscription that forwards conversation updates.
  StreamSubscription? _webSocketConversationSubscription;

  // Loading state per conversation.
  /// Tracks whether a conversation is currently fetching data.
  final Map<String, bool> _conversationLoadingStates = {};

  /// Remembers the last loaded page number per conversation.
  final Map<String, int> _messagePages = {};

  /// Tracks whether older messages still exist for a thread.
  final Map<String, bool> _hasMoreMessages = {};

  // Deduplicates already loaded messages.
  /// Message ids already seen by the bloc.
  final Map<String, Set<String>> _loadedMessageIds = {};

  // Optimistic message queue.
  /// Temporarily staged messages that wait for server confirmation.
  final Map<String, List<Message>> _optimisticMessages = {};

  /// Guards against the same local voice note being dispatched twice from the
  /// recorder gesture lifecycle.
  final Map<String, DateTime> _recentAudioDispatches = {};

  // Active attachment uploads.
  /// Upload tasks currently running for chat.
  final Map<String, UploadTask> _activeUploads = {};

  /// Builds the bloc with all chat use cases and websocket bridges wired in.
  /// ينشئ الـ bloc مع ربط حالات الاستخدام وجسور الـ websocket الخاصة بالدردشة.
  ChatBloc({
    required this.getConversationsUseCase,
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.createConversationUseCase,
    required this.deleteConversationUseCase,
    required this.archiveConversationUseCase,
    required this.unarchiveConversationUseCase,
    required this.deleteMessageUseCase,
    required this.editMessageUseCase,
    required this.addReactionUseCase,
    required this.removeReactionUseCase,
    required this.markAsReadUseCase,
    required this.uploadAttachmentUseCase,
    required this.searchChatsUseCase,
    required this.getAvailableUsersUseCase,
    required this.getAdminUsersUseCase,
    required this.updateUserStatusUseCase,
    required this.getChatSettingsUseCase,
    required this.updateChatSettingsUseCase,
    required this.getCurrentUserUseCase,
    required this.webSocketService,
    required this.localStorageService,
  }) : super(const ChatInitial()) {
    // Register event handlers.
    on<InitializeChatEvent>(_onInitializeChat);
    on<LoadConversationsEvent>(_onLoadConversations);
    on<LoadMessagesEvent>(_onLoadMessages);
    on<LoadMoreMessagesEvent>(_onLoadMoreMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<CreateConversationEvent>(_onCreateConversation);
    on<DeleteConversationEvent>(_onDeleteConversation);
    on<ArchiveConversationEvent>(_onArchiveConversation);
    on<UnarchiveConversationEvent>(_onUnarchiveConversation);
    on<DeleteMessageEvent>(_onDeleteMessage);
    on<EditMessageEvent>(_onEditMessage);
    on<AddReactionEvent>(_onAddReaction);
    on<RemoveReactionEvent>(_onRemoveReaction);
    on<MarkMessagesAsReadEvent>(_onMarkMessagesAsRead);
    on<UploadAttachmentEvent>(_onUploadAttachment);
    on<UploadMultipleAttachmentsEvent>(_onUploadMultipleAttachments);
    on<SendAudioMessageEvent>(_onSendAudioMessage);
    on<SearchChatsEvent>(_onSearchChats);
    on<LoadAvailableUsersEvent>(_onLoadAvailableUsers);
    on<LoadAdminUsersEvent>(_onLoadAdminUsers);
    on<UpdateUserStatusEvent>(_onUpdateUserStatus);
    on<LoadChatSettingsEvent>(_onLoadChatSettings);
    on<UpdateChatSettingsEvent>(_onUpdateChatSettings);
    on<SendTypingIndicatorEvent>(_onSendTypingIndicator);
    on<WebSocketMessageReceivedEvent>(_onWebSocketMessageReceived);
    on<WebSocketConversationUpdatedEvent>(_onWebSocketConversationUpdated);
    on<WebSocketTypingIndicatorEvent>(_onWebSocketTypingIndicator);
    on<WebSocketPresenceUpdateEvent>(_onWebSocketPresenceUpdate);
    on<ClearConversationCacheEvent>(_onClearConversationCache);
    on<RefreshConversationEvent>(_onRefreshConversation);
    on<RetryFailedMessageEvent>(_onRetryFailedMessage);
    on<CancelUploadEvent>(_onCancelUpload);

    // Attach websocket listeners immediately.
    _initializeWebSocket();
  }

  /// Hooks websocket streams into bloc events and opens the socket client.
  /// يربط تيارات websocket بأحداث الـ bloc ثم يفتح الاتصال.
  void _initializeWebSocket() {
    // Forward incoming message events.
    _webSocketMessagesSubscription =
        webSocketService.messageEvents.listen((event) {
      add(WebSocketMessageReceivedEvent(event));
    });

    // Forward typing indicator events.
    _webSocketTypingSubscription =
        webSocketService.typingEvents.listen((event) {
      add(WebSocketTypingIndicatorEvent(
        conversationId: event.conversationId,
        typingUserIds: event.typingUserIds,
      ));
    });

    // Forward presence updates.
    _webSocketPresenceSubscription =
        webSocketService.presenceEvents.listen((event) {
      add(WebSocketPresenceUpdateEvent(
        userId: event.userId,
        status: event.status,
        lastSeen: event.lastSeen,
      ));
    });

    // Forward conversation updates.
    _webSocketConversationSubscription =
        webSocketService.conversationUpdates.listen((conversation) {
      add(WebSocketConversationUpdatedEvent(conversation));
    });

    // Open the websocket connection after listeners are attached.
    webSocketService.connect();
  }

  /// Loads current-user context, cached preferences, and the initial inbox
  /// snapshot before live chat interaction begins.
  /// يحمل سياق المستخدم الحالي والتفضيلات المخزنة واللقطة الأولى للصندوق
  /// قبل بدء التفاعل الحي.
  Future<void> _onInitializeChat(
    InitializeChatEvent event,
    Emitter<ChatState> emit,
  ) async {
    final previousLoadedState =
        state is ChatLoaded ? state as ChatLoaded : null;
    if (previousLoadedState == null) {
      emit(const ChatLoading());
    }

    try {
      // جلب المحادثات
      final conversationsResult = await getConversationsUseCase(
        const GetConversationsParams(),
      );

      // جلب الإعدادات
      final settingsResult = await getChatSettingsUseCase(NoParams());

      // جلب المستخدم الحالي
      final currentUserResult = await getCurrentUserUseCase(NoParams());

      await conversationsResult.fold(
        (failure) async => emit(
          ChatError(message: await _mapFailureToMessage(failure)),
        ),
        (conversations) async {
          ChatSettings? settings;
          await settingsResult.fold(
            (_) async {}, // تجاهل فشل الإعدادات
            (s) async {
              settings = s;
              await _persistChatSettings(s);
            },
          );

          String? currentUserId;
          String? currentUserName;
          await currentUserResult.fold(
            (_) async {},
            (user) async {
              currentUserId = user.userId;
              currentUserName = user.name;
            },
          );

          if (previousLoadedState != null) {
            emit(previousLoadedState.copyWith(
              conversations: _mergeConversations(
                previousLoadedState.conversations,
                conversations,
              ),
              settings: settings ?? previousLoadedState.settings,
              currentUserId: currentUserId,
              currentUserName: currentUserName,
              error: null,
            ));
          } else {
            emit(ChatLoaded(
              conversations: conversations,
              settings: settings,
              currentUserId: currentUserId,
              currentUserName: currentUserName,
            ));
          }
        },
      );
    } catch (e) {
      emit(
        ChatError(
          message: await _tr('chat.errors.init'),
        ),
      );
    }
  }

  /// Loads a paginated inbox slice and merges it into the live state.
  /// يحمل جزءًا مرقمًا من الصندوق الوارد ويدمجه في الحالة الحية.
  Future<void> _onLoadConversations(
    LoadConversationsEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) {
      emit(const ChatLoading());
    }

    final result = await getConversationsUseCase(
      GetConversationsParams(
        pageNumber: event.pageNumber,
        pageSize: event.pageSize,
      ),
    );

    await result.fold(
      (failure) async {
        if (currentState is ChatLoaded) {
          emit(currentState.copyWith(
            error: await _mapFailureToMessage(failure),
          ));
        } else {
          emit(ChatError(message: await _mapFailureToMessage(failure)));
        }
      },
      (conversations) async {
        if (currentState is ChatLoaded) {
          // دمج المحادثات الجديدة مع القديمة
          final mergedConversations = _mergeConversations(
            currentState.conversations,
            conversations,
          );

          emit(currentState.copyWith(
            conversations: mergedConversations,
            error: null,
          ));
        } else {
          emit(ChatLoaded(conversations: conversations));
        }
      },
    );
  }

  /// Loads a conversation timeline and updates pagination bookkeeping.
  /// يحمل خط المحادثة ويحدّث بيانات الترقيم الخاصة به.
  Future<void> _onLoadMessages(
    LoadMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    // تحقق من حالة التحميل
    if (_conversationLoadingStates[event.conversationId] == true) {
      return;
    }

    _conversationLoadingStates[event.conversationId] = true;

    emit(currentState.copyWith(
      isLoadingMessages: true,
      loadingConversationId: event.conversationId,
    ));

    final result = await getMessagesUseCase(
      GetMessagesParams(
        conversationId: event.conversationId,
        pageNumber: event.pageNumber,
        pageSize: event.pageSize,
        beforeMessageId: event.beforeMessageId,
      ),
    );

    await result.fold(
      (failure) async {
        _conversationLoadingStates[event.conversationId] = false;
        emit(currentState.copyWith(
          isLoadingMessages: false,
          error: await _mapFailureToMessage(failure),
        ));
      },
      (messages) async {
        // تحديث معلومات الصفحات
        _messagePages[event.conversationId] = event.pageNumber;
        _hasMoreMessages[event.conversationId] =
            messages.length >= event.pageSize;

        // تتبع معرفات الرسائل المحملة
        _loadedMessageIds.putIfAbsent(event.conversationId, () => {});
        for (final message in messages) {
          _loadedMessageIds[event.conversationId]!.add(message.id);
        }

        // دمج الرسائل
        final updatedMessages =
            Map<String, List<Message>>.from(currentState.messages);
        final existingMessages = updatedMessages[event.conversationId] ?? [];

        final mergedMessages = _mergeMessages(existingMessages, messages);
        updatedMessages[event.conversationId] = mergedMessages;

        _conversationLoadingStates[event.conversationId] = false;

        emit(currentState.copyWith(
          messages: updatedMessages,
          isLoadingMessages: false,
          loadingConversationId: null,
          error: null,
        ));
      },
    );
  }

  /// Loads an older page of messages when the user scrolls upward.
  /// يحمل صفحة أقدم من الرسائل عندما يمرر المستخدم إلى الأعلى.
  Future<void> _onLoadMoreMessages(
    LoadMoreMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    // تحقق من وجود المزيد من الرسائل
    if (_hasMoreMessages[event.conversationId] == false) return;

    // تحقق من حالة التحميل
    if (_conversationLoadingStates[event.conversationId] == true) return;

    _conversationLoadingStates[event.conversationId] = true;

    emit(currentState.copyWith(isLoadingMore: true));

    final currentPage = _messagePages[event.conversationId] ?? 1;
    final nextPage = currentPage + 1;

    final result = await getMessagesUseCase(
      GetMessagesParams(
        conversationId: event.conversationId,
        pageNumber: nextPage,
        pageSize: event.pageSize,
        beforeMessageId: event.targetMessageId,
      ),
    );

    await result.fold(
      (failure) async {
        _conversationLoadingStates[event.conversationId] = false;
        emit(currentState.copyWith(
          isLoadingMore: false,
          error: await _mapFailureToMessage(failure),
        ));
      },
      (messages) async {
        // تحديث معلومات الصفحات
        _messagePages[event.conversationId] = nextPage;
        _hasMoreMessages[event.conversationId] =
            messages.length >= event.pageSize;

        // تتبع معرفات الرسائل المحملة
        for (final message in messages) {
          _loadedMessageIds[event.conversationId]!.add(message.id);
        }

        // دمج الرسائل القديمة مع الجديدة
        final updatedMessages =
            Map<String, List<Message>>.from(currentState.messages);
        final existingMessages = updatedMessages[event.conversationId] ?? [];

        // إضافة الرسائل القديمة في النهاية (التمرير لأعلى)
        final mergedMessages = [...existingMessages, ...messages]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        updatedMessages[event.conversationId] = mergedMessages;

        _conversationLoadingStates[event.conversationId] = false;

        emit(currentState.copyWith(
          messages: updatedMessages,
          isLoadingMore: false,
          error: null,
        ));
      },
    );
  }

  /// Sends a message with optimistic UI feedback until the backend responds.
  /// يرسل الرسالة مع تحديث تفاؤلي في الواجهة حتى يرد الخادم.
  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;
    final resolvedCurrentUserId =
        await _resolveCurrentUserId(event.currentUserId, currentState);
    final resolvedCurrentUserName = await _resolveCurrentUserName(currentState);

    // إنشاء رسالة متفائلة
    final optimisticMessage = Message(
      id: 'temp_${DateTime.now().microsecondsSinceEpoch}',
      conversationId: event.conversationId,
      senderId: resolvedCurrentUserId,
      senderName: resolvedCurrentUserName,
      messageType: event.messageType,
      content: event.content,
      location: event.location,
      replyToMessageId: event.replyToMessageId,
      attachments: const [],
      reactions: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: 'sending',
      isEdited: false,
      isDeleted: false,
      deliveryReceipt: null,
    );

    // إضافة الرسالة المتفائلة للقائمة
    final updatedMessages =
        Map<String, List<Message>>.from(currentState.messages);
    final conversationMessages = List<Message>.from(
      updatedMessages[event.conversationId] ?? [],
    );
    conversationMessages.insert(0, optimisticMessage);
    updatedMessages[event.conversationId] = conversationMessages;

    // تتبع الرسالة المتفائلة
    _optimisticMessages.putIfAbsent(event.conversationId, () => []);
    _optimisticMessages[event.conversationId]!.add(optimisticMessage);

    emit(currentState.copyWith(
      messages: updatedMessages,
      isSendingMessage: true,
      sendingConversationId: event.conversationId,
      currentUserId: resolvedCurrentUserId.isEmpty
          ? currentState.currentUserId
          : resolvedCurrentUserId,
      currentUserName: resolvedCurrentUserName,
    ));

    // إرسال الرسالة الفعلية
    final result = await sendMessageUseCase(
      SendMessageParams(
        conversationId: event.conversationId,
        messageType: event.messageType,
        content: event.content,
        location: event.location,
        replyToMessageId: event.replyToMessageId,
        attachmentIds: event.attachmentIds,
      ),
    );

    await result.fold(
      (failure) async {
        // فشل الإرسال - تحديث حالة الرسالة المتفائلة
        final liveState =
            state is ChatLoaded ? state as ChatLoaded : currentState;
        final failedMessages =
            Map<String, List<Message>>.from(liveState.messages);
        final messages = failedMessages[event.conversationId] ?? [];
        final failureReason = await _mapFailureToMessage(failure);

        final updatedMessagesList = messages.map((msg) {
          if (msg.id == optimisticMessage.id) {
            return Message(
              id: msg.id,
              conversationId: msg.conversationId,
              senderId: msg.senderId,
              senderName: msg.senderName,
              messageType: msg.messageType,
              content: msg.content,
              location: msg.location,
              replyToMessageId: msg.replyToMessageId,
              attachments: msg.attachments,
              reactions: msg.reactions,
              createdAt: msg.createdAt,
              updatedAt: msg.updatedAt,
              status: 'failed',
              isEdited: msg.isEdited,
              isDeleted: msg.isDeleted,
              deliveryReceipt: msg.deliveryReceipt,
              failureReason: failureReason,
            );
          }
          return msg;
        }).toList();

        failedMessages[event.conversationId] = updatedMessagesList;

        emit(liveState.copyWith(
          messages: failedMessages,
          isSendingMessage: false,
          sendingConversationId: null,
          error: await _tr('chat.errors.messageSendFailed'),
        ));
      },
      (sentMessage) async {
        // نجح الإرسال - استبدال الرسالة المتفائلة بالرسالة الفعلية
        final liveState =
            state is ChatLoaded ? state as ChatLoaded : currentState;
        final successMessages =
            Map<String, List<Message>>.from(liveState.messages);
        final messages = successMessages[event.conversationId] ?? [];
        final mergedSentMessage =
            _mergeMessageWithReference(sentMessage, optimisticMessage);
        final updatedMessagesList = _replaceOptimisticWithConfirmed(
          messages,
          optimisticMessage,
          mergedSentMessage,
        );
        successMessages[event.conversationId] = updatedMessagesList;

        // إزالة من قائمة الرسائل المتفائلة
        _optimisticMessages[event.conversationId]?.removeWhere(
          (msg) => msg.id == optimisticMessage.id,
        );

        // تحديث آخر رسالة في المحادثة
        final updatedConversations = liveState.conversations.map((conv) {
          if (conv.id == event.conversationId) {
            return Conversation(
              id: conv.id,
              conversationType: conv.conversationType,
              title: conv.title,
              description: conv.description,
              avatar: conv.avatar,
              createdAt: conv.createdAt,
              updatedAt: DateTime.now(),
              lastMessage: mergedSentMessage,
              unreadCount: conv.unreadCount,
              isArchived: conv.isArchived,
              isMuted: conv.isMuted,
              propertyId: conv.propertyId,
              participants: conv.participants,
            );
          }
          return conv;
        }).toList();

        emit(liveState.copyWith(
          messages: successMessages,
          conversations: updatedConversations,
          isSendingMessage: false,
          sendingConversationId: null,
          error: null,
        ));
      },
    );
  }

  /// Uploads several files in sequence and keeps their progress visible in
  /// the active conversation.
  /// يرفع عدة ملفات بالتسلسل ويحافظ على ظهور تقدمها داخل المحادثة النشطة.
  Future<void> _onUploadMultipleAttachments(
    UploadMultipleAttachmentsEvent event,
    Emitter<ChatState> emit,
  ) async {
    const maxParallelUploads = 2;
    final currentState = state;
    if (currentState is! ChatLoaded) return;
    if (event.filePaths.isEmpty) return;

    final now = DateTime.now();
    final resolvedCurrentUserId =
        await _resolveCurrentUserId(event.currentUserId, currentState);
    final resolvedCurrentUserName = await _resolveCurrentUserName(currentState);
    final uploadTasks = <ImageUploadInfo>[];
    final optimisticAttachments = <Attachment>[];
    final uploadedAttachmentsByIndex =
        List<Attachment?>.filled(event.filePaths.length, null);
    final attachmentIdsByIndex =
        List<String?>.filled(event.filePaths.length, null);
    final optimisticMessageId = 'temp_media_${now.microsecondsSinceEpoch}';
    String? failureReason;
    var hasFailure = false;

    for (int i = 0; i < event.filePaths.length; i++) {
      final filePath = event.filePaths[i];
      final uploadId = 'temp_attachment_${now.microsecondsSinceEpoch}_$i';
      final file = File(filePath);
      final fileName = file.uri.pathSegments.isNotEmpty
          ? file.uri.pathSegments.last
          : 'attachment_${i + 1}';
      final fileSize = await file.exists() ? await file.length() : 0;
      final optimisticThumbnailUrl = event.messageType == 'video'
          ? await _buildOptimisticVideoThumbnail(filePath, uploadId)
          : null;

      uploadTasks.add(ImageUploadInfo(
        id: uploadId,
        file: file,
        progress: 0.0,
        isCompleted: false,
        isFailed: false,
      ));

      optimisticAttachments.add(Attachment(
        id: uploadId,
        conversationId: event.conversationId,
        fileName: fileName,
        contentType: _inferAttachmentContentType(fileName, event.messageType),
        fileSize: fileSize,
        filePath: filePath,
        fileUrl: filePath,
        uploadedBy: resolvedCurrentUserId,
        createdAt: now,
        thumbnailUrl: optimisticThumbnailUrl,
        metadata: optimisticThumbnailUrl == null
            ? null
            : {
                _localThumbnailMetadataKey: optimisticThumbnailUrl,
              },
        downloadProgress: 0.0,
      ));
    }

    final optimisticMessage = Message(
      id: optimisticMessageId,
      conversationId: event.conversationId,
      senderId: resolvedCurrentUserId,
      senderName: resolvedCurrentUserName,
      messageType: event.messageType,
      content: event.content,
      replyToMessageId: event.replyToMessageId,
      attachments: optimisticAttachments,
      reactions: const [],
      createdAt: now,
      updatedAt: now,
      status: 'sending',
      isEdited: false,
      isDeleted: false,
      deliveryReceipt: null,
    );

    final updatedMessages =
        Map<String, List<Message>>.from(currentState.messages);
    final conversationMessages = List<Message>.from(
      updatedMessages[event.conversationId] ?? [],
    );
    conversationMessages.insert(0, optimisticMessage);
    updatedMessages[event.conversationId] = conversationMessages;
    _optimisticMessages.putIfAbsent(event.conversationId, () => []);
    _optimisticMessages[event.conversationId]!.add(optimisticMessage);

    final updatedUploads = Map<String, List<ImageUploadInfo>>.from(
      currentState.uploadingImages,
    );
    updatedUploads[event.conversationId] = uploadTasks;

    emit(currentState.copyWith(
      messages: updatedMessages,
      uploadingImages: updatedUploads,
      isSendingMessage: true,
      sendingConversationId: event.conversationId,
      currentUserId: resolvedCurrentUserId.isEmpty
          ? currentState.currentUserId
          : resolvedCurrentUserId,
      currentUserName: resolvedCurrentUserName,
    ));

    for (int start = 0;
        start < event.filePaths.length;
        start += maxParallelUploads) {
      if (hasFailure) break;

      final end = (start + maxParallelUploads > event.filePaths.length)
          ? event.filePaths.length
          : start + maxParallelUploads;
      final batch = <Future<void>>[];

      for (int i = start; i < end; i++) {
        final filePath = event.filePaths[i];
        final uploadTask = uploadTasks[i];

        batch.add(() async {
          try {
            final uploadController = UploadController();
            _activeUploads[uploadTask.id] = UploadTask(
              controller: uploadController,
              filePath: filePath,
            );

            final result = await uploadAttachmentUseCase(
              UploadAttachmentParams(
                conversationId: event.conversationId,
                filePath: filePath,
                messageType: event.messageType,
                onSendProgress: (sent, total) {
                  final progress = total > 0 ? sent / total : 0.0;
                  _updateUploadProgress(
                    emit,
                    currentState,
                    event.conversationId,
                    uploadTask.id,
                    progress,
                    optimisticMessageId: optimisticMessage.id,
                  );
                  event.onProgress?.call(i, sent, total);
                },
              ),
            );

            await result.fold(
              (failure) async {
                hasFailure = true;
                failureReason = await _mapFailureToMessage(failure);
                _updateUploadStatus(
                  emit,
                  currentState,
                  event.conversationId,
                  uploadTask.id,
                  isFailed: true,
                  error: failureReason,
                  optimisticMessageId: optimisticMessage.id,
                );
              },
              (attachment) async {
                attachmentIdsByIndex[i] = attachment.id;
                uploadedAttachmentsByIndex[i] = attachment;
                _updateUploadStatus(
                  emit,
                  currentState,
                  event.conversationId,
                  uploadTask.id,
                  isCompleted: true,
                  optimisticMessageId: optimisticMessage.id,
                  hydratedAttachment: attachment,
                );
              },
            );
          } catch (_) {
            hasFailure = true;
            failureReason = await _tr('chat.errors.unknown');
            _updateUploadStatus(
              emit,
              currentState,
              event.conversationId,
              uploadTask.id,
              isFailed: true,
              error: failureReason,
              optimisticMessageId: optimisticMessage.id,
            );
          } finally {
            _activeUploads.remove(uploadTask.id);
          }
        }());
      }

      await Future.wait(batch);
    }

    final attachmentIds = attachmentIdsByIndex.whereType<String>().toList();

    final liveAfterUploads =
        state is ChatLoaded ? state as ChatLoaded : currentState;
    final finalUploads = Map<String, List<ImageUploadInfo>>.from(
      liveAfterUploads.uploadingImages,
    );
    finalUploads.remove(event.conversationId);
    emit(liveAfterUploads.copyWith(uploadingImages: finalUploads));

    if (hasFailure || attachmentIds.length != event.filePaths.length) {
      await _markOptimisticMessageFailed(
        emit,
        optimisticMessage: optimisticMessage,
        currentState:
            state is ChatLoaded ? state as ChatLoaded : liveAfterUploads,
        failureReason: failureReason ?? await _tr('chat.errors.unknown'),
      );
      return;
    }

    final sendResult = await sendMessageUseCase(
      SendMessageParams(
        conversationId: event.conversationId,
        messageType: event.messageType,
        content: event.content,
        replyToMessageId: event.replyToMessageId,
        attachmentIds: attachmentIds,
      ),
    );

    await sendResult.fold(
      (failure) async {
        await _markOptimisticMessageFailed(
          emit,
          optimisticMessage: optimisticMessage,
          currentState:
              state is ChatLoaded ? state as ChatLoaded : liveAfterUploads,
          failureReason: await _mapFailureToMessage(failure),
        );
      },
      (sentMessage) async {
        final liveState =
            state is ChatLoaded ? state as ChatLoaded : liveAfterUploads;
        final successMessages =
            Map<String, List<Message>>.from(liveState.messages);
        final messages = successMessages[event.conversationId] ?? [];
        final hydratedOptimisticMessage = _hydrateOptimisticMessageAttachments(
          optimisticMessage,
          uploadedAttachmentsByIndex,
        );
        final mergedSentMessage =
            _mergeMessageWithReference(sentMessage, hydratedOptimisticMessage);
        final updatedMessagesList = _replaceOptimisticWithConfirmed(
          messages,
          optimisticMessage,
          mergedSentMessage,
        );
        successMessages[event.conversationId] = updatedMessagesList;

        _optimisticMessages[event.conversationId]?.removeWhere(
          (msg) => msg.id == optimisticMessage.id,
        );

        final updatedConversations = liveState.conversations.map((conv) {
          if (conv.id == event.conversationId) {
            return Conversation(
              id: conv.id,
              conversationType: conv.conversationType,
              title: conv.title,
              description: conv.description,
              avatar: conv.avatar,
              createdAt: conv.createdAt,
              updatedAt: DateTime.now(),
              lastMessage: mergedSentMessage,
              unreadCount: conv.unreadCount,
              isArchived: conv.isArchived,
              isMuted: conv.isMuted,
              propertyId: conv.propertyId,
              participants: conv.participants,
            );
          }
          return conv;
        }).toList();

        emit(liveState.copyWith(
          messages: successMessages,
          conversations: updatedConversations,
          isSendingMessage: false,
          sendingConversationId: null,
          error: null,
        ));
      },
    );
  }

  /// Uploads a single attachment by delegating to the batch upload path.
  /// يرفع مرفقًا واحدًا عبر مسار الرفع الدفعي نفسه.
  Future<void> _onUploadAttachment(
    UploadAttachmentEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    add(UploadMultipleAttachmentsEvent(
      conversationId: event.conversationId,
      filePaths: [event.filePath],
      messageType: event.messageType,
      currentUserId:
          currentState is ChatLoaded ? currentState.currentUserId : null,
      onProgress: event.onProgress != null
          ? (index, sent, total) {
              if (index == 0) event.onProgress!(sent, total);
            }
          : null,
    ));
  }

  /// Uploads one recorded voice note and sends it as an audio chat message
  /// with optimistic rendering.
  /// يرفع ملاحظة صوتية مسجلة ويرسلها كرسالة صوتية مع عرض تفاؤلي.
  Future<void> _onSendAudioMessage(
    SendAudioMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final normalizedPath = event.filePath.trim();
    final now = DateTime.now();
    _recentAudioDispatches.removeWhere(
      (_, timestamp) => now.difference(timestamp).inSeconds >= 15,
    );

    final previousDispatchAt = _recentAudioDispatches[normalizedPath];
    if (previousDispatchAt != null &&
        now.difference(previousDispatchAt).inSeconds < 15) {
      return;
    }
    _recentAudioDispatches[normalizedPath] = now;

    final resolvedCurrentUserId =
        await _resolveCurrentUserId(null, currentState);
    final resolvedCurrentUserName = await _resolveCurrentUserName(currentState);
    final file = File(normalizedPath);
    final tempMessageId = 'temp_voice_${now.microsecondsSinceEpoch}';
    final tempAttachmentId = 'temp_attachment_${now.microsecondsSinceEpoch}';
    final fileName = file.uri.pathSegments.isNotEmpty
        ? file.uri.pathSegments.last
        : 'voice_note.m4a';
    final fileSize = await file.exists() ? await file.length() : 0;

    final optimisticAttachment = Attachment(
      id: tempAttachmentId,
      conversationId: event.conversationId,
      fileName: fileName,
      contentType: 'audio/m4a',
      fileSize: fileSize,
      filePath: normalizedPath,
      fileUrl: normalizedPath,
      uploadedBy: resolvedCurrentUserId,
      createdAt: now,
      duration: event.durationSeconds,
    );

    final optimisticMessage = Message(
      id: tempMessageId,
      conversationId: event.conversationId,
      senderId: resolvedCurrentUserId,
      senderName: resolvedCurrentUserName,
      messageType: 'audio',
      replyToMessageId: event.replyToMessageId,
      attachments: [optimisticAttachment],
      reactions: const [],
      createdAt: now,
      updatedAt: now,
      status: 'sending',
      isEdited: false,
      isDeleted: false,
      deliveryReceipt: null,
    );

    final updatedMessages =
        Map<String, List<Message>>.from(currentState.messages);
    final conversationMessages = List<Message>.from(
      updatedMessages[event.conversationId] ?? [],
    );
    conversationMessages.insert(0, optimisticMessage);
    updatedMessages[event.conversationId] = conversationMessages;

    _optimisticMessages.putIfAbsent(event.conversationId, () => []);
    _optimisticMessages[event.conversationId]!.add(optimisticMessage);

    emit(currentState.copyWith(
      messages: updatedMessages,
      isSendingMessage: true,
      sendingConversationId: event.conversationId,
      currentUserId: resolvedCurrentUserId.isEmpty
          ? currentState.currentUserId
          : resolvedCurrentUserId,
      currentUserName: resolvedCurrentUserName,
    ));

    final uploadResult = await uploadAttachmentUseCase(
      UploadAttachmentParams(
        conversationId: event.conversationId,
        filePath: normalizedPath,
        messageType: 'audio',
        durationSeconds: event.durationSeconds,
      ),
    );

    await uploadResult.fold(
      (failure) async {
        _recentAudioDispatches.remove(normalizedPath);
        await _markOptimisticMessageFailed(
          emit,
          optimisticMessage: optimisticMessage,
          currentState:
              state is ChatLoaded ? state as ChatLoaded : currentState,
          failureReason: await _mapFailureToMessage(failure),
        );
      },
      (attachment) async {
        final sendResult = await sendMessageUseCase(
          SendMessageParams(
            conversationId: event.conversationId,
            messageType: 'audio',
            replyToMessageId: event.replyToMessageId,
            attachmentIds: [attachment.id],
          ),
        );

        await sendResult.fold(
          (failure) async {
            _recentAudioDispatches.remove(normalizedPath);
            await _markOptimisticMessageFailed(
              emit,
              optimisticMessage: optimisticMessage,
              currentState:
                  state is ChatLoaded ? state as ChatLoaded : currentState,
              failureReason: await _mapFailureToMessage(failure),
            );
          },
          (sentMessage) async {
            _recentAudioDispatches.remove(normalizedPath);
            final liveState =
                state is ChatLoaded ? state as ChatLoaded : currentState;
            final successMessages =
                Map<String, List<Message>>.from(liveState.messages);
            final messages = successMessages[event.conversationId] ?? [];
            final mergedSentMessage =
                _mergeMessageWithReference(sentMessage, optimisticMessage);
            final updatedMessagesList = _collapseTransientAudioDuplicates(
              _replaceOptimisticWithConfirmed(
                messages,
                optimisticMessage,
                mergedSentMessage,
              ),
              mergedSentMessage,
              optimisticMessage: optimisticMessage,
            );
            successMessages[event.conversationId] = updatedMessagesList;

            _optimisticMessages[event.conversationId]?.removeWhere(
              (msg) => msg.id == optimisticMessage.id,
            );

            final updatedConversations = liveState.conversations.map((conv) {
              if (conv.id == event.conversationId) {
                return Conversation(
                  id: conv.id,
                  conversationType: conv.conversationType,
                  title: conv.title,
                  description: conv.description,
                  avatar: conv.avatar,
                  createdAt: conv.createdAt,
                  updatedAt: DateTime.now(),
                  lastMessage: mergedSentMessage,
                  unreadCount: conv.unreadCount,
                  isArchived: conv.isArchived,
                  isMuted: conv.isMuted,
                  propertyId: conv.propertyId,
                  participants: conv.participants,
                );
              }
              return conv;
            }).toList();

            emit(liveState.copyWith(
              messages: successMessages,
              conversations: updatedConversations,
              isSendingMessage: false,
              sendingConversationId: null,
              error: null,
            ));
          },
        );
      },
    );
  }

  /// Updates the visible progress value for one in-flight upload.
  /// يحدّث قيمة التقدم المرئية لعملية رفع جارية.
  void _updateUploadProgress(Emitter<ChatState> emit, ChatLoaded currentState,
      String conversationId, String uploadId, double progress,
      {String? optimisticMessageId}) {
    final liveState = state is ChatLoaded ? state as ChatLoaded : currentState;
    final updatedUploads = Map<String, List<ImageUploadInfo>>.from(
      liveState.uploadingImages,
    );

    final uploads = updatedUploads[conversationId] ?? [];
    final updatedTasks = uploads.map((task) {
      if (task.id == uploadId) {
        return task.copyWith(progress: progress);
      }
      return task;
    }).toList();

    updatedUploads[conversationId] = updatedTasks;
    emit(liveState.copyWith(
      uploadingImages: updatedUploads,
      messages: optimisticMessageId == null
          ? liveState.messages
          : _updateOptimisticAttachmentAfterUpload(
              liveState.messages,
              conversationId: conversationId,
              messageId: optimisticMessageId,
              attachmentId: uploadId,
              progress: progress,
            ),
    ));
  }

  /// Updates the completion or failure state for one upload task.
  /// يحدّث حالة الاكتمال أو الفشل لمهمة رفع واحدة.
  void _updateUploadStatus(
    Emitter<ChatState> emit,
    ChatLoaded currentState,
    String conversationId,
    String uploadId, {
    bool? isCompleted,
    bool? isFailed,
    String? error,
    String? optimisticMessageId,
    Attachment? hydratedAttachment,
  }) {
    final liveState = state is ChatLoaded ? state as ChatLoaded : currentState;
    final updatedUploads = Map<String, List<ImageUploadInfo>>.from(
      liveState.uploadingImages,
    );

    final uploads = updatedUploads[conversationId] ?? [];
    final previousTask = uploads.firstWhere(
      (task) => task.id == uploadId,
      orElse: () => ImageUploadInfo(id: uploadId, file: File('')),
    );
    final updatedTasks = uploads.map((task) {
      if (task.id == uploadId) {
        return task.copyWith(
          isCompleted: isCompleted ?? task.isCompleted,
          isFailed: isFailed ?? task.isFailed,
          error: error ?? task.error,
          progress: isCompleted == true ? 1.0 : task.progress,
        );
      }
      return task;
    }).toList();

    updatedUploads[conversationId] = updatedTasks;
    emit(liveState.copyWith(
      uploadingImages: updatedUploads,
      messages: optimisticMessageId == null
          ? liveState.messages
          : _updateOptimisticAttachmentAfterUpload(
              liveState.messages,
              conversationId: conversationId,
              messageId: optimisticMessageId,
              attachmentId: uploadId,
              progress: isCompleted == true ? 1.0 : previousTask.progress,
              hydratedAttachment: hydratedAttachment,
            ),
    ));
  }

  String _inferAttachmentContentType(String fileName, String messageType) {
    final extension =
        fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';

    if (messageType == 'image') {
      switch (extension) {
        case 'png':
          return 'image/png';
        case 'gif':
          return 'image/gif';
        case 'webp':
          return 'image/webp';
        default:
          return 'image/jpeg';
      }
    }

    if (messageType == 'video') {
      switch (extension) {
        case 'mov':
          return 'video/quicktime';
        case 'mkv':
          return 'video/x-matroska';
        case 'webm':
          return 'video/webm';
        default:
          return 'video/mp4';
      }
    }

    if (messageType == 'audio') {
      return 'audio/m4a';
    }

    return 'application/octet-stream';
  }

  Map<String, List<Message>> _updateOptimisticAttachmentAfterUpload(
    Map<String, List<Message>> sourceMessages, {
    required String conversationId,
    required String messageId,
    required String attachmentId,
    required double progress,
    Attachment? hydratedAttachment,
  }) {
    final updatedMessages = Map<String, List<Message>>.from(sourceMessages);
    final conversationMessages = List<Message>.from(
      updatedMessages[conversationId] ?? const <Message>[],
    );

    final updatedConversationMessages = conversationMessages.map((message) {
      if (message.id != messageId) {
        return message;
      }

      final updatedAttachments = message.attachments.map((attachment) {
        if (attachment.id != attachmentId) {
          return attachment;
        }

        return Attachment(
          id: hydratedAttachment?.id ?? attachment.id,
          conversationId:
              hydratedAttachment?.conversationId ?? attachment.conversationId,
          fileName: (hydratedAttachment?.fileName.isNotEmpty ?? false)
              ? hydratedAttachment!.fileName
              : attachment.fileName,
          contentType: (hydratedAttachment?.contentType.isNotEmpty ?? false)
              ? hydratedAttachment!.contentType
              : attachment.contentType,
          fileSize: (hydratedAttachment?.fileSize ?? 0) > 0
              ? hydratedAttachment!.fileSize
              : attachment.fileSize,
          filePath: attachment.filePath,
          fileUrl: (hydratedAttachment?.fileUrl.isNotEmpty ?? false)
              ? hydratedAttachment!.fileUrl
              : attachment.fileUrl,
          uploadedBy: (hydratedAttachment?.uploadedBy.isNotEmpty ?? false)
              ? hydratedAttachment!.uploadedBy
              : attachment.uploadedBy,
          createdAt: hydratedAttachment?.createdAt ?? attachment.createdAt,
          thumbnailUrl:
              hydratedAttachment?.thumbnailUrl ?? attachment.thumbnailUrl,
          metadata: _mergeAttachmentMetadata(
            attachment.metadata,
            hydratedAttachment?.metadata,
            attachment.thumbnailUrl,
          ),
          duration: hydratedAttachment?.duration ?? attachment.duration,
          downloadProgress: progress,
        );
      }).toList();

      return Message(
        id: message.id,
        conversationId: message.conversationId,
        senderId: message.senderId,
        senderName: message.senderName,
        messageType: message.messageType,
        content: message.content,
        location: message.location,
        replyToMessageId: message.replyToMessageId,
        reactions: message.reactions,
        attachments: updatedAttachments,
        createdAt: message.createdAt,
        updatedAt: message.updatedAt,
        status: message.status,
        isEdited: message.isEdited,
        editedAt: message.editedAt,
        deliveryReceipt: message.deliveryReceipt,
        isDeleted: message.isDeleted,
        failureReason: message.failureReason,
      );
    }).toList();

    updatedMessages[conversationId] = updatedConversationMessages;
    return updatedMessages;
  }

  Message _hydrateOptimisticMessageAttachments(
    Message optimisticMessage,
    List<Attachment?> uploadedAttachmentsByIndex,
  ) {
    if (uploadedAttachmentsByIndex.every((attachment) => attachment == null)) {
      return optimisticMessage;
    }

    final mergedAttachments = List<Attachment>.generate(
      optimisticMessage.attachments.length,
      (index) {
        final fallback = optimisticMessage.attachments[index];
        final uploaded = index < uploadedAttachmentsByIndex.length
            ? uploadedAttachmentsByIndex[index]
            : null;

        if (uploaded == null) {
          return fallback;
        }

        return Attachment(
          id: uploaded.id,
          conversationId: uploaded.conversationId,
          fileName: uploaded.fileName.isNotEmpty
              ? uploaded.fileName
              : fallback.fileName,
          contentType: uploaded.contentType.isNotEmpty
              ? uploaded.contentType
              : fallback.contentType,
          fileSize:
              uploaded.fileSize > 0 ? uploaded.fileSize : fallback.fileSize,
          filePath: fallback.filePath,
          fileUrl:
              uploaded.fileUrl.isNotEmpty ? uploaded.fileUrl : fallback.fileUrl,
          uploadedBy: uploaded.uploadedBy.isNotEmpty
              ? uploaded.uploadedBy
              : fallback.uploadedBy,
          createdAt: uploaded.createdAt,
          thumbnailUrl: uploaded.thumbnailUrl ?? fallback.thumbnailUrl,
          metadata: _mergeAttachmentMetadata(
            fallback.metadata,
            uploaded.metadata,
            fallback.thumbnailUrl,
          ),
          duration: uploaded.duration ?? fallback.duration,
          downloadProgress: 1.0,
        );
      },
    );

    return Message(
      id: optimisticMessage.id,
      conversationId: optimisticMessage.conversationId,
      senderId: optimisticMessage.senderId,
      senderName: optimisticMessage.senderName,
      messageType: optimisticMessage.messageType,
      content: optimisticMessage.content,
      location: optimisticMessage.location,
      replyToMessageId: optimisticMessage.replyToMessageId,
      reactions: optimisticMessage.reactions,
      attachments: mergedAttachments,
      createdAt: optimisticMessage.createdAt,
      updatedAt: optimisticMessage.updatedAt,
      status: optimisticMessage.status,
      isEdited: optimisticMessage.isEdited,
      editedAt: optimisticMessage.editedAt,
      isDeleted: optimisticMessage.isDeleted,
      deliveryReceipt: optimisticMessage.deliveryReceipt,
      failureReason: optimisticMessage.failureReason,
    );
  }

  /// Cancels a running upload and reflects the cancellation in state.
  /// يلغي عملية رفع جارية ويعكس الإلغاء داخل الحالة.
  Future<void> _onCancelUpload(
    CancelUploadEvent event,
    Emitter<ChatState> emit,
  ) async {
    final uploadTask = _activeUploads[event.uploadId];
    if (uploadTask != null) {
      uploadTask.controller.cancel();
      _activeUploads.remove(event.uploadId);

      // Reflect the cancellation in the upload state.
      final currentState = state;
      if (currentState is ChatLoaded) {
        _updateUploadStatus(
          emit,
          currentState,
          event.conversationId,
          event.uploadId,
          isFailed: true,
          error: await _tr('chat.errors.uploadCancelled'),
        );
      }
    }
  }

  /// Creates a new conversation and inserts it into the inbox when the
  /// request succeeds.
  /// ينشئ محادثة جديدة ويضيفها إلى الصندوق الوارد عند نجاح الطلب.
  Future<void> _onCreateConversation(
    CreateConversationEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ConversationCreating());

    final result = await createConversationUseCase(
      CreateConversationParams(
        participantIds: event.participantIds,
        conversationType: event.conversationType,
        title: event.title,
        description: event.description,
        propertyId: event.propertyId,
      ),
    );

    await result.fold(
      (failure) async =>
          emit(ChatError(message: await _mapFailureToMessage(failure))),
      (conversation) async {
        emit(ConversationCreated(conversation: conversation));

        // Prepend the new conversation so it appears immediately.
        final currentState = state;
        if (currentState is ChatLoaded) {
          final updatedConversations = [
            conversation,
            ...currentState.conversations
          ];
          emit(currentState.copyWith(conversations: updatedConversations));
        } else {
          add(const LoadConversationsEvent());
        }
      },
    );
  }

  /// Deletes a conversation, removes its cached timeline, and clears local
  /// bookkeeping.
  /// يحذف المحادثة ويزيل خطها المخزن ويفرغ بيانات المتابعة المحلية.
  Future<void> _onDeleteConversation(
    DeleteConversationEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final result = await deleteConversationUseCase(
      DeleteConversationParams(conversationId: event.conversationId),
    );

    await result.fold(
      (failure) async {
        emit(currentState.copyWith(error: await _mapFailureToMessage(failure)));
      },
      (_) async {
        // Remove the conversation from the visible inbox.
        final updatedConversations = currentState.conversations
            .where((conv) => conv.id != event.conversationId)
            .toList();

        // Remove every cached message that belongs to the deleted thread.
        final updatedMessages =
            Map<String, List<Message>>.from(currentState.messages);
        updatedMessages.remove(event.conversationId);

        // Clear any residual cache or loading flags for that thread.
        add(ClearConversationCacheEvent(conversationId: event.conversationId));

        emit(currentState.copyWith(
          conversations: updatedConversations,
          messages: updatedMessages,
          error: null,
        ));
      },
    );
  }

  /// Moves a conversation into the archived state without deleting history.
  /// ينقل المحادثة إلى الأرشيف من دون حذف تاريخها.
  Future<void> _onArchiveConversation(
    ArchiveConversationEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final result = await archiveConversationUseCase(
      ArchiveConversationParams(conversationId: event.conversationId),
    );

    await result.fold(
      (failure) async {
        emit(currentState.copyWith(error: await _mapFailureToMessage(failure)));
      },
      (_) async {
        // Mark the conversation as archived in the visible list.
        final updatedConversations = currentState.conversations.map((conv) {
          if (conv.id == event.conversationId) {
            return Conversation(
              id: conv.id,
              conversationType: conv.conversationType,
              title: conv.title,
              description: conv.description,
              avatar: conv.avatar,
              createdAt: conv.createdAt,
              updatedAt: conv.updatedAt,
              lastMessage: conv.lastMessage,
              unreadCount: conv.unreadCount,
              isArchived: true,
              isMuted: conv.isMuted,
              propertyId: conv.propertyId,
              participants: conv.participants,
            );
          }
          return conv;
        }).toList();

        emit(currentState.copyWith(
          conversations: updatedConversations,
          error: null,
        ));
      },
    );
  }

  /// Restores an archived conversation back into the inbox view.
  /// يعيد محادثة مؤرشفة إلى عرض الصندوق الوارد.
  Future<void> _onUnarchiveConversation(
    UnarchiveConversationEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final result = await unarchiveConversationUseCase(
      UnarchiveConversationParams(conversationId: event.conversationId),
    );

    await result.fold(
      (failure) async {
        emit(currentState.copyWith(error: await _mapFailureToMessage(failure)));
      },
      (_) async {
        // Mark the conversation as active again.
        final updatedConversations = currentState.conversations.map((conv) {
          if (conv.id == event.conversationId) {
            return Conversation(
              id: conv.id,
              conversationType: conv.conversationType,
              title: conv.title,
              description: conv.description,
              avatar: conv.avatar,
              createdAt: conv.createdAt,
              updatedAt: conv.updatedAt,
              lastMessage: conv.lastMessage,
              unreadCount: conv.unreadCount,
              isArchived: false,
              isMuted: conv.isMuted,
              propertyId: conv.propertyId,
              participants: conv.participants,
            );
          }
          return conv;
        }).toList();

        emit(currentState.copyWith(
          conversations: updatedConversations,
          error: null,
        ));
      },
    );
  }

  /// Deletes a message and keeps the thread visually consistent afterward.
  /// يحذف رسالة ويُبقي السلسلة متسقة بصريًا بعد ذلك.
  Future<void> _onDeleteMessage(
    DeleteMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final result = await deleteMessageUseCase(
      DeleteMessageParams(messageId: event.messageId),
    );

    await result.fold(
      (failure) async {
        emit(currentState.copyWith(error: await _mapFailureToMessage(failure)));
      },
      (_) async {
        // Replace the message body with a deleted placeholder.
        final updatedMessages =
            Map<String, List<Message>>.from(currentState.messages);
        final deletedPlaceholder = await _tr('chat.message.deletedPlaceholder');

        updatedMessages.forEach((conversationId, messages) {
          final updatedList = messages.map((msg) {
            if (msg.id == event.messageId) {
              return Message(
                id: msg.id,
                conversationId: msg.conversationId,
                senderId: msg.senderId,
                senderName: msg.senderName,
                messageType: msg.messageType,
                content: deletedPlaceholder,
                location: msg.location,
                replyToMessageId: msg.replyToMessageId,
                attachments: const [],
                reactions: msg.reactions,
                createdAt: msg.createdAt,
                updatedAt: DateTime.now(),
                status: msg.status,
                isEdited: msg.isEdited,
                isDeleted: true,
                deliveryReceipt: msg.deliveryReceipt,
              );
            }
            return msg;
          }).toList();

          updatedMessages[conversationId] = updatedList;
        });

        emit(currentState.copyWith(
          messages: updatedMessages,
          error: null,
        ));
      },
    );
  }

  /// Applies an inline edit to a message and reconciles it with the server
  /// response.
  /// يطبّق تعديلًا مباشرًا على رسالة ثم يطابقه مع رد الخادم.
  Future<void> _onEditMessage(
    EditMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    // Apply the optimistic edit immediately.
    final updatedMessages =
        Map<String, List<Message>>.from(currentState.messages);
    String? targetConversationId;

    updatedMessages.forEach((conversationId, messages) {
      final messageIndex =
          messages.indexWhere((msg) => msg.id == event.messageId);
      if (messageIndex != -1) {
        targetConversationId = conversationId;
        final oldMessage = messages[messageIndex];
        messages[messageIndex] = Message(
          id: oldMessage.id,
          conversationId: oldMessage.conversationId,
          senderId: oldMessage.senderId,
          senderName: oldMessage.senderName,
          messageType: oldMessage.messageType,
          content: event.content,
          location: oldMessage.location,
          replyToMessageId: oldMessage.replyToMessageId,
          attachments: oldMessage.attachments,
          reactions: oldMessage.reactions,
          createdAt: oldMessage.createdAt,
          updatedAt: DateTime.now(),
          status: 'editing',
          isEdited: true,
          editedAt: DateTime.now(),
          isDeleted: oldMessage.isDeleted,
          deliveryReceipt: oldMessage.deliveryReceipt,
        );
      }
    });

    emit(currentState.copyWith(messages: updatedMessages));

    final result = await editMessageUseCase(
      EditMessageParams(
        messageId: event.messageId,
        content: event.content,
      ),
    );

    await result.fold(
      (failure) async {
        // Restore the previous state when the edit fails.
        emit(currentState.copyWith(error: await _mapFailureToMessage(failure)));
      },
      (editedMessage) async {
        // Replace the optimistic copy with the server response.
        final finalMessages =
            Map<String, List<Message>>.from(currentState.messages);

        if (targetConversationId != null) {
          final messages = finalMessages[targetConversationId]!;
          final messageIndex =
              messages.indexWhere((msg) => msg.id == event.messageId);
          if (messageIndex != -1) {
            messages[messageIndex] = editedMessage;
          }
        }

        emit(currentState.copyWith(
          messages: finalMessages,
          error: null,
        ));
      },
    );
  }

  /// Adds a reaction optimistically and keeps the thread responsive while
  /// the backend confirms it.
  /// يضيف تفاعلًا بشكل تفاؤلي ويُبقي السلسلة سريعة الاستجابة حتى يؤكد
  /// الخادم العملية.
  Future<void> _onAddReaction(
    AddReactionEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final userId = event.currentUserId ?? currentState.currentUserId ?? '';
    if (userId.isEmpty) return;

    // Apply the reaction locally before the network round-trip.
    final optimisticReaction = MessageReaction(
      id: 'temp_reaction_${DateTime.now().microsecondsSinceEpoch}',
      messageId: event.messageId,
      userId: userId,
      reactionType: event.reactionType,
    );

    final updatedMessages = _updateMessageReaction(
      currentState.messages,
      event.messageId,
      optimisticReaction,
      isAdding: true,
    );

    emit(currentState.copyWith(messages: updatedMessages));

    final result = await addReactionUseCase(
      AddReactionParams(
        messageId: event.messageId,
        reactionType: event.reactionType,
      ),
    );

    await result.fold(
      (failure) async {
        // Roll back the optimistic reaction when the request fails.
        final revertedMessages = _updateMessageReaction(
          currentState.messages,
          event.messageId,
          optimisticReaction,
          isAdding: false,
        );
        emit(currentState.copyWith(
          messages: revertedMessages,
          error: await _tr('chat.errors.reactionAddFailed'),
        ));
      },
      (_) async {
        // Keep the optimistic reaction because the backend accepted it.
        emit(currentState.copyWith(error: null));
      },
    );
  }

  /// Removes a reaction optimistically and restores it if the backend call
  /// fails.
  /// يزيل تفاعلًا بشكل تفاؤلي ويعيده إذا فشل طلب الخادم.
  Future<void> _onRemoveReaction(
    RemoveReactionEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final userId = event.currentUserId ?? currentState.currentUserId ?? '';
    if (userId.isEmpty) return;

    // Find the existing reaction before mutating the message.
    MessageReaction? reactionToRemove;
    currentState.messages.forEach((_, messages) {
      for (final message in messages) {
        if (message.id == event.messageId) {
          reactionToRemove = message.reactions.firstWhereOrNull(
            (r) => r.userId == userId && r.reactionType == event.reactionType,
          );
          break;
        }
      }
    });

    if (reactionToRemove == null) return;

    // Remove the reaction locally first.
    final updatedMessages = _updateMessageReaction(
      currentState.messages,
      event.messageId,
      reactionToRemove!,
      isAdding: false,
    );

    emit(currentState.copyWith(messages: updatedMessages));

    final result = await removeReactionUseCase(
      RemoveReactionParams(
        messageId: event.messageId,
        reactionType: event.reactionType,
      ),
    );

    await result.fold(
      (failure) async {
        // Put the reaction back if the backend rejects the request.
        final revertedMessages = _updateMessageReaction(
          currentState.messages,
          event.messageId,
          reactionToRemove!,
          isAdding: true,
        );
        emit(currentState.copyWith(
          messages: revertedMessages,
          error: await _tr('chat.errors.reactionRemoveFailed'),
        ));
      },
      (_) async {
        // Keep the local removal because the backend accepted it.
        emit(currentState.copyWith(error: null));
      },
    );
  }

  /// Marks messages as read locally and then confirms the change with the
  /// backend.
  /// يعلّم الرسائل كمقروءة محليًا ثم يؤكد التغيير مع الخادم.
  Future<void> _onMarkMessagesAsRead(
    MarkMessagesAsReadEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    // Update the local read state immediately.
    final updatedMessages =
        Map<String, List<Message>>.from(currentState.messages);
    final messages = updatedMessages[event.conversationId] ?? [];

    final updatedList = messages.map((msg) {
      if (event.messageIds.contains(msg.id)) {
        final receipt = msg.deliveryReceipt ?? const DeliveryReceipt();
        return Message(
          id: msg.id,
          conversationId: msg.conversationId,
          senderId: msg.senderId,
          senderName: msg.senderName,
          messageType: msg.messageType,
          content: msg.content,
          location: msg.location,
          replyToMessageId: msg.replyToMessageId,
          attachments: msg.attachments,
          reactions: msg.reactions,
          createdAt: msg.createdAt,
          updatedAt: msg.updatedAt,
          status: 'read',
          isEdited: msg.isEdited,
          editedAt: msg.editedAt,
          isDeleted: msg.isDeleted,
          deliveryReceipt: DeliveryReceipt(
            deliveredAt: receipt.deliveredAt ?? DateTime.now(),
            readAt: DateTime.now(),
            readBy: [...receipt.readBy, currentState.currentUserId ?? '']
                .where((id) => id.isNotEmpty)
                .toSet()
                .toList(),
          ),
        );
      }
      return msg;
    }).toList();

    updatedMessages[event.conversationId] = updatedList;

    // Reset the unread counter for the conversation.
    final updatedConversations = currentState.conversations.map((conv) {
      if (conv.id == event.conversationId) {
        return Conversation(
          id: conv.id,
          conversationType: conv.conversationType,
          title: conv.title,
          description: conv.description,
          avatar: conv.avatar,
          createdAt: conv.createdAt,
          updatedAt: conv.updatedAt,
          lastMessage: conv.lastMessage,
          unreadCount: 0,
          isArchived: conv.isArchived,
          isMuted: conv.isMuted,
          propertyId: conv.propertyId,
          participants: conv.participants,
        );
      }
      return conv;
    }).toList();

    emit(currentState.copyWith(
      messages: updatedMessages,
      conversations: updatedConversations,
    ));

    // Confirm the read state with the backend.
    await markAsReadUseCase(
      MarkAsReadParams(
        conversationId: event.conversationId,
        messageIds: event.messageIds,
      ),
    );
  }

  /// Searches chat history and stores the combined result in state.
  /// يبحث في سجل الدردشة ويخزن النتيجة المجمعة داخل الحالة.
  Future<void> _onSearchChats(
    SearchChatsEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    emit(currentState.copyWith(isSearching: true));

    final result = await searchChatsUseCase(
      SearchChatsParams(
        query: event.query,
        conversationId: event.conversationId,
        messageType: event.messageType,
        senderId: event.senderId,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
        page: event.page,
        limit: event.limit,
      ),
    );

    await result.fold(
      (failure) async {
        emit(currentState.copyWith(
          isSearching: false,
          error: await _mapFailureToMessage(failure),
        ));
      },
      (searchResult) async {
        emit(currentState.copyWith(
          searchResult: searchResult,
          isSearching: false,
          error: null,
        ));
      },
    );
  }

  /// Loads users that the UI can add to a conversation.
  /// يحمل المستخدمين الذين يمكن للواجهة إضافتهم إلى المحادثة.
  Future<void> _onLoadAvailableUsers(
    LoadAvailableUsersEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final result = await getAvailableUsersUseCase(
      GetAvailableUsersParams(
        userType: event.userType,
        propertyId: event.propertyId,
      ),
    );

    await result.fold(
      (failure) async {
        emit(currentState.copyWith(error: await _mapFailureToMessage(failure)));
      },
      (users) async {
        emit(currentState.copyWith(
          availableUsers: users,
          error: null,
        ));
      },
    );
  }

  /// Loads admin-capable users for staff-facing chat flows.
  /// يحمل مستخدمي الإدارة لمسارات الدردشة الموجهة للطاقم.
  Future<void> _onLoadAdminUsers(
    LoadAdminUsersEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final result = await getAdminUsersUseCase(NoParams());

    await result.fold(
      (failure) async {
        emit(currentState.copyWith(error: await _mapFailureToMessage(failure)));
      },
      (admins) async {
        emit(currentState.copyWith(
          adminUsers: admins,
          error: null,
        ));
      },
    );
  }

  /// Updates the current user's presence state in chat.
  /// يحدّث حالة حضور المستخدم الحالي داخل الدردشة.
  Future<void> _onUpdateUserStatus(
    UpdateUserStatusEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state is ChatLoaded ? state as ChatLoaded : null;

    final result = await updateUserStatusUseCase(
      UpdateUserStatusParams(status: event.status),
    );

    await result.fold(
      (failure) async {
        if (currentState == null) {
          return;
        }
        emit(currentState.copyWith(error: await _mapFailureToMessage(failure)));
      },
      (_) async {
        if (currentState == null) {
          return;
        }
        // Reflect the presence change locally as well.
        final updatedPresence =
            Map<String, UserPresence>.from(currentState.userPresence);
        updatedPresence[currentState.currentUserId ?? ''] = UserPresence(
          status: event.status,
          lastSeen: event.status == 'offline' ? DateTime.now() : null,
        );

        emit(currentState.copyWith(
          userPresence: updatedPresence,
          error: null,
        ));
      },
    );
  }

  /// Loads the persisted chat preferences for the active user.
  /// يحمل تفضيلات الدردشة المخزنة للمستخدم الحالي.
  Future<void> _onLoadChatSettings(
    LoadChatSettingsEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final result = await getChatSettingsUseCase(NoParams());

    await result.fold(
      (failure) async {
        emit(currentState.copyWith(error: await _mapFailureToMessage(failure)));
      },
      (settings) async {
        await _persistChatSettings(settings);
        emit(currentState.copyWith(
          settings: settings,
          error: null,
        ));
      },
    );
  }

  /// Persists partial chat settings changes and keeps the UI in sync.
  /// يحفظ تغييرات إعدادات الدردشة الجزئية ويُبقي الواجهة متزامنة.
  Future<void> _onUpdateChatSettings(
    UpdateChatSettingsEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final currentSettings = currentState.settings;
    if (currentSettings == null) return;

    final updatedSettings = ChatSettings(
      id: currentSettings.id,
      userId: currentSettings.userId,
      notificationsEnabled:
          event.notificationsEnabled ?? currentSettings.notificationsEnabled,
      soundEnabled: event.soundEnabled ?? currentSettings.soundEnabled,
      showReadReceipts:
          event.showReadReceipts ?? currentSettings.showReadReceipts,
      showTypingIndicator:
          event.showTypingIndicator ?? currentSettings.showTypingIndicator,
      theme: event.theme ?? currentSettings.theme,
      fontSize: event.fontSize ?? currentSettings.fontSize,
      autoDownloadMedia:
          event.autoDownloadMedia ?? currentSettings.autoDownloadMedia,
      backupMessages: event.backupMessages ?? currentSettings.backupMessages,
    );

    // Apply the settings change locally first.
    emit(currentState.copyWith(settings: updatedSettings));

    final result = await updateChatSettingsUseCase(
      UpdateChatSettingsParams(
        notificationsEnabled: updatedSettings.notificationsEnabled,
        soundEnabled: updatedSettings.soundEnabled,
        showReadReceipts: updatedSettings.showReadReceipts,
        showTypingIndicator: updatedSettings.showTypingIndicator,
        theme: updatedSettings.theme,
        fontSize: updatedSettings.fontSize,
        autoDownloadMedia: updatedSettings.autoDownloadMedia,
        backupMessages: updatedSettings.backupMessages,
      ),
    );

    await result.fold(
      (failure) async {
        // Restore the previous settings when persistence fails.
        emit(currentState.copyWith(
          settings: currentSettings,
          error: await _mapFailureToMessage(failure),
        ));
      },
      (settings) async {
        await _persistChatSettings(settings);
        // Replace the optimistic settings with the server response.
        emit(currentState.copyWith(
          settings: settings,
          error: null,
        ));
      },
    );
  }

  /// Sends a typing indicator through the websocket layer.
  /// يرسل مؤشر الكتابة عبر طبقة websocket.
  Future<void> _onSendTypingIndicator(
    SendTypingIndicatorEvent event,
    Emitter<ChatState> emit,
  ) async {
    // The websocket service is the authoritative channel for typing events.
    webSocketService.sendTypingIndicator(event.conversationId, event.isTyping);
  }

  /// Routes websocket message events to the matching state update handler.
  Future<void> _onWebSocketMessageReceived(
    WebSocketMessageReceivedEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final messageEvent = event.messageEvent;

    switch (messageEvent.type) {
      case MessageEventType.newMessage:
        await _handleNewMessage(messageEvent, currentState, emit);
        break;
      case MessageEventType.edited:
        await _handleMessageUpdated(messageEvent, currentState, emit);
        break;
      case MessageEventType.deleted:
        await _handleMessageDeleted(messageEvent, currentState, emit);
        break;
      case MessageEventType.reactionAdded:
        await _handleReactionAdded(messageEvent, currentState, emit);
        break;
      case MessageEventType.reactionRemoved:
        await _handleReactionRemoved(messageEvent, currentState, emit);
        break;
      case MessageEventType.statusUpdated:
        await _handleStatusUpdated(messageEvent, currentState, emit);
        break;
    }
  }

  /// Applies an incoming message event and updates the visible thread.
  Future<void> _handleNewMessage(
    MessageEvent event,
    ChatLoaded currentState,
    Emitter<ChatState> emit,
  ) async {
    if (event.message == null) {
      // FCM-driven chat updates may only contain ids. Refresh the inbox
      // snapshot so unread counters and previews stay accurate.
      await webSocketService.emitConversationById(
        conversationId: event.conversationId,
      );

      // If this thread is already loaded locally, fetch the latest first page
      // so the timeline also catches up with the server copy.
      if (currentState.messages.containsKey(event.conversationId)) {
        add(RefreshConversationEvent(conversationId: event.conversationId));
      }
      return;
    }

    final newMessage = event.message!;
    final conversationId = event.conversationId;

    // Insert the new message into the thread if it is not already present.
    final updatedMessages =
        Map<String, List<Message>>.from(currentState.messages);
    final messages = List<Message>.from(updatedMessages[conversationId] ?? []);

    final sameIdIndex = messages.indexWhere((msg) => msg.id == newMessage.id);

    if (sameIdIndex != -1) {
      messages[sameIdIndex] =
          _mergeMessageWithReference(newMessage, messages[sameIdIndex]);
      updatedMessages[conversationId] = messages;
    } else {
      final matchingIndex = messages.indexWhere(
        (msg) =>
            _isTransientMessage(msg) && _isRenderableDuplicate(msg, newMessage),
      );

      if (matchingIndex != -1) {
        final previousId = messages[matchingIndex].id;
        messages[matchingIndex] =
            _mergeMessageWithReference(newMessage, messages[matchingIndex]);
        _optimisticMessages[conversationId]?.removeWhere(
          (msg) => msg.id == previousId,
        );
      } else {
        messages.insert(0, newMessage);
      }

      updatedMessages[conversationId] = _collapseTransientAudioDuplicates(
        messages,
        newMessage,
      );
    }

    // Refresh the conversation preview and unread count.
    final updatedConversations = currentState.conversations.map((conv) {
      if (conv.id == conversationId) {
        final isMyMessage = newMessage.senderId == currentState.currentUserId;
        return Conversation(
          id: conv.id,
          conversationType: conv.conversationType,
          title: conv.title,
          description: conv.description,
          avatar: conv.avatar,
          createdAt: conv.createdAt,
          updatedAt: DateTime.now(),
          lastMessage: newMessage,
          unreadCount: isMyMessage ? 0 : conv.unreadCount + 1,
          isArchived: conv.isArchived,
          isMuted: conv.isMuted,
          propertyId: conv.propertyId,
          participants: conv.participants,
        );
      }
      return conv;
    }).toList();

    emit(currentState.copyWith(
      messages: updatedMessages,
      conversations: updatedConversations,
    ));
  }

  /// Replaces an existing message with the updated websocket payload.
  Future<void> _handleMessageUpdated(
    MessageEvent event,
    ChatLoaded currentState,
    Emitter<ChatState> emit,
  ) async {
    if (event.message == null) return;

    final updatedMessage = event.message!;
    final updatedMessages =
        Map<String, List<Message>>.from(currentState.messages);

    updatedMessages.forEach((conversationId, messages) {
      final messageIndex =
          messages.indexWhere((msg) => msg.id == updatedMessage.id);
      if (messageIndex != -1) {
        messages[messageIndex] = updatedMessage;
      }
    });

    emit(currentState.copyWith(messages: updatedMessages));
  }

  /// Marks the affected message as deleted while preserving thread context.
  Future<void> _handleMessageDeleted(
    MessageEvent event,
    ChatLoaded currentState,
    Emitter<ChatState> emit,
  ) async {
    final messageId = event.messageId;
    if (messageId == null) return;

    final updatedMessages =
        Map<String, List<Message>>.from(currentState.messages);
    final deletedPlaceholder = await _tr('chat.message.deletedPlaceholder');

    updatedMessages.forEach((conversationId, messages) {
      final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
      if (messageIndex != -1) {
        final deletedMessage = messages[messageIndex];
        messages[messageIndex] = Message(
          id: deletedMessage.id,
          conversationId: deletedMessage.conversationId,
          senderId: deletedMessage.senderId,
          senderName: deletedMessage.senderName,
          messageType: deletedMessage.messageType,
          content: deletedPlaceholder,
          location: deletedMessage.location,
          replyToMessageId: deletedMessage.replyToMessageId,
          attachments: const [],
          reactions: deletedMessage.reactions,
          createdAt: deletedMessage.createdAt,
          updatedAt: DateTime.now(),
          status: deletedMessage.status,
          isEdited: deletedMessage.isEdited,
          isDeleted: true,
          deliveryReceipt: deletedMessage.deliveryReceipt,
        );
      }
    });

    emit(currentState.copyWith(messages: updatedMessages));
  }

  /// Applies a reaction added elsewhere so all clients stay in sync.
  Future<void> _handleReactionAdded(
    MessageEvent event,
    ChatLoaded currentState,
    Emitter<ChatState> emit,
  ) async {
    final reaction = event.reaction;
    if (reaction == null) return;

    final updatedMessages = _updateMessageReaction(
      currentState.messages,
      reaction.messageId,
      reaction,
      isAdding: true,
    );

    emit(currentState.copyWith(messages: updatedMessages));
  }

  /// Applies a reaction removal event from another client or device.
  Future<void> _handleReactionRemoved(
    MessageEvent event,
    ChatLoaded currentState,
    Emitter<ChatState> emit,
  ) async {
    final reaction = event.reaction;
    if (reaction == null) return;

    final updatedMessages = _updateMessageReaction(
      currentState.messages,
      reaction.messageId,
      reaction,
      isAdding: false,
    );

    emit(currentState.copyWith(messages: updatedMessages));
  }

  /// Applies a status update such as sent, delivered, or read.
  Future<void> _handleStatusUpdated(
    MessageEvent event,
    ChatLoaded currentState,
    Emitter<ChatState> emit,
  ) async {
    final messageId = event.messageId;
    final status = event.status;
    if (messageId == null || status == null) return;

    final updatedMessages =
        Map<String, List<Message>>.from(currentState.messages);

    updatedMessages.forEach((conversationId, messages) {
      final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
      if (messageIndex != -1) {
        final message = messages[messageIndex];
        final currentReceipt =
            message.deliveryReceipt ?? const DeliveryReceipt();
        messages[messageIndex] = Message(
          id: message.id,
          conversationId: message.conversationId,
          senderId: message.senderId,
          senderName: message.senderName,
          messageType: message.messageType,
          content: message.content,
          location: message.location,
          replyToMessageId: message.replyToMessageId,
          attachments: message.attachments,
          reactions: message.reactions,
          createdAt: message.createdAt,
          updatedAt: message.updatedAt,
          status: status,
          isEdited: message.isEdited,
          editedAt: message.editedAt,
          isDeleted: message.isDeleted,
          deliveryReceipt: DeliveryReceipt(
            deliveredAt: event.deliveredAt ?? currentReceipt.deliveredAt,
            readAt: event.readAt ??
                currentReceipt.readAt ??
                (status == 'read' ? DateTime.now() : null),
            readBy: currentReceipt.readBy,
          ),
        );
      }
    });

    final updatedConversations = currentState.conversations.map((conv) {
      final lastMessage = conv.lastMessage;
      if (lastMessage == null || lastMessage.id != messageId) {
        return conv;
      }

      final currentReceipt =
          lastMessage.deliveryReceipt ?? const DeliveryReceipt();
      return Conversation(
        id: conv.id,
        conversationType: conv.conversationType,
        title: conv.title,
        description: conv.description,
        avatar: conv.avatar,
        createdAt: conv.createdAt,
        updatedAt: conv.updatedAt,
        lastMessage: Message(
          id: lastMessage.id,
          conversationId: lastMessage.conversationId,
          senderId: lastMessage.senderId,
          senderName: lastMessage.senderName,
          messageType: lastMessage.messageType,
          content: lastMessage.content,
          location: lastMessage.location,
          replyToMessageId: lastMessage.replyToMessageId,
          attachments: lastMessage.attachments,
          reactions: lastMessage.reactions,
          createdAt: lastMessage.createdAt,
          updatedAt: lastMessage.updatedAt,
          status: status,
          isEdited: lastMessage.isEdited,
          editedAt: lastMessage.editedAt,
          isDeleted: lastMessage.isDeleted,
          deliveryReceipt: DeliveryReceipt(
            deliveredAt: event.deliveredAt ?? currentReceipt.deliveredAt,
            readAt: event.readAt ??
                currentReceipt.readAt ??
                (status == 'read' ? DateTime.now() : null),
            readBy: currentReceipt.readBy,
          ),
        ),
        unreadCount: conv.unreadCount,
        isArchived: conv.isArchived,
        isMuted: conv.isMuted,
        propertyId: conv.propertyId,
        participants: conv.participants,
      );
    }).toList();

    emit(currentState.copyWith(
      messages: updatedMessages,
      conversations: updatedConversations,
    ));
  }

  /// Syncs a conversation-level websocket update into the inbox list.
  Future<void> _onWebSocketConversationUpdated(
    WebSocketConversationUpdatedEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final updatedConversation = event.conversation;

    // Replace the matching conversation entry in the inbox.
    final updatedConversations = currentState.conversations.map((conv) {
      if (conv.id == updatedConversation.id) {
        return updatedConversation;
      }
      return conv;
    }).toList();

    emit(currentState.copyWith(conversations: updatedConversations));
  }

  /// Syncs remote typing indicators while filtering the current user.
  Future<void> _onWebSocketTypingIndicator(
    WebSocketTypingIndicatorEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final updatedTypingUsers =
        Map<String, List<String>>.from(currentState.typingUsers);

    if (event.typingUserIds.isEmpty) {
      updatedTypingUsers.remove(event.conversationId);
    } else {
      // Remove the current user from the typing list before showing it.
      final filteredUsers = event.typingUserIds
          .where((id) => id != currentState.currentUserId)
          .toList();

      if (filteredUsers.isNotEmpty) {
        updatedTypingUsers[event.conversationId] = filteredUsers;
      } else {
        updatedTypingUsers.remove(event.conversationId);
      }
    }

    emit(currentState.copyWith(typingUsers: updatedTypingUsers));
  }

  /// Syncs presence changes into the active chat state and user lists.
  Future<void> _onWebSocketPresenceUpdate(
    WebSocketPresenceUpdateEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final updatedPresence =
        Map<String, UserPresence>.from(currentState.userPresence);
    updatedPresence[event.userId] = UserPresence(
      status: event.status,
      lastSeen: event.lastSeen,
    );

    // Refresh the presence flags for the available-user list.
    final updatedAvailableUsers = currentState.availableUsers.map((user) {
      if (user.id == event.userId) {
        return ChatUser(
          id: user.id,
          name: user.name,
          email: user.email,
          phone: user.phone,
          profileImage: user.profileImage,
          userType: user.userType,
          status: event.status,
          lastSeen: event.lastSeen,
          propertyId: user.propertyId,
          isOnline: event.status == 'online',
        );
      }
      return user;
    }).toList();

    // Refresh the same presence data inside every conversation thread.
    final updatedConversations = currentState.conversations.map((conv) {
      final updatedParticipants = conv.participants.map((participant) {
        if (participant.id == event.userId) {
          return ChatUser(
            id: participant.id,
            name: participant.name,
            email: participant.email,
            phone: participant.phone,
            profileImage: participant.profileImage,
            userType: participant.userType,
            status: event.status,
            lastSeen: event.lastSeen,
            propertyId: participant.propertyId,
            isOnline: event.status == 'online',
          );
        }
        return participant;
      }).toList();

      return Conversation(
        id: conv.id,
        conversationType: conv.conversationType,
        title: conv.title,
        description: conv.description,
        avatar: conv.avatar,
        createdAt: conv.createdAt,
        updatedAt: conv.updatedAt,
        lastMessage: conv.lastMessage,
        unreadCount: conv.unreadCount,
        isArchived: conv.isArchived,
        isMuted: conv.isMuted,
        propertyId: conv.propertyId,
        participants: updatedParticipants,
      );
    }).toList();

    emit(currentState.copyWith(
      userPresence: updatedPresence,
      availableUsers: updatedAvailableUsers,
      conversations: updatedConversations,
    ));
  }

  /// Clears cached messages and local bookkeeping for one conversation.
  /// يمسح الرسائل المخزنة محليًا وبيانات المتابعة الخاصة بمحادثة واحدة.
  Future<void> _onClearConversationCache(
    ClearConversationCacheEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    // Remove the cached message timeline.
    final updatedMessages =
        Map<String, List<Message>>.from(currentState.messages);
    updatedMessages.remove(event.conversationId);

    // Drop pagination and loading state for the thread.
    _conversationLoadingStates.remove(event.conversationId);
    _messagePages.remove(event.conversationId);
    _hasMoreMessages.remove(event.conversationId);
    _loadedMessageIds.remove(event.conversationId);
    _optimisticMessages.remove(event.conversationId);

    // Remove any typing indicators for that conversation.
    final updatedTypingUsers =
        Map<String, List<String>>.from(currentState.typingUsers);
    updatedTypingUsers.remove(event.conversationId);

    emit(currentState.copyWith(
      messages: updatedMessages,
      typingUsers: updatedTypingUsers,
    ));
  }

  /// Refreshes a conversation by clearing its cache and reloading messages.
  /// ينعش المحادثة عبر مسح كاشها ثم إعادة تحميل الرسائل.
  Future<void> _onRefreshConversation(
    RefreshConversationEvent event,
    Emitter<ChatState> emit,
  ) async {
    // Clear the local cache before requesting fresh data.
    add(ClearConversationCacheEvent(conversationId: event.conversationId));

    // Request the initial page again after clearing the state.
    add(LoadMessagesEvent(
      conversationId: event.conversationId,
      pageNumber: 1,
      pageSize: 50,
    ));
  }

  /// Mirrors chat settings into shared preferences for non-chat services.
  /// ينسخ إعدادات الشات إلى التفضيلات المشتركة كي تراها الخدمات خارج الشات.
  Future<void> _persistChatSettings(ChatSettings settings) async {
    await Future.wait([
      localStorageService.saveData(
        ChatSettingsKeys.notificationsEnabled,
        settings.notificationsEnabled,
      ),
      localStorageService.saveData(
        ChatSettingsKeys.soundEnabled,
        settings.soundEnabled,
      ),
      localStorageService.saveData(
        ChatSettingsKeys.showReadReceipts,
        settings.showReadReceipts,
      ),
      localStorageService.saveData(
        ChatSettingsKeys.showTypingIndicator,
        settings.showTypingIndicator,
      ),
      localStorageService.saveData(
        ChatSettingsKeys.theme,
        settings.theme,
      ),
      localStorageService.saveData(
        ChatSettingsKeys.fontSize,
        settings.fontSize,
      ),
      localStorageService.saveData(
        ChatSettingsKeys.autoDownloadMedia,
        settings.autoDownloadMedia,
      ),
      localStorageService.saveData(
        ChatSettingsKeys.backupMessages,
        settings.backupMessages,
      ),
    ]);
  }

  /// Retries a failed message by staging it again and sending a fresh copy.
  /// يعيد محاولة رسالة فاشلة عبر تجهيزها من جديد وإرسال نسخة جديدة.
  Future<void> _onRetryFailedMessage(
    RetryFailedMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    // Find the failed draft that should be retried.
    Message? failedMessage;
    currentState.messages[event.conversationId]?.forEach((msg) {
      if (msg.id == event.messageId && msg.status == 'failed') {
        failedMessage = msg;
      }
    });

    if (failedMessage == null) return;

    final normalizedMessageType =
        failedMessage!.messageType.trim().toLowerCase();
    final stableAttachmentIds = failedMessage!.attachments
        .where((attachment) => !attachment.id.startsWith('temp_'))
        .map((attachment) => attachment.id)
        .toList();
    final localFilePaths = failedMessage!.attachments
        .map((attachment) => attachment.filePath.trim())
        .where((path) => path.isNotEmpty && File(path).existsSync())
        .toList();
    final hasAllStableAttachmentIds = failedMessage!.attachments.isNotEmpty &&
        stableAttachmentIds.length == failedMessage!.attachments.length;
    final hasAllLocalFiles = failedMessage!.attachments.isNotEmpty &&
        localFilePaths.length == failedMessage!.attachments.length;

    ChatEvent? retryEvent;

    if (failedMessage!.attachments.isEmpty) {
      retryEvent = SendMessageEvent(
        conversationId: failedMessage!.conversationId,
        messageType: failedMessage!.messageType,
        content: failedMessage!.content,
        location: failedMessage!.location,
        replyToMessageId: failedMessage!.replyToMessageId,
        currentUserId: currentState.currentUserId,
      );
    } else if (normalizedMessageType == 'audio') {
      if (hasAllLocalFiles) {
        retryEvent = SendAudioMessageEvent(
          conversationId: failedMessage!.conversationId,
          filePath: localFilePaths.first,
          replyToMessageId: failedMessage!.replyToMessageId,
          durationSeconds: failedMessage!.attachments.first.duration,
        );
      } else if (hasAllStableAttachmentIds) {
        retryEvent = SendMessageEvent(
          conversationId: failedMessage!.conversationId,
          messageType: failedMessage!.messageType,
          replyToMessageId: failedMessage!.replyToMessageId,
          attachmentIds: stableAttachmentIds,
          currentUserId: currentState.currentUserId,
        );
      }
    } else if (hasAllLocalFiles) {
      retryEvent = UploadMultipleAttachmentsEvent(
        conversationId: failedMessage!.conversationId,
        filePaths: List<String>.from(localFilePaths),
        messageType: normalizedMessageType,
        content: failedMessage!.content,
        replyToMessageId: failedMessage!.replyToMessageId,
        currentUserId: currentState.currentUserId,
      );
    } else if (hasAllStableAttachmentIds) {
      retryEvent = SendMessageEvent(
        conversationId: failedMessage!.conversationId,
        messageType: failedMessage!.messageType,
        content: failedMessage!.content,
        location: failedMessage!.location,
        replyToMessageId: failedMessage!.replyToMessageId,
        attachmentIds: stableAttachmentIds,
        currentUserId: currentState.currentUserId,
      );
    }

    if (retryEvent == null) {
      emit(currentState.copyWith(
        error: await _tr('chat.errors.messageSendFailed'),
      ));
      return;
    }

    final updatedMessages =
        Map<String, List<Message>>.from(currentState.messages);
    final messages =
        List<Message>.from(updatedMessages[event.conversationId] ?? []);
    messages.removeWhere((msg) => msg.id == event.messageId);
    updatedMessages[event.conversationId] = messages;
    _optimisticMessages[event.conversationId]
        ?.removeWhere((msg) => msg.id == event.messageId);

    emit(currentState.copyWith(messages: updatedMessages));
    add(retryEvent);
  }

  /// Merges incoming conversations into the existing inbox without losing
  /// the freshest update per thread.
  /// يدمج المحادثات الواردة في الصندوق الحالي من دون فقدان أحدث تحديث لكل
  /// سلسلة.
  List<Conversation> _mergeConversations(
    List<Conversation> existing,
    List<Conversation> newConversations,
  ) {
    final conversationMap = <String, Conversation>{};

    // Seed the map with the conversations already in memory.
    for (final conv in existing) {
      conversationMap[conv.id] = conv;
    }

    // Overwrite or insert newer versions from the incoming page.
    for (final conv in newConversations) {
      final current = conversationMap[conv.id];
      conversationMap[conv.id] =
          current == null ? conv : _pickPreferredConversation(current, conv);
    }

    // Keep the inbox sorted by most recent activity.
    final merged = conversationMap.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return merged;
  }

  Conversation _pickPreferredConversation(
    Conversation current,
    Conversation incoming,
  ) {
    final mergedLastMessage = current.lastMessage == null
        ? incoming.lastMessage
        : incoming.lastMessage == null
            ? current.lastMessage
            : _pickRicherMessage(current.lastMessage!, incoming.lastMessage!);

    final shouldPreserveClearedUnread = current.unreadCount == 0 &&
        incoming.unreadCount > 0 &&
        _isSameConversationPreview(current, incoming);

    return Conversation(
      id: incoming.id,
      conversationType: incoming.conversationType,
      title: (incoming.title?.trim().isNotEmpty ?? false)
          ? incoming.title
          : current.title,
      description: (incoming.description?.trim().isNotEmpty ?? false)
          ? incoming.description
          : current.description,
      avatar: (incoming.avatar?.trim().isNotEmpty ?? false)
          ? incoming.avatar
          : current.avatar,
      createdAt: current.createdAt,
      updatedAt: incoming.updatedAt.isAfter(current.updatedAt)
          ? incoming.updatedAt
          : current.updatedAt,
      lastMessage: mergedLastMessage,
      unreadCount: shouldPreserveClearedUnread ? 0 : incoming.unreadCount,
      isArchived: incoming.isArchived,
      isMuted: incoming.isMuted,
      propertyId: incoming.propertyId ?? current.propertyId,
      participants: incoming.participants.length >= current.participants.length
          ? incoming.participants
          : current.participants,
    );
  }

  bool _isSameConversationPreview(Conversation current, Conversation incoming) {
    final currentLastMessage = current.lastMessage;
    final incomingLastMessage = incoming.lastMessage;

    if (currentLastMessage == null || incomingLastMessage == null) {
      return false;
    }

    if (currentLastMessage.id == incomingLastMessage.id) {
      return true;
    }

    return currentLastMessage.senderId == incomingLastMessage.senderId &&
        currentLastMessage.messageType == incomingLastMessage.messageType &&
        _normalizedText(currentLastMessage.content) ==
            _normalizedText(incomingLastMessage.content);
  }

  /// Matches optimistic attachment messages such as audio notes with their
  /// definitive websocket payload even when the textual content is empty.
  bool _isOptimisticAttachmentMatch(Message optimistic, Message incoming) {
    if (optimistic.attachments.isEmpty || incoming.attachments.isEmpty) {
      return false;
    }

    if (optimistic.attachments.length != incoming.attachments.length) {
      return false;
    }

    for (var index = 0; index < optimistic.attachments.length; index++) {
      final optimisticAttachment = optimistic.attachments[index];
      final incomingAttachment = incoming.attachments[index];

      final fileNameMatches =
          _normalizedText(optimisticAttachment.fileName).isNotEmpty &&
              _normalizedText(optimisticAttachment.fileName) ==
                  _normalizedText(incomingAttachment.fileName);

      final fileSizeMatches = optimisticAttachment.fileSize > 0 &&
          incomingAttachment.fileSize > 0 &&
          optimisticAttachment.fileSize == incomingAttachment.fileSize;

      final audioDurationMatches =
          optimistic.messageType == 'audio' && incoming.messageType == 'audio'
              ? optimisticAttachment.duration != null &&
                  incomingAttachment.duration != null &&
                  optimisticAttachment.duration == incomingAttachment.duration
              : false;

      if (!fileNameMatches && !fileSizeMatches && !audioDurationMatches) {
        return false;
      }
    }

    return true;
  }

  /// Detects visually duplicate messages even when transport layers assign
  /// different ids during the optimistic/send/realtime lifecycle.
  bool _isRenderableDuplicate(Message existing, Message incoming) {
    final existingSender = _normalizedText(existing.senderId);
    final incomingSender = _normalizedText(incoming.senderId);
    final senderMatches = existingSender.isEmpty ||
        incomingSender.isEmpty ||
        existingSender == incomingSender;

    if (!senderMatches ||
        existing.messageType != incoming.messageType ||
        existing.replyToMessageId != incoming.replyToMessageId) {
      return false;
    }

    if (_normalizedText(existing.content) != '' &&
        _normalizedText(existing.content) ==
            _normalizedText(incoming.content)) {
      return true;
    }

    if (_isOptimisticAttachmentMatch(existing, incoming)) {
      return true;
    }

    final existingAttachment =
        existing.attachments.isNotEmpty ? existing.attachments.first : null;
    final incomingAttachment =
        incoming.attachments.isNotEmpty ? incoming.attachments.first : null;

    if (existingAttachment == null ||
        incomingAttachment == null ||
        existing.attachments.length != incoming.attachments.length) {
      return false;
    }

    final ageDiff =
        existing.createdAt.difference(incoming.createdAt).inSeconds.abs();
    return ageDiff <= 10 &&
        existingAttachment.contentType == incomingAttachment.contentType &&
        ((existingAttachment.fileSize > 0 &&
                existingAttachment.fileSize == incomingAttachment.fileSize) ||
            (_normalizedText(existingAttachment.fileName).isNotEmpty &&
                _normalizedText(existingAttachment.fileName) ==
                    _normalizedText(incomingAttachment.fileName)));
  }

  bool _isTransientMessage(Message message) {
    final normalizedStatus = _normalizedText(message.status);
    return message.id.startsWith('temp_') ||
        normalizedStatus == 'sending' ||
        normalizedStatus == 'failed';
  }

  /// Preserves optimistic audio metadata such as duration when the server
  /// payload is incomplete or delayed.
  Message _mergeMessageWithReference(Message incoming, Message? reference) {
    if (reference == null) return incoming;

    final mergedAttachments = _mergeAttachmentsWithReference(
        incoming.attachments, reference.attachments);
    final mergedStatus =
        _pickPreferredStatus(incoming.status, reference.status);
    final mergedReceipt = _mergeDeliveryReceipt(
      incoming.deliveryReceipt,
      reference.deliveryReceipt,
    );

    return Message(
      id: incoming.id,
      conversationId: incoming.conversationId,
      senderId: incoming.senderId,
      senderName: incoming.senderName ?? reference.senderName,
      messageType: incoming.messageType,
      content: incoming.content ?? reference.content,
      location: incoming.location ?? reference.location,
      replyToMessageId: incoming.replyToMessageId ?? reference.replyToMessageId,
      reactions: incoming.reactions,
      attachments: mergedAttachments,
      createdAt: incoming.createdAt,
      updatedAt: incoming.updatedAt,
      status: mergedStatus,
      isEdited: incoming.isEdited,
      editedAt: incoming.editedAt,
      deliveryReceipt: mergedReceipt,
      isDeleted: incoming.isDeleted,
      failureReason: incoming.failureReason ?? reference.failureReason,
    );
  }

  List<Attachment> _mergeAttachmentsWithReference(
    List<Attachment> incoming,
    List<Attachment> reference,
  ) {
    if (incoming.isEmpty) return reference;
    if (reference.isEmpty) return incoming;

    final merged = <Attachment>[];
    final maxCount =
        incoming.length > reference.length ? incoming.length : reference.length;

    for (var index = 0; index < maxCount; index++) {
      final primary = index < incoming.length ? incoming[index] : null;
      final fallback = index < reference.length ? reference[index] : null;

      if (primary == null && fallback != null) {
        merged.add(fallback);
        continue;
      }

      if (primary == null) {
        continue;
      }

      if (fallback == null) {
        merged.add(primary);
        continue;
      }

      merged.add(Attachment(
        id: primary.id,
        conversationId: primary.conversationId,
        fileName:
            primary.fileName.isNotEmpty ? primary.fileName : fallback.fileName,
        contentType: primary.contentType.isNotEmpty
            ? primary.contentType
            : fallback.contentType,
        fileSize: primary.fileSize > 0 ? primary.fileSize : fallback.fileSize,
        filePath:
            primary.filePath.isNotEmpty ? primary.filePath : fallback.filePath,
        fileUrl:
            primary.fileUrl.isNotEmpty ? primary.fileUrl : fallback.fileUrl,
        uploadedBy: primary.uploadedBy.isNotEmpty
            ? primary.uploadedBy
            : fallback.uploadedBy,
        createdAt: primary.createdAt,
        thumbnailUrl: primary.thumbnailUrl ?? fallback.thumbnailUrl,
        metadata: _mergeAttachmentMetadata(
          fallback.metadata,
          primary.metadata,
          fallback.thumbnailUrl,
        ),
        duration: (primary.duration != null && primary.duration! > 0)
            ? primary.duration
            : fallback.duration,
        downloadProgress: primary.downloadProgress ?? fallback.downloadProgress,
      ));
    }

    return merged;
  }

  List<Message> _replaceOptimisticWithConfirmed(
    List<Message> messages,
    Message optimisticMessage,
    Message confirmedMessage,
  ) {
    final updated = List<Message>.from(messages);
    final replaceIndex = updated.indexWhere(
      (msg) =>
          msg.id == optimisticMessage.id ||
          msg.id == confirmedMessage.id ||
          (_isTransientMessage(msg) &&
              _isRenderableDuplicate(msg, confirmedMessage)),
    );

    if (replaceIndex != -1) {
      updated[replaceIndex] = confirmedMessage;
    } else {
      updated.insert(0, confirmedMessage);
    }

    return updated.whereIndexed((index, msg) {
      if (replaceIndex != -1 && index == replaceIndex) {
        return true;
      }

      if (msg.id == optimisticMessage.id || msg.id == confirmedMessage.id) {
        return false;
      }

      if (_isStaleOptimisticAudio(msg, confirmedMessage)) {
        return false;
      }

      if (_isTransientMessage(msg) &&
          _isRenderableDuplicate(msg, confirmedMessage)) {
        return false;
      }

      return true;
    }).toList();
  }

  bool _isStaleOptimisticAudio(Message existing, Message confirmed) {
    if (!existing.id.startsWith('temp_') ||
        existing.messageType != 'audio' ||
        confirmed.messageType != 'audio') {
      return false;
    }

    if (existing.conversationId != confirmed.conversationId) {
      return false;
    }

    if (_normalizedText(existing.status) == 'failed') {
      return false;
    }

    final existingSender = _normalizedText(existing.senderId);
    final confirmedSender = _normalizedText(confirmed.senderId);
    if (existingSender.isNotEmpty &&
        confirmedSender.isNotEmpty &&
        existingSender != confirmedSender) {
      return false;
    }

    if (existing.replyToMessageId != confirmed.replyToMessageId) {
      return false;
    }

    if (_isOptimisticAttachmentMatch(existing, confirmed)) {
      return true;
    }

    final ageDiff =
        existing.createdAt.difference(confirmed.createdAt).inSeconds;
    return ageDiff.abs() <= 45;
  }

  List<Message> _collapseTransientAudioDuplicates(
    List<Message> messages,
    Message confirmedMessage, {
    Message? optimisticMessage,
  }) {
    if (confirmedMessage.messageType != 'audio') {
      return messages;
    }

    final collapsed = <Message>[];
    var keptConfirmed = false;

    for (final message in messages) {
      final isConfirmedMessage = message.id == confirmedMessage.id;

      if (isConfirmedMessage && !keptConfirmed) {
        collapsed.add(message);
        keptConfirmed = true;
        continue;
      }

      if (_isStaleOptimisticAudio(message, confirmedMessage)) {
        continue;
      }

      if (_isRenderableDuplicate(message, confirmedMessage)) {
        if (!keptConfirmed) {
          collapsed.add(
            _mergeMessageWithReference(confirmedMessage, optimisticMessage),
          );
          keptConfirmed = true;
        }
        continue;
      }

      collapsed.add(message);
    }

    if (!keptConfirmed) {
      collapsed.insert(
        0,
        _mergeMessageWithReference(confirmedMessage, optimisticMessage),
      );
    }

    return collapsed;
  }

  String _normalizedText(String? value) => value?.trim().toLowerCase() ?? '';

  Future<String?> _buildOptimisticVideoThumbnail(
    String videoPath,
    String uploadId,
  ) async {
    final file = File(videoPath);
    if (!file.existsSync()) {
      return null;
    }

    try {
      return await VideoThumbnail.thumbnailFile(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 320,
        quality: 72,
        thumbnailPath: Directory.systemTemp.path,
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _mergeAttachmentMetadata(
    Map<String, dynamic>? baseMetadata,
    Map<String, dynamic>? incomingMetadata,
    String? localThumbnailCandidate,
  ) {
    final merged = <String, dynamic>{};

    if (baseMetadata != null) {
      merged.addAll(baseMetadata);
    }

    if (incomingMetadata != null) {
      merged.addAll(incomingMetadata);
    }

    final candidate = localThumbnailCandidate?.trim() ?? '';
    if (candidate.isNotEmpty && File(candidate).existsSync()) {
      merged[_localThumbnailMetadataKey] = candidate;
    } else if (!merged.containsKey(_localThumbnailMetadataKey)) {
      merged.remove(_localThumbnailMetadataKey);
    }

    return merged.isEmpty ? null : merged;
  }

  /// Merges a fresh message page with the existing thread while skipping
  /// temporary optimistic entries.
  /// يدمج صفحة الرسائل الجديدة مع السجل الحالي مع تجاهل العناصر التفاؤلية
  /// المؤقتة.
  List<Message> _mergeMessages(
    List<Message> existing,
    List<Message> newMessages,
  ) {
    final messageMap = <String, Message>{};

    // Seed the map with already loaded messages.
    for (final msg in existing) {
      // Skip temporary optimistic messages until the server confirms them.
      if (!msg.id.startsWith('temp_')) {
        messageMap[msg.id] = msg;
      }
    }

    // Keep the richer copy when the same message arrives again from another
    // source such as pagination, refresh, or websocket reconciliation.
    for (final msg in newMessages) {
      final existingMessage = messageMap[msg.id];
      messageMap[msg.id] = existingMessage == null
          ? msg
          : _pickRicherMessage(existingMessage, msg);
    }

    // Keep the newest message first in the rendered list.
    final merged = messageMap.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return merged;
  }

  Message _pickRicherMessage(Message current, Message incoming) {
    final merged = _mergeMessageWithReference(incoming, current);
    final currentScore = _messageRichnessScore(current);
    final incomingScore = _messageRichnessScore(merged);

    if (_messageStatusRank(merged.status) >
        _messageStatusRank(current.status)) {
      return merged;
    }

    final mergedReceipt = merged.deliveryReceipt;
    final currentReceipt = current.deliveryReceipt;
    if (mergedReceipt?.readAt != null && currentReceipt?.readAt == null) {
      return merged;
    }

    if (mergedReceipt?.deliveredAt != null &&
        currentReceipt?.deliveredAt == null) {
      return merged;
    }

    if (incomingScore > currentScore) {
      return merged;
    }

    if (incoming.updatedAt.isAfter(current.updatedAt)) {
      return merged;
    }

    return current;
  }

  int _messageRichnessScore(Message message) {
    var score = 0;

    if ((message.content?.trim().isNotEmpty ?? false)) {
      score += 2;
    }

    if (message.location != null) {
      score += 2;
    }

    score += _messageStatusRank(message.status) * 2;

    final receipt = message.deliveryReceipt;
    if (receipt?.deliveredAt != null) {
      score += 2;
    }

    if (receipt?.readAt != null) {
      score += 4;
    }

    if (message.attachments.isNotEmpty) {
      score += message.attachments.length * 4;
    }

    for (final attachment in message.attachments) {
      if (attachment.thumbnailUrl?.trim().isNotEmpty ?? false) {
        score += 5;
      }

      final localThumbnailPath =
          attachment.metadata?[_localThumbnailMetadataKey];
      if (localThumbnailPath is String &&
          localThumbnailPath.trim().isNotEmpty) {
        score += 4;
      }

      if (attachment.fileUrl.trim().isNotEmpty) {
        score += 2;
      }

      if (attachment.filePath.trim().isNotEmpty) {
        score += 1;
      }

      if ((attachment.duration ?? 0) > 0) {
        score += 1;
      }
    }

    return score;
  }

  int _messageStatusRank(String? status) {
    switch (_normalizedText(status)) {
      case 'read':
        return 3;
      case 'delivered':
        return 2;
      case 'sent':
        return 1;
      default:
        return 0;
    }
  }

  String _pickPreferredStatus(String incomingStatus, String referenceStatus) {
    final incomingRank = _messageStatusRank(incomingStatus);
    final referenceRank = _messageStatusRank(referenceStatus);

    if (incomingRank > referenceRank) {
      return incomingStatus;
    }

    if (referenceRank > incomingRank) {
      return referenceStatus;
    }

    return incomingStatus.trim().isNotEmpty ? incomingStatus : referenceStatus;
  }

  DeliveryReceipt? _mergeDeliveryReceipt(
    DeliveryReceipt? incoming,
    DeliveryReceipt? reference,
  ) {
    if (incoming == null) return reference;
    if (reference == null) return incoming;

    return DeliveryReceipt(
      deliveredAt: incoming.deliveredAt ?? reference.deliveredAt,
      readAt: incoming.readAt ?? reference.readAt,
      readBy: <String>{
        ...reference.readBy.where((id) => id.trim().isNotEmpty),
        ...incoming.readBy.where((id) => id.trim().isNotEmpty),
      }.toList(),
    );
  }

  /// Adds or removes a reaction from a message and returns updated threads.
  /// يضيف أو يزيل تفاعلًا من رسالة ثم يعيد السلاسل المحدثة.
  Map<String, List<Message>> _updateMessageReaction(
      Map<String, List<Message>> messages,
      String messageId,
      MessageReaction reaction,
      {required bool isAdding}) {
    final updatedMessages = Map<String, List<Message>>.from(messages);

    updatedMessages.forEach((conversationId, messageList) {
      final messageIndex = messageList.indexWhere((msg) => msg.id == messageId);
      if (messageIndex != -1) {
        final message = messageList[messageIndex];
        final updatedReactions = List<MessageReaction>.from(message.reactions);

        if (isAdding) {
          // Add the reaction only once.
          if (!updatedReactions.any((r) =>
              r.userId == reaction.userId &&
              r.reactionType == reaction.reactionType)) {
            updatedReactions.add(reaction);
          }
        } else {
          // Remove the matching reaction.
          updatedReactions.removeWhere((r) =>
              r.userId == reaction.userId &&
              r.reactionType == reaction.reactionType);
        }

        messageList[messageIndex] = Message(
          id: message.id,
          conversationId: message.conversationId,
          senderId: message.senderId,
          senderName: message.senderName,
          messageType: message.messageType,
          content: message.content,
          location: message.location,
          replyToMessageId: message.replyToMessageId,
          attachments: message.attachments,
          reactions: updatedReactions,
          createdAt: message.createdAt,
          updatedAt: message.updatedAt,
          status: message.status,
          isEdited: message.isEdited,
          editedAt: message.editedAt,
          isDeleted: message.isDeleted,
          deliveryReceipt: message.deliveryReceipt,
        );
      }
    });

    return updatedMessages;
  }

  /// Resolves a localized bloc-side message without requiring a widget
  /// context.
  Future<String> _tr(
    String key, {
    Map<String, Object?> params = const {},
  }) {
    return AppLocalizations.translate(
      key,
      locale: LocaleManager.getCurrentLocale(),
      params: params,
    );
  }

  /// Resolves the current user id for optimistic rendering even when the
  /// send action fires before the bloc has fully hydrated its user context.
  Future<String> _resolveCurrentUserId(
    String? eventCurrentUserId,
    ChatLoaded currentState,
  ) async {
    final explicit = eventCurrentUserId?.trim();
    if (explicit != null && explicit.isNotEmpty) {
      return explicit;
    }

    final hydrated = currentState.currentUserId?.trim();
    if (hydrated != null && hydrated.isNotEmpty) {
      return hydrated;
    }

    final currentUserResult = await getCurrentUserUseCase(NoParams());
    String resolved = '';
    await currentUserResult.fold(
      (_) async {},
      (user) async => resolved = user.userId,
    );
    return resolved;
  }

  /// Resolves the current user display name so optimistic bubbles look like
  /// final messages instead of anonymous placeholders.
  Future<String?> _resolveCurrentUserName(ChatLoaded currentState) async {
    final hydrated = currentState.currentUserName?.trim();
    if (hydrated != null && hydrated.isNotEmpty) {
      return hydrated;
    }

    final currentUserResult = await getCurrentUserUseCase(NoParams());
    String? resolved;
    await currentUserResult.fold(
      (_) async {},
      (user) async => resolved = user.name,
    );
    return resolved;
  }

  /// Marks one optimistic message as failed while preserving its local media
  /// preview so the user can understand what failed to send.
  Future<void> _markOptimisticMessageFailed(
    Emitter<ChatState> emit, {
    required Message optimisticMessage,
    required ChatLoaded currentState,
    required String failureReason,
  }) async {
    final failedMessages =
        Map<String, List<Message>>.from(currentState.messages);
    final messages = failedMessages[optimisticMessage.conversationId] ?? [];

    final updatedMessagesList = messages.map((msg) {
      if (msg.id == optimisticMessage.id) {
        return Message(
          id: msg.id,
          conversationId: msg.conversationId,
          senderId: msg.senderId,
          senderName: msg.senderName,
          messageType: msg.messageType,
          content: msg.content,
          location: msg.location,
          replyToMessageId: msg.replyToMessageId,
          attachments: msg.attachments,
          reactions: msg.reactions,
          createdAt: msg.createdAt,
          updatedAt: msg.updatedAt,
          status: 'failed',
          isEdited: msg.isEdited,
          isDeleted: msg.isDeleted,
          deliveryReceipt: msg.deliveryReceipt,
          failureReason: failureReason,
        );
      }
      return msg;
    }).toList();

    failedMessages[optimisticMessage.conversationId] = updatedMessagesList;

    emit(currentState.copyWith(
      messages: failedMessages,
      isSendingMessage: false,
      sendingConversationId: null,
      error: await _tr('chat.errors.messageSendFailed'),
    ));
  }

  /// Maps repository failures to user-facing copy that the UI can display.
  /// يحوّل أنواع الفشل إلى رسائل يمكن للواجهة عرضها للمستخدم.
  Future<String> _mapFailureToMessage(Failure failure) async {
    switch (failure.runtimeType) {
      case ServerFailure:
        return await _tr('chat.errors.server');
      case NetworkFailure:
        return await _tr('chat.errors.network');
      case AuthenticationFailure:
        return await _tr('chat.errors.auth');
      case ValidationFailure:
        return await _tr('chat.errors.validation');
      case NotFoundFailure:
        return await _tr('chat.errors.notFound');
      case PermissionDeniedFailure:
        return await _tr('chat.errors.permissionDenied');
      case TimeoutFailure:
        return await _tr('chat.errors.timeout');
      case CacheFailure:
        return await _tr('chat.errors.cache');
      default:
        return await _tr('chat.errors.unknown');
    }
  }

  /// Cancels live subscriptions, stops uploads, and closes the websocket
  /// connection before the bloc is disposed.
  /// يلغي الاشتراكات الحية ويوقف عمليات الرفع ويغلق اتصال websocket قبل
  /// التخلص من الـ bloc.
  @override
  Future<void> close() {
    // Cancel all active subscriptions.
    _webSocketMessagesSubscription?.cancel();
    _webSocketTypingSubscription?.cancel();
    _webSocketPresenceSubscription?.cancel();
    _webSocketConversationSubscription?.cancel();

    // Cancel any in-flight upload tasks.
    for (final upload in _activeUploads.values) {
      upload.controller.cancel();
    }
    _activeUploads.clear();

    // Tear down the websocket connection.
    webSocketService.disconnect();

    return super.close();
  }
}

/// Tracks a single attachment upload so it can be cancelled or updated.
/// يتتبع عملية رفع واحدة حتى يمكن إلغاؤها أو تحديثها.
class UploadTask {
  /// Controller used to cancel the upload request.
  /// متحكم يستخدم لإلغاء طلب الرفع.
  final UploadController controller;

  /// Local file path associated with the upload task.
  /// المسار المحلي المرتبط بمهمة الرفع.
  final String filePath;

  /// Builds a cancellable upload task for one file.
  /// ينشئ مهمة رفع قابلة للإلغاء لملف واحد.
  UploadTask({
    required this.controller,
    required this.filePath,
  });
}

/// Minimal controller that exposes cancellation state for upload tasks.
/// متحكم بسيط يوفّر حالة الإلغاء لمهام الرفع.
class UploadController {
  final cancelToken = CancelToken();

  /// Tracks whether cancellation has already been requested.
  /// يتتبع ما إذا كان الإلغاء قد طُلِب بالفعل.
  bool _isCancelled = false;

  /// Exposes the cancellation flag to the rest of the bloc.
  /// يوضح حالة الإلغاء لبقية الـ bloc.
  bool get isCancelled => _isCancelled;

  /// Cancels the upload and marks the task as no longer active.
  /// يلغي الرفع ويجعل المهمة غير نشطة بعد الآن.
  void cancel() {
    _isCancelled = true;
    cancelToken.cancel('Upload cancelled by user');
  }
}

/// Lightweight cancellation token used when `dio` cancellation is not
/// available directly in this path.
/// رمز إلغاء خفيف يستخدم عندما لا يكون إلغاء `dio` متاحًا مباشرة في هذا
/// المسار.
class CancelToken {
  /// Tracks whether the token has been cancelled.
  /// يتتبع ما إذا كان الرمز قد أُلغي.
  bool _isCancelled = false;

  /// Reason associated with the cancellation request.
  /// سبب مرتبط بطلب الإلغاء.
  String? _cancelReason;

  /// Exposes the cancellation flag.
  /// يوضح حالة الإلغاء.
  bool get isCancelled => _isCancelled;

  /// Exposes the last cancellation reason, if any.
  /// يوضح آخر سبب للإلغاء إن وُجد.
  String? get cancelReason => _cancelReason;

  /// Marks the token as cancelled and stores the reason.
  /// يعلّم الرمز كملغى ويحفظ السبب.
  void cancel([String? reason]) {
    _isCancelled = true;
    _cancelReason = reason;
  }
}
