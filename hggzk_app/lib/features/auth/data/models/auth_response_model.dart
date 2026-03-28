import '../../domain/entities/auth_response.dart';
import 'user_model.dart';

/// يترجم استجابة المصادقة الخام من الخادم إلى تمثيل موحد يمكن لبقية طبقات
/// التطبيق الاعتماد عليه.
/// Converts raw authentication responses from the backend into a normalized
/// representation consumable by the rest of the app.
class AuthResponseModel extends AuthResponse {
  /// ينشئ النموذج مع الحقول الأساسية للجلسة والمستخدم.
  /// Creates the model with the essential user and session fields.
  const AuthResponseModel({
    required super.user,
    required super.accessToken,
    required super.refreshToken,
    super.expiresAt,
  });

  /// يبني النموذج من JSON مع دعم أكثر من شكل للحمولة كما تأتي من نقاط النهاية
  /// المختلفة.
  /// Builds the model from JSON while supporting multiple payload shapes used
  /// by different authentication endpoints.
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // Tokens from Common AuthResultDto or Client DTOs
    final accessToken = json['accessToken'] ?? json['newAccessToken'] ?? '';
    final refreshToken = json['refreshToken'] ?? json['newRefreshToken'] ?? '';

    // User identity fields may be flat in payload
    final userJson = <String, dynamic>{
      'userId': json['userId'] ?? json['id'],
      'name': json['name'] ?? json['userName'],
      'email': json['email'],
      'phone': json['phone'] ?? json['phoneNumber'] ?? '',
      'roles': json['roles'] ?? (json['role'] != null ? [json['role']] : []),
    };

    DateTime? expiresAt;
    if (json['expiresAt'] != null) {
      expiresAt = DateTime.tryParse(json['expiresAt']);
    } else if (json['accessTokenExpiry'] != null) {
      expiresAt = DateTime.tryParse(json['accessTokenExpiry']);
    } else if (json['expiresIn'] != null) {
      final int seconds = json['expiresIn'] is int
          ? json['expiresIn']
          : int.tryParse(json['expiresIn'].toString()) ?? 0;
      if (seconds > 0) {
        expiresAt = DateTime.now().add(Duration(seconds: seconds));
      }
    }

    return AuthResponseModel(
      user: UserModel.fromJson(userJson),
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
  }

  /// يحول النموذج إلى JSON لتخزينه محليًا أو إعادة استخدامه داخل التطبيق.
  /// Converts the model to JSON for local caching or reuse inside the app.
  Map<String, dynamic> toJson() {
    return {
      'userId': user.userId,
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'roles': user.roles,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  /// ينشئ نموذج بيانات من كيان المجال عندما نحتاج تمريره إلى طبقة التخزين.
  /// Creates a data model from the domain entity when it needs to be cached.
  factory AuthResponseModel.fromEntity(AuthResponse authResponse) {
    return AuthResponseModel(
      user: authResponse.user,
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
      expiresAt: authResponse.expiresAt,
    );
  }
}
