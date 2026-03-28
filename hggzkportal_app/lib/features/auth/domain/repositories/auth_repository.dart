import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_response.dart';
import '../entities/user.dart';

/// يعرّف الكلاس المجرد `AuthRepository`.
/// Describes the abstract `AuthRepository` class.
abstract class AuthRepository {
  /// Receives `login`.
  /// العربية: يعالج `login`.
  Future<Either<Failure, AuthResponse>> login({
    required String emailOrPhone,
    required String password,
    required bool rememberMe,
  });

  /// ينفذ العملية `register`.
  /// Runs the `register` operation.
  Future<Either<Failure, AuthResponse>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  });

  /// تسجيل مالك عقار جديد مع إنشاء عقار مرتبط
  /// ينفذ العملية `registerOwnerWithProperty`.
  /// Runs the `registerOwnerWithProperty` operation.
  Future<Either<Failure, AuthResponse>> registerOwnerWithProperty({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String propertyTypeId,
    required String propertyName,
    required String city,
    required String address,
    double? latitude,
    double? longitude,
    int starRating = 3,
    String? description,
    String? currency,
    List<Map<String, dynamic>>? walletAccounts,
  });

  /// ينفذ العملية `portalSocialLogin`.
  /// Runs the `portalSocialLogin` operation.
  Future<Either<Failure, AuthResponse>> portalSocialLogin({
    required String provider,
    required String token,
    String? nonce,
    String? name,
  });

  /// ينفذ العملية `completeOwnerProfile`.
  /// Runs the `completeOwnerProfile` operation.
  Future<Either<Failure, AuthResponse>> completeOwnerProfile({
    required String name,
    required String phone,
    required String propertyTypeId,
    required String propertyName,
    required String city,
    required String address,
    double? latitude,
    double? longitude,
    int starRating = 3,
    String? description,
    String? currency,
    List<Map<String, dynamic>>? walletAccounts,
  });

  /// ينفذ العملية `logout`.
  /// Runs the `logout` operation.
  Future<Either<Failure, void>> logout();

  /// ينفذ العملية `resetPassword`.
  /// Runs the `resetPassword` operation.
  Future<Either<Failure, void>> resetPassword({
    required String emailOrPhone,
  });

  /// ينفذ العملية `refreshToken`.
  /// Runs the `refreshToken` operation.
  Future<Either<Failure, AuthResponse>> refreshToken({
    required String refreshToken,
  });

  /// ينفذ العملية `getCurrentUser`.
  /// Runs the `getCurrentUser` operation.
  Future<Either<Failure, User>> getCurrentUser();

  /// ينفذ العملية `updateProfile`.
  /// Runs the `updateProfile` operation.
  Future<Either<Failure, void>> updateProfile({
    required String name,
    String? email,
    String? phone,
    List<Map<String, dynamic>>? walletAccounts,
    // Owner property fields
    String? propertyId,
    String? propertyName,
    String? propertyAddress,
    String? propertyCity,
    String? propertyShortDescription,
    String? propertyDescription,
    String? propertyCurrency,
    int? propertyStarRating,
    double? propertyLatitude,
    double? propertyLongitude,
  });

  /// ينفذ العملية `changePassword`.
  /// Runs the `changePassword` operation.
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });

  /// ينفذ العملية `deleteOwnerAccount`.
  /// Runs the `deleteOwnerAccount` operation.
  Future<Either<Failure, void>> deleteOwnerAccount({
    String? password,
    String? socialProvider,
    String? socialToken,
    String? socialNonce,
    String? reason,
  });

  /// ينفذ العملية `checkAuthStatus`.
  /// Runs the `checkAuthStatus` operation.
  Future<Either<Failure, bool>> checkAuthStatus();

  /// ينفذ العملية `saveAuthData`.
  /// Runs the `saveAuthData` operation.
  Future<void> saveAuthData(AuthResponse authResponse);

  /// ينفذ العملية `clearAuthData`.
  /// Runs the `clearAuthData` operation.
  Future<void> clearAuthData();

  /// ينفذ العملية `getAccessToken`.
  /// Runs the `getAccessToken` operation.
  Future<String?> getAccessToken();

  /// ينفذ العملية `getRefreshToken`.
  /// Runs the `getRefreshToken` operation.
  Future<String?> getRefreshToken();

  /// ينفذ العملية `uploadProfileImage`.
  /// Runs the `uploadProfileImage` operation.
  Future<Either<Failure, User>> uploadProfileImage({
    required String imagePath,
  });

  // Email verification
  /// ينفذ العملية `verifyEmail`.
  /// Runs the `verifyEmail` operation.
  Future<Either<Failure, bool>> verifyEmail({
    required String userId,
    required String code,
  });

  /// ينفذ العملية `resendEmailVerification`.
  /// Runs the `resendEmailVerification` operation.
  Future<Either<Failure, int?>> resendEmailVerification({
    required String userId,
    required String email,
  });
}
