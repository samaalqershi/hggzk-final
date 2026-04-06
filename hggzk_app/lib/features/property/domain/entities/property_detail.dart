import 'package:equatable/equatable.dart';
import 'property_policy.dart';
import 'amenity.dart';
import 'unit.dart';

/// Represents the full property snapshot consumed by the detail screen.
/// يمثل اللقطة الكاملة للعقار التي تعتمد عليها شاشة التفاصيل.
class PropertyDetail extends Equatable {
  /// Backend identifier of the property.
  /// المعرّف الخلفي للعقار.
  final String id;

  /// Display name shown in the header and page title.
  /// اسم العرض الذي يظهر في الترويسة وعنوان الصفحة.
  final String name;

  /// Owner account that manages the property.
  /// حساب المالك الذي يدير العقار.
  final String ownerId;

  /// Backend identifier of the property type.
  /// المعرّف الخلفي لنوع العقار.
  final String typeId;

  /// Human-readable property type name.
  /// اسم نوع العقار المقروء.
  final String typeName;

  /// Display name of the property owner.
  /// اسم عرض مالك العقار.
  final String ownerName;

  /// Full street address used in the detail summary and map section.
  /// العنوان الكامل المستخدم في الملخص وقسم الخريطة.
  final String address;

  /// City label shown to help users place the property geographically.
  /// اسم المدينة الذي يساعد المستخدم على فهم موقع العقار.
  final String city;

  /// Latitude used for map markers and distance calculations.
  /// خط العرض المستخدم في المؤشر والحسابات الجغرافية.
  final double latitude;

  /// Longitude used for map markers and distance calculations.
  /// خط الطول المستخدم في المؤشر والحسابات الجغرافية.
  final double longitude;

  /// Public star rating shown near the property title.
  /// تقييم النجوم الظاهر قرب اسم العقار.
  final int starRating;

  /// Long-form description that explains the property story and offer.
  /// الوصف المطول الذي يشرح العقار وما يقدمه.
  final String description;

  /// Aggregate review score used in cards and summary widgets.
  /// درجة المراجعات المجمعة المستخدمة في البطاقات وملخص التقييم.
  final double averageRating;

  /// Number of reviews attached to the property.
  /// عدد المراجعات المرتبطة بالعقار.
  final int reviewsCount;

  /// Number of times the property page has been viewed.
  /// عدد مرات مشاهدة صفحة العقار.
  final int viewCount;

  /// Number of completed or recorded bookings.
  /// عدد الحجوزات المنجزة أو المسجلة.
  final int bookingCount;

  /// Total number of units that belong to the property.
  /// إجمالي عدد الوحدات التابعة للعقار.
  final int unitsCount;

  /// Count of services surfaced on the detail page.
  /// عدد الخدمات المعروضة في صفحة التفاصيل.
  final int servicesCount;

  /// Count of amenities attached to the property.
  /// عدد المزايا المرفقة بالعقار.
  final int amenitiesCount;

  /// Count of payment entries or tracked transactions.
  /// عدد عمليات الدفع أو السجلات المالية المتتبعة.
  final int paymentsCount;

  /// Shows whether the signed-in user has saved the property.
  /// يوضح ما إذا كان المستخدم الحالي قد حفظ العقار.
  final bool isFavorite;

  /// Shows whether the property passed moderation or approval.
  /// يوضح ما إذا كان العقار قد اجتاز الموافقة أو المراجعة.
  final bool isApproved;

  /// Time when the property was created in the backend.
  /// وقت إنشاء العقار في الخادم.
  final DateTime createdAt;

  /// Media gallery used across the detail, gallery, and booking screens.
  /// معرض الوسائط المستخدم في شاشات التفاصيل والمعرض والحجز.
  final List<PropertyImage> images;

  /// Amenities rendered in the property features section.
  /// المزايا المعروضة داخل قسم خصائص العقار.
  final List<Amenity> amenities;

  /// Service items shown as part of the property offer.
  /// عناصر الخدمات التي تظهر ضمن عرض العقار.
  final List<PropertyService> services;

  /// Booking and stay policies shown before confirmation.
  /// سياسات الحجز والإقامة المعروضة قبل التأكيد.
  final List<PropertyPolicy> policies;

  /// Real nearby places shown inside the map section.
  /// الأماكن القريبة الحقيقية الظاهرة في قسم الموقع.
  final List<NearbyPlace> nearbyPlaces;

  /// Units attached to the property and available for booking.
  /// الوحدات التابعة للعقار والمتاحة للحجز.
  final List<Unit> units;

  /// Builds the complete property snapshot used by detail-related screens.
  /// ينشئ اللقطة الكاملة للعقار التي تستخدمها شاشات التفاصيل المرتبطة.
  const PropertyDetail({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.typeId,
    required this.typeName,
    required this.ownerName,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.starRating,
    required this.description,
    required this.averageRating,
    required this.reviewsCount,
    required this.viewCount,
    required this.bookingCount,
    required this.unitsCount,
    required this.servicesCount,
    required this.amenitiesCount,
    required this.paymentsCount,
    required this.isFavorite,
    required this.isApproved,
    required this.createdAt,
    required this.images,
    required this.amenities,
    required this.services,
    required this.policies,
    required this.nearbyPlaces,
    required this.units,
  });

  /// Keeps equality aligned with the full property payload.
  /// يحافظ على ثبات المقارنة مع حمولة العقار الكاملة.
  @override
  List<Object?> get props => [
        id,
        name,
        ownerId,
        typeId,
        typeName,
        ownerName,
        address,
        city,
        latitude,
        longitude,
        starRating,
        description,
        averageRating,
        reviewsCount,
        viewCount,
        bookingCount,
        unitsCount,
        servicesCount,
        amenitiesCount,
        paymentsCount,
        isFavorite,
        isApproved,
        createdAt,
        images,
        amenities,
        services,
        policies,
        nearbyPlaces,
        units,
      ];
}

class NearbyPlace extends Equatable {
  final String id;
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

/// Represents one property media item displayed in galleries and hero cards.
/// يمثل عنصر وسائط واحدًا يظهر في المعارض وبطاقات العرض.
class PropertyImage extends Equatable {
  /// Backend identifier of the image.
  /// المعرّف الخلفي للصورة.
  final String id;

  /// Property that owns the image when it is not unit-specific.
  /// العقار الذي تملكه الصورة عندما لا تكون مرتبطة بوحدة محددة.
  final String? propertyId;

  /// Optional unit that owns the image when the media belongs to a unit.
  /// الوحدة الاختيارية المالكة للصورة عندما تتبع الوسائط وحدة معينة.
  final String? unitId;

  /// Original file name used by storage and downloads.
  /// اسم الملف الأصلي المستخدم في التخزين والتنزيل.
  final String name;

  /// Public URL rendered by image widgets.
  /// الرابط العام الذي تعرضه عناصر الصور.
  final String url;

  /// Size of the uploaded file in bytes.
  /// حجم الملف المرفوع بالبايت.
  final int sizeBytes;

  /// Media type reported by the backend.
  /// نوع الوسائط الذي يعيده الخادم.
  final String type;

  /// Category used to group media in the UI.
  /// التصنيف المستخدم لتجميع الوسائط في الواجهة.
  final String category;

  /// Short caption rendered with the image when available.
  /// وصف قصير يظهر مع الصورة عند توفره.
  final String caption;

  /// Accessibility text used by screen readers or fallback layouts.
  /// نص بديل لبرامج القراءة أو التخطيطات الاحتياطية.
  final String altText;

  /// Serialized tags used for filtering and grouping media.
  /// الوسوم المسلسلة المستخدمة في التصفية وتجميع الوسائط.
  final String tags;

  /// Size variants returned by the backend for responsive rendering.
  /// نسخ الأحجام التي يعيدها الخادم لعرض متجاوب.
  final String sizes;

  /// Marks the image as the primary hero media.
  /// يحدد الصورة كوسيط رئيسي ظاهر في الواجهة.
  final bool isMain;

  /// Order used when the gallery sorts images.
  /// الترتيب المستخدم عند فرز صور المعرض.
  final int displayOrder;

  /// Upload timestamp supplied by the backend.
  /// وقت الرفع الذي يعيده الخادم.
  final DateTime uploadedAt;

  /// Lifecycle status used by moderation and display rules.
  /// حالة دورة الحياة المستخدمة في المراجعة وقواعد العرض.
  final String status;

  /// Explains whether the image belongs to a property or a unit.
  /// يوضح ما إذا كانت الصورة تتبع عقارًا أم وحدة.
  final String associationType;

  /// Keeps the is360 value available to this object.
  /// العربية: يخزن القيمة `is360`.
  final bool is360;

  /// Constructs the PropertyImage value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `PropertyImage`.
  const PropertyImage({
    required this.id,
    this.propertyId,
    this.unitId,
    required this.name,
    required this.url,
    required this.sizeBytes,
    required this.type,
    required this.category,
    required this.caption,
    required this.altText,
    required this.tags,
    required this.sizes,
    required this.isMain,
    required this.displayOrder,
    required this.uploadedAt,
    required this.status,
    required this.associationType,
    this.is360 = false,
  });

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [
        id,
        propertyId,
        unitId,
        name,
        url,
        sizeBytes,
        type,
        category,
        caption,
        altText,
        tags,
        sizes,
        isMain,
        displayOrder,
        uploadedAt,
        status,
        associationType,
        is360,
      ];
}

/// Provides the services implemented by `PropertyService`.
/// العربية: يوفر الخدمات التي ينفذها `PropertyService`.
class PropertyService extends Equatable {
  /// Keeps the id value available to this object.
  /// العربية: يخزن القيمة `id`.
  final String id;

  /// Keeps the name value available to this object.
  /// العربية: يخزن القيمة `name`.
  final String name;

  /// Keeps the price value available to this object.
  /// العربية: يخزن القيمة `price`.
  final double price;

  /// Keeps the currency value available to this object.
  /// العربية: يخزن القيمة `currency`.
  final String currency;

  /// Keeps the pricingModel value available to this object.
  /// العربية: يخزن القيمة `pricingModel`.
  final String pricingModel;

  /// Keeps the icon value available to this object.
  /// العربية: يخزن القيمة `icon`.
  final String icon;

  /// Keeps the description value available to this object.
  /// العربية: يخزن القيمة `description`.
  final String? description;

  /// Constructs the PropertyService value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `PropertyService`.
  const PropertyService({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.pricingModel,
    required this.icon,
    this.description,
  });

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props =>
      [id, name, price, currency, pricingModel, icon, description];
}

/// Describes the PropertyType type used in the property feature.
/// العربية: يمثل `PropertyType`.
class PropertyType extends Equatable {
  /// Keeps the id value available to this object.
  /// العربية: يخزن القيمة `id`.
  final String id;

  /// Keeps the name value available to this object.
  /// العربية: يخزن القيمة `name`.
  final String name;

  /// Keeps the description value available to this object.
  /// العربية: يخزن القيمة `description`.
  final String description;

  /// Keeps the icon value available to this object.
  /// العربية: يخزن القيمة `icon`.
  final String icon;

  /// Keeps the count value available to this object.
  /// العربية: يخزن القيمة `count`.
  final int count;

  /// Constructs the PropertyType value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `PropertyType`.
  const PropertyType({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.count,
  });

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [id, name, description, icon, count];
}
