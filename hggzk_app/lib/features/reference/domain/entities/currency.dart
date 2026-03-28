/// Describes `Currency`.
/// العربية: يمثل `Currency`.
class Currency {
  /// Keeps the `code` value.
  /// العربية: يخزن القيمة `code`.
  final String code;

  /// Keeps the `arabicCode` value.
  /// العربية: يخزن القيمة `arabicCode`.
  final String arabicCode;

  /// Keeps the `name` value.
  /// العربية: يخزن القيمة `name`.
  final String name;

  /// Keeps the `arabicName` value.
  /// العربية: يخزن القيمة `arabicName`.
  final String arabicName;

  /// Indicates whether `isDefault` is enabled.
  /// العربية: يحدد ما إذا كانت القيمة `isDefault` مفعلة.
  final bool isDefault;

  /// Keeps the `exchangeRate` value.
  /// العربية: يخزن القيمة `exchangeRate`.
  final double? exchangeRate;

  /// Keeps the `lastUpdated` value.
  /// العربية: يخزن القيمة `lastUpdated`.
  final DateTime? lastUpdated;

  /// Builds a new `Currency` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `Currency`.
  const Currency({
    required this.code,
    required this.arabicCode,
    required this.name,
    required this.arabicName,
    required this.isDefault,
    this.exchangeRate,
    this.lastUpdated,
  });
}
