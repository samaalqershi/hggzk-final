import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';
import '../entities/attachment.dart';

/// Contract for every data source that powers chat conversations, messages,
/// reactions, attachments, search, and local cache behavior.
/// الواجهة التي تفرض سلوك مصادر بيانات الدردشة: المحادثات، الرسائل،
/// التفاعلات، المرفقات، البحث، والكاش المحلي.
abstract class ChatRepository {
  // Conversations
  /// Opens a new conversation thread for the selected participants and
  /// optional property context.
  /// ينشئ محادثة جديدة للمشاركين المختارين مع سياق عقار اختياري.
  Future<Either<Failure, Conversation>> createConversation({
    required List<String> participantIds,
    required String conversationType,
    String? title,
    String? description,
    String? propertyId,
  });

  /// Returns the inbox conversations page by page so the UI can keep loading
  /// the list incrementally.
  /// يعيد محادثات الصندوق الوارد بشكل مرقم حتى تتمكن الواجهة من تحميل
  /// القائمة تدريجيًا.
  Future<Either<Failure, List<Conversation>>> getConversations({
    required int pageNumber,
    required int pageSize,
  });

  /// Loads a single conversation using its identifier so detail screens can
  /// restore the active thread.
  /// يحمل محادثة واحدة عبر معرّفها حتى تستطيع الشاشات استعادة السلسلة
  /// النشطة.
  Future<Either<Failure, Conversation>> getConversationById(
      String conversationId);

  /// Moves a conversation out of the main inbox without destroying its
  /// history.
  /// ينقل المحادثة خارج الصندوق الوارد دون حذف تاريخها.
  Future<Either<Failure, void>> archiveConversation(String conversationId);

  /// Restores a previously archived conversation back into the inbox.
  /// يعيد المحادثة المؤرشفة سابقًا إلى الصندوق الوارد.
  Future<Either<Failure, void>> unarchiveConversation(String conversationId);

  /// Permanently removes a conversation and its active presentation state.
  /// يحذف المحادثة نهائيًا مع حالتها الظاهرة الحالية.
  Future<Either<Failure, void>> deleteConversation(String conversationId);

  // Messages
  /// Loads a page of messages for a conversation, optionally anchored before
  /// a known message id.
  /// يحمل صفحة من رسائل محادثة معيّنة، ويمكنه الاستئناف قبل رسالة مرساة
  /// محددة.
  Future<Either<Failure, List<Message>>> getMessages({
    required String conversationId,
    required int pageNumber,
    required int pageSize,
    String? beforeMessageId,
  });

  /// Sends a new message payload that may include text, location, replies,
  /// or attachment references.
  /// يرسل رسالة جديدة قد تحتوي على نص أو موقع أو رد أو مراجع لمرفقات.
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String messageType,
    String? content,
    Location? location,
    String? replyToMessageId,
    List<String>? attachmentIds,
  });

  /// Replaces the content of an existing message while keeping its identity
  /// and conversation context.
  /// يبدّل محتوى رسالة موجودة مع الحفاظ على هويتها وسياقها داخل المحادثة.
  Future<Either<Failure, Message>> editMessage({
    required String messageId,
    required String content,
  });

  /// Deletes a single message from a conversation thread.
  /// يحذف رسالة واحدة من سلسلة المحادثة.
  Future<Either<Failure, void>> deleteMessage(String messageId);

  /// Marks the supplied messages as read so unread counters stay in sync.
  /// يعلّم الرسائل المحددة كمقروءة حتى تبقى عدادات غير المقروء متزامنة.
  Future<Either<Failure, void>> markAsRead({
    required String conversationId,
    required List<String> messageIds,
  });

  // Reactions
  /// Attaches a reaction to a message so the conversation can reflect quick
  /// feedback.
  /// يضيف تفاعلًا إلى رسالة حتى تعكس المحادثة ردود الفعل السريعة.
  Future<Either<Failure, void>> addReaction({
    required String messageId,
    required String reactionType,
  });

  /// Removes a previously sent reaction from a message.
  /// يزيل تفاعلًا سبق إرساله على رسالة.
  Future<Either<Failure, void>> removeReaction({
    required String messageId,
    required String reactionType,
  });

  // Attachments
  /// Uploads a single attachment before it is referenced by a message.
  /// يرفع مرفقًا واحدًا قبل ربطه برسالة.
  Future<Either<Failure, Attachment>> uploadAttachment({
    required String conversationId,
    required String filePath,
    required String messageType,
    ProgressCallback? onSendProgress,
  });

  /// Uploads several attachments together so the composer can send a batch
  /// message with one progress flow.
  /// يرفع عدة مرفقات دفعة واحدة حتى يرسل المحرر رسالة مجمعة بمسار تقدم واحد.
  Future<Either<Failure, List<Attachment>>> uploadMultipleAttachments({
    required String conversationId,
    required List<String> filePaths,
    required String messageType,
    ProgressCallback? onSendProgress,
  });

  // Search
  /// Searches conversations and messages using text, sender, date, and
  /// pagination filters.
  /// يبحث في المحادثات والرسائل باستخدام النص والمرسل والتاريخ والترقيم.
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
  /// Returns users that can be added to a conversation based on the current
  /// property or audience context.
  /// يعيد المستخدمين الذين يمكن إضافتهم إلى المحادثة بحسب العقار أو السياق
  /// الحالي.
  Future<Either<Failure, List<ChatUser>>> getAvailableUsers({
    String? userType,
    String? propertyId,
  });

  /// Returns administrative users that the UI can surface for staff-facing
  /// conversations.
  /// يعيد مستخدمي الإدارة الذين يمكن للواجهة إظهارهم للمحادثات الموجهة
  /// للطاقم.
  Future<Either<Failure, List<ChatUser>>> getAdminUsers();

  /// Updates the current user's presence or availability state.
  /// يحدّث حالة حضور المستخدم الحالي أو جاهزيته.
  Future<Either<Failure, void>> updateUserStatus(String status);

  // Settings
  /// Loads the chat preferences that affect notifications, read receipts,
  /// theme, and media handling.
  /// يحمل تفضيلات الدردشة التي تؤثر في الإشعارات والإيصالات والسمات
  /// ومعالجة الوسائط.
  Future<Either<Failure, ChatSettings>> getChatSettings();

  /// Persists one or more chat preference changes without forcing the caller
  /// to send the full settings object.
  /// يحفظ تغييرات إعدادات الدردشة جزئيًا أو كليًا من دون إجبار المستدعي على
  /// إرسال كائن الإعدادات كاملًا.
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
  /// Stores the latest conversation list locally for offline-friendly
  /// startup.
  /// يخزن أحدث قائمة محادثات محليًا لتسريع التشغيل ودعم العمل دون اتصال.
  Future<void> cacheConversations(List<Conversation> conversations);

  /// Reads the cached conversation list when the app needs a local fallback.
  /// يقرأ قائمة المحادثات المخزنة عند الحاجة إلى بديل محلي.
  Future<List<Conversation>?> getCachedConversations();

  /// Persists a thread message list so the same history can reappear instantly
  /// after navigation or app restart.
  /// يخزن رسائل المحادثة حتى تعود نفس المحادثة للظهور فورًا بعد التنقل أو
  /// إعادة تشغيل التطبيق.
  Future<void> cacheMessages(String conversationId, List<Message> messages);

  /// Reads the cached messages for one conversation if the local store still
  /// has them.
  /// يقرأ الرسائل المخزنة لمحادثة واحدة إن كانت ما زالت متاحة محليًا.
  Future<List<Message>?> getCachedMessages(String conversationId);

  /// Clears the chat cache when the signed-in user changes or the local data
  /// is no longer trustworthy.
  /// يمسح كاش الدردشة عند تغيّر المستخدم الحالي أو عند عدم موثوقية البيانات
  /// المحلية.
  Future<void> clearChatCache();
}

/// Aggregated result returned by chat search when the backend or local cache
/// needs to return both messages and conversations together.
/// نتيجة مجمعة لبحث الدردشة عندما يجب إعادة الرسائل والمحادثات معًا.
class SearchResult {
  /// Message matches returned by the search pipeline.
  /// الرسائل المطابقة التي أعادها مسار البحث.
  final List<Message> messages;

  /// Conversation matches returned by the same query.
  /// المحادثات المطابقة لنفس الاستعلام.
  final List<Conversation> conversations;

  /// Total number of matches across both result buckets.
  /// العدد الإجمالي للنتائج عبر الفئتين معًا.
  final int totalCount;

  /// Whether another page of results is still available.
  /// يحدد ما إذا كانت هناك صفحة إضافية من النتائج.
  final bool hasMore;

  /// Next page number the UI can request when pagination continues.
  /// رقم الصفحة التالية الذي يمكن للواجهة طلبه عند متابعة الترقيم.
  final int? nextPageNumber;

  /// Builds a typed search payload that keeps pagination metadata alongside
  /// the actual matches.
  /// ينشئ حمولة بحث منسقة تحفظ بيانات الترقيم مع النتائج الفعلية.
  const SearchResult({
    required this.messages,
    required this.conversations,
    required this.totalCount,
    required this.hasMore,
    this.nextPageNumber,
  });
}
