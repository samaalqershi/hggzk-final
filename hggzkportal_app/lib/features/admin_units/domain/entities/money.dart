import 'package:equatable/equatable.dart';

/// يمثل هذا الكلاس Money البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for Money in the admin unit workflow.
class Money extends Equatable {
  /// This field keeps the amount value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة amount التي يعتمد عليها مسار إدارة الوحدات.
  final double amount;

  /// يحتفظ هذا الحقل بقيمة currency التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the currency value used by the admin unit workflow.
  final String currency;

  /// يحتفظ هذا الحقل بقيمة formattedAmount التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the formattedAmount value used by the admin unit workflow.
  final String? formattedAmount;

  /// ينشئ هذا المُنشئ مثيلاً من Money.
  /// This constructor creates an instance of Money.
  const Money({
    required this.amount,
    required this.currency,
    this.formattedAmount,
  });

  /// يعيد هذا getter قيمة displayAmount المشتقة من الحالة الحالية.
  /// This getter derives the displayAmount value from the current state.
  String get displayAmount {
    if (formattedAmount != null) return formattedAmount!;

    // Format based on currency
    switch (currency) {
      case 'YER':
        return '${amount.toStringAsFixed(0)} ﷼';
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      case 'EUR':
        return '€${amount.toStringAsFixed(2)}';
      default:
        return '${amount.toStringAsFixed(2)} $currency';
    }
  }

  /// ينفذ هذا الأسلوب عملية copyWith ضمن مسار إدارة الوحدات.
  /// This method performs the copyWith operation in the admin unit workflow.
  Money copyWith({
    double? amount,
    String? currency,
    String? formattedAmount,
  }) {
    return Money(
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      formattedAmount: formattedAmount ?? this.formattedAmount,
    );
  }

  /// ينفذ هذا الأسلوب عملية toJson ضمن مسار إدارة الوحدات.
  /// This method performs the toJson operation in the admin unit workflow.
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency,
      if (formattedAmount != null) 'formattedAmount': formattedAmount,
    };
  }

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [amount, currency, formattedAmount];
}
