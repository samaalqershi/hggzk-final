// lib/features/admin_properties/presentation/bloc/properties/properties_event.dart

part of 'properties_bloc.dart';

abstract class PropertiesEvent extends Equatable {
  /// العربية: ينشئ مثيلًا جديدًا من `PropertiesEvent`.
  const PropertiesEvent();
  @override
  List<Object?> get props => [];
}

class LoadPropertiesEvent extends PropertiesEvent {
  /// العربية: يخزن القيمة `pageNumber`.
  final int pageNumber;
  final int pageSize;
  final String? sortBy;
  final bool? isAscending;
  final bool? isApproved;
  const LoadPropertiesEvent({
    this.pageNumber = 1,
    this.pageSize = 1000,
    this.sortBy,
    this.isAscending,
    this.isApproved,
  });
  @override
  List<Object?> get props =>
      [pageNumber, pageSize, sortBy, isAscending, isApproved];
}

// إضافة حدث جديد لجلب تفاصيل العقار
class LoadPropertyDetailsEvent extends PropertiesEvent {
  /// العربية: يخزن القيمة `propertyId`.
  final String propertyId;
  final bool includeUnits;
  const LoadPropertyDetailsEvent({
    required this.propertyId,
    this.includeUnits = false,
  });
  @override
  List<Object?> get props => [propertyId, includeUnits];
}

class CreatePropertyEvent extends PropertiesEvent {
  /// العربية: يخزن القيمة `name`.
  final String name;
  final String? nameEn;
  final String address;
  final String? addressEn;
  final String propertyTypeId;
  final String ownerId;
  final String description;
  final String? descriptionEn;
  final double latitude;
  final double longitude;
  final String city;
  final int starRating;
  final List<String>? images;
  final List<String>? amenityIds;
  final String? tempKey;
  final String shortDescription;
  final String? shortDescriptionEn;
  final String currency;
  final bool isFeatured;
  final double? systemCommissionRate;
  const CreatePropertyEvent({
    required this.name,
    this.nameEn,
    required this.address,
    this.addressEn,
    required this.propertyTypeId,
    required this.ownerId,
    required this.description,
    this.descriptionEn,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.starRating,
    this.images,
    this.amenityIds,
    this.tempKey,
    required this.shortDescription,
    this.shortDescriptionEn,
    required this.currency,
    required this.isFeatured,
    this.systemCommissionRate,
  });
  @override
  List<Object?> get props => [
        name,
        nameEn,
        address,
        addressEn,
        propertyTypeId,
        ownerId,
        description,
        descriptionEn,
        latitude,
        longitude,
        city,
        starRating,
        images,
        amenityIds,
        tempKey,
        shortDescription,
        shortDescriptionEn,
        currency,
        isFeatured,
        systemCommissionRate,
      ];
}

class UpdatePropertyEvent extends PropertiesEvent {
  /// العربية: يخزن القيمة `propertyId`.
  final String propertyId;
  final String? name;
  final String? nameEn;
  final String? address;
  final String? addressEn;
  final String? description;
  final String? descriptionEn;
  final double? latitude;
  final double? longitude;
  final String? city;
  final int? starRating;
  final List<String>? images;
  final String? shortDescription;
  final String? shortDescriptionEn;
  final String? currency;
  final bool? isFeatured;
  final double? systemCommissionRate;
  final String? ownerId;
  final List<String>? amenityIds;
  const UpdatePropertyEvent({
    required this.propertyId,
    this.name,
    this.nameEn,
    this.address,
    this.addressEn,
    this.description,
    this.descriptionEn,
    this.latitude,
    this.longitude,
    this.city,
    this.starRating,
    this.images,
    this.shortDescription,
    this.shortDescriptionEn,
    this.currency,
    this.isFeatured,
    this.systemCommissionRate,
    this.ownerId,
    this.amenityIds,
  });
  @override
  List<Object?> get props => [
        propertyId,
        name,
        nameEn,
        address,
        addressEn,
        description,
        descriptionEn,
        latitude,
        longitude,
        city,
        starRating,
        images,
        shortDescription,
        shortDescriptionEn,
        currency,
        isFeatured,
        systemCommissionRate,
        ownerId,
        amenityIds,
      ];
}

class DeletePropertyEvent extends PropertiesEvent {
  /// العربية: يخزن القيمة `propertyId`.
  final String propertyId;
  const DeletePropertyEvent(this.propertyId);
  @override
  List<Object> get props => [propertyId];
}

class ApprovePropertyEvent extends PropertiesEvent {
  /// العربية: يخزن القيمة `propertyId`.
  final String propertyId;
  const ApprovePropertyEvent(this.propertyId);
  @override
  List<Object> get props => [propertyId];
}

class RejectPropertyEvent extends PropertiesEvent {
  /// العربية: يخزن القيمة `propertyId`.
  final String propertyId;
  const RejectPropertyEvent(this.propertyId);
  @override
  List<Object> get props => [propertyId];
}

class FilterPropertiesEvent extends PropertiesEvent {
  /// العربية: يخزن القيمة `searchTerm`.
  final String? searchTerm;
  final String? propertyTypeId;
  final double? minPrice;
  final double? maxPrice;
  final List<String>? amenityIds;
  final List<int>? starRatings;
  final double? minAverageRating;
  final bool? isApproved;
  final bool? hasActiveBookings;
  const FilterPropertiesEvent({
    this.searchTerm,
    this.propertyTypeId,
    this.minPrice,
    this.maxPrice,
    this.amenityIds,
    this.starRatings,
    this.minAverageRating,
    this.isApproved,
    this.hasActiveBookings,
  });
  @override
  List<Object?> get props => [
        searchTerm,
        propertyTypeId,
        minPrice,
        maxPrice,
        amenityIds,
        starRatings,
        minAverageRating,
        isApproved,
        hasActiveBookings,
      ];
}

class SearchPropertiesEvent extends PropertiesEvent {
  /// العربية: يخزن القيمة `searchTerm`.
  final String searchTerm;
  const SearchPropertiesEvent(this.searchTerm);
  @override
  List<Object> get props => [searchTerm];
}

/// Event to load the next page and append to existing list
class LoadMorePropertiesEvent extends PropertiesEvent {
  /// العربية: يخزن القيمة `pageNumber`.
  final int? pageNumber;
  final int? pageSize;
  const LoadMorePropertiesEvent({this.pageNumber, this.pageSize});
  @override
  List<Object?> get props => [pageNumber, pageSize];
}
