import '../../domain/entities/property_availability.dart';

/// Describes the PropertyAvailabilityModel data model used to parse and emit property API payloads.
/// العربية: يمثل نموذج البيانات `PropertyAvailabilityModel`.
class PropertyAvailabilityModel extends PropertyAvailability {
  /// Constructs the PropertyAvailabilityModel value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `PropertyAvailabilityModel`.
  const PropertyAvailabilityModel({
    required super.hasAvailableUnits,
    required super.availableUnitsCount,
    required super.minAvailablePrice,
    required super.currency,
    required super.message,
    required super.availableUnitTypes,
  });

  /// Constructs the PropertyAvailabilityModel.fromJson value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `PropertyAvailabilityModel.fromJson`.
  factory PropertyAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return PropertyAvailabilityModel(
      hasAvailableUnits: json['hasAvailableUnits'] as bool? ?? false,
      availableUnitsCount: json['availableUnitsCount'] as int? ?? 0,
      minAvailablePrice: (json['minAvailablePrice'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? '',
      message: (json['message'] ?? '') as String,
      availableUnitTypes: (json['availableUnitTypes'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[],
    );
  }
}
