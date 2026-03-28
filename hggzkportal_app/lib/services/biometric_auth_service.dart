import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error_codes;
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Captures the outcome of a biometric prompt without forcing callers to deal
/// with platform exceptions directly.
/// يلتقط نتيجة تحقق البصمة من دون أن يضطر المستدعي للتعامل مع استثناءات
/// المنصة مباشرة.
class BiometricAuthResult {
  /// Whether the biometric step succeeded.
  /// هل نجحت خطوة التحقق بالبصمة.
  final bool isSuccess;

  /// Human-readable explanation used when biometric auth fails.
  /// رسالة توضيحية تُستخدم عند فشل التحقق.
  final String? message;

  /// Internal constructor used by the success and failure factories.
  /// مُنشئ داخلي تستخدمه دوال الإنشاء الخاصة بالنجاح والفشل.
  const BiometricAuthResult._(this.isSuccess, this.message);

  /// Marks the biometric flow as successful.
  /// يحدد أن مسار البصمة نجح.
  const BiometricAuthResult.success() : this._(true, null);

  /// Marks the biometric flow as failed and keeps the reason for the caller.
  /// يحدد أن مسار البصمة فشل مع الاحتفاظ بالسبب للمستدعي.
  const BiometricAuthResult.failure(String message) : this._(false, message);
}

/// Coordinates device biometric checks and secure refresh-token storage for
/// flows that need local re-authentication.
/// ينسق فحوصات البصمة وتخزين refresh token بأمان للسيناريوهات التي تحتاج
/// إعادة تحقق محلية.
class BiometricAuthService {
  /// Native biometric plugin used for capability checks and prompts.
  /// مكوّن البصمة الأصلي المستخدم لفحص الدعم وعرض طلب التحقق.
  final LocalAuthentication _localAuth;

  /// Encrypted storage used for sensitive session data such as refresh tokens.
  /// التخزين المشفّر المستخدم للبيانات الحساسة مثل refresh token.
  final FlutterSecureStorage _secureStorage;

  /// Storage key under which the refresh token is persisted.
  /// المفتاح الذي يُحفظ تحته refresh token.
  static const String _refreshTokenKey = 'SECURE_REFRESH_TOKEN';

  /// Injects the biometric and secure-storage collaborators, falling back to
  /// their default implementations when the caller does not provide them.
  /// يحقن مكوّنات البصمة والتخزين الآمن مع الرجوع إلى التنفيذات الافتراضية
  /// عند عدم تمريرها.
  BiometricAuthService({
    LocalAuthentication? localAuth,
    FlutterSecureStorage? secureStorage,
  })  : _localAuth = localAuth ?? LocalAuthentication(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Checks whether the current device supports biometric authentication.
  /// يتحقق من أن الجهاز الحالي يدعم التحقق بالبصمة.
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Checks whether at least one biometric modality is available for use.
  /// يتحقق من توفر وسيلة بصمة واحدة على الأقل.
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  /// Lists the biometrics that the device can currently use.
  /// يسرد وسائل البصمة المتاحة حاليًا على الجهاز.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Runs a biometric prompt and converts platform failures into a stable
  /// result object the UI can render.
  /// يشغّل طلب البصمة ويحوّل أخطاء المنصة إلى نتيجة مستقرة يمكن للواجهة
  /// عرضها.
  Future<BiometricAuthResult> authenticate({
    String reason = 'تأكيد الهوية بالبصمة',
  }) async {
    try {
      if (!await isDeviceSupported()) {
        return const BiometricAuthResult.failure(
          'جهازك لا يدعم تسجيل الدخول بالبصمة.',
        );
      }

      if (!await canCheckBiometrics()) {
        final available = await getAvailableBiometrics();
        if (available.isEmpty) {
          return const BiometricAuthResult.failure(
            'قم بإعداد بصمة الإصبع أو التعرف على الوجه في إعدادات الجهاز أولاً.',
          );
        }
      }

      final didAuth = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      return didAuth
          ? const BiometricAuthResult.success()
          : const BiometricAuthResult.failure('لم يتم تأكيد الهوية.');
    } on PlatformException catch (e) {
      return BiometricAuthResult.failure(_mapPlatformException(e));
    }
  }

  /// Persists the refresh token in encrypted storage so the app can restore a
  /// session without exposing the token in plain text.
  /// يحفظ refresh token في تخزين مشفّر حتى يمكن استعادة الجلسة دون كشفه
  /// كنص صريح.
  Future<void> saveRefreshTokenSecurely(String refreshToken) async {
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Reads the encrypted refresh token when the app needs to resume a session.
  /// يقرأ refresh token المشفّر عندما يحتاج التطبيق إلى استئناف جلسة.
  Future<String?> getSecureRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  /// Removes the stored refresh token during logout or session invalidation.
  /// يحذف refresh token المخزن عند تسجيل الخروج أو إبطال الجلسة.
  Future<void> clearSecureRefreshToken() async {
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  /// Converts platform error codes into a message that the app can surface
  /// directly to the user.
  /// يحول رموز أخطاء المنصة إلى رسالة يمكن للتطبيق عرضها مباشرة للمستخدم.
  String _mapPlatformException(PlatformException exception) {
    switch (exception.code) {
      case auth_error_codes.notAvailable:
        return 'ميزة البصمة غير متوفرة على هذا الجهاز.';
      case auth_error_codes.notEnrolled:
        return 'لم يتم تسجيل أي بصمة. يرجى إضافة بصمة في إعدادات الجهاز.';
      case auth_error_codes.lockedOut:
      case auth_error_codes.permanentlyLockedOut:
        return 'تجاوزت عدد المحاولات المسموح بها. استخدم كلمة المرور أو افتح قفل الجهاز أولاً.';
      default:
        return exception.message ?? 'فشل التحقق بالبصمة.';
    }
  }
}
