part of 'register_payment_bloc.dart';

/// العربية: يعرّف أحداث تسجيل الدفعات من الإرسال إلى إعادة الضبط.
/// English: Defines payment-registration events from submission to reset.
abstract class RegisterPaymentEvent extends Equatable {
  /// العربية: ينشئ الأساس المشترك لأحداث تسجيل الدفعات.
  /// English: Creates the shared base for payment-registration events.
  const RegisterPaymentEvent();

  /// العربية: لا توجد حقول مشتركة، وتُفوض المساواة للفئات الفرعية.
  /// English: No shared fields exist here, so equality is delegated to subclasses.
  @override
  List<Object?> get props => [];
}

/// العربية: يطلب تسجيل دفعة جديدة مرتبطة بحجز محدد.
/// English: Requests a new payment registration for a specific booking.
class RegisterNewPaymentEvent extends RegisterPaymentEvent {
  /// العربية: معرّف الحجز الذي ستُسجل له الدفعة.
  /// English: The booking identifier that receives the payment.
  final String bookingId;

  /// العربية: قيمة الدفعة المراد تسجيلها.
  /// English: The payment amount to register.
  final double amount;

  /// العربية: العملة المستخدمة في الدفعة.
  /// English: The currency used for the payment.
  final String currency;

  /// العربية: طريقة الدفع المختارة.
  /// English: The selected payment method.
  final PaymentMethod paymentMethod;

  /// العربية: معرّف العملية الخارجية عند توفره.
  /// English: The external transaction identifier when available.
  final String? transactionId;

  /// العربية: ملاحظات إضافية مرتبطة بالدفعة.
  /// English: Additional notes associated with the payment.
  final String? notes;

  /// العربية: تاريخ الدفعة عند رغبته في الإرسال من الواجهة.
  /// English: The payment date when supplied by the UI.
  final DateTime? paymentDate;

  /// العربية: ينشئ طلب تسجيل الدفعة بجميع القيم الأساسية والاختيارية.
  /// English: Creates the payment registration request with required and optional values.
  const RegisterNewPaymentEvent({
    required this.bookingId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    this.transactionId,
    this.notes,
    this.paymentDate,
  });

  /// Uses every submitted payment field so duplicate events compare correctly.
  ///
  /// يعتمد على جميع حقول الدفعة المرسلة حتى تعمل المقارنة القيمية بشكل صحيح.
  @override
  List<Object?> get props => [
        bookingId,
        amount,
        currency,
        paymentMethod,
        transactionId,
        notes,
        paymentDate,
      ];
}

/// العربية: يعيد نموذج تسجيل الدفعة إلى حالته الابتدائية.
/// English: Resets the payment-registration form back to its initial state.
class ResetRegisterPaymentEvent extends RegisterPaymentEvent {}
