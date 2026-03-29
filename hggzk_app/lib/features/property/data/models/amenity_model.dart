import 'package:hggzk/core/localization/localized_api_value.dart';

import '../../domain/entities/amenity.dart';

/// Describes the AmenityModel data model used to parse and emit property API payloads.
/// العربية: يمثل نموذج البيانات `AmenityModel`.
class AmenityModel extends Amenity {
  /// Constructs the AmenityModel value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `AmenityModel`.
  const AmenityModel({
    required super.id,
    required super.name,
    required super.description,
    required super.iconUrl,
    required super.category,
    required super.icon,
    required super.isActive,
    super.extraCost,
    required super.displayOrder,
    required super.createdAt,
  });

  /// Constructs the AmenityModel.fromJson value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `AmenityModel.fromJson`.
  factory AmenityModel.fromJson(Map<String, dynamic> json) {
    return AmenityModel(
      // prefer property-specific amenityId, fallback to global id
      id: json['amenityId'] ?? json['id'] ?? '',
      name: LocalizedApiValue.text(
        json,
        arabicKey: 'name',
        englishKey: 'nameEn',
      ),
      description: LocalizedApiValue.text(
        json,
        arabicKey: 'description',
        englishKey: 'descriptionEn',
      ),
      iconUrl: json['iconUrl'] ?? '',
      category: json['category'] ?? '',
      icon: json['icon'] ?? '',
      // property JSON uses isAvailable, global DTO uses isActive
      isActive: json['isAvailable'] ?? json['isActive'] ?? true,
      extraCost: (json['extraCost'] as num?)?.toDouble(),
      displayOrder: json['displayOrder'] ?? 0,
      // createdAt may be missing in property payload
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  /// Converts this instance to a JSON representation.
  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'category': category,
      'icon': icon,
      'isActive': isActive,
      'extraCost': extraCost,
      'displayOrder': displayOrder,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Constructs the AmenityModel.fromEntity value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `AmenityModel.fromEntity`.
  factory AmenityModel.fromEntity(Amenity amenity) {
    return AmenityModel(
      id: amenity.id,
      name: amenity.name,
      description: amenity.description,
      iconUrl: amenity.iconUrl,
      category: amenity.category,
      icon: amenity.icon,
      isActive: amenity.isActive,
      extraCost: amenity.extraCost,
      displayOrder: amenity.displayOrder,
      createdAt: amenity.createdAt,
    );
  }
}
