import 'package:equatable/equatable.dart';
import '../../data/models/property_filter_mismatch_model.dart';

/// Search result payload used by the discovery screens and map views.
/// حمولة نتيجة البحث المستخدمة في شاشات الاكتشاف وعرض الخريطة.
class SearchResult extends Equatable {
  /// Unique identifier of the property result.
  /// المعرف الفريد لنتيجة العقار.
  final String id;

  /// Display name shown to users.
  /// الاسم الظاهر للمستخدم.
  final String name;

  /// Short summary used on cards and detail headers.
  /// ملخص قصير يظهر في البطاقات وترويسات التفاصيل.
  final String description;

  /// Human-readable address for the property.
  /// العنوان المقروء للبشر الخاص بالعقار.
  final String address;

  /// City name used for search filtering and labels.
  /// اسم المدينة المستخدم في التصفية والوسوم.
  final String city;

  /// Star rating assigned to the property.
  /// تقييم النجوم الممنوح للعقار.
  final int starRating;

  /// Average review score shown in the UI.
  /// متوسط التقييم المعروض في الواجهة.
  final double averageRating;

  /// Number of reviews attached to the property.
  /// عدد المراجعات المرتبطة بالعقار.
  final int reviewsCount;

  /// Base price used for comparison and sorting.
  /// السعر الأساسي المستخدم للمقارنة والترتيب.
  final double minPrice;

  /// Final display price after discounts.
  /// السعر النهائي المعروض بعد الخصومات.
  final double discountedPrice;

  /// Currency code used for pricing.
  /// رمز العملة المستخدم في التسعير.
  final String currency;

  /// Main preview image shown in result cards.
  /// الصورة الرئيسية المعروضة في بطاقات النتائج.
  final String? mainImageUrl;

  /// True when the backend marked the property as recommended.
  /// تكون صحيحة عندما يعلّم الخادم العقار كتوصية.
  final bool isRecommended;

  /// Distance from the selected location when proximity search is active.
  /// المسافة من الموقع المختار عندما يكون البحث القريب نشطًا.
  final double? distanceKm;

  /// Geographic latitude used for map and distance calculations.
  /// خط العرض الجغرافي المستخدم للخريطة وحساب المسافة.
  final double latitude;

  /// Geographic longitude used for map and distance calculations.
  /// خط الطول الجغرافي المستخدم للخريطة وحساب المسافة.
  final double longitude;

  /// Selected unit identifier when the result is unit-scoped.
  /// معرّف الوحدة المختارة عندما تكون النتيجة مرتبطة بوحدة.
  final String? unitId;

  /// Display name of the selected unit.
  /// اسم العرض للوحدة المختارة.
  final String? unitName;

  /// Dynamic form values returned by the property model.
  /// القيم الديناميكية التي يعيدها نموذج العقار.
  final Map<String, dynamic> dynamicFieldValues;

  /// True when the property can currently be booked.
  /// تكون صحيحة عندما يمكن حجز العقار حاليًا.
  final bool isAvailable;

  /// Number of units still available for booking.
  /// عدد الوحدات المتاحة للحجز.
  final int availableUnitsCount;

  /// Human-readable property type name.
  /// اسم نوع العقار المقروء.
  final String propertyType;

  /// True when the property should be promoted visually.
  /// تكون صحيحة عندما يجب إبراز العقار بصريًا.
  final bool isFeatured;

  /// Top amenities surfaced in the result card.
  /// أبرز المزايا المعروضة في بطاقة النتيجة.
  final List<String> mainAmenities;

  /// Lightweight review snippets shown alongside the result.
  /// مقتطفات مراجعات خفيفة تُعرض مع النتيجة.
  final List<Review> reviews;

  /// True when the current user has saved the property.
  /// تكون صحيحة عندما يحفظ المستخدم الحالي العقار.
  final bool isFavorite;

  /// Match score used by search feedback and badges.
  /// درجة المطابقة المستخدمة في ملاحظات البحث والشارات.
  final int matchPercentage;

  /// Maximum guest capacity for the property.
  /// السعة القصوى للضيوف في العقار.
  final int maxCapacity;

  /// Last backend refresh timestamp.
  /// آخر طابع زمني للتحديث من الخلفية.
  final DateTime lastUpdated;

  /// Gallery images used by cards and previews.
  /// صور المعرض المستخدمة في البطاقات والمعاينات.
  final List<String> imageUrls;

  /// Filters that the property does not satisfy.
  /// الفلاتر التي لا يطابقها العقار.
  final List<PropertyFilterMismatchModel> filterMismatches;

  /// Builds the search result snapshot from backend data.
  /// يبني لقطة نتيجة البحث من بيانات الخلفية.
  const SearchResult({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.starRating,
    required this.averageRating,
    required this.reviewsCount,
    required this.minPrice,
    required this.discountedPrice,
    required this.currency,
    this.mainImageUrl,
    required this.isRecommended,
    this.distanceKm,
    required this.latitude,
    required this.longitude,
    this.unitId,
    this.unitName,
    required this.dynamicFieldValues,
    required this.isAvailable,
    required this.availableUnitsCount,
    required this.propertyType,
    required this.isFeatured,
    required this.mainAmenities,
    required this.reviews,
    required this.isFavorite,
    required this.matchPercentage,
    required this.maxCapacity,
    required this.lastUpdated,
    required this.imageUrls,
    this.filterMismatches = const [],
  });

  /// هل توجد فروقات؟
  /// Are there any mismatches?
  bool get hasMismatches => filterMismatches.isNotEmpty;

  /// عدد الفروقات
  /// Number of mismatches
  int get mismatchesCount => filterMismatches.length;

  /// Equality fields used by Equatable.
  /// حقول المساواة المستخدمة بواسطة `Equatable`.
  @override
  List<Object?> get props => [
        id,
        name,
        description,
        address,
        city,
        starRating,
        averageRating,
        reviewsCount,
        minPrice,
        discountedPrice,
        currency,
        mainImageUrl,
        isRecommended,
        distanceKm,
        latitude,
        longitude,
        unitId,
        unitName,
        dynamicFieldValues,
        isAvailable,
        availableUnitsCount,
        propertyType,
        isFeatured,
        mainAmenities,
        reviews,
        isFavorite,
        matchPercentage,
        maxCapacity,
        lastUpdated,
        imageUrls,
        filterMismatches,
      ];
}

/// Review snippet attached to a search result.
/// مقتطف مراجعة مرتبط بنتيجة البحث.
class Review extends Equatable {
  /// Review identifier.
  /// معرّف المراجعة.
  final String id;

  /// Author identifier.
  /// معرّف صاحب المراجعة.
  final String userId;

  /// Author display name.
  /// اسم العرض لصاحب المراجعة.
  final String userName;

  /// Star rating supplied by the reviewer.
  /// تقييم النجوم الذي أدخله المراجع.
  final double rating;

  /// Short review comment.
  /// تعليق المراجعة القصير.
  final String? comment;

  /// Time when the review was created.
  /// وقت إنشاء المراجعة.
  final DateTime createdAt;

  /// Builds a review snippet from backend review data.
  /// يبني مقتطف مراجعة من بيانات المراجعة القادمة من الخلفية.
  const Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  /// Equality fields used by Equatable.
  /// حقول المساواة المستخدمة بواسطة `Equatable`.
  @override
  List<Object?> get props => [id, userId, userName, rating, comment, createdAt];
}

/// العربية: يمثل `SearchFilters`.
class SearchFilters extends Equatable {
  /// العربية: يخزن القيمة `cities`.
  final List<CityFilter> cities;

  /// العربية: يخزن القيمة `propertyTypes`.
  final List<PropertyTypeFilter> propertyTypes;

  /// العربية: يخزن القيمة `priceRange`.
  final PriceRange priceRange;

  /// العربية: يخزن القيمة `amenities`.
  final List<AmenityFilter> amenities;

  /// العربية: يخزن القيمة `starRatings`.
  final List<int> starRatings;

  /// العربية: يخزن القيمة `starRatingOptions`.
  final List<StarRatingOption> starRatingOptions;

  /// العربية: يخزن القيمة `availableCities`.
  final List<String> availableCities;

  /// العربية: يخزن القيمة `maxGuestCapacity`.
  final int maxGuestCapacity;

  /// العربية: يخزن القيمة `unitTypes`.
  final List<UnitTypeFilter> unitTypes;

  /// العربية: يخزن القيمة `distanceRange`.
  final DistanceRange distanceRange;

  /// العربية: يخزن القيمة `supportedCurrencies`.
  final List<String> supportedCurrencies;

  /// العربية: يخزن القيمة `services`.
  final List<ServiceFilter> services;

  /// العربية: يخزن القيمة `dynamicFieldValues`.
  final List<DynamicFieldValueFilter> dynamicFieldValues;

  /// العربية: ينشئ مثيلًا جديدًا من `SearchFilters`.
  const SearchFilters({
    required this.cities,
    required this.propertyTypes,
    required this.priceRange,
    required this.amenities,
    required this.starRatings,
    this.starRatingOptions = const [],
    required this.availableCities,
    required this.maxGuestCapacity,
    required this.unitTypes,
    required this.distanceRange,
    required this.supportedCurrencies,
    required this.services,
    required this.dynamicFieldValues,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [
        cities,
        propertyTypes,
        priceRange,
        amenities,
        starRatings,
        starRatingOptions,
        availableCities,
        maxGuestCapacity,
        unitTypes,
        distanceRange,
        supportedCurrencies,
        services,
        dynamicFieldValues,
      ];
}

/// العربية: يمثل `CityFilter`.
class CityFilter extends Equatable {
  /// العربية: يخزن القيمة `id`.
  final String id;

  /// العربية: يخزن القيمة `name`.
  final String name;

  /// العربية: يخزن القيمة `propertiesCount`.
  final int propertiesCount;

  /// العربية: ينشئ مثيلًا جديدًا من `CityFilter`.
  const CityFilter({
    required this.id,
    required this.name,
    required this.propertiesCount,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [id, name, propertiesCount];
}

/// العربية: يمثل `PropertyTypeFilter`.
class PropertyTypeFilter extends Equatable {
  /// العربية: يخزن القيمة `id`.
  final String id;

  /// العربية: يخزن القيمة `name`.
  final String name;

  /// العربية: يخزن القيمة `propertiesCount`.
  final int propertiesCount;

  /// العربية: ينشئ مثيلًا جديدًا من `PropertyTypeFilter`.
  const PropertyTypeFilter({
    required this.id,
    required this.name,
    required this.propertiesCount,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [id, name, propertiesCount];
}

/// العربية: يمثل `PriceRange`.
class PriceRange extends Equatable {
  /// العربية: يخزن القيمة `minPrice`.
  final double minPrice;

  /// العربية: يخزن القيمة `maxPrice`.
  final double maxPrice;

  /// العربية: يخزن القيمة `averagePrice`.
  final double averagePrice;

  /// العربية: ينشئ مثيلًا جديدًا من `PriceRange`.
  const PriceRange({
    required this.minPrice,
    required this.maxPrice,
    required this.averagePrice,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [minPrice, maxPrice, averagePrice];
}

/// العربية: يمثل `AmenityFilter`.
class AmenityFilter extends Equatable {
  /// العربية: يخزن القيمة `id`.
  final String id;

  /// العربية: يخزن القيمة `name`.
  final String name;

  /// العربية: يخزن القيمة `category`.
  final String category;

  /// العربية: يخزن القيمة `propertiesCount`.
  final int propertiesCount;

  /// العربية: يخزن القيمة `icon`.
  final String icon;

  /// العربية: يخزن القيمة `propertyTypeIds`.
  final List<String> propertyTypeIds;

  /// العربية: ينشئ مثيلًا جديدًا من `AmenityFilter`.
  const AmenityFilter({
    required this.id,
    required this.name,
    required this.category,
    required this.propertiesCount,
    required this.icon,
    this.propertyTypeIds = const [],
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props =>
      [id, name, category, propertiesCount, icon, propertyTypeIds];
}

/// العربية: يمثل `UnitTypeFilter`.
class UnitTypeFilter extends Equatable {
  /// العربية: يخزن القيمة `id`.
  final String id;

  /// العربية: يخزن القيمة `name`.
  final String name;

  /// العربية: يخزن القيمة `propertyTypeId`.
  final String propertyTypeId;

  /// العربية: يخزن القيمة `unitsCount`.
  final int unitsCount;

  /// العربية: يحدد ما إذا كانت القيمة `isHasAdults` مفعلة.
  final bool isHasAdults;

  /// العربية: يحدد ما إذا كانت القيمة `isHasChildren` مفعلة.
  final bool isHasChildren;

  /// العربية: يحدد ما إذا كانت القيمة `isMultiDays` مفعلة.
  final bool isMultiDays;

  /// العربية: يحدد ما إذا كانت القيمة `isRequiredToDetermineTheHour` مفعلة.
  final bool isRequiredToDetermineTheHour;

  /// العربية: ينشئ مثيلًا جديدًا من `UnitTypeFilter`.
  const UnitTypeFilter({
    required this.id,
    required this.name,
    this.propertyTypeId = '',
    required this.unitsCount,
    required this.isHasAdults,
    required this.isHasChildren,
    required this.isMultiDays,
    required this.isRequiredToDetermineTheHour,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [
        id,
        name,
        propertyTypeId,
        unitsCount,
        isHasAdults,
        isHasChildren,
        isMultiDays,
        isRequiredToDetermineTheHour
      ];
}

/// العربية: يمثل `DistanceRange`.
class DistanceRange extends Equatable {
  /// العربية: يخزن القيمة `minDistance`.
  final double minDistance;

  /// العربية: يخزن القيمة `maxDistance`.
  final double maxDistance;

  /// العربية: ينشئ مثيلًا جديدًا من `DistanceRange`.
  const DistanceRange({
    required this.minDistance,
    required this.maxDistance,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [minDistance, maxDistance];
}

/// العربية: يمثل `ServiceFilter`.
class ServiceFilter extends Equatable {
  /// العربية: يخزن القيمة `id`.
  final String id;

  /// العربية: يخزن القيمة `name`.
  final String name;

  /// العربية: يخزن القيمة `propertiesCount`.
  final int propertiesCount;

  /// العربية: يخزن القيمة `icon`.
  final String icon;

  /// العربية: ينشئ مثيلًا جديدًا من `ServiceFilter`.
  const ServiceFilter({
    required this.id,
    required this.name,
    required this.propertiesCount,
    required this.icon,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [id, name, propertiesCount, icon];
}

/// العربية: يمثل `DynamicFieldValueFilter`.
class DynamicFieldValueFilter extends Equatable {
  /// العربية: يخزن القيمة `fieldName`.
  final String fieldName;

  /// العربية: يخزن القيمة `displayName`.
  final String displayName;

  /// العربية: يخزن القيمة `value`.
  final String value;

  /// العربية: يخزن القيمة `count`.
  final int count;

  /// العربية: ينشئ مثيلًا جديدًا من `DynamicFieldValueFilter`.
  const DynamicFieldValueFilter({
    required this.fieldName,
    required this.displayName,
    required this.value,
    required this.count,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [fieldName, displayName, value, count];
}

/// العربية: يمثل `StarRatingOption`.
class StarRatingOption extends Equatable {
  /// العربية: يخزن القيمة `value`.
  final int value;

  /// العربية: يخزن القيمة `propertiesCount`.
  final int propertiesCount;

  /// العربية: ينشئ مثيلًا جديدًا من `StarRatingOption`.
  const StarRatingOption({
    required this.value,
    required this.propertiesCount,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [value, propertiesCount];
}
