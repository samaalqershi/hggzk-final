import '../../domain/entities/message.dart';

/// العربية: يمثل نموذج البيانات `MessageReactionModel`.
class MessageReactionModel extends MessageReaction {
  /// العربية: ينشئ مثيلًا جديدًا من `MessageReactionModel`.
  const MessageReactionModel({
    required super.id,
    required super.messageId,
    required super.userId,
    required super.reactionType,
  });

  /// العربية: ينشئ مثيلًا جديدًا من `MessageReactionModel.fromJson`.
  factory MessageReactionModel.fromJson(Map<String, dynamic> json) {
    return MessageReactionModel(
      id: json['id'] ?? '',
      messageId: json['messageId'] ?? json['message_id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      reactionType: json['reactionType'] ?? json['reaction_type'] ?? '',
    );
  }

  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message_id': messageId,
      'user_id': userId,
      'reaction_type': reactionType,
    };
  }
}
