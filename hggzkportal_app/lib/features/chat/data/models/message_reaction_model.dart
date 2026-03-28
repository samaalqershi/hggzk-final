import 'package:hggzkportal/features/chat/domain/entities/message.dart';

/// يعرّف الكلاس `MessageReactionModel`.
/// Describes the `MessageReactionModel` class.
class MessageReactionModel extends MessageReaction {
  /// Initializes a new `MessageReactionModel` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `MessageReactionModel`.
  const MessageReactionModel({
    required super.id,
    required super.messageId,
    required super.userId,
    required super.reactionType,
  });

  /// ينشئ مثيلاً من `MessageReactionModel`.
  /// Builds an instance of `MessageReactionModel`.
  factory MessageReactionModel.fromJson(Map<String, dynamic> json) {
    return MessageReactionModel(
      id: json['id'] ?? '',
      messageId: json['messageId'] ?? json['message_id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      reactionType: json['reactionType'] ?? json['reaction_type'] ?? '',
    );
  }

  /// ينفذ العملية `toJson`.
  /// Runs the `toJson` operation.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message_id': messageId,
      'user_id': userId,
      'reaction_type': reactionType,
    };
  }
}
