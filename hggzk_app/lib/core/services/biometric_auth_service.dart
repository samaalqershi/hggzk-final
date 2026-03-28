import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error_codes;
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// نتيجة موحدة لمسار التحقق الحيوي حتى تفهم بقية الطبقات النجاح والفشل
/// من دون الارتباط بتفاصيل `local_auth`.
/// Unified result for the biometric flow so higher layers can react to success
/// or failure without depending on `local_auth` details.
class BiometricAuthResult {
  /// يحدد ما إذا كان التحقق الحيوي قد اكتمل بنجاح.
  /// Indicates whether the biometric step completed successfully.
  final bool isSuccess;

  /// يشرح سبب الفشل أو يحمل ملاحظة مساعدة عند الحاجة.
  /// Carries the failure reason or an optional helper message.
  final String? message;

  /// ينشئ النتيجة الداخلية المشتركة التي تعتمد عليها حالات النجاح والفشل.
  /// Creates the shared internal result used by both success and failure cases.
  const BiometricAuthResult._(this.isSuccess, this.message);

  /// ينشئ نتيجة نجاح خالية من الرسائل الإضافية.
  /// Creates a success result with no extra message.
  const BiometricAuthResult.success() : this._(true, null);

  /// ينشئ نتيجة فشل مع الرسالة التي تساعد واجهة المستخدم على الرد.
  /// Creates a failure result with a message the UI can surface.
  const BiometricAuthResult.failure(String message) : this._(false, message);
}

/// يلف واجهة التحقق بالبصمة ويخفي تفاصيل التخزين الآمن ومزود القياس الحيوي.
/// Wraps biometric sign-in and hides the secure-storage and auth-provider details.
class BiometricAuthService {
  /// المزود الذي يتعامل مع البصمة والوجه وغيرها من وسائل التحقق الحيوي.
  /// Authentication plugin used for fingerprint, face, and other biometrics.
  final LocalAuthentication _localAuth;

  /// مساحة التخزين الآمنة التي تحفظ التوكن حتى لا يظل في الذاكرة العادية.
  /// Secure storage used to keep refresh tokens away from regular storage.
  final FlutterSecureStorage _secureStorage;

  /// المفتاح الثابت الذي نعتمد عليه عند حفظ التوكن المشفر محليًا.
  /// Stable key used to store the encrypted refresh token locally.
  static const String _refreshTokenKey = 'SECURE_REFRESH_TOKEN';

  /// ينشئ الخدمة مع السماح بحقن الاعتماديات في الاختبارات أو عند الاستبدال.
  /// Creates the service while allowing dependency injection for tests or swaps.
  BiometricAuthService({
    LocalAuthentication? localAuth,
    FlutterSecureStorage? secureStorage,
  })  : _localAuth = localAuth ?? LocalAuthentication(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// يتحقق مما إذا كان الجهاز يدعم أصلًا التحقق الحيوي قبل عرض خيار الدخول.
  /// Checks whether the device supports biometrics before the app exposes that option.
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// يختبر ما إذا كان النظام يسمح حاليًا بقراءة البصمات أو الوجه.
  /// Checks whether biometrics can be queried at the moment.
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  /// يعيد الأنواع الحيوية التي سجلها المستخدم على هذا الجهاز.
  /// Returns the biometric methods currently enrolled on the device.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// ينفذ طلب التحقق الحيوي ويحوّل الاستجابات التقنية إلى نتيجة مفهومة للواجهة.
  /// Runs the biometric prompt and converts platform responses into a UI-friendly result.
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

  /// يحفظ توكن التحديث داخل التخزين الآمن حتى يبقى خارج التخزين العادي.
  /// Stores the refresh token in secure storage instead of regular preferences.
  Future<void> saveRefreshTokenSecurely(String refreshToken) async {
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// يقرأ توكن التحديث من التخزين الآمن عند الحاجة لإكمال جلسة المستخدم.
  /// Reads the refresh token from secure storage when the session needs it.
  Future<String?> getSecureRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  /// يمسح التوكن الآمن عند تسجيل الخروج أو عند انتهاء صلاحيته.
  /// Removes the secure token during logout or when the session must end.
  Future<void> clearSecureRefreshToken() async {
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  /// يحول أخطاء النظام إلى رسائل عملية يمكن عرضها للمستخدم مباشرة.
  /// Maps platform exceptions into user-facing messages.
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
