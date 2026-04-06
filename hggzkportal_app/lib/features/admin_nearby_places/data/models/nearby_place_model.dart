import '../../domain/entities/nearby_place.dart';

class NearbyPlaceModel extends NearbyPlace {
  const NearbyPlaceModel({
    required super.id,
    required super.propertyId,
    required super.propertyName,
    super.propertyNameEn,
    required super.name,
    super.nameEn,
    super.description,
    super.descriptionEn,
    required super.category,
    required super.icon,
    super.latitude,
    super.longitude,
    required super.distanceInMeters,
    super.walkingMinutes,
    super.drivingMinutes,
    super.displayOrder,
    super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  factory NearbyPlaceModel.fromJson(Map<String, dynamic> json) {
    return NearbyPlaceModel(
      id: json['id']?.toString() ?? '',
      propertyId: json['propertyId']?.toString() ?? '',
      propertyName: json['propertyName']?.toString() ?? '',
      propertyNameEn: json['propertyNameEn']?.toString(),
      name: json['name']?.toString() ?? '',
      nameEn: json['nameEn']?.toString(),
      description: json['description']?.toString(),
      descriptionEn: json['descriptionEn']?.toString(),
      category: json['category']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceInMeters: (json['distanceInMeters'] as num?)?.toInt() ?? 0,
      walkingMinutes: (json['walkingMinutes'] as num?)?.toInt(),
      drivingMinutes: (json['drivingMinutes'] as num?)?.toInt(),
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }
}
