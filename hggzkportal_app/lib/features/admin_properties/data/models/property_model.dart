// lib/features/admin_properties/data/models/property_model.dart

import 'package:hggzkportal/core/constants/api_constants.dart';
import 'package:hggzkportal/features/admin_properties/domain/entities/amenity.dart';
import 'package:hggzkportal/features/admin_properties/domain/entities/nearby_place.dart';
import 'package:hggzkportal/features/admin_properties/domain/entities/policy.dart';
import 'package:hggzkportal/features/admin_properties/domain/entities/property.dart';
import 'package:hggzkportal/features/admin_properties/domain/entities/property_image.dart';
import 'property_image_model.dart';
import 'amenity_model.dart';
import 'nearby_place_model.dart';
import 'policy_model.dart';

/// Maps property payloads from the backend into the domain entity while also
/// normalizing images, amenities, policies, and dashboard stats.
///
/// يطابق حمولة العقار القادمة من الخادم مع كيان المجال مع تطبيع الصور
/// والمزايا والسياسات وإحصاءات اللوحة.
class PropertyModel extends Property {
  /// Creates the immutable property snapshot used by the management screens.
  ///
  /// ينشئ لقطة العقار غير القابلة للتعديل المستخدمة في شاشات الإدارة.
  const PropertyModel({
    required super.id,
    required super.ownerId,
    required super.typeId,
    required super.name,
    super.nameEn,
    super.shortDescription,
    super.shortDescriptionEn,
    double basePricePerNight = 0.0,
    required super.address,
    super.addressEn,
    required super.city,
    super.cityEn,
    super.latitude,
    super.longitude,
    required super.starRating,
    required super.description,
    super.descriptionEn,
    required super.isApproved,
    required super.createdAt,
    super.viewCount,
    super.bookingCount,
    super.averageRating,
    super.currency,
    super.isFeatured,
    super.systemCommissionRate,
    required super.ownerName,
    required super.typeName,
    super.typeNameEn,
    super.distanceKm,
    super.images,
    super.amenities,
    super.policies,
    super.nearbyPlaces,
    super.stats,
  });

  /// Normalizes image URLs so relative or filename-only values still render in
  /// the portal.
  ///
  /// يوحّد روابط الصور حتى تعمل القيم النسبية أو أسماء الملفات داخل البوابة.
  static String _validateAndFixUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://via.placeholder.com/400x300?text=No+Image';
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      if (url.startsWith('/')) {
        return '${ApiConstants.imageBaseUrl}$url';
      }
      return 'https://via.placeholder.com/400x300?text=$url';
    }

    return url;
  }

  /// Builds the property model while tolerating mixed image, amenity, and
  /// policy payload shapes from the backend.
  ///
  /// تبني نموذج العقار مع تحمل اختلاف صيغ الصور والمزايا والسياسات القادمة
  /// من الخادم.
  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    // Images may arrive as nested objects, plain URLs, or a single string.
    List<PropertyImage> parsedImages = [];
    if (json['images'] != null) {
      if (json['images'] is List) {
        parsedImages = (json['images'] as List)
            .map((e) {
              if (e is Map<String, dynamic>) {
                return PropertyImageModel.fromJson(e);
              } else if (e is String) {
                final validUrl = _validateAndFixUrl(e);
                return PropertyImageModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  url: validUrl,
                  filename: 'image.jpg',
                  size: 0,
                  mimeType: 'image/jpeg',
                  width: 0,
                  height: 0,
                  uploadedAt: DateTime.now(),
                  uploadedBy: json['ownerId'] as String? ?? '',
                  order: parsedImages.length,
                  isPrimary: parsedImages.isEmpty,
                  category: ImageCategory.gallery,
                  processingStatus: ProcessingStatus.ready,
                  thumbnails: ImageThumbnailsModel(
                    small: validUrl,
                    medium: validUrl,
                    large: validUrl,
                    hd: validUrl,
                  ),
                );
              }
              return null;
            })
            .whereType<PropertyImage>()
            .toList();
      } else if (json['images'] is String) {
        final imageUrl = _validateAndFixUrl(json['images'] as String);
        parsedImages = [
          PropertyImageModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            url: imageUrl,
            filename: 'image.jpg',
            size: 0,
            mimeType: 'image/jpeg',
            width: 0,
            height: 0,
            uploadedAt: DateTime.now(),
            uploadedBy: json['ownerId'] as String? ?? '',
            order: 0,
            isPrimary: true,
            category: ImageCategory.gallery,
            processingStatus: ProcessingStatus.ready,
            thumbnails: ImageThumbnailsModel(
              small: imageUrl,
              medium: imageUrl,
              large: imageUrl,
              hd: imageUrl,
            ),
          ),
        ];
      }
    }

    return PropertyModel(
      id: json['id'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      typeId: json['typeId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameEn: json['nameEn'] as String?,
      shortDescription: json['shortDescription'] as String?,
      shortDescriptionEn: json['shortDescriptionEn'] as String?,
      basePricePerNight: (json['basePricePerNight'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String? ?? '',
      addressEn: json['addressEn'] as String?,
      city: json['city'] as String? ?? '',
      cityEn: json['cityEn'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      starRating: (json['starRating'] as num?)?.toInt() ?? 0,
      description: json['description'] as String? ?? '',
      descriptionEn: json['descriptionEn'] as String?,
      isApproved: json['isApproved'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      bookingCount: (json['bookingCount'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'YER',
      isFeatured: json['isFeatured'] as bool? ?? false,
      systemCommissionRate: (json['systemCommissionRate'] as num?)?.toDouble(),
      ownerName: json['ownerName'] as String? ?? '',
      typeName: json['typeName'] as String? ?? '',
      typeNameEn: json['typeNameEn'] as String?,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      images: parsedImages,
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) {
                if (e is Map<String, dynamic>) {
                  return AmenityModel.fromJson(e);
                }
                return null;
              })
              .whereType<Amenity>()
              .toList() ??
          [],
      policies: (json['policies'] as List<dynamic>?)
              ?.map((e) {
                try {
                  if (e is Map<String, dynamic>) {
                    return PolicyModel.fromJson(e);
                  }
                } catch (e) {
                  print('⚠️ Error parsing policy: $e');
                }
                return null;
              })
              .whereType<Policy>()
              .toList() ??
          [],
      nearbyPlaces: (json['nearbyPlaces'] as List<dynamic>?)
              ?.map((e) {
                if (e is Map<String, dynamic>) {
                  return NearbyPlaceModel.fromJson(e);
                }
                return null;
              })
              .whereType<NearbyPlace>()
              .toList() ??
          [],
      stats: json['stats'] != null && json['stats'] is Map<String, dynamic>
          ? PropertyStatsModel.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Serializes the property using the data-layer shape expected by the API.
  ///
  /// يعيد العقار بصيغة طبقة البيانات التي يتوقعها الـ API.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'typeId': typeId,
      'name': name,
      'nameEn': nameEn,
      'shortDescription': shortDescription,
      'shortDescriptionEn': shortDescriptionEn,
      'address': address,
      'addressEn': addressEn,
      'city': city,
      'cityEn': cityEn,
      'latitude': latitude,
      'longitude': longitude,
      'starRating': starRating,
      'description': description,
      'descriptionEn': descriptionEn,
      'isApproved': isApproved,
      'createdAt': createdAt.toIso8601String(),
      'viewCount': viewCount,
      'bookingCount': bookingCount,
      'averageRating': averageRating,
      'currency': currency,
      'isFeatured': isFeatured,
      'systemCommissionRate': systemCommissionRate,
      'ownerName': ownerName,
      'typeName': typeName,
      'typeNameEn': typeNameEn,
      'distanceKm': distanceKm,
      'images': images.map((e) => (e as PropertyImageModel).toJson()).toList(),
      'amenities': amenities.map((e) => (e as AmenityModel).toJson()).toList(),
      'policies': policies.map((e) => (e as PolicyModel).toJson()).toList(),
      'nearbyPlaces':
          nearbyPlaces.map((e) => (e as NearbyPlaceModel).toJson()).toList(),
      'stats': stats != null ? (stats as PropertyStatsModel).toJson() : null,
    };
  }
}

/// Concrete model for the dashboard metrics attached to a property payload.
///
/// النموذج الفعلي لمؤشرات اللوحة المرفقة بحمولة العقار.
class PropertyStatsModel extends PropertyStats {
  /// Creates the property metrics snapshot used by admin dashboards.
  ///
  /// ينشئ لقطة الإحصاءات المستخدمة في لوحات الإدارة.
  const PropertyStatsModel({
    required super.totalBookings,
    required super.activeBookings,
    required super.averageRating,
    required super.reviewCount,
    required super.occupancyRate,
    required super.monthlyRevenue,
  });

  /// Parses the lightweight statistics block returned with the property.
  ///
  /// يحلل كتلة الإحصاءات الخفيفة العائدة مع العقار.
  factory PropertyStatsModel.fromJson(Map<String, dynamic> json) {
    return PropertyStatsModel(
      totalBookings: (json['totalBookings'] as num?)?.toInt() ?? 0,
      activeBookings: (json['activeBookings'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      occupancyRate: (json['occupancyRate'] as num?)?.toDouble() ?? 0.0,
      monthlyRevenue: (json['monthlyRevenue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Serializes the metrics into the backend property payload shape.
  ///
  /// يعيد المؤشرات إلى صيغة حمولة العقار المتوقعة.
  Map<String, dynamic> toJson() {
    return {
      'totalBookings': totalBookings,
      'activeBookings': activeBookings,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'occupancyRate': occupancyRate,
      'monthlyRevenue': monthlyRevenue,
    };
  }
}
