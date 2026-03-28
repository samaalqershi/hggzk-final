import 'package:equatable/equatable.dart';

/// Describes `Favorite`.
/// العربية: يمثل `Favorite`.
class Favorite extends Equatable {
  /// Keeps the `id` value.
  /// العربية: يخزن القيمة `id`.
  final String id;

  /// Keeps the `userId` value.
  /// العربية: يخزن القيمة `userId`.
  final String userId;

  /// Keeps the `propertyId` value.
  /// العربية: يخزن القيمة `propertyId`.
  final String propertyId;

  /// Keeps the `propertyName` value.
  /// العربية: يخزن القيمة `propertyName`.
  final String propertyName;

  /// Keeps the `propertyImage` value.
  /// العربية: يخزن القيمة `propertyImage`.
  final String propertyImage;

  /// Keeps the `propertyLocation` value.
  /// العربية: يخزن القيمة `propertyLocation`.
  final String propertyLocation;

  /// Keeps the `typeId` value.
  /// العربية: يخزن القيمة `typeId`.
  final String typeId;

  /// Keeps the `typeName` value.
  /// العربية: يخزن القيمة `typeName`.
  final String typeName;

  /// Keeps the `ownerName` value.
  /// العربية: يخزن القيمة `ownerName`.
  final String ownerName;

  /// Keeps the `address` value.
  /// العربية: يخزن القيمة `address`.
  final String address;

  /// Keeps the `city` value.
  /// العربية: يخزن القيمة `city`.
  final String city;

  /// Keeps the `latitude` value.
  /// العربية: يخزن القيمة `latitude`.
  final double latitude;

  /// Keeps the `longitude` value.
  /// العربية: يخزن القيمة `longitude`.
  final double longitude;

  /// Keeps the `starRating` value.
  /// العربية: يخزن القيمة `starRating`.
  final int starRating;

  /// Keeps the `averageRating` value.
  /// العربية: يخزن القيمة `averageRating`.
  final double averageRating;

  /// Keeps the `reviewsCount` value.
  /// العربية: يخزن القيمة `reviewsCount`.
  final int reviewsCount;

  /// Keeps the `minPrice` value.
  /// العربية: يخزن القيمة `minPrice`.
  final double minPrice;

  /// Keeps the `currency` value.
  /// العربية: يخزن القيمة `currency`.
  final String currency;

  /// Keeps the `images` value.
  /// العربية: يخزن القيمة `images`.
  final List<PropertyImage> images;

  /// Keeps the `amenities` value.
  /// العربية: يخزن القيمة `amenities`.
  final List<Amenity> amenities;

  /// Keeps the `createdAt` value.
  /// العربية: يخزن القيمة `createdAt`.
  final DateTime createdAt;

  /// Builds a new `Favorite` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `Favorite`.
  const Favorite({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.propertyName,
    required this.propertyImage,
    required this.propertyLocation,
    required this.typeId,
    required this.typeName,
    required this.ownerName,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.starRating,
    required this.averageRating,
    required this.reviewsCount,
    this.minPrice = 0,
    this.currency = 'YER',
    required this.images,
    required this.amenities,
    required this.createdAt,
  });

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [
        id,
        userId,
        propertyId,
        propertyName,
        propertyImage,
        propertyLocation,
        typeId,
        typeName,
        ownerName,
        address,
        city,
        latitude,
        longitude,
        starRating,
        averageRating,
        reviewsCount,
        minPrice,
        currency,
        images,
        amenities,
        createdAt,
      ];
}

/// Describes `PropertyImage`.
/// العربية: يمثل `PropertyImage`.
class PropertyImage extends Equatable {
  /// Keeps the `id` value.
  /// العربية: يخزن القيمة `id`.
  final String id;

  /// Keeps the `propertyId` value.
  /// العربية: يخزن القيمة `propertyId`.
  final String? propertyId;

  /// Keeps the `unitId` value.
  /// العربية: يخزن القيمة `unitId`.
  final String? unitId;

  /// Keeps the `name` value.
  /// العربية: يخزن القيمة `name`.
  final String name;

  /// Keeps the `url` value.
  /// العربية: يخزن القيمة `url`.
  final String url;

  /// Keeps the `sizeBytes` value.
  /// العربية: يخزن القيمة `sizeBytes`.
  final int sizeBytes;

  /// Keeps the `type` value.
  /// العربية: يخزن القيمة `type`.
  final String type;

  /// Keeps the `category` value.
  /// العربية: يخزن القيمة `category`.
  final String category;

  /// Keeps the `caption` value.
  /// العربية: يخزن القيمة `caption`.
  final String caption;

  /// Keeps the `altText` value.
  /// العربية: يخزن القيمة `altText`.
  final String altText;

  /// Keeps the `tags` value.
  /// العربية: يخزن القيمة `tags`.
  final String tags;

  /// Keeps the `sizes` value.
  /// العربية: يخزن القيمة `sizes`.
  final String sizes;

  /// Indicates whether `isMain` is enabled.
  /// العربية: يحدد ما إذا كانت القيمة `isMain` مفعلة.
  final bool isMain;

  /// Keeps the `displayOrder` value.
  /// العربية: يخزن القيمة `displayOrder`.
  final int displayOrder;

  /// Keeps the `uploadedAt` value.
  /// العربية: يخزن القيمة `uploadedAt`.
  final DateTime uploadedAt;

  /// Keeps the `status` value.
  /// العربية: يخزن القيمة `status`.
  final String status;

  /// Keeps the `associationType` value.
  /// العربية: يخزن القيمة `associationType`.
  final String associationType;

  /// Builds a new `PropertyImage` instance.
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
      ];
}

/// Describes `Amenity`.
/// العربية: يمثل `Amenity`.
class Amenity extends Equatable {
  /// Keeps the `id` value.
  /// العربية: يخزن القيمة `id`.
  final String id;

  /// Keeps the `name` value.
  /// العربية: يخزن القيمة `name`.
  final String name;

  /// Keeps the `description` value.
  /// العربية: يخزن القيمة `description`.
  final String description;

  /// Keeps the `iconUrl` value.
  /// العربية: يخزن القيمة `iconUrl`.
  final String iconUrl;

  /// Keeps the `category` value.
  /// العربية: يخزن القيمة `category`.
  final String category;

  /// Indicates whether `isActive` is enabled.
  /// العربية: يحدد ما إذا كانت القيمة `isActive` مفعلة.
  final bool isActive;

  /// Keeps the `displayOrder` value.
  /// العربية: يخزن القيمة `displayOrder`.
  final int displayOrder;

  /// Keeps the `createdAt` value.
  /// العربية: يخزن القيمة `createdAt`.
  final DateTime createdAt;

  /// Builds a new `Amenity` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `Amenity`.
  const Amenity({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.category,
    required this.isActive,
    required this.displayOrder,
    required this.createdAt,
  });

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [
        id,
        name,
        description,
        iconUrl,
        category,
        isActive,
        displayOrder,
        createdAt,
      ];
}
