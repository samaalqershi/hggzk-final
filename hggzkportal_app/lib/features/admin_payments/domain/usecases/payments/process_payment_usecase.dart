import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../../../../../core/enums/payment_method_enum.dart';
import '../../entities/payment.dart';
import '../../repositories/payments_repository.dart';

class ProcessPaymentUseCase implements UseCase<String, ProcessPaymentParams> {
  /// العربية: يخزن القيمة `repository`.
  final PaymentsRepository repository;
  ProcessPaymentUseCase(this.repository);
  @override
  Future<Either<Failure, String>> call(ProcessPaymentParams params) async {
    return await repository.processPayment(
      bookingId: params.bookingId,
      amount: params.amount,
      method: params.method,
    );
  }
}

class ProcessPaymentParams extends Equatable {
  /// العربية: يخزن القيمة `bookingId`.
  final String bookingId;
  final Money amount;
  final PaymentMethod method;
  const ProcessPaymentParams({
    required this.bookingId,
    required this.amount,
    required this.method,
  });
  @override
  List<Object> get props => [bookingId, amount, method];
}
