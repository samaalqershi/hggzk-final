import 'package:equatable/equatable.dart';

/// العربية: يمثل `Payment`.
class Payment extends Equatable {
  /// العربية: يخزن القيمة `id`.
  final String id;

  /// العربية: يخزن القيمة `bookingId`.
  final String bookingId;

  /// العربية: يخزن القيمة `amount`.
  final double amount;

  /// العربية: يخزن القيمة `currency`.
  final String currency;

  /// العربية: يخزن القيمة `paymentMethod`.
  final String paymentMethod;

  /// العربية: يخزن القيمة `status`.
  final PaymentStatus status;

  /// العربية: يخزن القيمة `paymentDate`.
  final DateTime paymentDate;

  /// العربية: يخزن القيمة `transactionId`.
  final String? transactionId;

  /// العربية: يخزن القيمة `receiptUrl`.
  final String? receiptUrl;

  /// العربية: يخزن القيمة `notes`.
  final String? notes;

  /// العربية: ينشئ مثيلًا جديدًا من `Payment`.
  const Payment({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    required this.paymentDate,
    this.transactionId,
    this.receiptUrl,
    this.notes,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [
        id,
        bookingId,
        amount,
        currency,
        paymentMethod,
        status,
        paymentDate,
        transactionId,
        receiptUrl,
        notes,
      ];
}

/// العربية: يعرّف القيم المتاحة للنوع `PaymentStatus`.
enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded,
  partiallyRefunded,
}
