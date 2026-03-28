import 'package:hggzkportal/features/chat/domain/entities/conversation.dart';

/// يعرّف الكلاس `ChatUserModel`.
/// Describes the `ChatUserModel` class.
class ChatUserModel extends ChatUser {
  /// Initializes a new `ChatUserModel` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `ChatUserModel`.
  const ChatUserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    super.profileImage,
    required super.userType,
    required super.status,
    super.lastSeen,
    super.propertyId,
    required super.isOnline,
  });

  /// ينشئ مثيلاً من `ChatUserModel`.
  /// Builds an instance of `ChatUserModel`.
  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      id: json['user_id'] ?? json['userId'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profileImage: json['profile_image'] ?? json['profileImage'],
      userType: json['user_type'] ?? json['userType'] ?? 'customer',
      status: json['status'] ?? 'offline',
      lastSeen: json['last_seen'] != null || json['lastSeen'] != null
          ? DateTime.parse(json['last_seen'] ?? json['lastSeen'])
          : null,
      propertyId: json['property_id'] ?? json['propertyId'],
      isOnline: json['is_online'] ?? json['isOnline'] ?? false,
    );
  }

  /// ينفذ العملية `toJson`.
  /// Runs the `toJson` operation.
  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      if (profileImage != null) 'profile_image': profileImage,
      'user_type': userType,
      'status': status,
      if (lastSeen != null) 'last_seen': lastSeen!.toIso8601String(),
      if (propertyId != null) 'property_id': propertyId,
      'is_online': isOnline,
    };
  }
}
