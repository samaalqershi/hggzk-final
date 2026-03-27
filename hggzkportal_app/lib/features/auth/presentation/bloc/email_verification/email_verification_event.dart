import 'package:equatable/equatable.dart';

/// Arabic: الحدث الأساسي لجميع تفاعلات التحقق من البريد الإلكتروني.
/// English: Base event for all email verification interactions.
abstract class EmailVerificationEvent extends Equatable {
  const EmailVerificationEvent();

  @override
  List<Object?> get props => [];
}

/// Arabic: حدث يطلب تأكيد البريد الإلكتروني بالرمز المدخل.
/// English: Event that submits the verification code for confirmation.
class VerifyEmailSubmitted extends EmailVerificationEvent {
  /// Arabic: معرف المستخدم المطلوب تفعيل بريده.
  /// English: Identifier of the user whose email should be verified.
  final String userId;

  /// Arabic: البريد الإلكتروني المرتبط بعملية التحقق الحالية.
  /// English: Email address attached to the current verification flow.
  final String email;

  /// Arabic: رمز التحقق الذي أدخله المستخدم.
  /// English: Verification code entered by the user.
  final String code;

  /// Arabic: ينشئ حدث إرسال رمز التحقق.
  /// English: Creates a verification-submit event.
  const VerifyEmailSubmitted({
    required this.userId,
    required this.email,
    required this.code,
  });

  @override
  List<Object?> get props => [userId, email, code];
}

/// Arabic: حدث يطلب إعادة إرسال رمز التحقق للمستخدم الحالي.
/// English: Event that asks the backend to resend the verification code.
class ResendCodePressed extends EmailVerificationEvent {
  /// Arabic: معرف المستخدم الذي ستعاد له رسالة التحقق.
  /// English: User identifier that should receive the new verification message.
  final String userId;

  /// Arabic: البريد الإلكتروني الهدف لإعادة الإرسال.
  /// English: Target email address for the resend request.
  final String email;

  /// Arabic: ينشئ حدث إعادة إرسال رمز التحقق.
  /// English: Creates a resend-verification-code event.
  const ResendCodePressed({required this.userId, required this.email});

  @override
  List<Object?> get props => [userId, email];
}
