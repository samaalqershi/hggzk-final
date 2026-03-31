import 'dart:convert';

import 'delivery_receipt_model.dart';
import 'message_reaction_model.dart';

import '../../domain/entities/message.dart';
import 'attachment_model.dart';

/// العربية: يمثل نموذج البيانات `MessageModel`.
class MessageModel extends Message {
  /// العربية: ينشئ مثيلًا جديدًا من `MessageModel`.
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.messageType,
    super.content,
    super.location,
    super.replyToMessageId,
    super.reactions,
    super.attachments,
    required super.createdAt,
    required super.updatedAt,
    required super.status,
    super.isEdited,
    super.editedAt,
    super.deliveryReceipt,
  });

  /// العربية: ينشئ مثيلًا جديدًا من `MessageModel.fromJson`.
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final parsedAttachments = (json['attachments'] as List? ?? [])
        .map((a) => AttachmentModel.fromJson(a))
        .toList();
    final parsedLocation = _parseLocation(json);
    final rawMessageType =
        json['messageType'] ?? json['message_type'] ?? 'text';

    return MessageModel(
      id: json['id'] ?? json['message_id'] ?? '',
      conversationId: json['conversationId'] ?? json['conversation_id'] ?? '',
      senderId: json['senderId'] ?? json['sender_id'] ?? '',
      messageType: rawMessageType.toString().toLowerCase(),
      content: json['content'],
      location: parsedLocation,
      replyToMessageId: json['replyToMessageId'] ?? json['reply_to_message_id'],
      reactions: (json['reactions'] as List? ?? [])
          .map((r) => MessageReactionModel.fromJson(r))
          .toList(),
      attachments: _dedupeAttachments(parsedAttachments),
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
      updatedAt: DateTime.parse(json['updatedAt'] ?? json['updated_at']),
      status: json['status'] ?? 'sent',
      isEdited: json['isEdited'] ?? json['is_edited'] ?? false,
      editedAt: json['editedAt'] != null || json['edited_at'] != null
          ? DateTime.parse(json['editedAt'] ?? json['edited_at'])
          : null,
      deliveryReceipt:
          json['deliveryReceipt'] != null || json['delivery_receipt'] != null
              ? DeliveryReceiptModel.fromJson(
                  json['deliveryReceipt'] ?? json['delivery_receipt'])
              : null,
    );
  }

  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'message_id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'message_type': messageType,
      if (content != null) 'content': content,
      if (location != null) 'location': location!.toJson(),
      if (replyToMessageId != null) 'reply_to_message_id': replyToMessageId,
      'reactions': reactions
          .map((reaction) => reaction is MessageReactionModel
              ? reaction.toJson()
              : MessageReactionModel(
                  id: reaction.id,
                  messageId: reaction.messageId,
                  userId: reaction.userId,
                  reactionType: reaction.reactionType,
                ).toJson())
          .toList(),
      'attachments': attachments
          .map((attachment) => attachment is AttachmentModel
              ? attachment.toJson()
              : AttachmentModel.fromEntity(attachment).toJson())
          .toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status,
      'is_edited': isEdited,
      if (editedAt != null) 'edited_at': editedAt!.toIso8601String(),
      if (deliveryReceipt != null)
        'delivery_receipt': (deliveryReceipt as DeliveryReceiptModel).toJson(),
    };
  }

  /// العربية: ينشئ مثيلًا جديدًا من `MessageModel.fromEntity`.
  factory MessageModel.fromEntity(Message message) {
    return MessageModel(
      id: message.id,
      conversationId: message.conversationId,
      senderId: message.senderId,
      messageType: message.messageType,
      content: message.content,
      location: message.location,
      replyToMessageId: message.replyToMessageId,
      reactions: message.reactions,
      attachments: message.attachments,
      createdAt: message.createdAt,
      updatedAt: message.updatedAt,
      status: message.status,
      isEdited: message.isEdited,
      editedAt: message.editedAt,
      deliveryReceipt: message.deliveryReceipt,
    );
  }
}

LocationModel? _parseLocation(Map<String, dynamic> json) {
  final rawLocation = json['location'] ??
      json['Location'] ??
      json['locationData'] ??
      json['location_data'] ??
      json['LocationData'];

  if (rawLocation is Map<String, dynamic>) {
    return LocationModel.fromJson(rawLocation);
  }

  if (rawLocation is Map) {
    return LocationModel.fromJson(Map<String, dynamic>.from(rawLocation));
  }

  if (rawLocation is String && rawLocation.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(rawLocation);
      if (decoded is Map<String, dynamic>) {
        return LocationModel.fromJson(decoded);
      }
      if (decoded is Map) {
        return LocationModel.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {}
  }

  final latitude = json['latitude'] ?? json['Latitude'] ?? json['lat'];
  final longitude =
      json['longitude'] ?? json['Longitude'] ?? json['lng'] ?? json['lon'];

  if (latitude is num && longitude is num) {
    return LocationModel(
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      address: json['address'] ?? json['Address'],
    );
  }

  return null;
}

List<AttachmentModel> _dedupeAttachments(List<AttachmentModel> attachments) {
  final seenIds = <String>{};
  final deduped = <AttachmentModel>[];

  for (final attachment in attachments) {
    final normalizedId = attachment.id.trim();
    if (normalizedId.isNotEmpty) {
      if (seenIds.add(normalizedId)) {
        deduped.add(attachment);
      }
      continue;
    }

    deduped.add(attachment);
  }

  return deduped;
}

/// العربية: يمثل نموذج البيانات `LocationModel`.
class LocationModel extends Location {
  /// العربية: ينشئ مثيلًا جديدًا من `LocationModel`.
  const LocationModel({
    required super.latitude,
    required super.longitude,
    super.address,
  });

  /// العربية: ينشئ مثيلًا جديدًا من `LocationModel.fromJson`.
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    final latitude = json['latitude'] ?? json['Latitude'];
    final longitude = json['longitude'] ?? json['Longitude'];

    return LocationModel(
      latitude: (latitude as num).toDouble(),
      longitude: (longitude as num).toDouble(),
      address: json['address'] ?? json['Address'] ?? json['placeName'],
    );
  }

  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (address != null) 'address': address,
    };
  }
}
