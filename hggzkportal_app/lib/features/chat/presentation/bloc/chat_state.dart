part of 'chat_bloc.dart';

/// يمثل حالات الشات خلال التحميل والعرض والتحديث اللحظي حتى تتمكن
/// الواجهة من التبديل بين هذه الأوضاع بسلاسة.
/// Represents chat states during loading, display, and realtime
/// updates so the UI can move between them smoothly.
abstract class ChatState extends Equatable {
  /// تضمن القاعدة مقارنة ثابتة لحالات الشات حتى لا تُعاد بناء
  /// الواجهة بلا سبب.
  /// Keeps comparison stable across chat states so the UI does not
  /// rebuild without reason.
  const ChatState();

  /// لا توجد حقول مشتركة على مستوى القاعدة، لذلك تعتمد المساواة على
  /// نوع الحالة.
  /// The base has no shared fields, so equality depends on the state
  /// type.
  @override
  List<Object?> get props => [];
}

/// الحالة الأولى قبل أن يكتمل ربط الشات بالمصادر المطلوبة.
/// The initial state before chat wiring is complete.
class ChatInitial extends ChatState {
  /// لا تحمل بيانات إضافية لأنها مجرد نقطة بدء.
  /// No extra data is needed because this is only a starting point.
  const ChatInitial();
}

/// تشير إلى أن قائمة المحادثات أو الرسائل ما زالت تُحمّل.
/// Indicates that conversations or messages are still loading.
class ChatLoading extends ChatState {
  /// تستعمل أثناء انتظار البيانات قبل إظهار المحتوى.
  /// Used while waiting for data before showing content.
  const ChatLoading();
}

/// تحمل بيانات المحادثات والرسائل وحالة الاتصال والتفاعل داخل
/// الشاشة.
/// Carries conversations, messages, presence, and interaction state
/// for the chat screen.
class ChatLoaded extends ChatState {
  /// المحادثات الحالية المعروضة للمستخدم.
  /// The current conversations visible to the user.
  final List<Conversation> conversations;

  /// الرسائل الحالية مفصولة بحسب المحادثة حتى يمكن تحديث كل سلسلة
  /// بشكل مستقل.
  /// Current messages grouped by conversation so each thread can be
  /// updated independently.
  final Map<String, List<Message>> messages;

  /// يضم المستخدمين الذين يكتبون الآن داخل كل محادثة.
  /// Holds the users currently typing in each conversation.
  final Map<String, List<String>> typingUsers;

  /// يحفظ حالة حضور المستخدمين حتى تعرضها الواجهة بجانب الأسماء.
  /// Stores user presence so the UI can show it beside names.
  final Map<String, UserPresence> userPresence;

  /// المستخدمون المتاحون لبدء محادثات أو إضافة مشاركين.
  /// Users available for starting conversations or adding
  /// participants.
  final List<ChatUser> availableUsers;

  /// قائمة المستخدمين الإداريين التي تستخدم في المسارات الخاصة.
  /// The admin-user list used in privileged flows.
  final List<ChatUser> adminUsers;

  /// إعدادات الشات الحالية التي تتحكم في السلوك العام للواجهة.
  /// Current chat settings that govern the overall UI behavior.
  final ChatSettings? settings;

  /// نتيجة البحث الأخيرة حتى تبقى شاشة النتائج مرتبطة بالسياق.
  /// The last search result so the result screen remains in context.
  final SearchResult? searchResult;

  /// يوضح أن الرسائل الخاصة بالمحادثة الحالية ما زالت تُحمّل.
  /// Indicates that the current conversation messages are still
  /// loading.
  final bool isLoadingMessages;

  /// يميز تحميل الرسائل الأقدم عند التمرير.
  /// Marks older-message loading during infinite scroll.
  final bool isLoadingMore;

  /// يشير إلى أن عملية البحث قيد التنفيذ.
  /// Indicates that a search operation is running.
  final bool isSearching;

  /// يوضح أن رسالة ما ما زالت تُرسل أو تُرفع.
  /// Indicates that a message is currently being sent or uploaded.
  final bool isSendingMessage;

  /// رسالة الخطأ الأخيرة المعروضة للمستخدم.
  /// The latest error message shown to the user.
  final String? error;

  /// المرفق الذي يجري رفعه حاليًا.
  /// The attachment currently being uploaded.
  final Attachment? uploadingAttachment;

  /// نسبة تقدم الرفع الحالية للمرفق النشط.
  /// The current progress ratio for the active upload.
  final double? uploadProgress;

  /// تتبع رفع الصور داخل كل محادثة بشكل منفصل.
  /// Tracks image uploads separately for each conversation.
  final Map<String, List<ImageUploadInfo>> uploadingImages;

  /// معرف المستخدم الحالي لتنسيق الرسائل المتفائلة والحضور.
  /// The current user id used for optimistic messaging and presence.
  final String? currentUserId;

  /// اسم المستخدم الحالي كما يظهر في واجهات الشات.
  /// The current user's display name as shown in chat surfaces.
  final String? currentUserName;

  /// المحادثة التي يجري تحميلها الآن.
  /// The conversation currently being loaded.
  final String? loadingConversationId;

  /// المحادثة التي يتم إرسال رسالة إليها في هذه اللحظة.
  /// The conversation currently receiving an outgoing message.
  final String? sendingConversationId;

  /// يجمع كل ما تحتاجه الشاشة حتى تعرض المحادثات والرسائل وحالات
  /// الرفع والبحث من لقطة واحدة.
  /// Bundles everything the screen needs to show conversations,
  /// messages, uploads, and search from one snapshot.
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

  /// ينسخ الحالة مع السماح بتحديث الأجزاء المتغيرة فقط، حتى تبقى
  /// بقية اللقطة ثابتة.
  /// Copies the state while letting callers update only the changing
  /// pieces, keeping the rest of the snapshot stable.
  ChatLoaded copyWith({
    List<Conversation>? conversations,
    Map<String, List<Message>>? messages,
    Map<String, List<String>>? typingUsers,
    Map<String, UserPresence>? userPresence,
    List<ChatUser>? availableUsers,
    List<ChatUser>? adminUsers,
    ChatSettings? settings,
    SearchResult? searchResult,
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
      searchResult: searchResult ?? this.searchResult,
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

  /// تدخل كل البيانات المرئية وحالات التفاعل اللحظي في المقارنة
  /// حتى لا يتجاهل Equatable أي تغيير حقيقي.
  /// Every visible field and realtime interaction state participates
  /// in equality so `Equatable` does not miss real changes.
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

/// تمثل فشلًا يحتاج إلى عرضه للمستخدم أو تسجيله في الواجهة.
/// Represents a failure that needs to be surfaced to the user or
/// logged by the UI.
class ChatError extends ChatState {
  /// رسالة الخطأ التي تعرض أو تسجل دون تحميل الحالة بيانات إضافية.
  /// The error message to display or log without adding more state.
  final String message;

  /// يحمل النص وحده لأن الخطأ يحتاج رسالة واحدة واضحة.
  /// Carries only the text because this failure state needs one clear
  /// message.
  const ChatError({required this.message});

  /// تعتمد الحالة على الرسالة نفسها.
  /// The state depends on the message itself.
  @override
  List<Object> get props => [message];
}

  /// يصف حضور المستخدم داخل الشات مع توقيت آخر ظهور إذا كان معروفًا.
  /// Describes chat presence together with the last-seen timestamp
  /// when it is known.
class UserPresence extends Equatable {
  /// الحالة الظاهرة للمستخدم مثل online أو offline أو away.
  /// The visible status for the user such as online, offline, or away.
  final String status;

  /// وقت آخر ظهور إن كان متاحًا من مزود الحضور.
  /// The last-seen time when the presence provider supplies it.
  final DateTime? lastSeen;

  /// يربط الحالة بآخر ظهور حتى تعرض الواجهة الحضور بشكل موثوق.
  /// Links the status to the last-seen time so the UI can present
  /// presence reliably.
  const UserPresence({
    required this.status,
    this.lastSeen,
  });

  /// تعتمد المقارنة على الحالة ووقت آخر ظهور.
  /// Equality depends on the status and last-seen timestamp.
  @override
  List<Object?> get props => [status, lastSeen];
}

  /// تؤكد نجاح إنشاء محادثة جديدة وتعيدها للواجهة مع رسالة نجاح
  /// اختيارية.
  /// Confirms that a new conversation was created and returns it to
  /// the UI with an optional success message.
class ConversationCreated extends ChatState {
  /// المحادثة الجديدة التي يجب عرضها أو إضافتها للقائمة.
  /// The newly created conversation to show or append to the list.
  final Conversation conversation;

  /// رسالة نجاح اختياريّة يمكن استخدامها في التنبيه أو الشريط
  /// السفلي.
  /// Optional success text that can be used in a toast or banner.
  final String? message;

  /// يحمل المحادثة الجديدة مع رسالة نجاح افتراضية قابلة للتخصيص.
  /// Carries the new conversation with a customizable success
  /// message.
  const ConversationCreated({
    required this.conversation,
    this.message = 'تم إنشاء المحادثة بنجاح',
  });

  /// تعتمد المساواة على المحادثة والرسالة المصاحبة لها.
  /// Equality depends on the conversation and its accompanying
  /// message.
  @override
  List<Object?> get props => [conversation, message];
}

  /// تشير إلى أن عملية إنشاء المحادثة تعمل الآن.
  /// Indicates that conversation creation is currently in progress.
class ConversationCreating extends ChatState {
  /// لا تحمل حقولًا لأنها تمثل حالة انتظار بحتة.
  /// No fields are needed because this is a pure waiting state.
  const ConversationCreating();
}
