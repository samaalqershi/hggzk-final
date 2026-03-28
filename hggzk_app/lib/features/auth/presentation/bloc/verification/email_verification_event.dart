import 'package:equatable/equatable.dart';

/// يمثل الأحداث القادمة من واجهة التحقق بالبريد الإلكتروني.
/// Represents the events emitted by the email-verification UI.
abstract class EmailVerificationEvent extends Equatable {
  const EmailVerificationEvent();
  @override
  List<Object?> get props => [];
}

/// يحمل الرمز الذي أدخله المستخدم لإتمام التحقق.
/// Carries the code entered by the user to complete verification.
class VerifyEmailSubmitted extends EmailVerificationEvent {
  final String userId;
  final String email;
  final String code;
  const VerifyEmailSubmitted({
    required this.userId,
    required this.email,
    required this.code,
  });
  @override
  List<Object?> get props => [userId, email, code];
}

/// يطلب إعادة إرسال رمز التحقق إلى البريد الحالي.
/// Requests resending the verification code to the current email address.
class ResendCodePressed extends EmailVerificationEvent {
  final String userId;
  final String email;
  const ResendCodePressed({
    required this.userId,
    required this.email,
  });
  @override
  List<Object?> get props => [userId, email];
}
