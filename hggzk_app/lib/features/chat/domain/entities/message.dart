import 'package:equatable/equatable.dart';
import 'attachment.dart';

/// Immutable chat message that carries text, media, reactions, delivery
/// status, and optional location data.
/// رسالة دردشة غير قابلة للتعديل تحمل النص أو الوسائط أو التفاعلات أو حالة
/// التسليم أو الموقع الاختياري.
class Message extends Equatable {
  /// Stable identifier for the message.
  /// المعرّف الثابت للرسالة.
  final String id;

  /// Conversation that owns this message.
  /// المحادثة التي تنتمي إليها هذه الرسالة.
  final String conversationId;

  /// Sender id used for ownership, coloring, and permissions.
  /// معرّف المرسل المستخدم للملكية والألوان والصلاحيات.
  final String senderId;

  /// Display name shown next to the message when available.
  /// اسم العرض الذي يظهر بجانب الرسالة عندما يكون متاحًا.
  final String? senderName;

  /// Message payload type such as text, image, video, location, or audio.
  /// نوع حمولة الرسالة مثل النص أو الصورة أو الفيديو أو الموقع أو الصوت.
  final String messageType;

  /// Text body for text-like messages.
  /// النص الأساسي للرسائل النصية وما يشابهها.
  final String? content;

  /// Optional geographic payload for location messages.
  /// حمولة جغرافية اختيارية لرسائل الموقع.
  final Location? location;

  /// Message id this one replies to, if the thread is a quoted reply.
  /// معرّف الرسالة التي ترد عليها هذه الرسالة إن كانت مقتبسة.
  final String? replyToMessageId;

  /// Reaction list applied to this message.
  /// قائمة التفاعلات المضافة إلى هذه الرسالة.
  final List<MessageReaction> reactions;

  /// Attachments linked to this message.
  /// المرفقات المرتبطة بهذه الرسالة.
  final List<Attachment> attachments;

  /// Time when the message was first created.
  /// وقت إنشاء الرسالة أول مرة.
  final DateTime createdAt;

  /// Time when the message was last updated.
  /// وقت آخر تحديث للرسالة.
  final DateTime updatedAt;

  /// Delivery lifecycle state such as sending, sent, delivered, read, or
  /// failed.
  /// حالة دورة التسليم مثل الإرسال أو الوصول أو القراءة أو الفشل.
  final String status;

  /// Whether the user edited the message after sending it.
  /// يحدد ما إذا كان المستخدم عدّل الرسالة بعد إرسالها.
  final bool isEdited;

  /// Time when the last edit happened, if any.
  /// وقت آخر تعديل إن وجد.
  final DateTime? editedAt;

  /// Delivery receipt metadata for sent and read acknowledgements.
  /// بيانات إيصال التسليم للتأكيدات الخاصة بالإرسال والقراءة.
  final DeliveryReceipt? deliveryReceipt;

  /// Whether the message was deleted from the conversation timeline.
  /// يحدد ما إذا كانت الرسالة حُذفت من خط المحادثة.
  final bool isDeleted;

  /// Human-readable reason when sending failed.
  /// سبب قابل للقراءة عندما يفشل الإرسال.
  final String? failureReason;

  /// Builds an immutable chat message snapshot.
  /// ينشئ لقطة غير قابلة للتعديل لرسالة دردشة.
  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.senderName,
    required this.messageType,
    this.content,
    this.location,
    this.replyToMessageId,
    this.reactions = const [],
    this.attachments = const [],
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    this.isEdited = false,
    this.editedAt,
    this.deliveryReceipt,
    this.isDeleted = false,
    this.failureReason,
  });

  /// Equality is based on the full message snapshot.
  /// تُبنى المساواة على اللقطة الكاملة للرسالة.
  @override
  List<Object?> get props => [
        id,
        conversationId,
        senderId,
        senderName,
        messageType,
        content,
        location,
        replyToMessageId,
        reactions,
        attachments,
        createdAt,
        updatedAt,
        status,
        isEdited,
        editedAt,
        deliveryReceipt,
        isDeleted,
        failureReason,
      ];
}

/// Geographic location payload attached to a chat message.
/// حمولة موقع جغرافي مرفقة برسالة دردشة.
class Location extends Equatable {
  /// Latitude component of the coordinate pair.
  /// خط العرض في الزوج الإحداثي.
  final double latitude;

  /// Longitude component of the coordinate pair.
  /// خط الطول في الزوج الإحداثي.
  final double longitude;

  /// Optional human-readable address for the location.
  /// عنوان نصي اختياري للموقع.
  final String? address;

  /// Builds a location payload for the message entity.
  /// ينشئ حمولة موقع لكيان الرسالة.
  const Location({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  /// Equality is based on the coordinate payload.
  /// تُبنى المساواة على حمولة الإحداثيات.
  @override
  List<Object?> get props => [latitude, longitude, address];
}

/// Reaction attached to a message by a specific user.
/// تفاعل يضيفه مستخدم محدد إلى رسالة.
class MessageReaction extends Equatable {
  /// Stable identifier for the reaction record.
  /// المعرّف الثابت لسجل التفاعل.
  final String id;

  /// Message that received the reaction.
  /// الرسالة التي استقبلت التفاعل.
  final String messageId;

  /// User who sent the reaction.
  /// المستخدم الذي أرسل التفاعل.
  final String userId;

  /// Reaction label such as like, love, laugh, sad, angry, or wow.
  /// تسمية التفاعل مثل like أو love أو laugh أو sad أو angry أو wow.
  final String reactionType;

  /// Builds a reaction snapshot for one message and one user.
  /// ينشئ لقطة تفاعل لرسالة واحدة ومستخدم واحد.
  const MessageReaction({
    required this.id,
    required this.messageId,
    required this.userId,
    required this.reactionType,
  });

  /// Equality is based on the reaction identity and owner.
  /// تُبنى المساواة على هوية التفاعل وصاحبه.
  @override
  List<Object?> get props => [id, messageId, userId, reactionType];
}

/// Delivery acknowledgements for a message, including delivered and read
/// timestamps.
/// تأكيدات تسليم الرسالة، بما في ذلك أوقات الوصول والقراءة.
class DeliveryReceipt extends Equatable {
  /// Time when the message reached the recipient.
  /// وقت وصول الرسالة إلى المستلم.
  final DateTime? deliveredAt;

  /// Time when the recipient opened the message.
  /// وقت فتح المستلم للرسالة.
  final DateTime? readAt;

  /// Users who have read the message.
  /// المستخدمون الذين قرأوا الرسالة.
  final List<String> readBy;

  /// Builds the delivery receipt snapshot for the message.
  /// ينشئ لقطة إيصال التسليم للرسالة.
  const DeliveryReceipt({
    this.deliveredAt,
    this.readAt,
    this.readBy = const [],
  });

  /// Equality is based on the delivery timestamps and readers.
  /// تُبنى المساواة على أوقات التسليم والقراءة والقارئين.
  @override
  List<Object?> get props => [deliveredAt, readAt, readBy];
}

/// JSON helpers for the location payload.
/// مساعدات JSON لحمولة الموقع.
extension LocationExtension on Location {
  /// Serializes the location into the backend payload shape.
  /// يحول الموقع إلى الشكل الذي يتوقعه الخادم.
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (address != null) 'address': address,
    };
  }
}
