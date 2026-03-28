import 'package:equatable/equatable.dart';
import 'attachment.dart';

/// يعرّف الكلاس `Message`.
/// Describes the `Message` class.
class Message extends Equatable {
  /// Holds the `id` value.
  /// العربية: يخزن القيمة `id`.
  final String id;

  /// يخزن العضو `conversationId`.
  /// Holds the `conversationId` member.
  final String conversationId;

  /// يخزن العضو `senderId`.
  /// Holds the `senderId` member.
  final String senderId;

  /// يخزن العضو `senderName`.
  /// Holds the `senderName` member.
  final String? senderName;

  /// يخزن العضو `senderAvatar`.
  /// Holds the `senderAvatar` member.
  final String? senderAvatar;

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

  /// يخزن العضو `replyToMessage`.
  /// Holds the `replyToMessage` member.
  final Message? replyToMessage;

  /// يخزن العضو `reactions`.
  /// Holds the `reactions` member.
  final List<MessageReaction> reactions;

  /// يخزن العضو `attachments`.
  /// Holds the `attachments` member.
  final List<Attachment> attachments;

  /// يخزن العضو `createdAt`.
  /// Holds the `createdAt` member.
  final DateTime createdAt;

  /// يخزن العضو `updatedAt`.
  /// Holds the `updatedAt` member.
  final DateTime updatedAt;

  /// يخزن العضو `status`.
  /// Holds the `status` member.
  final String status;

  /// يخزن العضو `isEdited`.
  /// Holds the `isEdited` member.
  final bool isEdited;

  /// يخزن العضو `editedAt`.
  /// Holds the `editedAt` member.
  final DateTime? editedAt;

  /// يخزن العضو `deliveryReceipt`.
  /// Holds the `deliveryReceipt` member.
  final DeliveryReceipt? deliveryReceipt;

  /// يخزن العضو `isDeleted`.
  /// Holds the `isDeleted` member.
  final bool isDeleted;

  /// يخزن العضو `deletedAt`.
  /// Holds the `deletedAt` member.
  final DateTime? deletedAt;

  /// يخزن العضو `failureReason`.
  /// Holds the `failureReason` member.
  final String? failureReason; // إضافة سبب الفشل
  /// يخزن العضو `isForwarded`.
  /// Holds the `isForwarded` member.
  final bool isForwarded;

  /// يخزن العضو `forwardedFrom`.
  /// Holds the `forwardedFrom` member.
  final String? forwardedFrom;

  /// يخزن العضو `mentions`.
  /// Holds the `mentions` member.
  final List<String> mentions;

  /// يخزن العضو `isPinned`.
  /// Holds the `isPinned` member.
  final bool isPinned;

  /// يخزن العضو `isStarred`.
  /// Holds the `isStarred` member.
  final bool isStarred;

  /// يخزن العضو `readBy`.
  /// Holds the `readBy` member.
  final List<String> readBy;

  /// يخزن العضو `metadata`.
  /// Holds the `metadata` member.
  final Map<String, dynamic>? metadata;

  /// ينشئ مثيلاً من `Message`.
  /// Builds an instance of `Message`.
  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.senderName,
    this.senderAvatar,
    required this.messageType,
    this.content,
    this.location,
    this.replyToMessageId,
    this.replyToMessage,
    this.reactions = const [],
    this.attachments = const [],
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    this.isEdited = false,
    this.editedAt,
    this.deliveryReceipt,
    this.isDeleted = false,
    this.deletedAt,
    this.failureReason,
    this.isForwarded = false,
    this.forwardedFrom,
    this.mentions = const [],
    this.isPinned = false,
    this.isStarred = false,
    this.readBy = const [],
    this.metadata,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [
        id,
        conversationId,
        senderId,
        senderName,
        senderAvatar,
        messageType,
        content,
        location,
        replyToMessageId,
        replyToMessage,
        reactions,
        attachments,
        createdAt,
        updatedAt,
        status,
        isEdited,
        editedAt,
        deliveryReceipt,
        isDeleted,
        deletedAt,
        failureReason,
        isForwarded,
        forwardedFrom,
        mentions,
        isPinned,
        isStarred,
        readBy,
        metadata,
      ];

  // Helper methods
  /// يعيد قيمة `isTextMessage`.
  /// Exposes the `isTextMessage` value.
  bool get isTextMessage => messageType == 'text';

  /// يعيد قيمة `isMediaMessage`.
  /// Exposes the `isMediaMessage` value.
  bool get isMediaMessage => ['image', 'video', 'audio'].contains(messageType);

  /// يعيد قيمة `hasAttachments`.
  /// Exposes the `hasAttachments` value.
  bool get hasAttachments => attachments.isNotEmpty;

  /// يعيد قيمة `isDelivered`.
  /// Exposes the `isDelivered` value.
  bool get isDelivered => status == 'delivered' || status == 'read';

  /// يعيد قيمة `isRead`.
  /// Exposes the `isRead` value.
  bool get isRead => status == 'read';

  /// يعيد قيمة `isFailed`.
  /// Exposes the `isFailed` value.
  bool get isFailed => status == 'failed';
}

/// يعرّف الكلاس `Location`.
/// Describes the `Location` class.
class Location extends Equatable {
  /// Holds the `latitude` value.
  /// العربية: يخزن القيمة `latitude`.
  final double latitude;

  /// يخزن العضو `longitude`.
  /// Holds the `longitude` member.
  final double longitude;

  /// يخزن العضو `address`.
  /// Holds the `address` member.
  final String? address;

  /// يخزن العضو `placeName`.
  /// Holds the `placeName` member.
  final String? placeName;

  /// يخزن العضو `accuracy`.
  /// Holds the `accuracy` member.
  final double? accuracy;

  /// ينشئ مثيلاً من `Location`.
  /// Builds an instance of `Location`.
  const Location({
    required this.latitude,
    required this.longitude,
    this.address,
    this.placeName,
    this.accuracy,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props =>
      [latitude, longitude, address, placeName, accuracy];
}

/// يعرّف الكلاس `MessageReaction`.
/// Describes the `MessageReaction` class.
class MessageReaction extends Equatable {
  /// Holds the `id` value.
  /// العربية: يخزن القيمة `id`.
  final String id;

  /// يخزن العضو `messageId`.
  /// Holds the `messageId` member.
  final String messageId;

  /// يخزن العضو `userId`.
  /// Holds the `userId` member.
  final String userId;

  /// يخزن العضو `reactionType`.
  /// Holds the `reactionType` member.
  final String reactionType; // "like", "love", "laugh", "sad", "angry", "wow"

  /// ينشئ مثيلاً من `MessageReaction`.
  /// Builds an instance of `MessageReaction`.
  const MessageReaction({
    required this.id,
    required this.messageId,
    required this.userId,
    required this.reactionType,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [id, messageId, userId, reactionType];
}

/// يعرّف الكلاس `DeliveryReceipt`.
/// Describes the `DeliveryReceipt` class.
class DeliveryReceipt extends Equatable {
  /// Holds the `deliveredAt` value.
  /// العربية: يخزن القيمة `deliveredAt`.
  final DateTime? deliveredAt;

  /// يخزن العضو `readAt`.
  /// Holds the `readAt` member.
  final DateTime? readAt;

  /// يخزن العضو `readBy`.
  /// Holds the `readBy` member.
  final List<String> readBy;

  /// ينشئ مثيلاً من `DeliveryReceipt`.
  /// Builds an instance of `DeliveryReceipt`.
  const DeliveryReceipt({
    this.deliveredAt,
    this.readAt,
    this.readBy = const [],
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [deliveredAt, readAt, readBy];
}

/// يضيف الامتداد `LocationExtension` سلوكاً إضافياً.
/// Adds extra behavior through the `LocationExtension` extension.
extension LocationExtension on Location {
  /// Converts this instance to a JSON representation.
  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (address != null) 'address': address,
    };
  }
}
