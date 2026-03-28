import 'package:equatable/equatable.dart';

/// الحدث الأساسي لجميع تفاعلات التحقق من البريد الإلكتروني.
/// Base event for all email verification interactions.
abstract class EmailVerificationEvent extends Equatable {
  /// العربية: يثبت أن أحداث التحقق تُقارن وفق بياناتها فقط.
  /// Ensures verification events compare only by the data they carry.
  const EmailVerificationEvent();

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [];
}

/// حدث يطلب تأكيد البريد الإلكتروني بالرمز المدخل.
/// Event that submits the verification code for confirmation.
class VerifyEmailSubmitted extends EmailVerificationEvent {
  /// معرف المستخدم المطلوب تفعيل بريده.
  /// Identifier of the user whose email should be verified.
  final String userId;

  /// البريد الإلكتروني المرتبط بعملية التحقق الحالية.
  /// Email address attached to the current verification flow.
  final String email;

  /// رمز التحقق الذي أدخله المستخدم.
  /// Verification code entered by the user.
  final String code;

  /// العربية: يضم بيانات التأكيد في حدث واحد قابل للإرسال إلى البلوك.
  /// Wraps the confirmation data into one event for the bloc to process.
  const VerifyEmailSubmitted({
    required this.userId,
    required this.email,
    required this.code,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [userId, email, code];
}

/// حدث يطلب إعادة إرسال رمز التحقق للمستخدم الحالي.
/// Event that asks the backend to resend the verification code.
class ResendCodePressed extends EmailVerificationEvent {
  /// معرف المستخدم الذي ستعاد له رسالة التحقق.
  /// User identifier that should receive the new verification message.
  final String userId;

  /// البريد الإلكتروني الهدف لإعادة الإرسال.
  /// Target email address for the resend request.
  final String email;

  /// العربية: يمثل طلب إعادة إرسال رمز التحقق.
  /// Represents a request to resend the verification code.
  const ResendCodePressed({required this.userId, required this.email});

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [userId, email];
}
