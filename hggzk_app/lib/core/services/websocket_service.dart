import 'dart:async';
import 'package:hggzk/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:hggzk/features/chat/domain/entities/conversation.dart';
import 'package:hggzk/features/chat/domain/entities/message.dart';

/// غلاف مؤقت يحافظ على واجهة الشات حتى لو كان النقل الفوري معطلاً.
/// Temporary chat transport façade that preserves the public API while realtime is limited.
class ChatWebSocketService {
  /// يوضح ما إذا كانت الخدمة في وضع الجاهزية المنطقية أم لا.
  /// Indicates whether the service is logically ready to emit events.
  bool _isConnected = false;
  final _conversationController = StreamController<Conversation>.broadcast();
  final _messageController = StreamController<MessageEvent>.broadcast();
  final _typingController = StreamController<TypingEvent>.broadcast();
  final _presenceController = StreamController<PresenceEvent>.broadcast();

  /// يبث تحديثات المحادثات إلى واجهات الشات.
  /// Emits conversation updates to chat consumers.
  Stream<Conversation> get conversationUpdates =>
      _conversationController.stream;

  /// يبث أحداث الرسائل مثل الإضافة أو التعديل أو الحالة.
  /// Emits message lifecycle events such as create, edit, delete, and status changes.
  Stream<MessageEvent> get messageEvents => _messageController.stream;

  /// يبث حالات الكتابة من المشاركين في المحادثة.
  /// Emits typing indicators for the active conversation.
  Stream<TypingEvent> get typingEvents => _typingController.stream;

  /// يبث تواجد المستخدمين وحالة آخر ظهور لهم.
  /// Emits user presence and last-seen updates.
  Stream<PresenceEvent> get presenceEvents => _presenceController.stream;

  /// يربط الاعتمادات الاختيارية دون فتح اتصال فعلي لأن الخدمة حالية منطقية فقط.
  /// Accepts optional dependencies without creating a real socket connection.
  ChatWebSocketService({
    AuthLocalDataSource? authLocalDataSource,
  });

  /// يفعّل حالة الاتصال المنطقية فقط لأن استقبال الرسائل الفعلي يعتمد على FCM.
  /// Marks the logical connection as active while real-time delivery relies on FCM.
  Future<void> connect() async {
    if (_isConnected) return;
    _isConnected = true;
  }

  /// يغلق الحالة المنطقية للاتصال دون قناة WebSocket فعلية.
  /// Resets the logical connection state without an active WebSocket channel.
  void disconnect() {
    _isConnected = false;
  }

  /// هذه العملية معطلة حاليًا لأن التزامن الفوري يعتمد على الباكند/FCM.
  /// Kept as a no-op so chat flows do not break while WebSocket is disabled.
  void sendTypingIndicator(String conversationId, bool isTyping) {
    if (!_isConnected) return;
  }

  /// يغلق التدفقات ويصفي الحالة الداخلية.
  /// Closes the streams and clears the internal state.
  void dispose() {
    disconnect();
    _conversationController.close();
    _messageController.close();
    _typingController.close();
    _presenceController.close();
  }
}

// Event Models
/// وصف موحد للحدث الذي يخص الرسائل داخل الشات.
/// Unified description for message-related chat events.
class MessageEvent {
  /// نوع الحدث الذي حدث على الرسالة.
  /// Type of lifecycle event that occurred.
  final MessageEventType type;

  /// الرسالة المرتبطة بالحدث عند توفرها.
  /// The message payload when the event carries one.
  final Message? message;

  /// معرف الرسالة إذا كان الحدث لا يحمل الكائن كاملًا.
  /// Message identifier when the full object is not included.
  final String? messageId;

  /// المحادثة التي ينتمي إليها الحدث.
  /// Conversation that owns the event.
  final String conversationId;

  /// حالة الرسالة عندما يتعلق الحدث بالتسليم أو القراءة.
  /// Message delivery/read status when applicable.
  final String? status;

  /// التفاعل المرتبط بالرسالة إن كان الحدث تفاعلًا.
  /// Reaction payload when the event is reaction-related.
  final MessageReaction? reaction;

  /// يبني حدث الرسالة بالحد الأدنى من البيانات التي تحتاجها طبقة الشات.
  /// Builds the message event with the minimum data the chat layer needs.
  MessageEvent({
    required this.type,
    this.message,
    this.messageId,
    required this.conversationId,
    this.status,
    this.reaction,
  });
}

/// يصف من يكتب الآن داخل محادثة محددة.
/// Describes who is currently typing inside a conversation.
class TypingEvent {
  /// المحادثة التي يظهر فيها مؤشر الكتابة.
  /// Conversation where the typing indicator belongs.
  final String conversationId;

  /// المستخدمون الذين يكتبون في هذه اللحظة.
  /// Users who are typing at the moment.
  final List<String> typingUserIds;

  /// ينشئ حدث الكتابة مع قائمة المستخدمين الذين يكتبون الآن.
  /// Builds the typing event with the currently active typers.
  TypingEvent({
    required this.conversationId,
    required this.typingUserIds,
  });
}

/// يصف حالة التواجد وآخر ظهور لمستخدم ما.
/// Describes a user's presence state and last seen timestamp.
class PresenceEvent {
  /// المستخدم الذي تتحدث عنه حالة التواجد.
  /// User that the presence state belongs to.
  final String userId;

  /// الحالة الحالية مثل online أو offline أو away.
  /// Current status such as online, offline, or away.
  final String status;

  /// وقت آخر ظهور إذا كان معروفًا.
  /// Timestamp for the last seen moment when available.
  final DateTime? lastSeen;

  /// يبني حدث التواجد بالمعرف والحالة ووقت آخر ظهور إن توفر.
  /// Builds the presence event used to mirror user availability in chat.
  PresenceEvent({
    required this.userId,
    required this.status,
    this.lastSeen,
  });
}

/// أنواع الأحداث التي يمكن أن تصدرها طبقة الشات.
/// Event types emitted by the chat transport layer.
enum MessageEventType {
  newMessage,
  edited,
  deleted,
  statusUpdated,
  reactionAdded,
  reactionRemoved,
}
