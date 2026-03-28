part of 'chat_bloc.dart';

/// يجمع أحداث المحادثة كلها في عقد واحد حتى يبقى تدفق الرسائل،
/// المرفقات، والاتصال اللحظي متسقًا داخل الـ BLoC.
/// Groups all chat actions behind one contract so messages,
/// attachments, and realtime updates stay coordinated inside the BLoC.
abstract class ChatEvent extends Equatable {
  /// يضمن أن جميع أحداث الشات غير قابلة للتغيير، لأن التحديثات
  /// يجب أن تعتمد على بيانات الحدث فقط.
  /// Keeps chat events immutable so updates depend only on the event
  /// data.
  const ChatEvent();

  /// القاعدة لا تحمل حقولًا مشتركة، لذلك تعتمد المساواة على النوع.
  /// The base type has no shared fields, so equality falls back to
  /// the type.
  @override
  List<Object?> get props => [];
}

/// يبدأ ربط الشات بالمصادر والخدمات اللازمة قبل تحميل المحادثات.
/// Starts chat wiring with the required services before loading any
/// conversations.
class InitializeChatEvent extends ChatEvent {
  /// لا يحمل حقولًا لأنه مجرد إشارة لبدء التهيئة.
  /// No fields are needed because this is only a start-up signal.
  const InitializeChatEvent();
}

/// يطلب تحميل قائمة المحادثات مع دعم التصفح الصفحي.
/// Requests the conversation list with pagination support.
class LoadConversationsEvent extends ChatEvent {
  /// يحدد الصفحة المطلوبة من قائمة المحادثات.
  /// Identifies the conversation page to load.
  final int pageNumber;

  /// يخزن العضو `pageSize`.
  /// Holds the `pageSize` member.
  final int pageSize;

  /// يجمع معطيات الصفحات حتى يبقى تحميل المحادثات متوقعًا.
  /// Bundles paging inputs so conversation loading stays predictable.
  const LoadConversationsEvent({
    this.pageNumber = 1,
    this.pageSize = 20,
  });

  /// تعتمد المساواة على رقم الصفحة وحجمها لأنهما يحددان الطلب نفسه.
  /// Equality depends on page number and size because they identify
  /// the same request.
  @override
  List<Object> get props => [pageNumber, pageSize];
}

/// يطلب رسائل محادثة محددة مع إمكانية التحميل قبل رسالة مرجعية.
/// Requests messages for one conversation and can load around a
/// reference message.
class LoadMessagesEvent extends ChatEvent {
  /// يحدد المحادثة المستهدفة.
  /// Identifies the target conversation.
  final String conversationId;

  /// يخزن العضو `pageNumber`.
  /// Holds the `pageNumber` member.
  final int pageNumber;

  /// يخزن العضو `pageSize`.
  /// Holds the `pageSize` member.
  final int pageSize;

  /// يخزن العضو `beforeMessageId`.
  /// Holds the `beforeMessageId` member.
  final String? beforeMessageId;

  /// يجمع معرف المحادثة مع إعدادات الصفحة والسجل المرجعي للرسائل.
  /// Combines the conversation id with paging settings and an
  /// optional anchor message.
  const LoadMessagesEvent({
    required this.conversationId,
    this.pageNumber = 1,
    this.pageSize = 50,
    this.beforeMessageId,
  });

  /// يعتمد الحدث على المحادثة والصفحة والرسالة المرجعية إذا وُجدت.
  /// The event depends on the conversation, paging, and anchor
  /// message when present.
  @override
  List<Object?> get props =>
      [conversationId, pageNumber, pageSize, beforeMessageId];
}

/// يطلب المزيد من الرسائل القديمة داخل نفس المحادثة.
/// Requests older messages within the same conversation.
class LoadMoreMessagesEvent extends ChatEvent {
  /// يحدد المحادثة التي سيتم توسيع سجلها.
  /// Identifies the conversation whose history should be expanded.
  final String conversationId;

  /// يخزن العضو `targetMessageId`.
  /// Holds the `targetMessageId` member.
  final String? targetMessageId;

  /// يخزن العضو `pageSize`.
  /// Holds the `pageSize` member.
  final int pageSize;

  /// يحمل مرجعًا للمحادثة وعدد العناصر الإضافية المطلوبة.
  /// Carries the conversation reference and the number of additional
  /// items requested.
  const LoadMoreMessagesEvent({
    required this.conversationId,
    this.targetMessageId,
    this.pageSize = 50,
  });

  /// يعتمد على المحادثة والرسالة المستهدفة وحجم الصفحة.
  /// Depends on the conversation, target anchor, and page size.
  @override
  List<Object?> get props => [conversationId, targetMessageId, pageSize];
}

/// يصف الرسالة المراد إرسالها مع كل البيانات المرتبطة بها قبل
/// بدء النقل أو التحديث المتفائل.
/// Describes the message to send together with the data needed before
/// transport or optimistic updates begin.
class SendMessageEvent extends ChatEvent {
  /// يحدد المحادثة التي ستستقبل الرسالة.
  /// Identifies the conversation that will receive the message.
  final String conversationId;

  /// يخزن العضو `messageType`.
  /// Holds the `messageType` member.
  final String messageType;

  /// يخزن العضو `content`.
  /// Holds the `content` member.
  final String? content;

  /// يخزن العضو `location`.
  /// Holds the `location` member.
  final Location? location;

  /// يخزن العضو `replyToMessageId`.
  /// Holds the `replyToMessageId` member.
  final String? replyToMessageId;

  /// يخزن العضو `attachmentIds`.
  /// Holds the `attachmentIds` member.
  final List<String>? attachmentIds;

  /// يخزن العضو `currentUserId`.
  /// Holds the `currentUserId` member.
  final String? currentUserId;

  /// يخزن العضو `skipOptimistic`.
  /// Holds the `skipOptimistic` member.
  final bool skipOptimistic;

  /// يخزن العضو `optimisticMessageId`.
  /// Holds the `optimisticMessageId` member.
  final String? optimisticMessageId;

  /// يجمع نص الرسالة أو موقعها أو مرفقاتها في حدث واحد حتى يتولى
  /// الـ BLoC إرسالها بالطريقة المناسبة.
  /// Bundles the message body, location, or attachments into one
  /// event so the BLoC can send it in the appropriate way.
  const SendMessageEvent({
    required this.conversationId,
    required this.messageType,
    this.content,
    this.location,
    this.replyToMessageId,
    this.attachmentIds,
    this.currentUserId,
    this.skipOptimistic = false,
    this.optimisticMessageId,
  });

  /// تعتمد المقارنة على جميع الحقول التي تغيّر شكل الرسالة أو
  /// طريقة إرسالها.
  /// Equality depends on every field that changes message shape or
  /// send behavior.
  @override
  List<Object?> get props => [
        conversationId,
        messageType,
        content,
        location,
        replyToMessageId,
        attachmentIds,
        currentUserId,
        skipOptimistic,
        optimisticMessageId,
      ];
}

/// يصف طلب إنشاء محادثة جديدة بمجموعة المشاركين ونوعها وعنوانها
/// الاختياري.
/// Describes a request to create a new conversation with its
/// participants, type, and optional title.
class CreateConversationEvent extends ChatEvent {
  /// قائمة المعرفات التي ستدخل في المحادثة الجديدة.
  /// The participant ids that will join the new conversation.
  final List<String> participantIds;

  /// يخزن العضو `conversationType`.
  /// Holds the `conversationType` member.
  final String conversationType;

  /// يخزن العضو `title`.
  /// Holds the `title` member.
  final String? title;

  /// يخزن العضو `description`.
  /// Holds the `description` member.
  final String? description;

  /// يخزن العضو `propertyId`.
  /// Holds the `propertyId` member.
  final String? propertyId;

  /// يجمّع الأطراف ونوع المحادثة والبيانات المساعدة في طلب واحد.
  /// Combines participants, conversation type, and helper metadata
  /// into one request.
  const CreateConversationEvent({
    required this.participantIds,
    required this.conversationType,
    this.title,
    this.description,
    this.propertyId,
  });

  /// تعتمد المساواة على جميع البيانات التي تغيّر هوية المحادثة
  /// الجديدة.
  /// Equality depends on everything that changes the identity of the
  /// new conversation.
  @override
  List<Object?> get props => [
        participantIds,
        conversationType,
        title,
        description,
        propertyId,
      ];
}

/// يطلب حذف محادثة معينة من الخادم ومن الحالة المحلية.
/// Requests deletion of a specific conversation from both server and
/// local state.
class DeleteConversationEvent extends ChatEvent {
  /// يحدد المحادثة المطلوب حذفها.
  /// Identifies the conversation to delete.
  final String conversationId;

  /// لا يحمل سوى معرف المحادثة لأن الحذف يحتاج هذا المفتاح فقط.
  /// Carries only the conversation id because deletion needs that
  /// key alone.
  const DeleteConversationEvent({required this.conversationId});

  /// يعتمد الحدث على معرف المحادثة فقط.
  /// The event depends only on the conversation id.
  @override
  List<Object> get props => [conversationId];
}

/// يعرّف الكلاس `ArchiveConversationEvent`.
/// Describes the `ArchiveConversationEvent` class.
class ArchiveConversationEvent extends ChatEvent {
  /// Holds the `conversationId` value.
  /// العربية: يخزن القيمة `conversationId`.
  final String conversationId;

  /// ينشئ مثيلاً من `ArchiveConversationEvent`.
  /// Builds an instance of `ArchiveConversationEvent`.
  const ArchiveConversationEvent({required this.conversationId});

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object> get props => [conversationId];
}

/// يطلب إعادة محادثة مؤرشفة إلى الوضع النشط.
/// Requests that an archived conversation be restored to active
/// status.
class UnarchiveConversationEvent extends ChatEvent {
  /// يحدد المحادثة المطلوب إلغاء أرشفتها.
  /// Identifies the conversation to unarchive.
  final String conversationId;

  /// يحمل المعرف فقط لأن الإلغاء يعتمد على المحادثة المستهدفة.
  /// Carries only the id because unarchiving acts on the target
  /// conversation.
  const UnarchiveConversationEvent({required this.conversationId});

  /// يعتمد هذا الحدث على معرف المحادثة فقط.
  /// This event depends only on the conversation id.
  @override
  List<Object> get props => [conversationId];
}

/// يطلب حذف رسالة واحدة من المحادثة.
/// Requests deletion of one message from the conversation.
class DeleteMessageEvent extends ChatEvent {
  /// يحدد الرسالة المطلوب حذفها.
  /// Identifies the message to delete.
  final String messageId;

  /// يحمل معرّف الرسالة فقط لأن الحذف يعتمد عليه وحده.
  /// Carries only the message id because deletion depends on that
  /// single key.
  const DeleteMessageEvent({required this.messageId});

  /// تعتمد المساواة على معرف الرسالة فقط.
  /// Equality depends only on the message id.
  @override
  List<Object> get props => [messageId];
}

/// يطلب تعديل نص رسالة موجودة دون تغيير هويتها.
/// Requests that an existing message be edited without changing its
/// identity.
class EditMessageEvent extends ChatEvent {
  /// يحدد الرسالة المراد تعديلها.
  /// Identifies the message to edit.
  final String messageId;

  /// المحتوى الجديد الذي سيستبدل النص الحالي.
  /// The new content that will replace the existing text.
  final String content;

  /// يجمع المعرّف والمحتوى الجديد حتى يعالج الـ BLoC التعديل كعملية
  /// واحدة.
  /// Bundles the id and new content so the BLoC treats editing as one
  /// operation.
  const EditMessageEvent({
    required this.messageId,
    required this.content,
  });

  /// تعتمد المساواة على الرسالة والمحتوى الجديد.
  /// Equality depends on the message id and the replacement content.
  @override
  List<Object> get props => [messageId, content];
}

/// يضيف تفاعلًا إلى رسالة داخل المحادثة.
/// Adds a reaction to a message in the conversation.
class AddReactionEvent extends ChatEvent {
  /// يحدد الرسالة المستهدفة.
  /// Identifies the target message.
  final String messageId;

  /// يخزن العضو `reactionType`.
  /// Holds the `reactionType` member.
  final String reactionType;

  /// معرف المستخدم الحالي يساعد على مطابقة التفاعل المتفائل مع
  /// المرسل الحقيقي.
  /// The current user id helps match optimistic reactions with the
  /// actual sender.
  final String? currentUserId;

  /// يحمل الرسالة ونوع التفاعل ومعرف المستخدم عند توفره.
  /// Carries the message id, reaction type, and user id when
  /// available.
  const AddReactionEvent({
    required this.messageId,
    required this.reactionType,
    this.currentUserId,
  });

  /// تعتمد المقارنة على الرسالة والتفاعل والمستخدم الحالي.
  /// Equality depends on the message, reaction type, and current
  /// user.
  @override
  List<Object?> get props => [messageId, reactionType, currentUserId];
}

/// يزيل تفاعلًا سابقًا من رسالة.
/// Removes a previously added reaction from a message.
class RemoveReactionEvent extends ChatEvent {
  /// يحدد الرسالة المستهدفة.
  /// Identifies the target message.
  final String messageId;

  /// يخزن العضو `reactionType`.
  /// Holds the `reactionType` member.
  final String reactionType;

  /// معرف المستخدم الحالي يساعد على عكس الإزالة المتفائلة بشكل
  /// صحيح.
  /// The current user id helps reverse the optimistic removal
  /// correctly.
  final String? currentUserId;

  /// يجمع الرسالة ونوع التفاعل والمستخدم لتصبح عملية الإزالة واضحة.
  /// Bundles the message, reaction type, and user so removal is
  /// unambiguous.
  const RemoveReactionEvent({
    required this.messageId,
    required this.reactionType,
    this.currentUserId,
  });

  /// تعتمد المقارنة على الرسالة والتفاعل والمستخدم الحالي.
  /// Equality depends on the message, reaction type, and current
  /// user.
  @override
  List<Object?> get props => [messageId, reactionType, currentUserId];
}

/// يعلّم مجموعة رسائل كمقروءة داخل محادثة محددة.
/// Marks a group of messages as read within one conversation.
class MarkMessagesAsReadEvent extends ChatEvent {
  /// يحدد المحادثة التي ستتغير حالتها.
  /// Identifies the conversation whose state will change.
  final String conversationId;

  /// يخزن العضو `messageIds`.
  /// Holds the `messageIds` member.
  final List<String> messageIds;

  /// يحمل المحادثة مع قائمة الرسائل التي يجب اعتمادها كمقروءة.
  /// Carries the conversation and the message ids that should be
  /// acknowledged as read.
  const MarkMessagesAsReadEvent({
    required this.conversationId,
    required this.messageIds,
  });

  /// تعتمد المساواة على المحادثة والرسائل نفسها.
  /// Equality depends on the conversation and the message ids.
  @override
  List<Object> get props => [conversationId, messageIds];
}

/// يصف طلب رفع مرفق واحد ثم ربطه بالمحادثة المستهدفة.
/// Describes uploading one attachment and linking it to the target
/// conversation.
class UploadAttachmentEvent extends ChatEvent {
  /// يحدد المحادثة التي ستستقبل المرفق.
  /// Identifies the conversation that will receive the attachment.
  final String conversationId;

  /// يخزن العضو `filePath`.
  /// Holds the `filePath` member.
  final String filePath;

  /// يخزن العضو `messageType`.
  /// Holds the `messageType` member.
  final String messageType;

  /// يُستدعى هذا المعالج لتحديث نسبة التقدم أثناء الرفع.
  /// This callback reports upload progress to the UI.
  final Function(int, int)? onProgress;

  /// يخزن العضو `replyToMessageId`.
  /// Holds the `replyToMessageId` member.
  final String? replyToMessageId;

  /// يخزن العضو `optimisticMessageId`.
  /// Holds the `optimisticMessageId` member.
  final String? optimisticMessageId;

  /// يجمع ملفًا واحدًا مع نوع الرسالة وخيارات الربط المساندة.
  /// Bundles one file with the message type and supporting link
  /// options.
  const UploadAttachmentEvent({
    required this.conversationId,
    required this.filePath,
    required this.messageType,
    this.onProgress,
    this.replyToMessageId,
    this.optimisticMessageId,
  });

  /// تعتمد المساواة على المحادثة والمسار ونوع الرسالة.
  /// Equality depends on the conversation, file path, and message
  /// type.
  @override
  List<Object?> get props => [
        conversationId,
        filePath,
        messageType,
        replyToMessageId,
        optimisticMessageId
      ];
}

// Legacy SendImagesEvent and UpdateImageUploadProgressEvent removed. UI now
// uploads attachments sequentially and shows local progress overlay.

// Begin: In-bubble image upload events
/// يهيئ رفع صور داخل المحادثة دفعة واحدة قبل بدء الإرسال الفعلي.
/// Prepares a batch of in-chat image uploads before the actual send
/// starts.
class StartImageUploadsEvent extends ChatEvent {
  /// يحدد المحادثة التي ستعرض الصور أثناء الرفع.
  /// Identifies the conversation that will show the uploads.
  final String conversationId;

  /// قائمة عمليات الرفع التي ستدار داخل طبقة الشات.
  /// The upload tasks that will be handled by the chat layer.
  final List<ImageUploadInfo> uploads;

  /// يجمع جميع عمليات الرفع في بداية واحدة حتى يمكن تتبعها
  /// بشكل متماسك.
  /// Bundles all uploads into one starting point so they can be
  /// tracked coherently.
  const StartImageUploadsEvent({
    required this.conversationId,
    required this.uploads,
  });

  /// تعتمد المساواة على المحادثة والعمليات المرفقة.
  /// Equality depends on the conversation and the attached uploads.
  @override
  List<Object?> get props => [conversationId, uploads];
}

/// يحدّث حالة رفع صورة واحدة داخل العملية المتعددة.
/// Updates the progress of one image inside a multi-upload flow.
class UpdateImageUploadProgressEvent extends ChatEvent {
  /// يحدد المحادثة التي تخص عملية الرفع.
  /// Identifies the conversation for the upload flow.
  final String conversationId;

  /// يميز عملية الرفع المحددة داخل الدفعة.
  /// Distinguishes the specific upload within the batch.
  final String uploadId;

  /// النسبة المنطقية للتقدم بين `0.0` و`1.0`.
  /// Normalized progress between `0.0` and `1.0`.
  final double? progress;
  /// يشير إلى اكتمال الرفع أم لا.
  /// Indicates whether the upload finished successfully.
  final bool? isCompleted;

  /// يوضح ما إذا كانت العملية انتهت بخطأ.
  /// Indicates whether the upload failed.
  final bool? isFailed;

  /// يحمل الرسالة التي تشرح سبب الفشل عندما تتوقف العملية.
  /// Carries the failure explanation when the upload stops.
  final String? error;

  /// يجمع مؤشرات الرفع في حدث واحد حتى ينعكس التقدم في الواجهة
  /// بدقة.
  /// Bundles upload markers into one event so progress is reflected in
  /// the UI precisely.
  const UpdateImageUploadProgressEvent({
    required this.conversationId,
    required this.uploadId,
    this.progress,
    this.isCompleted,
    this.isFailed,
    this.error,
  });

  /// تعتمد المساواة على كل ما يغير هوية عملية الرفع نفسها.
  /// Equality depends on everything that changes the upload identity.
  @override
  List<Object?> get props => [
        conversationId,
        uploadId,
        progress,
        isCompleted,
        isFailed,
        error,
      ];
}

/// يعلن انتهاء دفعة رفع الصور داخل المحادثة.
/// Marks the end of the image-upload batch for the conversation.
class FinishImageUploadsEvent extends ChatEvent {
  /// يحدد المحادثة التي انتهت دفعة الرفع الخاصة بها.
  /// Identifies the conversation whose upload batch finished.
  final String conversationId;

  /// يرسل إشارة نهائية حتى تنظف الواجهة حالة الرفع المؤقتة.
  /// Sends a final signal so the UI can clear temporary upload state.
  const FinishImageUploadsEvent({required this.conversationId});

  /// يعتمد على المحادثة فقط لأن الحدث يخص دفعة محددة.
  /// Depends only on the conversation because the event belongs to one
  /// batch.
  @override
  List<Object?> get props => [conversationId];
}
// End: In-bubble image upload events

/// يطلب البحث داخل المحادثات أو الرسائل مع مرشحات إضافية.
/// Requests search across conversations or messages with optional
/// filters.
class SearchChatsEvent extends ChatEvent {
  /// نص البحث الأساسي الذي يحدد النتائج.
  /// The primary search query that drives the results.
  final String query;

  /// يخزن العضو `conversationId`.
  /// Holds the `conversationId` member.
  final String? conversationId;

  /// يخزن العضو `messageType`.
  /// Holds the `messageType` member.
  final String? messageType;

  /// يخزن العضو `senderId`.
  /// Holds the `senderId` member.
  final String? senderId;

  /// يخزن العضو `dateFrom`.
  /// Holds the `dateFrom` member.
  final DateTime? dateFrom;

  /// يخزن العضو `dateTo`.
  /// Holds the `dateTo` member.
  final DateTime? dateTo;

  /// يخزن العضو `page`.
  /// Holds the `page` member.
  final int page;

  /// يخزن العضو `limit`.
  /// Holds the `limit` member.
  final int limit;

  /// يجمع نص البحث مع مرشحات السياق حتى تبقى النتائج دقيقة.
  /// Combines the query with contextual filters so results stay
  /// relevant.
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

  /// تعتمد المساواة على نص البحث وكل المرشحات المرتبطة به.
  /// Equality depends on the query and all attached filters.
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

/// يطلب المستخدمين المتاحين للاختيار في المحادثة الجديدة أو
/// الإعدادات المرتبطة بها.
/// Requests available users for selection in a new chat or related
/// settings flow.
class LoadAvailableUsersEvent extends ChatEvent {
  /// يقيّد النتائج بنوع مستخدم معين عندما يلزم.
  /// Restricts the results to a specific user type when needed.
  final String? userType;

  /// يخزن العضو `propertyId`.
  /// Holds the `propertyId` member.
  final String? propertyId;

  /// يربط فلتر النوع بالعقار الحالي عند الحاجة.
  /// Associates the type filter with the current property when
  /// required.
  const LoadAvailableUsersEvent({
    this.userType,
    this.propertyId,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [userType, propertyId];
}

  /// يطلب قائمة المستخدمين الإداريين لتعبئتها في شاشات الإدارة.
  /// Requests the list of admin users for admin-facing screens.
class LoadAdminUsersEvent extends ChatEvent {
  /// لا يحمل حقولًا لأن الهدف هو جلب القائمة فقط.
  /// No fields are needed because the event only loads a list.
  const LoadAdminUsersEvent();
}

/// يغيّر حالة المستخدم الحالية مثل التفعيل أو التوقيف.
/// Changes the current user status such as activation or suspension.
class UpdateUserStatusEvent extends ChatEvent {
  /// الحالة الجديدة التي ستُطبق على المستخدم.
  /// The new status to apply to the user.
  final String status;

  /// يحمل قيمة الحالة فقط لأن التغيير يعتمد عليها وحدها.
  /// Carries only the status value because the change depends on it
  /// alone.
  const UpdateUserStatusEvent({required this.status});

  /// تعتمد المساواة على الحالة المستهدفة فقط.
  /// Equality depends only on the target status.
  @override
  List<Object> get props => [status];
}

/// يطلب إعدادات الشات الحالية حتى تبني الواجهة القيم الافتراضية
/// الصحيحة.
/// Requests the current chat settings so the UI can build the right
/// defaults.
class LoadChatSettingsEvent extends ChatEvent {
  /// هذا الحدث مجرد إشارة لجلب الإعدادات.
  /// This event is only a signal to load the settings.
  const LoadChatSettingsEvent();
}

/// يحمل التعديلات الجزئية على إعدادات الشات لتحديثها دفعة واحدة.
/// Carries partial chat-settings changes so they can be updated in a
/// single pass.
class UpdateChatSettingsEvent extends ChatEvent {
  /// يحدد ما إذا كانت الإشعارات مفعلة أم لا.
  /// Indicates whether notifications are enabled.
  final bool? notificationsEnabled;

  /// يخزن العضو `soundEnabled`.
  /// Holds the `soundEnabled` member.
  final bool? soundEnabled;

  /// يخزن العضو `showReadReceipts`.
  /// Holds the `showReadReceipts` member.
  final bool? showReadReceipts;

  /// يخزن العضو `showTypingIndicator`.
  /// Holds the `showTypingIndicator` member.
  final bool? showTypingIndicator;

  /// يخزن العضو `theme`.
  /// Holds the `theme` member.
  final String? theme;

  /// يخزن العضو `fontSize`.
  /// Holds the `fontSize` member.
  final String? fontSize;

  /// يخزن العضو `autoDownloadMedia`.
  /// Holds the `autoDownloadMedia` member.
  final bool? autoDownloadMedia;

  /// يخزن العضو `backupMessages`.
  /// Holds the `backupMessages` member.
  final bool? backupMessages;

  /// يجمع القيم المعدلة فقط حتى يبقى التحديث جزئيًا وآمنًا.
  /// Bundles only the changed values so the update stays partial and
  /// safe.
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

  /// تعتمد المقارنة على كل إعداد قابل للتعديل.
  /// Equality depends on every editable setting.
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

/// يرسل مؤشر الكتابة للحظة الحالية داخل المحادثة.
/// Sends the typing indicator for the current conversation moment.
class SendTypingIndicatorEvent extends ChatEvent {
  /// يحدد المحادثة التي يظهر فيها المؤشر.
  /// Identifies the conversation that shows the indicator.
  final String conversationId;

  /// يخزن العضو `isTyping`.
  /// Holds the `isTyping` member.
  final bool isTyping;

  /// يجمع المحادثة وحالة الكتابة في حدث واحد.
  /// Combines the conversation and typing flag into one event.
  const SendTypingIndicatorEvent({
    required this.conversationId,
    required this.isTyping,
  });

  /// يعتمد على المحادثة وحالة الكتابة.
  /// Depends on the conversation and typing state.
  @override
  List<Object> get props => [conversationId, isTyping];
}

/// ينقل رسالة وصلت من WebSocket إلى طبقة الحالة حتى تظهر فورًا
/// في الشاشة.
/// Moves a message received from WebSocket into the state layer so it
/// appears immediately on screen.
class WebSocketMessageReceivedEvent extends ChatEvent {
  /// يضم حدث الرسالة الخام القادم من البث اللحظي.
  /// Holds the raw message event coming from the realtime stream.
  final MessageEvent messageEvent;

  /// يمرر حدث الرسالة كما ورد من الخادم من دون تعديل إضافي.
  /// Passes through the message event as delivered by the server.
  const WebSocketMessageReceivedEvent(this.messageEvent);

  /// يعتمد هذا الحدث على الرسالة الخام نفسها.
  /// This event depends on the raw message payload itself.
  @override
  List<Object> get props => [messageEvent];
}

/// يحدّث لقطة المحادثة عندما يرسل WebSocket تغييرًا على مستوى
/// المحادثة نفسها.
/// Updates the conversation snapshot when WebSocket emits a
/// conversation-level change.
class WebSocketConversationUpdatedEvent extends ChatEvent {
  /// المحادثة المحدثة كما وصلت من البث اللحظي.
  /// The updated conversation as received from the realtime stream.
  final Conversation conversation;

  /// يمرر المحادثة الجديدة إلى الحالة دون إعادة صياغتها.
  /// Passes the new conversation into state without reshaping it.
  const WebSocketConversationUpdatedEvent(this.conversation);

  /// تعتمد المساواة على المحادثة نفسها.
  /// Equality depends on the conversation itself.
  @override
  List<Object> get props => [conversation];
}

/// يحمل مؤشرات الكتابة الواردة لكل محادثة.
/// Carries incoming typing indicators for a conversation.
class WebSocketTypingIndicatorEvent extends ChatEvent {
  /// يحدد المحادثة التي تخص مؤشرات الكتابة.
  /// Identifies the conversation for the typing indicator.
  final String conversationId;

  /// يخزن العضو `typingUserIds`.
  /// Holds the `typingUserIds` member.
  final List<String> typingUserIds;

  /// يجمع المحادثة مع قائمة المستخدمين الذين يكتبون حاليًا.
  /// Combines the conversation with the users who are typing now.
  const WebSocketTypingIndicatorEvent({
    required this.conversationId,
    required this.typingUserIds,
  });

  /// تعتمد المساواة على المحادثة والمستخدمين.
  /// Equality depends on the conversation and typing users.
  @override
  List<Object> get props => [conversationId, typingUserIds];
}

/// يحمل تحديث حضور مستخدم من WebSocket إلى طبقة الحالة.
/// Carries a presence update from WebSocket into state.
class WebSocketPresenceUpdateEvent extends ChatEvent {
  /// يحدد المستخدم الذي تغيّرت حالته.
  /// Identifies the user whose status changed.
  final String userId;

  /// يخزن العضو `status`.
  /// Holds the `status` member.
  final String status;

  /// يخزن العضو `lastSeen`.
  /// Holds the `lastSeen` member.
  final DateTime? lastSeen;

  /// يجمع معرف المستخدم والحالة وآخر ظهور ليعكس التغيير اللحظي.
  /// Bundles the user id, status, and last-seen time for a realtime
  /// presence change.
  const WebSocketPresenceUpdateEvent({
    required this.userId,
    required this.status,
    this.lastSeen,
  });

  /// تعتمد المساواة على المستخدم والحالة وآخر ظهور.
  /// Equality depends on the user id, status, and last seen.
  @override
  List<Object?> get props => [userId, status, lastSeen];
}

/// يصف رفع عدة مرفقات متتالية داخل المحادثة نفسها.
/// Describes uploading multiple attachments sequentially in the same
/// conversation.
class UploadMultipleAttachmentsEvent extends ChatEvent {
  /// يحدد المحادثة التي ستستقبل المرفقات.
  /// Identifies the conversation that will receive the attachments.
  final String conversationId;

  /// يخزن العضو `filePaths`.
  /// Holds the `filePaths` member.
  final List<String> filePaths;

  /// يخزن العضو `messageType`.
  /// Holds the `messageType` member.
  final String messageType;

  /// callback يتابع التقدم على مستوى كل ملف وداخل الدفعة ككل.
  /// Callback that tracks progress per file and across the whole
  /// batch.
  final Function(int index, int sent, int total)? onProgress;

  /// يحمل المسارات ونوع الرسالة حتى تتم عملية الرفع بشكل متسق.
  /// Carries file paths and message type so the upload happens
  /// consistently.
  const UploadMultipleAttachmentsEvent({
    required this.conversationId,
    required this.filePaths,
    required this.messageType,
    this.onProgress,
  });

  /// تعتمد المساواة على المحادثة والملفات ونوع الرسالة.
  /// Equality depends on the conversation, files, and message type.
  @override
  List<Object?> get props => [conversationId, filePaths, messageType];
}

/// يمسح الذاكرة المؤقتة الخاصة بمحادثة واحدة.
/// Clears the cached data for one conversation.
class ClearConversationCacheEvent extends ChatEvent {
  /// يحدد المحادثة التي يجب تنظيف ذاكرتها.
  /// Identifies the conversation whose cache should be cleared.
  final String conversationId;

  /// يمرر معرف المحادثة فقط لأن التنظيف محلي ومحدد.
  /// Carries only the conversation id because the cleanup is local
  /// and targeted.
  const ClearConversationCacheEvent({required this.conversationId});

  /// يعتمد على معرف المحادثة فقط.
  /// Depends only on the conversation id.
  @override
  List<Object> get props => [conversationId];
}

/// يطلب إعادة جلب محادثة بعينها لتحديث محتواها.
/// Requests a refresh of a specific conversation to update its
/// contents.
class RefreshConversationEvent extends ChatEvent {
  /// يحدد المحادثة المطلوب تحديثها.
  /// Identifies the conversation to refresh.
  final String conversationId;

  /// يحمل معرّف المحادثة فقط لأن المطلوب هو إعادة التحميل.
  /// Carries only the conversation id because the operation is a
  /// reload.
  const RefreshConversationEvent({required this.conversationId});

  /// يعتمد على معرف المحادثة فقط.
  /// Depends only on the conversation id.
  @override
  List<Object> get props => [conversationId];
}

/// يعيد محاولة إرسال رسالة فشلت سابقًا.
/// Retries sending a message that failed earlier.
class RetryFailedMessageEvent extends ChatEvent {
  /// يحدد المحادثة التي تنتمي إليها الرسالة الفاشلة.
  /// Identifies the conversation that owns the failed message.
  final String conversationId;

  /// يحدد الرسالة التي ستُعاد محاولتها.
  /// Identifies the message to retry.
  final String messageId;

  /// يجمع المحادثة والرسالة الفاشلة حتى يستعيدها الـ BLoC بشكل
  /// صحيح.
  /// Bundles the conversation and failed message so the BLoC can
  /// restore it correctly.
  const RetryFailedMessageEvent({
    required this.conversationId,
    required this.messageId,
  });

  /// تعتمد المساواة على المحادثة والرسالة المستهدفة.
  /// Equality depends on the conversation and target message.
  @override
  List<Object> get props => [conversationId, messageId];
}

/// يلغي عملية رفع جارية لمرفق داخل محادثة محددة.
/// Cancels an in-flight upload for an attachment in a specific
/// conversation.
class CancelUploadEvent extends ChatEvent {
  /// يحدد عملية الرفع التي يجب إيقافها.
  /// Identifies the upload operation to stop.
  final String uploadId;

  /// يحدد المحادثة التي تنتمي إليها العملية.
  /// Identifies the conversation that owns the upload.
  final String conversationId;

  /// يمرر معرف الرفع ومعرف المحادثة حتى يمكن إلغاء العملية بدقة.
  /// Carries the upload id and conversation id so the operation can
  /// be cancelled precisely.
  const CancelUploadEvent(
      {required this.uploadId, required this.conversationId});

  /// تعتمد المساواة على الرفع والمحادثة المستهدفة.
  /// Equality depends on the upload and target conversation.
  @override
  List<Object> get props => [uploadId, conversationId];
}
