import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// يرسل رمز التحقق إلى الخادم للتأكد من صحة البريد الإلكتروني وربط الحالة
/// الجديدة بجلسة المستخدم.
/// Sends the verification code to the backend to confirm the email address
/// and attach the updated status to the user session.
class VerifyEmailUseCase implements UseCase<bool, VerifyEmailParams> {
  /// المستودع الذي ينفذ طلب التحقق الفعلي.
  /// Repository that performs the actual email-verification request.
  final AuthRepository repository;

  /// ينشئ حالة الاستخدام مع مستودع المصادقة.
  /// Creates the use case with the auth repository.
  VerifyEmailUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(VerifyEmailParams params) {
    return repository.verifyEmail(
      userId: params.userId,
      code: params.code,
    );
  }
}

/// يحمل القيم المطلوبة للتحقق من البريد الإلكتروني.
/// Holds the values required to verify an email address.
class VerifyEmailParams {
  /// معرّف المستخدم الذي نريد تفعيل بريده الإلكتروني.
  /// Identifier of the user whose email should be verified.
  final String userId;

  /// الرمز الذي أدخله المستخدم من رسالة التحقق.
  /// Code entered by the user from the verification message.
  final String code;

  VerifyEmailParams({
    required this.userId,
    required this.code,
  });
}
