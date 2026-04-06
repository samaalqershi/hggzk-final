import 'package:equatable/equatable.dart';

class NearbyPlace extends Equatable {
  final String id;
  final String propertyId;
  final String name;
  final String? nameEn;
  final String? description;
  final String? descriptionEn;
  final String category;
  final String icon;
  final double? latitude;
  final double? longitude;
  final int distanceInMeters;
  final int? walkingMinutes;
  final int? drivingMinutes;
  final int displayOrder;
  final bool isActive;

  const NearbyPlace({
    required this.id,
    required this.propertyId,
    required this.name,
    this.nameEn,
    this.description,
    this.descriptionEn,
    required this.category,
    required this.icon,
    this.latitude,
    this.longitude,
    required this.distanceInMeters,
    this.walkingMinutes,
    this.drivingMinutes,
    this.displayOrder = 0,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        propertyId,
        name,
        nameEn,
        description,
        descriptionEn,
        category,
        icon,
        latitude,
        longitude,
        distanceInMeters,
        walkingMinutes,
        drivingMinutes,
        displayOrder,
        isActive,
      ];
}
