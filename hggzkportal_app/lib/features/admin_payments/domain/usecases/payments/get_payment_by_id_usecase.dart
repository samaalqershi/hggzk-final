import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../entities/payment.dart';
import '../../repositories/payments_repository.dart';

class GetPaymentByIdUseCase implements UseCase<Payment, GetPaymentByIdParams> {
  /// العربية: يخزن القيمة `repository`.
  final PaymentsRepository repository;
  GetPaymentByIdUseCase(this.repository);
  @override
  Future<Either<Failure, Payment>> call(GetPaymentByIdParams params) async {
    return await repository.getPaymentById(paymentId: params.paymentId);
  }
}

class GetPaymentByIdParams extends Equatable {
  /// العربية: يخزن القيمة `paymentId`.
  final String paymentId;
  const GetPaymentByIdParams({required this.paymentId});
  @override
  List<Object> get props => [paymentId];
}
