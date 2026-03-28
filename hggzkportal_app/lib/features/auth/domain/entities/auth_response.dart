import 'package:equatable/equatable.dart';
import 'user.dart';

/// يعرّف الكلاس `AuthResponse`.
/// Describes the `AuthResponse` class.
class AuthResponse extends Equatable {
  /// Holds the `user` value.
  /// العربية: يخزن القيمة `user`.
  final User user;

  /// يخزن العضو `accessToken`.
  /// Holds the `accessToken` member.
  final String accessToken;

  /// يخزن العضو `refreshToken`.
  /// Holds the `refreshToken` member.
  final String refreshToken;

  /// يخزن العضو `expiresAt`.
  /// Holds the `expiresAt` member.
  final DateTime? expiresAt;

  /// ينشئ مثيلاً من `AuthResponse`.
  /// Builds an instance of `AuthResponse`.
  const AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.expiresAt,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [user, accessToken, refreshToken, expiresAt];
}
