import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/enums/payment_method_enum.dart';
import '../../../domain/entities/booking_details.dart';
import '../../../domain/usecases/register_booking_payment.dart';

part 'register_payment_event.dart';
part 'register_payment_state.dart';

/// العربية: يدير تسجيل الدفعات للحجوزات ويربط الإرسال وإعادة الضبط بحالات واضحة.
/// English: Manages payment registration for bookings and connects submission and reset flows to clear states.
class RegisterPaymentBloc
    extends Bloc<RegisterPaymentEvent, RegisterPaymentState> {
  /// العربية: ينفذ عملية تسجيل الدفعة من خلال حالة الاستخدام المعتمدة.
  /// English: Executes the payment registration through the injected use case.
  final RegisterBookingPaymentUseCase registerBookingPaymentUseCase;

  /// العربية: ينشئ BLoC تسجيل الدفعات ويربط الأحداث بمعالجاتها.
  /// English: Creates the payment-registration bloc and binds events to their handlers.
  RegisterPaymentBloc({
    required this.registerBookingPaymentUseCase,
  }) : super(RegisterPaymentInitial()) {
    on<RegisterNewPaymentEvent>(_onRegisterNewPayment);
    on<ResetRegisterPaymentEvent>(_onResetRegisterPayment);
  }

  /// العربية: يرسل طلب تسجيل الدفعة ويحوّل النتيجة إلى حالة نجاح أو خطأ.
  /// English: Submits the payment registration request and maps the result to success or error states.
  Future<void> _onRegisterNewPayment(
    RegisterNewPaymentEvent event,
    Emitter<RegisterPaymentState> emit,
  ) async {
    emit(RegisterPaymentLoading());

    final params = RegisterPaymentParams(
      bookingId: event.bookingId,
      amount: event.amount,
      currency: event.currency,
      paymentMethod: event.paymentMethod,
      transactionId: event.transactionId,
      notes: event.notes,
      paymentDate: event.paymentDate,
    );

    final result = await registerBookingPaymentUseCase(params);

    result.fold(
      (failure) => emit(RegisterPaymentError(failure.message)),
      (payment) => emit(
        RegisterPaymentSuccess(
          payment: payment,
          successMessage: 'تم تسجيل الدفعة بنجاح',
        ),
      ),
    );
  }

  /// العربية: يعيد نموذج تسجيل الدفعة إلى الحالة الابتدائية بعد الإلغاء أو الانتهاء.
  /// English: Returns the payment-registration form to its initial state after canceling or completing a flow.
  void _onResetRegisterPayment(
    ResetRegisterPaymentEvent event,
    Emitter<RegisterPaymentState> emit,
  ) {
    emit(RegisterPaymentInitial());
  }
}
