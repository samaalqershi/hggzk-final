import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/booking_details.dart';
import '../repositories/bookings_repository.dart';
import '../../../../../core/enums/payment_method_enum.dart';

/// يسجل دفعة جديدة مرتبطة بحجز قائم حتى تنعكس في سجل المدفوعات وحالة
/// الحجز المالية.
/// Registers a new payment linked to an existing booking so it appears in the
/// payment ledger and booking financial state.
class RegisterBookingPaymentUseCase
    implements UseCase<Payment, RegisterPaymentParams> {
  /// المستودع الذي ينفذ تسجيل الدفعة فعليًا.
  /// The repository that performs the actual payment registration.
  final BookingsRepository repository;

  /// Creates the booking-payment use case with the bookings repository.
  RegisterBookingPaymentUseCase(this.repository);
  @override

  /// يمرر معطيات الدفعة إلى المستودع ثم يعيد سجل الدفع الناتج.
  /// Forwards the payment details to the repository and returns the created
  /// payment record.
  Future<Either<Failure, Payment>> call(RegisterPaymentParams params) async {
    return await repository.registerBookingPayment(params);
  }
}

/// يجمع كل القيم اللازمة لإنشاء دفعة جديدة للحجز في طلب واحد immutable.
/// Collects all values needed to create a new booking payment inside one
/// immutable request object.
class RegisterPaymentParams extends Equatable {
  /// معرّف الحجز الذي ستُسجل عليه الدفعة.
  /// The booking identifier to attach the payment to.
  final String bookingId;

  /// المبلغ المدفوع فعليًا.
  /// The actual amount paid.
  final double amount;

  /// رمز العملة المستخدم في هذه الدفعة.
  /// The currency code used for this payment.
  final String currency;

  /// وسيلة الدفع المختارة مثل البطاقة أو النقد أو التحويل.
  /// The selected payment method, such as card, cash, or transfer.
  final PaymentMethod paymentMethod;

  /// رقم العملية أو المرجع الخارجي عند توفره.
  /// The transaction or external reference when available.
  final String? transactionId;

  /// ملاحظات اختيارية تشرح سبب الدفعة أو سياقها.
  /// Optional notes that explain the payment or its context.
  final String? notes;

  /// تاريخ تسجيل الدفعة عندما يختلف عن وقت الإنشاء الفعلي.
  /// The payment date when it differs from the actual creation time.
  final DateTime? paymentDate;

  /// Creates the immutable parameters required to register a booking payment.
  const RegisterPaymentParams({
    required this.bookingId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    this.transactionId,
    this.notes,
    this.paymentDate,
  });
  @override

  /// تعتمد المساواة على كل حقل لأن أي اختلاف فيها يعني دفعة مختلفة.
  /// Equality depends on every field because any difference produces a
  /// different payment request.
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
