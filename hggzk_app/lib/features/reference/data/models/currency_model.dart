import '../../domain/entities/currency.dart' as domain;

/// Describes the data model `CurrencyModel`.
/// العربية: يمثل نموذج البيانات `CurrencyModel`.
class CurrencyModel {
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

  /// Builds a new `CurrencyModel` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `CurrencyModel`.
  const CurrencyModel({
    required this.code,
    required this.arabicCode,
    required this.name,
    required this.arabicName,
    required this.isDefault,
    this.exchangeRate,
    this.lastUpdated,
  });

  /// Builds a new `CurrencyModel.fromJson` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `CurrencyModel.fromJson`.
  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      code: json['code'] ?? '',
      arabicCode: json['arabicCode'] ?? '',
      name: json['name'] ?? '',
      arabicName: json['arabicName'] ?? '',
      isDefault: json['isDefault'] ?? false,
      exchangeRate: (json['exchangeRate'] as num?)?.toDouble(),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'])
          : null,
    );
  }

  /// Converts this instance to a JSON representation.
  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() => {
        'code': code,
        'arabicCode': arabicCode,
        'name': name,
        'arabicName': arabicName,
        'isDefault': isDefault,
        'exchangeRate': exchangeRate,
        'lastUpdated': lastUpdated?.toIso8601String(),
      };

  domain.Currency toEntity() => domain.Currency(
        code: code,
        arabicCode: arabicCode,
        name: name,
        arabicName: arabicName,
        isDefault: isDefault,
        exchangeRate: exchangeRate,
        lastUpdated: lastUpdated,
      );
}
