import 'package:equatable/equatable.dart';
import 'package:hggzkportal/features/chat/domain/entities/message.dart';

/// يعرّف الكلاس `Conversation`.
/// Describes the `Conversation` class.
class Conversation extends Equatable {
  /// Holds the `id` value.
  /// العربية: يخزن القيمة `id`.
  final String id;

  /// يخزن العضو `conversationType`.
  /// Holds the `conversationType` member.
  final String conversationType; // "direct" or "group"
  /// يخزن العضو `title`.
  /// Holds the `title` member.
  final String? title;

  /// يخزن العضو `description`.
  /// Holds the `description` member.
  final String? description;

  /// يخزن العضو `avatar`.
  /// Holds the `avatar` member.
  final String? avatar;

  /// يخزن العضو `createdAt`.
  /// Holds the `createdAt` member.
  final DateTime createdAt;

  /// يخزن العضو `updatedAt`.
  /// Holds the `updatedAt` member.
  final DateTime updatedAt;

  /// يخزن العضو `lastMessage`.
  /// Holds the `lastMessage` member.
  final Message? lastMessage;

  /// يخزن العضو `unreadCount`.
  /// Holds the `unreadCount` member.
  final int unreadCount;

  /// يخزن العضو `isArchived`.
  /// Holds the `isArchived` member.
  final bool isArchived;

  /// يخزن العضو `isMuted`.
  /// Holds the `isMuted` member.
  final bool isMuted;

  /// يخزن العضو `propertyId`.
  /// Holds the `propertyId` member.
  final String? propertyId;

  /// يخزن العضو `participants`.
  /// Holds the `participants` member.
  final List<ChatUser> participants;

  /// ينشئ مثيلاً من `Conversation`.
  /// Builds an instance of `Conversation`.
  const Conversation({
    required this.id,
    required this.conversationType,
    this.title,
    this.description,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
    this.unreadCount = 0,
    this.isArchived = false,
    this.isMuted = false,
    this.propertyId,
    required this.participants,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [
        id,
        conversationType,
        title,
        description,
        avatar,
        createdAt,
        updatedAt,
        lastMessage,
        unreadCount,
        isArchived,
        isMuted,
        propertyId,
        participants,
      ];

  // Helper methods
  /// يعيد قيمة `isDirectChat`.
  /// Exposes the `isDirectChat` value.
  bool get isDirectChat => conversationType == 'direct';

  /// يعيد قيمة `isGroupChat`.
  /// Exposes the `isGroupChat` value.
  bool get isGroupChat => conversationType == 'group';

  /// يعيد قيمة `hasUnreadMessages`.
  /// Exposes the `hasUnreadMessages` value.
  bool get hasUnreadMessages => unreadCount > 0;

  // Get other participant in direct chat
  /// ينفذ العملية `getOtherParticipant`.
  /// Runs the `getOtherParticipant` operation.
  ChatUser? getOtherParticipant(String currentUserId) {
    if (!isDirectChat || participants.length != 2) return null;
    return participants.firstWhere((p) => p.id != currentUserId);
  }
}

/// يعرّف الكلاس `ChatUser`.
/// Describes the `ChatUser` class.
class ChatUser extends Equatable {
  /// Holds the `id` value.
  /// العربية: يخزن القيمة `id`.
  final String id;

  /// يخزن العضو `name`.
  /// Holds the `name` member.
  final String name;

  /// يخزن العضو `email`.
  /// Holds the `email` member.
  final String email;

  /// يخزن العضو `phone`.
  /// Holds the `phone` member.
  final String? phone;

  /// يخزن العضو `profileImage`.
  /// Holds the `profileImage` member.
  final String? profileImage;

  /// يخزن العضو `userType`.
  /// Holds the `userType` member.
  final String userType; // "admin", "property_owner", "customer"
  /// يخزن العضو `status`.
  /// Holds the `status` member.
  final String status; // "online", "offline", "away", "busy"
  /// يخزن العضو `lastSeen`.
  /// Holds the `lastSeen` member.
  final DateTime? lastSeen;

  /// يخزن العضو `propertyId`.
  /// Holds the `propertyId` member.
  final String? propertyId;

  /// يخزن العضو `isOnline`.
  /// Holds the `isOnline` member.
  final bool isOnline;

  /// ينشئ مثيلاً من `ChatUser`.
  /// Builds an instance of `ChatUser`.
  const ChatUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
    required this.userType,
    required this.status,
    this.lastSeen,
    this.propertyId,
    required this.isOnline,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        profileImage,
        userType,
        status,
        lastSeen,
        propertyId,
        isOnline,
      ];
}
