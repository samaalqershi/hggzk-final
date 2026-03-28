import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// يطلب إعادة إرسال رمز تحقق البريد عندما يحتاج المستخدم رمزًا جديدًا.
/// Requests a new email-verification code when the user needs another one.
class ResendEmailVerificationUseCase
    implements UseCase<int?, ResendEmailVerificationParams> {
  /// المستودع الذي يتولى طلب إعادة الإرسال من الخادم.
  /// Repository that asks the backend to resend the verification code.
  final AuthRepository repository;

  /// ينشئ حالة الاستخدام مع مستودع المصادقة.
  /// Creates the use case with the auth repository.
  ResendEmailVerificationUseCase(this.repository);

  @override
  Future<Either<Failure, int?>> call(ResendEmailVerificationParams params) {
    return repository.resendEmailVerification(
      userId: params.userId,
      email: params.email,
    );
  }
}

/// يحمل بيانات المستخدم المطلوبة لإعادة إرسال رمز التحقق.
/// Carries the user identifiers required to resend a verification code.
class ResendEmailVerificationParams {
  /// معرّف المستخدم الذي سيستقبل الرمز الجديد.
  /// Identifier of the user who should receive the new code.
  final String userId;

  /// البريد الإلكتروني الذي سيُرسل إليه الرمز.
  /// Email address to which the new verification code should be sent.
  final String email;

  ResendEmailVerificationParams({
    required this.userId,
    required this.email,
  });
}
