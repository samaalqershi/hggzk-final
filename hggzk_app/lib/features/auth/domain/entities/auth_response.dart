import 'package:equatable/equatable.dart';
import 'user.dart';

/// يمثل الحمولة الأساسية التي تعود بعد نجاح المصادقة، وتشمل بيانات المستخدم
/// والرموز اللازمة للجلسة الحالية وتحديثها لاحقًا.
/// Represents the core payload returned after successful authentication,
/// including user data and the tokens required for the current session.
class AuthResponse extends Equatable {
  /// بيانات المستخدم التي يجب أن تتوفر مباشرة بعد المصادقة.
  /// User data that should be available immediately after authentication.
  final User user;

  /// رمز الوصول المستخدم للطلبات المحمية.
  /// Access token used for authenticated API requests.
  final String accessToken;

  /// رمز التحديث المستخدم لتجديد الجلسة عند انتهاء صلاحية رمز الوصول.
  /// Refresh token used to renew the session when the access token expires.
  final String refreshToken;

  /// وقت انتهاء صلاحية الجلسة إن كان الخادم يرسله بشكل صريح.
  /// Session expiry timestamp when the backend provides it explicitly.
  final DateTime? expiresAt;

  /// ينشئ استجابة مصادقة موحدة يمكن تداولها بين الطبقات المختلفة.
  /// Creates a normalized authentication response that can flow across layers.
  const AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.expiresAt,
  });

  @override
  List<Object?> get props => [user, accessToken, refreshToken, expiresAt];
}
