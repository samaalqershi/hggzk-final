import 'package:equatable/equatable.dart';

/// يمثل لقطات حالة التحقق بالبريد الإلكتروني كما تراها الواجهة.
/// Represents email-verification state snapshots as seen by the UI.
abstract class EmailVerificationState extends Equatable {
  const EmailVerificationState();
  @override
  List<Object?> get props => [];
}

/// الحالة الابتدائية قبل إرسال أي رمز أو طلب.
/// Initial state before any verification action runs.
class EmailVerificationInitial extends EmailVerificationState {
  const EmailVerificationInitial();
}

/// تشير إلى أن عملية تحقق أو إعادة إرسال قيد التنفيذ.
/// Indicates that verification or resend work is currently in progress.
class EmailVerificationLoading extends EmailVerificationState {
  const EmailVerificationLoading();
}

/// تؤكد نجاح التحقق من البريد الإلكتروني.
/// Confirms that email verification succeeded.
class EmailVerificationSuccess extends EmailVerificationState {
  const EmailVerificationSuccess();
}

/// تحمل رسالة خطأ مرتبطة بعملية التحقق أو إعادة الإرسال.
/// Carries an error message related to verification or resend attempts.
class EmailVerificationError extends EmailVerificationState {
  final String message;
  const EmailVerificationError(this.message);
  @override
  List<Object?> get props => [message];
}

/// تؤكد إعادة إرسال الرمز وتعيد مهلة الانتظار عند الحاجة.
/// Confirms that a new code was sent and exposes any retry wait time.
class EmailVerificationCodeResent extends EmailVerificationState {
  final int? retryAfterSeconds;
  const EmailVerificationCodeResent({this.retryAfterSeconds});
  @override
  List<Object?> get props => [retryAfterSeconds];
}
