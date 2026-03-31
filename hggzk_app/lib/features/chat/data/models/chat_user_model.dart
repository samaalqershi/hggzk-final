import '../../domain/entities/conversation.dart';

/// العربية: يمثل نموذج البيانات `ChatUserModel`.
class ChatUserModel extends ChatUser {
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

  /// العربية: ينشئ مثيلًا جديدًا من `ChatUserModel.fromJson`.
  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      id: json['user_id'] ?? json['userId'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profileImage: _readFirstString(
        json,
        const [
          'profile_image',
          'profileImage',
          'profile_image_url',
          'profileImageUrl',
          'avatar',
          'avatar_url',
          'avatarUrl',
          'photo_url',
          'photoUrl',
          'image',
          'image_url',
          'imageUrl',
        ],
      ),
      userType: json['user_type'] ?? json['userType'] ?? 'customer',
      status: json['status'] ?? 'offline',
      lastSeen: json['last_seen'] != null || json['lastSeen'] != null
          ? DateTime.parse(json['last_seen'] ?? json['lastSeen'])
          : null,
      propertyId: json['property_id'] ?? json['propertyId'],
      isOnline: json['is_online'] ?? json['isOnline'] ?? false,
    );
  }

  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
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

String? _readFirstString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}
