import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/payment_repository.dart';

/// ينسق التحقق الأولي من مدخلات الدفع قبل تمريرها إلى المستودع.
/// Coordinates initial validation of payment inputs before delegating to the
/// repository.
class ProcessPaymentUseCase
    implements UseCase<Transaction, ProcessPaymentParams> {
  final PaymentRepository repository;
  ProcessPaymentUseCase(this.repository);
  @override
  Future<Either<Failure, Transaction>> call(ProcessPaymentParams params) async {
    // Validate payment details
    if (params.amount <= 0) {
      return Left(
        ValidationFailure(
          AppLocalizations.translateSync('common.invalidData'),
        ),
      );
    }

    if (params.paymentMethod.isEmpty) {
      return Left(
        ValidationFailure(AppLocalizations.translateSync('common.required')),
      );
    }

    final methodLower = params.paymentMethod.toLowerCase();

    // Process payment based on method
    if (methodLower.contains('credit')) {
      // Validate credit card details
      final cardDetails = params.paymentDetails?['cardDetails'];
      if (cardDetails is! Map ||
          cardDetails['cardNumber'] == null ||
          cardDetails['cardNumber'].toString().isEmpty) {
        return Left(
          ValidationFailure(
            AppLocalizations.translateSync(
              'payment.validation.cardNumberRequired',
            ),
          ),
        );
      }
    } else if (methodLower.contains('jwali')) {
      // جوالي: يعتمد على voucher (كود شراء) وليس رقم محفظة/WalletId
      if (params.paymentDetails == null ||
          params.paymentDetails!['voucher'] == null ||
          params.paymentDetails!['voucher'].toString().isEmpty) {
        return Left(
          ValidationFailure(
            AppLocalizations.translateSync(
              'payment.validation.walletCodeRequired',
            ),
          ),
        );
      }
    } else if (methodLower.contains('wallet') &&
        !methodLower.contains('sabacash') &&
        !methodLower.contains('flosk')) {
      // Validate generic wallet details (باستثناء سبأ كاش وفلوسك)
      if (params.paymentDetails == null ||
          params.paymentDetails!['walletId'] == null ||
          params.paymentDetails!['walletId'].toString().isEmpty) {
        return Left(
          ValidationFailure(
            AppLocalizations.translateSync(
              'payment.validation.walletNumberRequired',
            ),
          ),
        );
      }
    } else if (methodLower.contains('sabacash')) {
      // سبأ كاش: التحقق من OTP في المرحلة الثانية فقط (إذا أرسلت)
      if (params.paymentDetails != null &&
          params.paymentDetails!['otp'] != null &&
          params.paymentDetails!['otp'].toString().isNotEmpty) {
        final otp = params.paymentDetails!['otp'].toString();
        if (otp.length != 4) {
          return Left(
            ValidationFailure(
              AppLocalizations.translateSync('common.invalidData'),
            ),
          );
        }
      }
    } else if (methodLower.contains('flosk')) {
      // فلوسك: تدفق من مرحلتين مثل سبأ كاش، لكن OTP من 6 أرقام
      if (params.paymentDetails != null &&
          params.paymentDetails!['otp'] != null &&
          params.paymentDetails!['otp'].toString().isNotEmpty) {
        final otp = params.paymentDetails!['otp'].toString();
        if (otp.length != 6 || int.tryParse(otp) == null) {
          return Left(
            ValidationFailure(
              AppLocalizations.translateSync('common.invalidData'),
            ),
          );
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

/// يحمل كل القيم المطلوبة لمحاولة دفع واحدة.
/// Carries all values required for one payment attempt.
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
