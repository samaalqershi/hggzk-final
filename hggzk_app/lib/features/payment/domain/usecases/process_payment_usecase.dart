/// features/payment/domain/usecases/process_payment_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/payment_repository.dart';

class ProcessPaymentUseCase implements UseCase<Transaction, ProcessPaymentParams> {
  final PaymentRepository repository;

  ProcessPaymentUseCase(this.repository);

  @override
  Future<Either<Failure, Transaction>> call(ProcessPaymentParams params) async {
    // Validate payment details
    if (params.amount <= 0) {
      return const Left(ValidationFailure('مبلغ الدفع غير صالح'));
    }

    if (params.paymentMethod.isEmpty) {
      return const Left(ValidationFailure('طريقة الدفع مطلوبة'));
    }

    final methodLower = params.paymentMethod.toLowerCase();

    // Process payment based on method
    if (methodLower.contains('credit')) {
      // Validate credit card details
      final cardDetails = params.paymentDetails?['cardDetails'];
      if (cardDetails is! Map ||
          cardDetails['cardNumber'] == null ||
          cardDetails['cardNumber'].toString().isEmpty) {
        return const Left(ValidationFailure('رقم البطاقة مطلوب'));
      }
    } else if (methodLower.contains('jwali')) {
      // جوالي: يعتمد على voucher (كود شراء) وليس رقم محفظة/WalletId
      if (params.paymentDetails == null ||
          params.paymentDetails!['voucher'] == null ||
          params.paymentDetails!['voucher'].toString().isEmpty) {
        return const Left(ValidationFailure('كود جوالي مطلوب'));
      }
    } else if (methodLower.contains('wallet') &&
        !methodLower.contains('sabacash') &&
        !methodLower.contains('flosk')) {
      // Validate generic wallet details (باستثناء سبأ كاش وفلوسك)
      if (params.paymentDetails == null ||
          params.paymentDetails!['walletId'] == null ||
          params.paymentDetails!['walletId'].toString().isEmpty) {
        return const Left(ValidationFailure('رقم المحفظة مطلوب'));
      }
    } else if (methodLower.contains('sabacash')) {
      // سبأ كاش: التحقق من OTP في المرحلة الثانية فقط (إذا أرسلت)
      if (params.paymentDetails != null &&
          params.paymentDetails!['otp'] != null &&
          params.paymentDetails!['otp'].toString().isNotEmpty) {
        final otp = params.paymentDetails!['otp'].toString();
        if (otp.length != 4) {
          return const Left(ValidationFailure('رمز التحقق يجب أن يتكون من 4 أرقام'));
        }
      }
    } else if (methodLower.contains('flosk')) {
      // فلوسك: تدفق من مرحلتين مثل سبأ كاش، لكن OTP من 6 أرقام
      if (params.paymentDetails != null &&
          params.paymentDetails!['otp'] != null &&
          params.paymentDetails!['otp'].toString().isNotEmpty) {
        final otp = params.paymentDetails!['otp'].toString();
        if (otp.length != 6 || int.tryParse(otp) == null) {
          return const Left(
              ValidationFailure('رمز التحقق يجب أن يتكون من 6 أرقام'));
        }
      }
    }

    return await repository.processPayment(
      bookingId: params.bookingId,
      userId: params.userId,
      amount: params.amount,
      paymentMethod: params.paymentMethod,
      currency: params.currency,
      paymentDetails: params.paymentDetails,
    );
  }
}

class ProcessPaymentParams extends Equatable {
  final String bookingId;
  final String userId;
  final double amount;
  final String paymentMethod;
  final String currency;
  final Map<String, dynamic>? paymentDetails;

  const ProcessPaymentParams({
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    required this.currency,
    this.paymentDetails,
  });

  @override
  List<Object?> get props => [
        bookingId,
        userId,
        amount,
        paymentMethod,
        currency,
        paymentDetails,
      ];
}