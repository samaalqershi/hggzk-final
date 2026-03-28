import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_response.dart';
import '../entities/user.dart';

/// يعرّف العقد الذي تعتمد عليه طبقة المجال لتنفيذ عمليات المصادقة وإدارة
/// الجلسة من دون معرفة مصدر البيانات الفعلي.
/// Defines the contract used by the domain layer to perform authentication and
/// session-management operations without knowing the concrete data source.
abstract class AuthRepository {
  /// يسجل دخول المستخدم باستخدام بريد إلكتروني أو هاتف مع كلمة المرور.
  /// Signs the user in with email or phone plus password credentials.
  Future<Either<Failure, AuthResponse>> login({
    required String emailOrPhone,
    required String password,
    required bool rememberMe,
  });

  /// ينشئ حسابًا جديدًا ويعيد حمولة المصادقة الأولية عند النجاح.
  /// Registers a new account and returns the initial auth payload on success.
  Future<Either<Failure, AuthResponse>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  });

  /// ينهي الجلسة الحالية ويطلب من الطبقات السفلية تنظيف بياناتها إن لزم.
  /// Terminates the current session and lets lower layers clear stored auth
  /// data when needed.
  Future<Either<Failure, void>> logout();

  /// يبدأ مسار إعادة تعيين كلمة المرور باستخدام هوية المستخدم المدخلة.
  /// Starts the password-reset flow using the supplied user identifier.
  Future<Either<Failure, void>> resetPassword({
    required String emailOrPhone,
  });

  /// يجدد رموز الجلسة باستخدام رمز التحديث الحالي.
  /// Renews the active session tokens using the current refresh token.
  Future<Either<Failure, AuthResponse>> refreshToken({
    required String refreshToken,
  });

  /// ينفذ مصادقة اجتماعية عبر مزود خارجي مثل Google أو Apple.
  /// Performs social authentication through an external provider such as
  /// Google or Apple.
  Future<Either<Failure, AuthResponse>> socialLogin({
    required String provider,
    required String token,
    String? nonce,
    String? name,
  });

  /// يجلب أحدث نسخة من ملف المستخدم الحالي من المصدر المعتمد.
  /// Fetches the latest version of the current user's profile.
  Future<Either<Failure, User>> getCurrentUser();

  /// يحدث الحقول الأساسية في ملف المستخدم الشخصي.
  /// Updates the core fields of the user's profile.
  Future<Either<Failure, void>> updateProfile({
    required String name,
    String? email,
    String? phone,
  });

  /// يغير كلمة المرور بعد التحقق من الكلمة الحالية.
  /// Changes the password after validating the current password.
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });

  /// يحذف الحساب نهائيًا عبر إحدى وسائل التأكيد المتاحة.
  /// Permanently deletes the account using one of the supported confirmation
  /// methods.
  Future<Either<Failure, void>> deleteAccount({
    String? password,
    String? socialProvider,
    String? socialToken,
    String? socialNonce,
    String? reason,
  });

  /// يتحقق سريعًا من وجود جلسة صالحة أو إمكانية استعادتها.
  /// Quickly checks whether a valid session exists or can be restored.
  Future<Either<Failure, bool>> checkAuthStatus();

  /// يحفظ حمولة المصادقة محليًا لاستخدامها في الاستئناف والاعتراضات الشبكية.
  /// Persists the auth payload locally for resume flows and network
  /// interceptors.
  Future<void> saveAuthData(AuthResponse authResponse);

  /// يزيل كل بيانات المصادقة المخزنة محليًا.
  /// Clears every piece of locally stored authentication data.
  Future<void> clearAuthData();

  /// يعيد رمز الوصول المخزن إن كان موجودًا.
  /// Returns the cached access token when one exists.
  Future<String?> getAccessToken();

  /// يعيد رمز التحديث المخزن إن كان موجودًا.
  /// Returns the cached refresh token when one exists.
  Future<String?> getRefreshToken();

  /// يرفع صورة الملف الشخصي ويعيد نسخة المستخدم بعد تحديثها.
  /// Uploads a profile image and returns the updated user record.
  Future<Either<Failure, User>> uploadProfileImage({
    required String imagePath,
  });

  /// يتحقق من رمز تأكيد البريد الإلكتروني ويعيد ما إذا كانت العملية نجحت.
  /// Verifies an email confirmation code and reports whether it succeeded.
  Future<Either<Failure, bool>> verifyEmail({
    required String userId,
    required String code,
  });

  /// يطلب إعادة إرسال رمز التحقق ويعيد مدة الانتظار إن كانت متوفرة.
  /// Requests a new verification code and returns a retry delay when provided.
  Future<Either<Failure, int?>> resendEmailVerification({
    required String userId,
    required String email,
  });
}
