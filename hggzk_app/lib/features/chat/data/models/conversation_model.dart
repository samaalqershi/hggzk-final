import 'chat_user_model.dart';

import '../../domain/entities/conversation.dart';
import 'message_model.dart';

/// العربية: يمثل نموذج البيانات `ConversationModel`.
class ConversationModel extends Conversation {
  /// العربية: ينشئ مثيلًا جديدًا من `ConversationModel`.
  const ConversationModel({
    required super.id,
    required super.conversationType,
    super.title,
    super.description,
    super.avatar,
    required super.createdAt,
    required super.updatedAt,
    super.lastMessage,
    super.unreadCount,
    super.isArchived,
    super.isMuted,
    super.propertyId,
    required super.participants,
  });

  /// العربية: ينشئ مثيلًا جديدًا من `ConversationModel.fromJson`.
  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['conversation_id'] ?? json['id'] ?? '',
      conversationType:
          json['conversationType'] ?? json['conversation_type'] ?? 'direct',
      title: json['title'],
      description: json['description'],
      avatar: _readConversationImage(
        json,
        const [
          'avatar',
          'avatar_url',
          'avatarUrl',
          'image',
          'image_url',
          'imageUrl',
          'profile_image',
          'profileImage',
        ],
      ),
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
      updatedAt: DateTime.parse(json['updatedAt'] ?? json['updated_at']),
      lastMessage: json['lastMessage'] != null || json['last_message'] != null
          ? MessageModel.fromJson(json['lastMessage'] ?? json['last_message'])
          : null,
      unreadCount: json['unreadCount'] ?? json['unread_count'] ?? 0,
      isArchived: json['isArchived'] ?? json['is_archived'] ?? false,
      isMuted: json['isMuted'] ?? json['is_muted'] ?? false,
      propertyId: json['propertyId'] ?? json['property_id'],
      participants: (json['participants'] as List? ?? [])
          .map((p) => ChatUserModel.fromJson(p))
          .toList(),
    );
  }

  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'conversation_id': id,
      'conversation_type': conversationType,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (avatar != null) 'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (lastMessage != null)
        'last_message': (lastMessage as MessageModel).toJson(),
      'unread_count': unreadCount,
      'is_archived': isArchived,
      'is_muted': isMuted,
      if (propertyId != null) 'property_id': propertyId,
      'participants':
          participants.map((p) => (p as ChatUserModel).toJson()).toList(),
    };
  }

  /// العربية: ينشئ مثيلًا جديدًا من `ConversationModel.fromEntity`.
  factory ConversationModel.fromEntity(Conversation conversation) {
    return ConversationModel(
      id: conversation.id,
      conversationType: conversation.conversationType,
      title: conversation.title,
      description: conversation.description,
      avatar: conversation.avatar,
      createdAt: conversation.createdAt,
      updatedAt: conversation.updatedAt,
      lastMessage: conversation.lastMessage,
      unreadCount: conversation.unreadCount,
      isArchived: conversation.isArchived,
      isMuted: conversation.isMuted,
      propertyId: conversation.propertyId,
      participants: conversation.participants,
    );
  }
}

String? _readConversationImage(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}
