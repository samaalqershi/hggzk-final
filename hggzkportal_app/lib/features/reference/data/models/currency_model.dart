import '../../domain/entities/currency.dart' as domain;

/// يعرّف الكلاس `CurrencyModel`.
/// Describes the `CurrencyModel` class.
class CurrencyModel {
  /// Holds the `code` value.
  /// العربية: يخزن القيمة `code`.
  final String code;

  /// يخزن العضو `arabicCode`.
  /// Holds the `arabicCode` member.
  final String arabicCode;

  /// يخزن العضو `name`.
  /// Holds the `name` member.
  final String name;

  /// يخزن العضو `arabicName`.
  /// Holds the `arabicName` member.
  final String arabicName;

  /// يخزن العضو `isDefault`.
  /// Holds the `isDefault` member.
  final bool isDefault;

  /// يخزن العضو `exchangeRate`.
  /// Holds the `exchangeRate` member.
  final double? exchangeRate;

  /// يخزن العضو `lastUpdated`.
  /// Holds the `lastUpdated` member.
  final DateTime? lastUpdated;

  /// ينشئ مثيلاً من `CurrencyModel`.
  /// Builds an instance of `CurrencyModel`.
  const CurrencyModel({
    required this.code,
    required this.arabicCode,
    required this.name,
    required this.arabicName,
    required this.isDefault,
    this.exchangeRate,
    this.lastUpdated,
  });

  /// ينشئ مثيلاً من `CurrencyModel`.
  /// Builds an instance of `CurrencyModel`.
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

  /// ينفذ العملية `toJson`.
  /// Runs the `toJson` operation.
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
