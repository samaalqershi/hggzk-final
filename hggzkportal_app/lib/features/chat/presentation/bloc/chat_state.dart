part of 'chat_bloc.dart';

/// Base state for chat interactions. Concrete states expose the current
/// conversation list, message timeline, loading flags, and transient send or
/// search outcomes so the UI can react without re-deriving chat state from the
/// repository layer.
/// الحالة الأساسية لتفاعل الدردشة. الحالات المشتقة تنقل قائمة المحادثات
/// وخط الرسائل وحالات التحميل والنتائج المؤقتة للإرسال أو البحث كي تتفاعل
/// الواجهة معها مباشرة دون إعادة اشتقاقها من طبقة المستودع.
abstract class ChatState extends Equatable {
  /// Builds the shared base for every chat state variant.
  /// ينشئ الأساس المشترك لكل حالة من حالات الدردشة.
  const ChatState();

  /// Chat states are compared by value so the bloc only rebuilds when the
  /// visible chat data actually changes.
  /// تُقارن حالات الدردشة بالقيمة حتى تعيد الـ bloc البناء فقط عندما تتغير
  /// البيانات الظاهرة فعلًا.
  @override
  List<Object?> get props => [];
}

/// Default idle state before any conversations or messages have been loaded.
/// الحالة الهادئة الافتراضية قبل تحميل المحادثات أو الرسائل.
class ChatInitial extends ChatState {
  /// Builds the initial idle chat state.
  /// ينشئ حالة الدردشة الابتدائية الهادئة.
  const ChatInitial();
}

/// Indicates that the bloc is fetching chat data or restoring the active
/// conversation context.
/// تشير إلى أن الـ bloc يجلب بيانات الدردشة أو يستعيد سياق المحادثة النشطة.
class ChatLoading extends ChatState {
  /// Builds the loading state used while chat data is in flight.
  /// ينشئ حالة التحميل المستخدمة أثناء جلب بيانات الدردشة.
  const ChatLoading();
}

/// Holds the live chat workspace: conversations, message maps, typing and
/// presence indicators, upload progress, search results, and per-conversation
/// loading flags.
/// تحفظ مساحة العمل الحية للدردشة: المحادثات، والرسائل، ومؤشرات الكتابة
/// والحضور، وتقدم الرفع، ونتائج البحث، وحالات التحميل الخاصة بكل محادثة.
class ChatLoaded extends ChatState {
  static const Object _searchResultUnchanged = Object();

  /// Conversation list shown by the inbox and side panels.
  /// قائمة المحادثات التي تظهر في الصندوق الجانبي وشاشات المحادثات.
  final List<Conversation> conversations;

  /// Cached messages keyed by conversation id so each thread can render
  /// independently.
  /// الرسائل المخزنة محليًا والمفهرسة بمعرّف المحادثة حتى تعرض كل سلسلة
  /// محادثة بشكل مستقل.
  final Map<String, List<Message>> messages;

  /// Users currently typing inside each conversation.
  /// المستخدمون الذين يكتبون الآن داخل كل محادثة.
  final Map<String, List<String>> typingUsers;

  /// Presence metadata used to show whether a participant is online or last
  /// seen recently.
  /// بيانات الحضور المستخدمة لإظهار ما إذا كان المستخدم متصلًا أو شوهد
  /// مؤخرًا.
  final Map<String, UserPresence> userPresence;

  /// People available for starting a new conversation.
  /// الأشخاص المتاحون لبدء محادثة جديدة معهم.
  final List<ChatUser> availableUsers;

  /// Admin accounts surfaced when the UI needs to start staff-facing threads.
  /// حسابات الإدارة التي تُعرض عندما تحتاج الواجهة لبدء محادثات موجهة للطاقم.
  final List<ChatUser> adminUsers;

  /// Conversation-level chat settings returned by the backend.
  /// إعدادات الدردشة على مستوى المحادثة كما يعيدها الخادم.
  final ChatSettings? settings;

  /// Search result payload used by chat search and quick jump flows.
  /// حمولة نتائج البحث المستخدمة في البحث داخل الدردشة والتبديل السريع.
  final SearchResult? searchResult;

  /// True while the current thread is loading its message history.
  /// تكون صحيحة أثناء تحميل سجل الرسائل للمحادثة الحالية.
  final bool isLoadingMessages;

  /// True while older messages are being paged in.
  /// تكون صحيحة أثناء جلب الرسائل الأقدم على دفعات.
  final bool isLoadingMore;

  /// True while the chat search pipeline is resolving a query.
  /// تكون صحيحة أثناء معالجة البحث داخل الدردشة.
  final bool isSearching;

  /// True while a message send request is still pending.
  /// تكون صحيحة أثناء انتظار إرسال رسالة.
  final bool isSendingMessage;

  /// Last human-readable error reported by chat operations.
  /// آخر رسالة خطأ قابلة للقراءة من المستخدم صادرة عن عمليات الدردشة.
  final String? error;

  /// Attachment currently being uploaded, if any.
  /// المرفق الجاري رفعه إن وجد.
  final Attachment? uploadingAttachment;

  /// Progress value for the active attachment upload.
  /// قيمة التقدم الخاصة برفع المرفق النشط.
  final double? uploadProgress;

  /// Per-conversation image upload queue and progress metadata.
  /// قائمة رفع الصور وبيانات التقدم لكل محادثة.
  final Map<String, List<ImageUploadInfo>> uploadingImages;

  /// Current user id used to colorize message ownership and actions.
  /// معرّف المستخدم الحالي المستخدم لتمييز ملكية الرسائل والإجراءات.
  final String? currentUserId;

  /// Current user display name used in composer and status labels.
  /// اسم العرض للمستخدم الحالي في المحرر وتسميات الحالة.
  final String? currentUserName;

  /// Conversation currently showing a thread-level loading indicator.
  /// المحادثة التي تعرض الآن مؤشر تحميل خاصًا بها.
  final String? loadingConversationId;

  /// Conversation currently waiting for a send operation to finish.
  /// المحادثة التي تنتظر الآن اكتمال عملية الإرسال.
  final String? sendingConversationId;

  /// Builds the fully populated chat state that the UI listens to during
  /// normal operation.
  /// ينشئ حالة الدردشة المكتملة التي تراقبها الواجهة أثناء التشغيل العادي.
  const ChatLoaded({
    this.conversations = const [],
    this.messages = const {},
    this.typingUsers = const {},
    this.userPresence = const {},
    this.availableUsers = const [],
    this.adminUsers = const [],
    this.settings,
    this.searchResult,
    this.isLoadingMessages = false,
    this.isLoadingMore = false,
    this.isSearching = false,
    this.isSendingMessage = false,
    this.error,
    this.uploadingAttachment,
    this.uploadProgress,
    this.uploadingImages = const {},
    this.currentUserId,
    this.currentUserName,
    this.loadingConversationId,
    this.sendingConversationId,
  });

  /// Produces a new chat state while preserving every field that did not
  /// change, which keeps rebuilds narrow and predictable.
  /// ينشئ حالة جديدة مع الإبقاء على كل الحقول غير المتغيرة، حتى تبقى إعادة
  /// البناء محدودة ويمكن التنبؤ بها.
  ChatLoaded copyWith({
    List<Conversation>? conversations,
    Map<String, List<Message>>? messages,
    Map<String, List<String>>? typingUsers,
    Map<String, UserPresence>? userPresence,
    List<ChatUser>? availableUsers,
    List<ChatUser>? adminUsers,
    ChatSettings? settings,
    Object? searchResult = _searchResultUnchanged,
    bool? isLoadingMessages,
    bool? isLoadingMore,
    bool? isSearching,
    bool? isSendingMessage,
    String? error,
    Attachment? uploadingAttachment,
    double? uploadProgress,
    Map<String, List<ImageUploadInfo>>? uploadingImages,
    String? currentUserId,
    String? currentUserName,
    String? loadingConversationId,
    String? sendingConversationId,
  }) {
    return ChatLoaded(
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      typingUsers: typingUsers ?? this.typingUsers,
      userPresence: userPresence ?? this.userPresence,
      availableUsers: availableUsers ?? this.availableUsers,
      adminUsers: adminUsers ?? this.adminUsers,
      settings: settings ?? this.settings,
      searchResult: searchResult == _searchResultUnchanged
          ? this.searchResult
          : searchResult as SearchResult?,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSearching: isSearching ?? this.isSearching,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
      error: error,
      uploadingAttachment: uploadingAttachment,
      uploadProgress: uploadProgress,
      uploadingImages: uploadingImages ?? this.uploadingImages,
      currentUserId: currentUserId ?? this.currentUserId,
      currentUserName: currentUserName ?? this.currentUserName,
      loadingConversationId: loadingConversationId,
      sendingConversationId: sendingConversationId,
    );
  }

  /// The bloc compares chat snapshots by content so UI updates only happen
  /// when the live conversation data really changes.
  /// يقارن الـ bloc لقطات الدردشة بالمحتوى حتى تحدث تحديثات الواجهة فقط عند
  /// تغير البيانات الحية فعلًا.
  @override
  List<Object?> get props => [
        conversations,
        messages,
        typingUsers,
        userPresence,
        availableUsers,
        adminUsers,
        settings,
        searchResult,
        isLoadingMessages,
        isLoadingMore,
        isSearching,
        isSendingMessage,
        error,
        uploadingAttachment,
        uploadProgress,
        uploadingImages,
        currentUserId,
        currentUserName,
        loadingConversationId,
        sendingConversationId,
      ];
}

/// Describes a message that could not be delivered and is still useful for
/// retry, diagnostics, or user-facing failure banners.
/// يصف الرسالة التي لم تصل بعد لكنها ما زالت مفيدة لإعادة المحاولة أو
/// للتشخيص أو لعرض فشل الإرسال للمستخدم.
class FailedMessage {
  /// Local identifier for the failed message entry.
  /// المعرف المحلي لمدخل الرسالة الفاشلة.
  final String id;

  /// Conversation that owns the failed message.
  /// المحادثة المالكة لهذه الرسالة.
  final String conversationId;

  /// Reason captured when the send attempt failed.
  /// سبب الفشل المسجّل عند تعذر الإرسال.
  final String failureReason;

  /// Time at which the send attempt was marked as failed.
  /// الزمن الذي سُجلت فيه حالة الفشل.
  final DateTime failedAt;

  /// Captures the minimum data needed to retry or inspect a failed send.
  /// يلتقط الحد الأدنى من البيانات اللازمة لإعادة المحاولة أو لفحص فشل الإرسال.
  const FailedMessage({
    required this.id,
    required this.conversationId,
    required this.failureReason,
    required this.failedAt,
  });
}

/// Surface-level failure state used when a chat operation cannot complete.
/// حالة فشل سطحية تستخدم عندما تتعذر إحدى عمليات الدردشة.
class ChatError extends ChatState {
  /// User-facing explanation for the chat failure.
  /// رسالة موجّهة للمستخدم تشرح فشل الدردشة.
  final String message;

  /// Builds the failure state for the chat bloc.
  /// ينشئ حالة الفشل الخاصة بـ bloc الدردشة.
  const ChatError({required this.message});

  /// Error states are compared by message so repeated failures remain stable.
  /// تُقارن حالات الخطأ بالرسالة حتى تبقى الأخطاء المتكررة مستقرة.
  @override
  List<Object> get props => [message];
}

/// Tracks whether a user is online and, if not, when they were last seen.
/// يتتبع ما إذا كان المستخدم متصلًا أو متى شوهد آخر مرة.
class UserPresence extends Equatable {
  /// Presence label such as online, offline, or away.
  /// تسمية الحضور مثل متصل أو غير متصل أو بعيد.
  final String status;

  /// Timestamp for the last known activity, if available.
  /// الطابع الزمني لآخر نشاط معروف إن وجد.
  final DateTime? lastSeen;

  /// Creates a presence snapshot for one user.
  /// ينشئ لقطة حضور لمستخدم واحد.
  const UserPresence({
    required this.status,
    this.lastSeen,
  });

  /// Presence snapshots are compared by status and last-seen time.
  /// تُقارن لقطات الحضور بالحالة ووقت آخر ظهور.
  @override
  List<Object?> get props => [status, lastSeen];
}

/// Emitted when a new conversation is created and the inbox should reflect
/// the newly available thread.
/// تصدر عندما تنشأ محادثة جديدة ويجب أن يعكس الصندوق الوارد السلسلة الجديدة.
class ConversationCreated extends ChatState {
  /// Newly created conversation payload.
  /// حمولة المحادثة الجديدة.
  final Conversation conversation;

  /// Optional confirmation message shown after creation.
  /// رسالة تأكيد اختيارية تظهر بعد الإنشاء.
  final String? message;

  /// Builds the success state for conversation creation.
  /// ينشئ حالة نجاح إنشاء المحادثة.
  const ConversationCreated({
    required this.conversation,
    this.message = '',
  });

  /// Creation states are compared by the conversation and confirmation text.
  /// تُقارن حالات الإنشاء بالمحادثة ونص التأكيد.
  @override
  List<Object?> get props => [conversation, message];
}

/// Indicates that the bloc is waiting for a create-conversation request to
/// finish.
/// تشير إلى أن الـ bloc ينتظر اكتمال طلب إنشاء المحادثة.
class ConversationCreating extends ChatState {
  /// Builds the in-flight creation state.
  /// ينشئ حالة الإنشاء الجارية.
  const ConversationCreating();
}

/// Tracks the upload state for one image that is being attached to chat.
/// يتتبع حالة رفع صورة واحدة تُرفق بالدردشة.
class ImageUploadInfo extends Equatable {
  /// Local upload identifier.
  /// معرّف الرفع المحلي.
  final String id;

  /// File associated with this upload.
  /// الملف المرتبط بعملية الرفع.
  final File file;

  /// Upload progress from `0.0` to `1.0`.
  /// تقدم الرفع من `0.0` إلى `1.0`.
  final double progress;

  /// True once the upload finished successfully.
  /// تكون صحيحة بعد اكتمال الرفع بنجاح.
  final bool isCompleted;

  /// True when the upload failed and should be retried or shown as failed.
  /// تكون صحيحة عندما يفشل الرفع ويحتاج إلى إعادة محاولة أو عرض فشل.
  final bool isFailed;

  /// Optional upload error message.
  /// رسالة خطأ اختيارية تخص الرفع.
  final String? error;

  /// Builds the upload-progress snapshot for one attachment.
  /// ينشئ لقطة تقدم رفع لمرفق واحد.
  const ImageUploadInfo({
    required this.id,
    required this.file,
    this.progress = 0.0,
    this.isCompleted = false,
    this.isFailed = false,
    this.error,
  });

  /// Produces a new upload snapshot while preserving unchanged values.
  /// ينشئ لقطة رفع جديدة مع الإبقاء على القيم غير المتغيرة.
  ImageUploadInfo copyWith({
    double? progress,
    bool? isCompleted,
    bool? isFailed,
    String? error,
  }) {
    return ImageUploadInfo(
      id: id,
      file: file,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      isFailed: isFailed ?? this.isFailed,
      error: error ?? this.error,
    );
  }

  /// Upload snapshots are compared by the tracked file and its state.
  /// تُقارن لقطات الرفع بالملف المتابع وحالته.
  @override
  List<Object?> get props => [id, file, progress, isCompleted, isFailed, error];
}
