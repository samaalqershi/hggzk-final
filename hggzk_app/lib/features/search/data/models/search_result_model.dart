import 'package:hggzk/core/localization/localized_api_value.dart';

import '../../domain/entities/search_result.dart';
import 'property_filter_mismatch_model.dart';

/// العربية: يمثل نموذج البيانات `SearchResultModel`.
class SearchResultModel extends SearchResult {
  /// العربية: ينشئ مثيلًا جديدًا من `SearchResultModel`.
  const SearchResultModel({
    required super.id,
    required super.name,
    required super.description,
    required super.address,
    required super.city,
    required super.starRating,
    required super.averageRating,
    required super.reviewsCount,
    required super.minPrice,
    required super.discountedPrice,
    required super.currency,
    super.mainImageUrl,
    required super.isRecommended,
    super.distanceKm,
    required super.latitude,
    required super.longitude,
    super.unitId,
    super.unitName,
    required super.dynamicFieldValues,
    required super.isAvailable,
    required super.availableUnitsCount,
    required super.propertyType,
    required super.isFeatured,
    required super.mainAmenities,
    required super.reviews,
    required super.isFavorite,
    required super.matchPercentage,
    required super.maxCapacity,
    required super.lastUpdated,
    required super.imageUrls,
    super.filterMismatches = const [],
  });

  /// العربية: ينشئ مثيلًا جديدًا من `SearchResultModel.fromJson`.
  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    // Debug: Check filterMismatches
    final filterMismatchesRaw = json['filterMismatches'];
    if (filterMismatchesRaw != null) {
      print(
          '🔍 [SearchResultModel] Property "${json['name']}" has filterMismatches: ${filterMismatchesRaw is List ? filterMismatchesRaw.length : 'not a list'}');
    }

    return SearchResultModel(
      id: json['id'] ?? '',
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
      address: LocalizedApiValue.text(
        json,
        arabicKey: 'address',
        englishKey: 'addressEn',
      ),
      city: LocalizedApiValue.text(
        json,
        arabicKey: 'city',
        englishKey: 'cityEn',
      ),
      starRating: json['starRating'] ?? 0,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      reviewsCount: json['reviewsCount'] ?? 0,
      minPrice: (json['minPrice'] ?? 0).toDouble(),
      discountedPrice: (json['discountedPrice'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'YER',
      mainImageUrl: json['mainImageUrl'],
      isRecommended: json['isRecommended'] ?? false,
      distanceKm: json['distanceKm']?.toDouble(),
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      unitId: json['unitId'],
      unitName: LocalizedApiValue.text(
        json,
        arabicKey: 'unitName',
        englishKey: 'unitNameEn',
      ),
      dynamicFieldValues:
          Map<String, dynamic>.from(json['dynamicFieldValues'] ?? {}),
      isAvailable: json['isAvailable'] ?? true,
      availableUnitsCount: json['availableUnitsCount'] ?? 0,
      propertyType: LocalizedApiValue.text(
        json,
        arabicKey: 'propertyType',
        englishKey: 'propertyTypeEn',
      ),
      isFeatured: json['isFeatured'] ?? false,
      mainAmenities: LocalizedApiValue.stringList(
        json,
        arabicKey: 'mainAmenities',
        englishKey: 'mainAmenitiesEn',
      ),
      reviews: (json['reviews'] as List?)
              ?.map((e) => ReviewModel.fromJson(e))
              .toList() ??
          [],
      isFavorite: json['isFavorite'] ?? false,
      matchPercentage: json['matchPercentage'] ?? 0,
      maxCapacity: json['maxCapacity'] ?? 0,
      lastUpdated: DateTime.parse(
          json['lastUpdated'] ?? DateTime.now().toIso8601String()),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      filterMismatches: (json['filterMismatches'] as List?)
              ?.map((e) => PropertyFilterMismatchModel.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'starRating': starRating,
      'averageRating': averageRating,
      'reviewsCount': reviewsCount,
      'minPrice': minPrice,
      'discountedPrice': discountedPrice,
      'currency': currency,
      'mainImageUrl': mainImageUrl,
      'isRecommended': isRecommended,
      'distanceKm': distanceKm,
      'latitude': latitude,
      'longitude': longitude,
      'unitId': unitId,
      'unitName': unitName,
      'dynamicFieldValues': dynamicFieldValues,
      'isAvailable': isAvailable,
      'availableUnitsCount': availableUnitsCount,
      'propertyType': propertyType,
      'isFeatured': isFeatured,
      'mainAmenities': mainAmenities,
      'reviews': reviews.map((e) => (e as ReviewModel).toJson()).toList(),
      'isFavorite': isFavorite,
      'matchPercentage': matchPercentage,
      'maxCapacity': maxCapacity,
      'lastUpdated': lastUpdated.toIso8601String(),
      'imageUrls': imageUrls,
      'filterMismatches': filterMismatches.map((e) => e.toJson()).toList(),
    };
  }
}

/// العربية: يمثل نموذج البيانات `ReviewModel`.
class ReviewModel extends Review {
  /// العربية: ينشئ مثيلًا جديدًا من `ReviewModel`.
  const ReviewModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.rating,
    super.comment,
    required super.createdAt,
  });

  /// العربية: ينشئ مثيلًا جديدًا من `ReviewModel.fromJson`.
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'],
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// العربية: يعرّف الامتداد `SearchResultUi`.
extension SearchResultUi on SearchResultModel {
  /// العربية: يعيد القيمة `imageUrl`.
  String? get imageUrl =>
      mainImageUrl ?? (imageUrls.isNotEmpty ? imageUrls.first : null);

  /// العربية: يعيد القيمة `location`.
  String? get location => address.isNotEmpty ? address : city;

  /// العربية: يعيد القيمة `price`.
  double? get price => (discountedPrice > 0 ? discountedPrice : minPrice);

  /// العربية: يعيد القيمة `rating`.
  double? get rating => averageRating;

  /// العربية: يعيد القيمة `bedrooms`.
  int? get bedrooms {
    final v =
        dynamicFieldValues['bedrooms'] ?? dynamicFieldValues['numBedrooms'];
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

  /// العربية: يعيد القيمة `bathrooms`.
  int? get bathrooms {
    final v =
        dynamicFieldValues['bathrooms'] ?? dynamicFieldValues['numBathrooms'];
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

  /// العربية: يعيد القيمة `area`.
  double? get area {
    final v = dynamicFieldValues['area'] ?? dynamicFieldValues['size'];
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  /// العربية: يعيد القيمة `discount`.
  int? get discount {
    if (minPrice > 0 && discountedPrice > 0 && discountedPrice < minPrice) {
      final pct = ((minPrice - discountedPrice) / minPrice) * 100;
      return pct.round();
    }
    return null;
  }

  /// العربية: يعيد القيمة `propertiesCount`.
  int get propertiesCount {
    final v = dynamicFieldValues['propertiesCount'];
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
