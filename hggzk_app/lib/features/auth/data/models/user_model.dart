import '../../domain/entities/user.dart';

/// يترجم بيانات المستخدم الخام القادمة من API إلى كيان `User`، مع معالجة
/// فروق التسمية بين الحقول وحالات التحقق غير المكتملة.
/// Maps raw user payloads from the API into the `User` entity while handling
/// field-name variations and incomplete verification data.
class UserModel extends User {
  /// ينشئ نموذج المستخدم مع الاعتماد على البنية القياسية لكيان المجال.
  /// Creates the user model by reusing the standardized domain-entity shape.
  const UserModel({
    required super.userId,
    required super.name,
    required super.email,
    required super.phone,
    required super.roles,
    super.profileImage,
    super.emailVerifiedAt,
    super.phoneVerifiedAt,
    required super.createdAt,
    required super.updatedAt,
  });

  /// يبني النموذج من JSON مع تطبيع الحقول البديلة التي قد تختلف بين
  /// نقاط النهاية.
  /// Builds the model from JSON while normalizing alternate field names that
  /// may vary across endpoints.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // The app determines verification via `emailVerifiedAt != null`.
    // Some backend responses (notably social-login) may return a boolean
    // `isEmailVerified` without an `emailVerifiedAt` timestamp.
    // In that case, synthesize a timestamp so routing guards don't
    // incorrectly force the email verification screen.
    final bool isEmailVerifiedFlag = json['isEmailVerified'] == true ||
        json['is_email_verified'] == true ||
        json['emailConfirmed'] == true ||
        json['email_confirmed'] == true;

    final DateTime? emailVerifiedAt = json['emailVerifiedAt'] != null
        ? DateTime.tryParse(json['emailVerifiedAt'].toString())
        : json['email_verified_at'] != null
            ? DateTime.tryParse(json['email_verified_at'].toString())
            : (isEmailVerifiedFlag ? DateTime.now() : null);

    return UserModel(
      userId: (json['userId'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? json['userName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? json['phoneNumber'] ?? '').toString(),
      roles: json['roles'] != null
          ? List<String>.from(json['roles'])
          : json['role'] != null
              ? [json['role'].toString()]
              : <String>[],
      profileImage: json['profileImage'] ??
          json['profile_image'] ??
          json['profileImageUrl'],
      emailVerifiedAt: emailVerifiedAt,
      phoneVerifiedAt: json['phoneVerifiedAt'] != null
          ? DateTime.tryParse(json['phoneVerifiedAt'])
          : json['phone_verified_at'] != null
              ? DateTime.tryParse(json['phone_verified_at'])
              : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : json['created_at'] != null
              ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
              : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at']) ?? DateTime.now()
              : DateTime.now(),
    );
  }

  /// يحول النموذج إلى JSON قابل للحفظ المحلي أو التمرير بين الطبقات.
  /// Converts the model back to JSON for local caching or inter-layer passing.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'roles': roles,
      'profileImage': profileImage,
      'emailVerifiedAt': emailVerifiedAt?.toIso8601String(),
      'phoneVerifiedAt': phoneVerifiedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// ينشئ النموذج من كيان مجال موجود عندما تحتاج طبقة البيانات لإعادة حفظه
  /// أو إرساله.
  /// Creates the model from an existing domain entity when the data layer
  /// needs to persist or resend it.
  factory UserModel.fromEntity(User user) {
    return UserModel(
      userId: user.userId,
      name: user.name,
      email: user.email,
      phone: user.phone,
      roles: user.roles,
      profileImage: user.profileImage,
      emailVerifiedAt: user.emailVerifiedAt,
      phoneVerifiedAt: user.phoneVerifiedAt,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }
}
