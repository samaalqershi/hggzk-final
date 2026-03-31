part of 'chat_bloc.dart';

/// Base event for chat flows. Concrete events cover loading history, sending
/// messages, mutating threads, and reacting to websocket updates.
/// الحدث الأساسي لمسارات الدردشة. الأحداث المشتقة تغطي تحميل التاريخ وإرسال
/// الرسائل وتعديل السلاسل والتفاعل مع تحديثات websocket.
abstract class ChatEvent extends Equatable {
  /// Builds the shared base for every chat event variant.
  /// ينشئ الأساس المشترك لكل أنواع أحداث الدردشة.
  const ChatEvent();

  /// Chat events are compared by payload so repeated dispatches remain
  /// deterministic.
  /// تُقارن أحداث الدردشة بحسب الحمولة حتى تبقى الإرسالات المتكررة حتمية.
  @override
  List<Object?> get props => [];
}

/// Requests an older slice of messages for the current conversation.
/// يطلب جزءًا أقدم من الرسائل للمحادثة الحالية.
class LoadMoreMessagesEvent extends ChatEvent {
  /// Conversation whose history should be extended.
  /// المحادثة التي يجب تمديد سجلها.
  final String conversationId;

  /// Number of messages requested in one batch.
  /// عدد الرسائل المطلوبة في دفعة واحدة.
  final int pageSize;

  /// Optional anchor message used to align pagination.
  /// رسالة مرساة اختيارية تستخدم لمواءمة الترقيم.
  final String? targetMessageId;

  /// Starts pagination for older chat messages.
  /// ينشئ حدث الترقيم للرسائل الأقدم.
  const LoadMoreMessagesEvent({
    required this.conversationId,
    this.pageSize = 50,
    this.targetMessageId,
  });

  /// Pagination requests are compared by their destination and batch size.
  /// تُقارن طلبات الترقيم بحسب وجهتها وحجم الدفعة.
  @override
  List<Object?> get props => [conversationId, pageSize, targetMessageId];
}

/// Initializes chat caches, settings, and any startup state the bloc needs.
/// يهيئ كاش الدردشة والإعدادات وأي حالة بدء يحتاجها الـ bloc.
class InitializeChatEvent extends ChatEvent {
  /// Starts the boot-time chat initialization request.
  /// ينشئ طلب تهيئة الدردشة عند الإقلاع.
  const InitializeChatEvent();
}

/// Loads the paginated conversation inbox.
/// يحمل صندوق المحادثات الوارد المرقم.
class LoadConversationsEvent extends ChatEvent {
  /// Requested inbox page.
  /// صفحة الصندوق المطلوبة.
  final int pageNumber;

  /// Number of conversations per page.
  /// عدد المحادثات في كل صفحة.
  final int pageSize;

  /// Starts loading the conversation inbox.
  /// ينشئ طلب تحميل الصندوق الوارد.
  const LoadConversationsEvent({
    this.pageNumber = 1,
    this.pageSize = 20,
  });

  /// Conversation loads are compared by page settings.
  /// تُقارن عمليات تحميل المحادثات بإعدادات الصفحة.
  @override
  List<Object> get props => [pageNumber, pageSize];
}

/// Loads the visible message history for a conversation and can resume from a
/// specific anchor message.
/// يحمل سجل الرسائل الظاهر لمحادثة ويمكنه الاستئناف من رسالة مرساة محددة.
class LoadMessagesEvent extends ChatEvent {
  /// Conversation whose history should be loaded.
  /// المحادثة التي يجب تحميل سجلها.
  final String conversationId;

  /// Requested message page number.
  /// رقم صفحة الرسائل المطلوب.
  final int pageNumber;

  /// Number of messages per page.
  /// عدد الرسائل في كل صفحة.
  final int pageSize;

  /// Optional boundary message used when loading older messages.
  /// رسالة حد اختيارية تستخدم عند تحميل الرسائل الأقدم.
  final String? beforeMessageId;

  /// Starts loading a conversation's message history.
  /// ينشئ طلب سجل الرسائل.
  const LoadMessagesEvent({
    required this.conversationId,
    this.pageNumber = 1,
    this.pageSize = 50,
    this.beforeMessageId,
  });

  /// Message-history loads are compared by the conversation and pagination
  /// anchor.
  /// تُقارن عمليات تحميل سجل الرسائل بالمحادثة ومرساة الترقيم.
  @override
  List<Object?> get props =>
      [conversationId, pageNumber, pageSize, beforeMessageId];
}

/// Sends a new message with the payload required by the backend.
/// يرسل رسالة جديدة بالحِمل الذي يتطلبه الخادم.
class SendMessageEvent extends ChatEvent {
  /// Conversation receiving the outgoing message.
  /// المحادثة المستقبلة للرسالة الصادرة.
  final String conversationId;

  /// Backend-recognized message type such as text or media.
  /// نوع الرسالة المعتمد من الخادم مثل النص أو الوسائط.
  final String messageType;

  /// Optional text body.
  /// نص اختياري.
  final String? content;

  /// Optional location payload.
  /// حمولة موقع اختيارية.
  final Location? location;

  /// Message being replied to, if any.
  /// الرسالة التي يُرد عليها إن وجدت.
  final String? replyToMessageId;

  /// Already-uploaded attachments to link to this message.
  /// المرفقات التي تم رفعها بالفعل لربطها بهذه الرسالة.
  final List<String>? attachmentIds;

  /// Current user id used for optimistic UI updates.
  /// معرّف المستخدم الحالي المستخدم للتحديثات المتفائلة.
  final String? currentUserId;

  /// Starts the send-message flow.
  /// ينشئ طلب إرسال الرسالة.
  const SendMessageEvent({
    required this.conversationId,
    required this.messageType,
    this.content,
    this.location,
    this.replyToMessageId,
    this.attachmentIds,
    this.currentUserId,
  });

  /// Send events are compared by destination and content payload.
  /// تُقارن أحداث الإرسال بحسب الوجهة والحمولة النصية.
  @override
  List<Object?> get props => [
        conversationId,
        messageType,
        content,
        location,
        replyToMessageId,
        attachmentIds,
        currentUserId,
      ];
}

/// Starts a conversation thread and optionally attaches property context so
/// staff or participants can continue the same booking discussion.
/// ينشئ محادثة جديدة ويمكنه إرفاق سياق العقار حتى يستمر فريق العمل أو
/// المشاركون في نفس نقاش الحجز.
/// ينشئ محادثة جديدة لمجموعة مشاركين مع سياق عقار اختياري.
class CreateConversationEvent extends ChatEvent {
  /// Users that should join the thread.
  /// المستخدمون الذين يجب أن ينضموا إلى السلسلة.
  final List<String> participantIds;

  /// Type used by the backend to route the conversation correctly.
  /// النوع الذي يستخدمه الخادم لتوجيه المحادثة بشكل صحيح.
  final String conversationType;

  /// Optional display title.
  /// عنوان عرض اختياري.
  final String? title;

  /// Optional description or context note.
  /// وصف أو ملاحظة سياقية اختيارية.
  final String? description;

  /// Property context attached to the thread when relevant.
  /// سياق العقار المرفق بالمحادثة عند الحاجة.
  final String? propertyId;

  /// Starts the conversation-creation flow.
  /// ينشئ طلب إنشاء المحادثة.
  const CreateConversationEvent({
    required this.participantIds,
    required this.conversationType,
    this.title,
    this.description,
    this.propertyId,
  });

  /// Creation requests are compared by participants and seed metadata.
  /// تُقارن طلبات الإنشاء بالمشاركين وبيانات التهيئة.
  @override
  List<Object?> get props => [
        participantIds,
        conversationType,
        title,
        description,
        propertyId,
      ];
}

/// Removes a conversation from the active chat list.
/// يزيل محادثة من قائمة الدردشة النشطة.
class DeleteConversationEvent extends ChatEvent {
  /// Conversation that should be deleted.
  /// المحادثة التي يجب حذفها.
  final String conversationId;

  /// Starts deletion for one conversation.
  /// ينشئ طلب حذف لمحادثة واحدة.
  const DeleteConversationEvent({required this.conversationId});

  /// Delete requests are compared by conversation id.
  /// تُقارن طلبات الحذف بمعرّف المحادثة.
  @override
  List<Object> get props => [conversationId];
}

/// Moves a conversation out of the inbox without deleting its history.
/// ينقل محادثة خارج الصندوق الوارد دون حذف تاريخها.
class ArchiveConversationEvent extends ChatEvent {
  /// Conversation that should be archived.
  /// المحادثة التي يجب أرشفتها.
  final String conversationId;

  /// Starts archiving one conversation.
  /// ينشئ طلب الأرشفة.
  const ArchiveConversationEvent({required this.conversationId});

  /// Archive requests are compared by conversation id.
  /// تُقارن طلبات الأرشفة بمعرّف المحادثة.
  @override
  List<Object> get props => [conversationId];
}

/// Restores a previously archived conversation back into the inbox.
/// يعيد محادثة مؤرشفة سابقًا إلى الصندوق الوارد.
class UnarchiveConversationEvent extends ChatEvent {
  /// Conversation that should be restored.
  /// المحادثة التي يجب استعادتها.
  final String conversationId;

  /// Starts restoring one archived conversation.
  /// ينشئ طلب إلغاء الأرشفة.
  const UnarchiveConversationEvent({required this.conversationId});

  /// Unarchive requests are compared by conversation id.
  /// تُقارن طلبات إلغاء الأرشفة بمعرّف المحادثة.
  @override
  List<Object> get props => [conversationId];
}

/// Removes a single message from the visible timeline.
/// يزيل رسالة واحدة من الخط الزمني المرئي.
class DeleteMessageEvent extends ChatEvent {
  /// Message that should be deleted.
  /// الرسالة التي يجب حذفها.
  final String messageId;

  /// Starts deletion for one message.
  /// ينشئ طلب حذف الرسالة.
  const DeleteMessageEvent({required this.messageId});

  /// Delete requests are compared by message id.
  /// تُقارن طلبات الحذف بمعرّف الرسالة.
  @override
  List<Object> get props => [messageId];
}

/// Updates the text content of an existing message.
/// يحدّث المحتوى النصي لرسالة موجودة.
class EditMessageEvent extends ChatEvent {
  /// Message that should be edited.
  /// الرسالة التي يجب تعديلها.
  final String messageId;

  /// Replacement text body.
  /// نص بديل للرسالة.
  final String content;

  /// Starts editing an existing message.
  /// ينشئ طلب تعديل الرسالة.
  const EditMessageEvent({
    required this.messageId,
    required this.content,
  });

  /// Edit requests are compared by message id and replacement content.
  /// تُقارن طلبات التعديل بمعرّف الرسالة والمحتوى البديل.
  @override
  List<Object> get props => [messageId, content];
}

/// Adds a reaction to one message and optionally mirrors the change in the
/// local UI.
/// يضيف تفاعلًا إلى رسالة واحدة ويمكنه عكس التغيير محليًا في الواجهة.
class AddReactionEvent extends ChatEvent {
  /// Message that receives the reaction.
  /// الرسالة التي تستقبل التفاعل.
  final String messageId;

  /// Reaction code or emoji identifier.
  /// رمز التفاعل أو معرّف الإيموجي.
  final String reactionType;

  /// Current user id used for optimistic rendering.
  /// معرّف المستخدم الحالي المستخدم للعرض المتفائل.
  final String? currentUserId;

  /// Starts adding a reaction to a message.
  /// ينشئ طلب إضافة التفاعل.
  const AddReactionEvent({
    required this.messageId,
    required this.reactionType,
    this.currentUserId,
  });

  /// Reaction requests are compared by message, reaction type, and user.
  /// تُقارن طلبات التفاعل بالرسالة ونوع التفاعل والمستخدم.
  @override
  List<Object?> get props => [messageId, reactionType, currentUserId];
}

/// Removes a reaction from one message.
/// يزيل تفاعلًا من رسالة واحدة.
class RemoveReactionEvent extends ChatEvent {
  /// Message whose reaction should be removed.
  /// الرسالة التي يجب إزالة تفاعلها.
  final String messageId;

  /// Reaction code or emoji identifier.
  /// رمز التفاعل أو معرّف الإيموجي.
  final String reactionType;

  /// Current user id used when the UI mirrors the change immediately.
  /// معرّف المستخدم الحالي المستخدم عند عكس التغيير فورًا في الواجهة.
  final String? currentUserId;

  /// Starts removing a reaction from a message.
  /// ينشئ طلب إزالة التفاعل.
  const RemoveReactionEvent({
    required this.messageId,
    required this.reactionType,
    this.currentUserId,
  });

  /// Removal requests are compared by message, reaction type, and user.
  /// تُقارن طلبات الإزالة بالرسالة ونوع التفاعل والمستخدم.
  @override
  List<Object> get props => [messageId, reactionType];
}

/// Marks a set of messages as read so counters and delivery markers can be
/// cleared.
/// يعلّم مجموعة رسائل كمقروءة حتى يمكن تصفير العدادات ومؤشرات التسليم.
class MarkMessagesAsReadEvent extends ChatEvent {
  /// Conversation whose messages were read.
  /// المحادثة التي قُرئت رسائلها.
  final String conversationId;

  /// Messages that should be marked as read.
  /// الرسائل التي يجب تعليمها كمقروءة.
  final List<String> messageIds;

  /// Starts marking messages as read.
  /// ينشئ طلب التعليم كمقروء.
  const MarkMessagesAsReadEvent({
    required this.conversationId,
    required this.messageIds,
  });

  /// Mark-as-read requests are compared by conversation and message batch.
  /// تُقارن طلبات التعليم بالمحادثة ودفعة الرسائل.
  @override
  List<Object> get props => [conversationId, messageIds];
}

/// Uploads a file attachment before the message is sent.
/// يرفع مرفقًا ملفيًا قبل إرسال الرسالة.
class UploadAttachmentEvent extends ChatEvent {
  /// Conversation that will receive the attachment.
  /// المحادثة التي ستستقبل المرفق.
  final String conversationId;

  /// Local path of the file selected by the user.
  /// المسار المحلي للملف الذي اختاره المستخدم.
  final String filePath;

  /// Message type that will own the uploaded attachment.
  /// نوع الرسالة التي ستمتلك المرفق المرفوع.
  final String messageType;

  /// Optional progress callback used by the UI to mirror upload progress.
  /// دالة تقدم اختيارية تستخدمها الواجهة لمزامنة تقدم الرفع.
  final Function(int, int)? onProgress;

  /// Starts uploading a single attachment.
  /// ينشئ طلب رفع لمرفق واحد.
  const UploadAttachmentEvent({
    required this.conversationId,
    required this.filePath,
    required this.messageType,
    this.onProgress,
  });

  /// Upload requests are compared by conversation, file path, and message
  /// type.
  /// تُقارن طلبات الرفع بالمحادثة ومسار الملف ونوع الرسالة.
  @override
  List<Object?> get props => [conversationId, filePath, messageType];
}

/// Sends a recorded audio file as a chat message.
/// يرسل ملفًا صوتيًا مسجلاً كرسالة دردشة.
class SendAudioMessageEvent extends ChatEvent {
  /// Conversation receiving the audio message.
  /// المحادثة المستقبلة للرسالة الصوتية.
  final String conversationId;

  /// Local path to the recorded audio file.
  /// المسار المحلي لملف الصوت المسجل.
  final String filePath;

  /// Optional reply target for threaded audio responses.
  /// هدف رد اختياري للردود الصوتية المتسلسلة.
  final String? replyToMessageId;

  /// Captured audio duration in seconds when known by the recorder UI.
  /// مدة التسجيل الصوتي بالثواني عندما تكون معروفة من واجهة التسجيل.
  final int? durationSeconds;

  /// Starts the audio-message send flow.
  /// ينشئ طلب إرسال الرسالة الصوتية.
  const SendAudioMessageEvent({
    required this.conversationId,
    required this.filePath,
    this.replyToMessageId,
    this.durationSeconds,
  });

  /// Audio sends are compared by conversation, file path, and reply target.
  /// تُقارن عمليات الإرسال الصوتي بالمحادثة ومسار الملف وهدف الرد.
  @override
  List<Object?> get props => [
        conversationId,
        filePath,
        replyToMessageId,
        durationSeconds,
      ];
}

/// Searches message history using text and optional metadata filters.
/// يبحث في سجل الرسائل باستخدام النص وفلاتر البيانات الوصفية الاختيارية.
class SearchChatsEvent extends ChatEvent {
  /// Free-text search query.
  /// نص الاستعلام الحر.
  final String query;

  /// Optional conversation scope.
  /// نطاق محادثة اختياري.
  final String? conversationId;

  /// Optional message type filter.
  /// فلتر نوع الرسالة الاختياري.
  final String? messageType;

  /// Optional sender filter.
  /// فلتر المرسل الاختياري.
  final String? senderId;

  /// Lower bound for date-based filtering.
  /// الحد الأدنى للتصفية بحسب التاريخ.
  final DateTime? dateFrom;

  /// Upper bound for date-based filtering.
  /// الحد الأعلى للتصفية بحسب التاريخ.
  final DateTime? dateTo;

  /// Page number for search pagination.
  /// رقم الصفحة لترقيم البحث.
  final int page;

  /// Number of results to request per page.
  /// عدد النتائج المطلوب في كل صفحة.
  final int limit;

  /// Starts the chat-search flow.
  /// ينشئ طلب البحث في الدردشة.
  const SearchChatsEvent({
    required this.query,
    this.conversationId,
    this.messageType,
    this.senderId,
    this.dateFrom,
    this.dateTo,
    this.page = 1,
    this.limit = 20,
  });

  /// Search requests are compared by text and filter payload.
  /// تُقارن طلبات البحث بالنص وحمولة الفلاتر.
  @override
  List<Object?> get props => [
        query,
        conversationId,
        messageType,
        senderId,
        dateFrom,
        dateTo,
        page,
        limit,
      ];
}

/// Loads users that can be attached to a new or existing conversation.
/// يحمل المستخدمين الذين يمكن إضافتهم إلى محادثة جديدة أو قائمة.
class LoadAvailableUsersEvent extends ChatEvent {
  /// Optional filter used to narrow the user list.
  /// فلتر اختياري لتضييق قائمة المستخدمين.
  final String? userType;

  /// Optional property context for property-linked threads.
  /// سياق عقار اختياري للمحادثات المرتبطة بالعقارات.
  final String? propertyId;

  /// Starts loading available users.
  /// ينشئ طلب المستخدمين المتاحين.
  const LoadAvailableUsersEvent({
    this.userType,
    this.propertyId,
  });

  /// User loading requests are compared by their filters.
  /// تُقارن طلبات تحميل المستخدمين بحسب فلاترها.
  @override
  List<Object?> get props => [userType, propertyId];
}

/// Loads admin-capable users for staff-focused conversation flows.
/// يحمل المستخدمين ذوي الصلاحيات الإدارية لمسارات المحادثات الموجهة للطاقم.
class LoadAdminUsersEvent extends ChatEvent {
  /// Starts loading admin users.
  /// ينشئ طلب المستخدمين الإداريين.
  const LoadAdminUsersEvent();
}

/// Updates the current user's presence or availability status.
/// يحدّث حالة الحضور أو التوفر للمستخدم الحالي.
class UpdateUserStatusEvent extends ChatEvent {
  /// New presence status to persist.
  /// حالة الحضور الجديدة المطلوب حفظها.
  final String status;

  /// Starts updating the user's chat status.
  /// ينشئ طلب تحديث الحالة.
  const UpdateUserStatusEvent({required this.status});

  /// Status updates are compared by the target status string.
  /// تُقارن تحديثات الحالة بنص الحالة المستهدف.
  @override
  List<Object> get props => [status];
}

/// Loads the persisted chat settings for the current user.
/// يحمل إعدادات الدردشة المخزنة للمستخدم الحالي.
class LoadChatSettingsEvent extends ChatEvent {
  /// Starts loading chat settings.
  /// ينشئ طلب تحميل الإعدادات.
  const LoadChatSettingsEvent();
}

/// Updates one or more chat preferences without resending unrelated values.
/// يحدّث تفضيلات الدردشة دون إعادة إرسال القيم غير المرتبطة.
class UpdateChatSettingsEvent extends ChatEvent {
  /// Optional toggle for push notifications.
  /// مفتاح اختياري لتفعيل الإشعارات.
  final bool? notificationsEnabled;

  /// Optional toggle for notification sounds.
  /// مفتاح اختياري لأصوات الإشعارات.
  final bool? soundEnabled;

  /// Optional toggle for read receipts.
  /// مفتاح اختياري لإيصالات القراءة.
  final bool? showReadReceipts;

  /// Optional toggle for typing indicators.
  /// مفتاح اختياري لمؤشرات الكتابة.
  final bool? showTypingIndicator;

  /// Optional chat theme name.
  /// اسم سمة الدردشة الاختياري.
  final String? theme;

  /// Optional font size setting.
  /// إعداد حجم الخط الاختياري.
  final String? fontSize;

  /// Optional toggle for auto-downloading media.
  /// مفتاح اختياري للتنزيل التلقائي للوسائط.
  final bool? autoDownloadMedia;

  /// Optional toggle for message backup.
  /// مفتاح اختياري لنسخ الرسائل احتياطيًا.
  final bool? backupMessages;

  /// Starts a partial update of chat settings.
  /// ينشئ طلب التحديث الجزئي لإعدادات الدردشة.
  const UpdateChatSettingsEvent({
    this.notificationsEnabled,
    this.soundEnabled,
    this.showReadReceipts,
    this.showTypingIndicator,
    this.theme,
    this.fontSize,
    this.autoDownloadMedia,
    this.backupMessages,
  });

  /// Settings updates are compared by the fields that were explicitly
  /// requested.
  /// تُقارن تحديثات الإعدادات بالحقول التي طُلب تغييرها صراحةً.
  @override
  List<Object?> get props => [
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

/// Broadcasts the local user's typing state to the conversation.
/// يرسل حالة الكتابة للمستخدم المحلي إلى المحادثة.
class SendTypingIndicatorEvent extends ChatEvent {
  /// Conversation that should receive the indicator.
  /// المحادثة التي يجب أن تستقبل المؤشر.
  final String conversationId;

  /// True while the user is actively typing.
  /// تكون صحيحة أثناء كتابة المستخدم فعليًا.
  final bool isTyping;

  /// Starts broadcasting a typing indicator.
  /// ينشئ طلب مؤشر الكتابة.
  const SendTypingIndicatorEvent({
    required this.conversationId,
    required this.isTyping,
  });

  /// Typing updates are compared by target conversation and typing flag.
  /// تُقارن تحديثات الكتابة بالمحادثة المستهدفة وعلم الكتابة.
  @override
  List<Object> get props => [conversationId, isTyping];
}

/// Bridges a raw websocket message into the chat bloc so the stream can update
/// the active conversation without waiting for a full reload.
/// يمرر رسالة websocket خامة إلى الـ bloc كي يحدّث المحادثة النشطة مباشرة
/// دون انتظار إعادة تحميل كاملة.
class WebSocketMessageReceivedEvent extends ChatEvent {
  /// Raw websocket message payload.
  /// حمولة رسالة websocket الخام.
  final MessageEvent messageEvent;

  /// Wraps the server payload so the bloc can merge it with local state and
  /// refresh unread counters or message ordering.
  /// يغلف حمولة الخادم كي يدمجها الـ bloc مع الحالة المحلية ويحدّث العدادات
  /// غير المقروءة أو ترتيب الرسائل.
  const WebSocketMessageReceivedEvent(this.messageEvent);

  /// Websocket payloads are compared by the raw message event.
  /// تُقارن حمولات websocket برسالة الحدث الخام.
  @override
  List<Object> get props => [messageEvent];
}

/// Applies a websocket conversation snapshot when another device or participant
/// changes the thread metadata.
/// يطبّق لقطة محادثة واردة من websocket عندما يغيّر جهاز آخر أو مشارك
/// بيانات السلسلة.
class WebSocketConversationUpdatedEvent extends ChatEvent {
  /// Updated conversation payload.
  /// حمولة المحادثة المحدّثة.
  final Conversation conversation;

  /// Passes the refreshed conversation snapshot through the same event stream
  /// used by manual refresh actions.
  /// يمرر لقطة المحادثة المحدّثة عبر مسار الأحداث نفسه المستخدم عند
  /// التحديث اليدوي.
  const WebSocketConversationUpdatedEvent(this.conversation);

  /// Conversation updates are compared by the received snapshot.
  /// تُقارن تحديثات المحادثة باللقطة المستلمة.
  @override
  List<Object> get props => [conversation];
}

/// Synchronizes the typing-indicator map with websocket notifications so the
/// UI can show who is currently composing a reply.
/// يزامن خريطة مؤشر الكتابة مع إشعارات websocket كي تعرض الواجهة من
/// يكتب الرد حاليًا.
class WebSocketTypingIndicatorEvent extends ChatEvent {
  /// Conversation whose typing state changed.
  /// المحادثة التي تغيّرت حالة الكتابة فيها.
  final String conversationId;

  /// Users currently typing in that conversation.
  /// المستخدمون الذين يكتبون حاليًا في تلك المحادثة.
  final List<String> typingUserIds;

  /// Carries the current set of active typers so the bloc can rebuild the
  /// typing banner for the conversation.
  /// يحمل مجموعة المستخدمين النشطين في الكتابة لكي يعيد الـ bloc بناء شريط
  /// الكتابة في المحادثة.
  const WebSocketTypingIndicatorEvent({
    required this.conversationId,
    required this.typingUserIds,
  });

  /// Typing updates are compared by conversation and active user ids.
  /// تُقارن تحديثات الكتابة بالمحادثة ومعرّفات المستخدمين النشطين.
  @override
  List<Object> get props => [conversationId, typingUserIds];
}

/// Applies a live presence update so the conversation list can reflect whether
/// a user is online, away, or offline.
/// يطبّق تحديث حضور حيًا كي تظهر قائمة المحادثات حالة المستخدم متصلًا أو
/// بعيدًا أو غير متصل.
class WebSocketPresenceUpdateEvent extends ChatEvent {
  /// User whose presence changed.
  /// المستخدم الذي تغيّرت حالته.
  final String userId;

  /// New presence status.
  /// حالة الحضور الجديدة.
  final String status;

  /// Optional last-seen time received from the server.
  /// وقت آخر ظهور اختياري وارد من الخادم.
  final DateTime? lastSeen;

  /// Relays the presence payload to the bloc, including an optional
  /// server-provided last-seen timestamp.
  /// يمرر حمولة الحضور إلى الـ bloc مع وقت آخر ظهور اختياري من الخادم.
  const WebSocketPresenceUpdateEvent({
    required this.userId,
    required this.status,
    this.lastSeen,
  });

  /// Presence updates are compared by user, status, and last-seen value.
  /// تُقارن تحديثات الحضور بالمستخدم والحالة ووقت آخر ظهور.
  @override
  List<Object?> get props => [userId, status, lastSeen];
}

/// Uploads several attachments together when the composer needs to send one
/// message that depends on multiple local files.
/// يرفع عدة مرفقات معًا عندما يحتاج المحرر إلى إرسال رسالة واحدة تعتمد على
/// عدة ملفات محلية.
class UploadMultipleAttachmentsEvent extends ChatEvent {
  /// Conversation receiving the attachment batch.
  /// المحادثة التي ستستقبل دفعة المرفقات.
  final String conversationId;

  /// Local file paths queued for upload.
  /// مسارات الملفات المحلية المصفوفة للرفع.
  final List<String> filePaths;

  /// Message type that will own the uploaded assets.
  /// نوع الرسالة التي ستملك الأصول المرفوعة.
  final String messageType;

  /// Optional caption or text sent together with the attachment batch.
  /// نص أو تعليق اختياري يُرسل مع دفعة المرفقات.
  final String? content;

  /// Optional reply target that should be preserved for the outgoing message.
  /// هدف الرد الاختياري الذي يجب الحفاظ عليه للرسالة الصادرة.
  final String? replyToMessageId;

  /// Current user id used to keep optimistic rendering aligned.
  /// معرّف المستخدم الحالي المستخدم لمواءمة العرض التفاؤلي.
  final String? currentUserId;

  /// Optional progress callback used to mirror batch upload progress.
  /// دالة تقدم اختيارية لمزامنة تقدم رفع الدفعة.
  final Function(int index, int sent, int total)? onProgress;

  /// Starts the coordinated upload flow that reports progress for every file
  /// in the batch.
  /// يبدأ مسار الرفع المنسق الذي يبلّغ عن التقدم لكل ملف داخل الدفعة.
  const UploadMultipleAttachmentsEvent({
    required this.conversationId,
    required this.filePaths,
    required this.messageType,
    this.content,
    this.replyToMessageId,
    this.currentUserId,
    this.onProgress,
  });

  /// Batch uploads are compared by conversation, files, and message type.
  /// تُقارن عمليات الرفع المجمعة بالمحادثة والملفات ونوع الرسالة.
  @override
  List<Object?> get props => [
        conversationId,
        filePaths,
        messageType,
        content,
        replyToMessageId,
        currentUserId,
      ];
}

/// Drops cached data for a single conversation when its local snapshot is no
/// longer trustworthy.
/// يحذف البيانات المخزنة لمحادثة واحدة عندما تصبح اللقطة المحلية غير موثوقة.
class ClearConversationCacheEvent extends ChatEvent {
  /// Conversation whose cached data should be removed.
  /// المحادثة التي يجب إزالة كاشها.
  final String conversationId;

  /// Forces the repository and cache layer to discard the stored thread state.
  /// يفرض على المستودع وطبقة التخزين حذف حالة السلسلة المحفوظة.
  const ClearConversationCacheEvent({required this.conversationId});

  /// Cache-clear requests are compared by conversation id.
  /// تُقارن طلبات مسح الكاش بمعرّف المحادثة.
  @override
  List<Object> get props => [conversationId];
}

/// Re-reads one conversation from the source of truth so list views and detail
/// pages converge after a local or remote change.
/// يعيد قراءة محادثة واحدة من المصدر الموثوق كي تتطابق قائمة المحادثات
/// وصفحة التفاصيل بعد تغيير محلي أو بعيد.
class RefreshConversationEvent extends ChatEvent {
  /// Conversation that should be refreshed.
  /// المحادثة التي يجب تحديثها.
  final String conversationId;

  /// Requests a targeted refresh instead of reloading the entire inbox.
  /// يطلب تحديثًا موجهًا بدل إعادة تحميل كل صندوق الوارد.
  const RefreshConversationEvent({required this.conversationId});

  /// Refresh requests are compared by conversation id.
  /// تُقارن طلبات التحديث بمعرّف المحادثة.
  @override
  List<Object> get props => [conversationId];
}

/// Resubmits a failed message after the app regains connectivity or the user
/// asks for another attempt.
/// يعيد إرسال رسالة فشلت بعد عودة الاتصال أو عند طلب المستخدم محاولة
/// جديدة.
class RetryFailedMessageEvent extends ChatEvent {
  /// Conversation containing the failed message.
  /// المحادثة التي تحتوي الرسالة الفاشلة.
  final String conversationId;

  /// Failed message that should be resent.
  /// الرسالة الفاشلة التي يجب إعادة إرسالها.
  final String messageId;

  /// Replays the stored message payload through the normal send pipeline.
  /// يعيد تمرير حمولة الرسالة المخزنة عبر مسار الإرسال المعتاد.
  const RetryFailedMessageEvent({
    required this.conversationId,
    required this.messageId,
  });

  /// Retry requests are compared by conversation and message id.
  /// تُقارن طلبات إعادة المحاولة بالمحادثة ومعرّف الرسالة.
  @override
  List<Object> get props => [conversationId, messageId];
}

/// Cancels an active attachment upload when the user backs out or replaces the
/// file before completion.
/// يلغي رفع مرفق جارٍ عندما يتراجع المستخدم أو يستبدل الملف قبل الاكتمال.
class CancelUploadEvent extends ChatEvent {
  /// Upload operation identifier.
  /// معرّف عملية الرفع.
  final String uploadId;

  /// Conversation tied to the upload.
  /// المحادثة المرتبطة بالرفع.
  final String conversationId;

  /// Stops the upload session so progress listeners and UI state can reset
  /// cleanly.
  /// يوقف جلسة الرفع كي تعود مستمعات التقدم وحالة الواجهة إلى وضعها
  /// النظيف.
  const CancelUploadEvent(
      {required this.uploadId, required this.conversationId});

  /// Cancellation requests are compared by upload and conversation id.
  /// تُقارن طلبات الإلغاء بمعرّف الرفع ومعرّف المحادثة.
  @override
  List<Object> get props => [uploadId, conversationId];
}
