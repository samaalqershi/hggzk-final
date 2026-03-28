import 'package:equatable/equatable.dart';

/// الحالة الأساسية لجميع مراحل التحقق من البريد الإلكتروني.
/// Base state for every step of the email verification flow.
abstract class EmailVerificationState extends Equatable {
  /// العربية: يثبت أن حالات التحقق تُقارن وفق البيانات التي تحملها فقط.
  /// Ensures verification states compare only by the data they carry.
  const EmailVerificationState();

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [];
}

/// الحالة الابتدائية قبل بدء أي إجراء.
/// Initial idle state before any verification action starts.
class EmailVerificationInitial extends EmailVerificationState {
  /// العربية: تمثل لحظة البداية قبل إرسال أي رمز.
  /// Represents the starting point before any code is sent.
  const EmailVerificationInitial();
}

/// حالة تحميل أثناء التحقق أو إعادة الإرسال.
/// Loading state while verifying or resending the code.
class EmailVerificationLoading extends EmailVerificationState {
  /// العربية: تعني أن التحقق أو إعادة الإرسال قيد التنفيذ.
  /// Indicates that verification or resend is in progress.
  const EmailVerificationLoading();
}

/// حالة نجاح عند اكتمال تأكيد البريد الإلكتروني.
/// Success state emitted when the email is verified.
class EmailVerificationSuccess extends EmailVerificationState {
  /// العربية: تعلن نجاح التحقق من البريد الإلكتروني.
  /// Announces that the email verification succeeded.
  const EmailVerificationSuccess();
}

/// حالة خطأ تحتوي على الرسالة المعروضة للمستخدم.
/// Error state carrying the user-facing failure message.
class EmailVerificationError extends EmailVerificationState {
  /// العربية: الرسالة النهائية التي يجب عرضها في الواجهة.
  /// Final message that should be shown in the UI.
  final String message;

  /// العربية: يسجل الفشل مع الرسالة المناسبة.
  /// Records the failure with the resolved message.
  const EmailVerificationError(this.message);

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [message];
}

/// حالة تؤكد نجاح إعادة الإرسال مع مدة الانتظار التالية.
/// State emitted after resend succeeds with the next retry cooldown.
class EmailVerificationCodeResent extends EmailVerificationState {
  /// العربية: عدد الثواني قبل السماح بمحاولة إعادة إرسال أخرى.
  /// Cooldown duration in seconds before another resend attempt.
  final int? retryAfterSeconds;

  /// العربية: يعلن أن إعادة إرسال الرمز تمت بنجاح.
  /// Announces that the resend code request succeeded.
  const EmailVerificationCodeResent({this.retryAfterSeconds});

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [retryAfterSeconds];
}
