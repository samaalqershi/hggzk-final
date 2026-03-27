import 'package:equatable/equatable.dart';

/// Arabic: الحالة الأساسية لجميع مراحل التحقق من البريد الإلكتروني.
/// English: Base state for every step of the email verification flow.
abstract class EmailVerificationState extends Equatable {
  const EmailVerificationState();

  @override
  List<Object?> get props => [];
}

/// Arabic: الحالة الابتدائية قبل بدء أي إجراء.
/// English: Initial idle state before any verification action starts.
class EmailVerificationInitial extends EmailVerificationState {
  const EmailVerificationInitial();
}

/// Arabic: حالة تحميل أثناء التحقق أو إعادة الإرسال.
/// English: Loading state while verifying or resending the code.
class EmailVerificationLoading extends EmailVerificationState {
  const EmailVerificationLoading();
}

/// Arabic: حالة نجاح عند اكتمال تأكيد البريد الإلكتروني.
/// English: Success state emitted when the email is verified.
class EmailVerificationSuccess extends EmailVerificationState {
  const EmailVerificationSuccess();
}

/// Arabic: حالة خطأ تحتوي على الرسالة المعروضة للمستخدم.
/// English: Error state carrying the user-facing failure message.
class EmailVerificationError extends EmailVerificationState {
  /// Arabic: الرسالة النهائية المراد عرضها في الواجهة.
  /// English: Final message that should be shown in the UI.
  final String message;

  /// Arabic: ينشئ حالة فشل مع الرسالة المناسبة.
  /// English: Creates an error state with the resolved message.
  const EmailVerificationError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Arabic: حالة تؤكد نجاح إعادة الإرسال مع مدة الانتظار التالية.
/// English: State emitted after resend succeeds with the next retry cooldown.
class EmailVerificationCodeResent extends EmailVerificationState {
  /// Arabic: عدد الثواني قبل السماح بمحاولة إعادة إرسال أخرى.
  /// English: Cooldown duration in seconds before another resend attempt.
  final int? retryAfterSeconds;

  /// Arabic: ينشئ حالة نجاح إعادة إرسال الرمز.
  /// English: Creates the resend-success state.
  const EmailVerificationCodeResent({this.retryAfterSeconds});

  @override
  List<Object?> get props => [retryAfterSeconds];
}
