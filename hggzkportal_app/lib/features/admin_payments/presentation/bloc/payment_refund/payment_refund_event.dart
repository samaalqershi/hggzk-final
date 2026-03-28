import 'package:equatable/equatable.dart';
import '../../../domain/entities/payment.dart';
import '../../../domain/entities/refund.dart';

abstract class PaymentRefundEvent extends Equatable {
  /// العربية: ينشئ مثيلًا جديدًا من `PaymentRefundEvent`.
  const PaymentRefundEvent();
  @override
  List<Object?> get props => [];
}

/// 🎬 حدث تهيئة الاسترداد
class InitializeRefundEvent extends PaymentRefundEvent {
  /// العربية: يخزن القيمة `paymentId`.
  final String paymentId;
  const InitializeRefundEvent({required this.paymentId});
  @override
  List<Object> get props => [paymentId];
}

/// 🧮 حدث حساب مبلغ الاسترداد
class CalculateRefundAmountEvent extends PaymentRefundEvent {
  /// العربية: يخزن القيمة `refundType`.
  final RefundType refundType;
  final Money? customAmount;
  const CalculateRefundAmountEvent({
    required this.refundType,
    this.customAmount,
  });
  @override
  List<Object?> get props => [refundType, customAmount];
}

/// ✅ حدث التحقق من صحة الاسترداد
class ValidateRefundEvent extends PaymentRefundEvent {
  /// العربية: ينشئ مثيلًا جديدًا من `ValidateRefundEvent`.
  const ValidateRefundEvent();
}

/// 💸 حدث معالجة الاسترداد
class ProcessRefundEvent extends PaymentRefundEvent {
  /// العربية: يخزن القيمة `paymentId`.
  final String paymentId;
  final Money refundAmount;
  final String refundReason;
  const ProcessRefundEvent({
    required this.paymentId,
    required this.refundAmount,
    required this.refundReason,
  });
  @override
  List<Object> get props => [paymentId, refundAmount, refundReason];
}

/// 🔄 حدث تغيير نوع الاسترداد
class ChangeRefundTypeEvent extends PaymentRefundEvent {
  /// العربية: يخزن القيمة `refundType`.
  final RefundType refundType;
  const ChangeRefundTypeEvent({required this.refundType});
  @override
  List<Object> get props => [refundType];
}

/// 📝 حدث تحديث سبب الاسترداد
class UpdateRefundReasonEvent extends PaymentRefundEvent {
  /// العربية: يخزن القيمة `reason`.
  final String reason;
  const UpdateRefundReasonEvent({required this.reason});
  @override
  List<Object> get props => [reason];
}

/// 📜 حدث تحميل تاريخ الاستردادات
class LoadRefundHistoryEvent extends PaymentRefundEvent {
  /// العربية: يخزن القيمة `paymentId`.
  final String paymentId;
  const LoadRefundHistoryEvent({required this.paymentId});
  @override
  List<Object> get props => [paymentId];
}

/// ❌ حدث إلغاء الاسترداد
class CancelRefundEvent extends PaymentRefundEvent {
  /// العربية: ينشئ مثيلًا جديدًا من `CancelRefundEvent`.
  const CancelRefundEvent();
}

/// 🔄 حدث إعادة محاولة الاسترداد
class RetryRefundEvent extends PaymentRefundEvent {
  /// العربية: ينشئ مثيلًا جديدًا من `RetryRefundEvent`.
  const RetryRefundEvent();
}
