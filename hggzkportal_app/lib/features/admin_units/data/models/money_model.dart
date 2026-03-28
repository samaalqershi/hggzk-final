import '../../domain/entities/money.dart';

/// يمثل هذا الكلاس MoneyModel البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for MoneyModel in the admin unit workflow.
class MoneyModel extends Money {
  /// This constructor creates a new MoneyModel instance.
  /// ينشئ مثيلًا جديدًا من MoneyModel.
  const MoneyModel({
    required double amount,
    required String currency,
    String? formattedAmount,
  }) : super(
          amount: amount,
          currency: currency,
          formattedAmount: formattedAmount,
        );

  /// ينشئ هذا المُنشئ مثيلاً من MoneyModel.
  /// This constructor creates an instance of MoneyModel.
  factory MoneyModel.fromJson(Map<String, dynamic> json) {
    return MoneyModel(
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      formattedAmount: json['formattedAmount'] as String?,
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

  /// ينشئ هذا المُنشئ مثيلاً من MoneyModel.
  /// This constructor creates an instance of MoneyModel.
  factory MoneyModel.fromEntity(Money entity) {
    return MoneyModel(
      amount: entity.amount,
      currency: entity.currency,
      formattedAmount: entity.formattedAmount,
    );
  }
}
