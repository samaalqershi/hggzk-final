// Shared filter DTOs used by helpers facades. No UI here.

/// يعرّف الكلاس `UserSearchFilters`.
/// Describes the `UserSearchFilters` class.
class UserSearchFilters {
  /// Holds the `pageNumber` value.
  /// العربية: يخزن القيمة `pageNumber`.
  final int? pageNumber;

  /// يخزن العضو `pageSize`.
  /// Holds the `pageSize` member.
  final int? pageSize;

  /// يخزن العضو `searchTerm`.
  /// Holds the `searchTerm` member.
  final String? searchTerm;

  /// يخزن العضو `sortBy`.
  /// Holds the `sortBy` member.
  final String? sortBy;

  /// يخزن العضو `isAscending`.
  /// Holds the `isAscending` member.
  final bool? isAscending;

  /// يخزن العضو `roleId`.
  /// Holds the `roleId` member.
  final String? roleId;

  /// يخزن العضو `isActive`.
  /// Holds the `isActive` member.
  final bool? isActive;

  /// يخزن العضو `createdAfter`.
  /// Holds the `createdAfter` member.
  final DateTime? createdAfter;

  /// يخزن العضو `createdBefore`.
  /// Holds the `createdBefore` member.
  final DateTime? createdBefore;

  /// يخزن العضو `lastLoginAfter`.
  /// Holds the `lastLoginAfter` member.
  final DateTime? lastLoginAfter;

  /// يخزن العضو `loyaltyTier`.
  /// Holds the `loyaltyTier` member.
  final String? loyaltyTier;

  /// يخزن العضو `minTotalSpent`.
  /// Holds the `minTotalSpent` member.
  final double? minTotalSpent;

  /// ينشئ مثيلاً من `UserSearchFilters`.
  /// Builds an instance of `UserSearchFilters`.
  const UserSearchFilters({
    this.pageNumber,
    this.pageSize,
    this.searchTerm,
    this.sortBy,
    this.isAscending,
    this.roleId,
    this.isActive,
    this.createdAfter,
    this.createdBefore,
    this.lastLoginAfter,
    this.loyaltyTier,
    this.minTotalSpent,
  });
}

/// يعرّف الكلاس `PropertySearchFilters`.
/// Describes the `PropertySearchFilters` class.
class PropertySearchFilters {
  /// Holds the `pageNumber` value.
  /// العربية: يخزن القيمة `pageNumber`.
  final int? pageNumber;

  /// يخزن العضو `pageSize`.
  /// Holds the `pageSize` member.
  final int? pageSize;

  /// يخزن العضو `searchTerm`.
  /// Holds the `searchTerm` member.
  final String? searchTerm;

  /// يخزن العضو `propertyTypeId`.
  /// Holds the `propertyTypeId` member.
  final String? propertyTypeId;

  /// يخزن العضو `sortBy`.
  /// Holds the `sortBy` member.
  final String? sortBy;

  /// يخزن العضو `isAscending`.
  /// Holds the `isAscending` member.
  final bool? isAscending;

  /// يخزن العضو `minPrice`.
  /// Holds the `minPrice` member.
  final double? minPrice;

  /// يخزن العضو `maxPrice`.
  /// Holds the `maxPrice` member.
  final double? maxPrice;

  /// يخزن العضو `amenityIds`.
  /// Holds the `amenityIds` member.
  final List<String>? amenityIds;

  /// يخزن العضو `starRatings`.
  /// Holds the `starRatings` member.
  final List<int>? starRatings;

  /// يخزن العضو `minAverageRating`.
  /// Holds the `minAverageRating` member.
  final double? minAverageRating;

  /// يخزن العضو `isApproved`.
  /// Holds the `isApproved` member.
  final bool? isApproved;

  /// يخزن العضو `hasActiveBookings`.
  /// Holds the `hasActiveBookings` member.
  final bool? hasActiveBookings;

  /// ينشئ مثيلاً من `PropertySearchFilters`.
  /// Builds an instance of `PropertySearchFilters`.
  const PropertySearchFilters({
    this.pageNumber,
    this.pageSize,
    this.searchTerm,
    this.propertyTypeId,
    this.sortBy,
    this.isAscending,
    this.minPrice,
    this.maxPrice,
    this.amenityIds,
    this.starRatings,
    this.minAverageRating,
    this.isApproved,
    this.hasActiveBookings,
  });
}

/// يعرّف الكلاس `UnitSearchFilters`.
/// Describes the `UnitSearchFilters` class.
class UnitSearchFilters {
  /// Holds the `pageNumber` value.
  /// العربية: يخزن القيمة `pageNumber`.
  final int? pageNumber;

  /// يخزن العضو `pageSize`.
  /// Holds the `pageSize` member.
  final int? pageSize;

  /// يخزن العضو `propertyId`.
  /// Holds the `propertyId` member.
  final String? propertyId;

  /// يخزن العضو `unitTypeId`.
  /// Holds the `unitTypeId` member.
  final String? unitTypeId;

  /// يخزن العضو `isAvailable`.
  /// Holds the `isAvailable` member.
  final bool? isAvailable;

  /// يخزن العضو `minPrice`.
  /// Holds the `minPrice` member.
  final double? minPrice;

  /// يخزن العضو `maxPrice`.
  /// Holds the `maxPrice` member.
  final double? maxPrice;

  /// يخزن العضو `searchQuery`.
  /// Holds the `searchQuery` member.
  final String? searchQuery;

  /// ينشئ مثيلاً من `UnitSearchFilters`.
  /// Builds an instance of `UnitSearchFilters`.
  const UnitSearchFilters({
    this.pageNumber,
    this.pageSize,
    this.propertyId,
    this.unitTypeId,
    this.isAvailable,
    this.minPrice,
    this.maxPrice,
    this.searchQuery,
  });
}
