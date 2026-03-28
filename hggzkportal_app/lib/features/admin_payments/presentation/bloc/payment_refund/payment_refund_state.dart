import 'package:equatable/equatable.dart';
import '../../../domain/entities/payment.dart';
import '../../../domain/entities/refund.dart';

abstract class PaymentRefundState extends Equatable {
  /// العربية: ينشئ مثيلًا جديدًا من `PaymentRefundState`.
  const PaymentRefundState();
  @override
  List<Object?> get props => [];
}

/// 🎬 الحالة الابتدائية
class PaymentRefundInitial extends PaymentRefundState {}

/// ⏳ حالة التحميل
class PaymentRefundLoading extends PaymentRefundState {}

/// ✅ حالة الجاهزية للاسترداد
class PaymentRefundReady extends PaymentRefundState {
  /// العربية: يخزن القيمة `payment`.
  final Payment payment;
  final Money availableAmount;
  final List<Refund> refundHistory;
  final RefundType refundType;
  final Money? refundAmount;
  final String refundReason;
  final bool canRefund;
  const PaymentRefundReady({
    required this.payment,
    required this.availableAmount,
    required this.refundHistory,
    required this.refundType,
    this.refundAmount,
    required this.refundReason,
    required this.canRefund,
  });
  PaymentRefundReady copyWith({
    Payment? payment,
    Money? availableAmount,
    List<Refund>? refundHistory,
    RefundType? refundType,
    Money? refundAmount,
    String? refundReason,
    bool? canRefund,
  }) {
    return PaymentRefundReady(
      payment: payment ?? this.payment,
      availableAmount: availableAmount ?? this.availableAmount,
      refundHistory: refundHistory ?? this.refundHistory,
      refundType: refundType ?? this.refundType,
      refundAmount: refundAmount ?? this.refundAmount,
      refundReason: refundReason ?? this.refundReason,
      canRefund: canRefund ?? this.canRefund,
    );
  }

  @override
  List<Object?> get props => [
        payment,
        availableAmount,
        refundHistory,
        refundType,
        refundAmount,
        refundReason,
        canRefund,
      ];
}

/// ✅ حالة التحقق من صحة الاسترداد
class PaymentRefundValidated extends PaymentRefundState {
  /// العربية: يخزن القيمة `payment`.
  final Payment payment;
  final Money availableAmount;
  final List<Refund> refundHistory;
  final Money refundAmount;
  final String refundReason;
  final RefundType refundType;
  const PaymentRefundValidated({
    required this.payment,
    required this.availableAmount,
    required this.refundHistory,
    required this.refundAmount,
    required this.refundReason,
    required this.refundType,
  });
  @override
  List<Object> get props => [
        payment,
        availableAmount,
        refundHistory,
        refundAmount,
        refundReason,
        refundType,
      ];
}

/// ❌ حالة خطأ التحقق
class PaymentRefundValidationError extends PaymentRefundState {
  /// العربية: يخزن القيمة `payment`.
  final Payment payment;
  final Money availableAmount;
  final List<Refund> refundHistory;
  final List<String> errors;
  const PaymentRefundValidationError({
    required this.payment,
    required this.availableAmount,
    required this.refundHistory,
    required this.errors,
  });
  @override
  List<Object> get props => [payment, availableAmount, refundHistory, errors];
}

/// ⏳ حالة معالجة الاسترداد
class PaymentRefundProcessing extends PaymentRefundState {
  /// العربية: يخزن القيمة `payment`.
  final Payment payment;
  final Money refundAmount;
  final String refundReason;
  const PaymentRefundProcessing({
    required this.payment,
    required this.refundAmount,
    required this.refundReason,
  });
  @override
  List<Object> get props => [payment, refundAmount, refundReason];
}

/// ✅ حالة نجاح الاسترداد
class PaymentRefundSuccess extends PaymentRefundState {
  /// العربية: يخزن القيمة `payment`.
  final Payment payment;
  final Money refundAmount;
  final String message;
  final String refundId;
  const PaymentRefundSuccess({
    required this.payment,
    required this.refundAmount,
    required this.message,
    required this.refundId,
  });
  @override
  List<Object> get props => [payment, refundAmount, message, refundId];
}

/// ❌ حالة فشل الاسترداد
class PaymentRefundFailure extends PaymentRefundState {
  /// العربية: يخزن القيمة `payment`.
  final Payment payment;
  final String message;
  final bool canRetry;
  const PaymentRefundFailure({
    required this.payment,
    required this.message,
    required this.canRetry,
  });
  @override
  List<Object> get props => [payment, message, canRetry];
}

/// ❌ حالة الخطأ
class PaymentRefundError extends PaymentRefundState {
  /// العربية: يخزن القيمة `message`.
  final String message;
  const PaymentRefundError({required this.message});
  @override
  List<Object> get props => [message];
}

/// 🚫 حالة إلغاء الاسترداد
class PaymentRefundCancelled extends PaymentRefundState {}
