part of 'register_payment_bloc.dart';

/// العربية: يعرّف حالات واجهة تسجيل الدفعات من البدء إلى النجاح أو الفشل.
/// English: Defines payment-registration UI states from idle to success or failure.
abstract class RegisterPaymentState extends Equatable {
  /// العربية: ينشئ الأساس المشترك لحالات تسجيل الدفعات.
  /// English: Creates the shared base for payment-registration states.
  const RegisterPaymentState();

  /// العربية: لا توجد حقول مشتركة، وتُفوض المساواة للفئات الفرعية.
  /// English: No shared fields exist here, so equality is delegated to subclasses.
  @override
  List<Object?> get props => [];
}

/// العربية: تمثل حالة الانتظار قبل بدء تسجيل أي دفعة.
/// English: Represents the idle state before any payment registration starts.
class RegisterPaymentInitial extends RegisterPaymentState {}

/// العربية: تشير إلى أن عملية تسجيل الدفعة جارية الآن.
/// English: Indicates that the payment registration is currently in progress.
class RegisterPaymentLoading extends RegisterPaymentState {}

/// العربية: تمثل نجاح تسجيل الدفعة مع الاحتفاظ بالنتيجة المعتمدة.
/// English: Represents a successful payment registration with the confirmed result.
class RegisterPaymentSuccess extends RegisterPaymentState {
  /// العربية: الدفعة التي تم تسجيلها بنجاح.
  /// English: The payment that was successfully registered.
  final Payment payment;

  /// العربية: الرسالة التأكيدية الموجهة للمستخدم.
  /// English: The confirmation message shown to the user.
  final String successMessage;

  /// العربية: ينشئ حالة النجاح مع الدفعة ورسالة التأكيد.
  /// English: Creates the success state with the payment and confirmation message.
  const RegisterPaymentSuccess({
    required this.payment,
    required this.successMessage,
  });

  /// العربية: يعتمد على الدفعة ورسالة النجاح في المقارنة.
  /// English: Uses the payment and success message for equality.
  @override
  List<Object?> get props => [payment, successMessage];
}

/// العربية: تمثل فشل تسجيل الدفعة مع رسالة توضح السبب.
/// English: Represents a failed payment registration with an explanatory message.
class RegisterPaymentError extends RegisterPaymentState {
  /// العربية: الرسالة التي تشرح سبب الفشل.
  /// English: The message explaining the failure.
  final String message;

  /// العربية: ينشئ حالة الخطأ مع الرسالة المرتبطة بها.
  /// English: Creates the error state with its associated message.
  const RegisterPaymentError(this.message);

  /// العربية: يعتمد على رسالة الخطأ فقط.
  /// English: Uses the error message only for equality.
  @override
  List<Object> get props => [message];
}
