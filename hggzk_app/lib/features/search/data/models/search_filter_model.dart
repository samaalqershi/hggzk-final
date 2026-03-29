import 'package:hggzk/features/search/domain/entities/search_result.dart';
import 'package:hggzk/core/localization/localized_api_value.dart';

import '../../domain/entities/search_filter.dart';

/// العربية: يمثل نموذج البيانات `SearchFilterModel`.
class SearchFilterModel extends SearchFilter {
  /// العربية: ينشئ مثيلًا جديدًا من `SearchFilterModel`.
  const SearchFilterModel({
    required super.filterId,
    required super.fieldId,
    required super.filterType,
    required super.displayName,
    required super.filterOptions,
    required super.isActive,
    required super.sortOrder,
    super.field,
  });

  /// العربية: ينشئ مثيلًا جديدًا من `SearchFilterModel.fromJson`.
  factory SearchFilterModel.fromJson(Map<String, dynamic> json) {
    return SearchFilterModel(
      filterId: json['filterId'] ?? '',
      fieldId: json['fieldId'] ?? '',
      filterType: json['filterType'] ?? '',
      displayName: LocalizedApiValue.text(
        json,
        arabicKey: 'displayName',
        englishKey: 'displayNameEn',
      ),
      filterOptions: LocalizedApiValue.map(
        json,
        arabicKey: 'filterOptions',
        englishKey: 'filterOptionsEn',
      ),
      isActive: json['isActive'] ?? false,
      sortOrder: json['sortOrder'] ?? 0,
      field: json['field'] != null
          ? UnitTypeFieldModel.fromJson(json['field'])
          : null,
    );
  }

  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'filterId': filterId,
      'fieldId': fieldId,
      'filterType': filterType,
      'displayName': displayName,
      'filterOptions': filterOptions,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'field': field != null ? (field as UnitTypeFieldModel).toJson() : null,
    };
  }
}

/// العربية: يمثل نموذج البيانات `UnitTypeFieldModel`.
class UnitTypeFieldModel extends UnitTypeField {
  /// العربية: ينشئ مثيلًا جديدًا من `UnitTypeFieldModel`.
  const UnitTypeFieldModel({
    required super.fieldId,
    required super.unitTypeId,
    required super.fieldTypeId,
    required super.fieldName,
    required super.displayName,
    super.description,
    required super.fieldOptions,
    required super.validationRules,
    required super.isRequired,
    required super.isSearchable,
    required super.isPublic,
    required super.sortOrder,
    super.category,
    super.groupId,
    required super.isForUnits,
    required super.showInCards,
    required super.isPrimaryFilter,
    required super.priority,
  });

  /// العربية: ينشئ مثيلًا جديدًا من `UnitTypeFieldModel.fromJson`.
  factory UnitTypeFieldModel.fromJson(Map<String, dynamic> json) {
    return UnitTypeFieldModel(
      fieldId: json['fieldId'] ?? '',
      unitTypeId: json['unitTypeId'] ?? '',
      fieldTypeId: json['fieldTypeId'] ?? '',
      fieldName: json['fieldName'] ?? '',
      displayName: LocalizedApiValue.text(
        json,
        arabicKey: 'displayName',
        englishKey: 'displayNameEn',
        fallbackKey: 'fieldName',
      ),
      description: LocalizedApiValue.text(
        json,
        arabicKey: 'description',
        englishKey: 'descriptionEn',
      ),
      fieldOptions: LocalizedApiValue.map(
        json,
        arabicKey: 'fieldOptions',
        englishKey: 'fieldOptionsEn',
      ),
      validationRules: Map<String, dynamic>.from(json['validationRules'] ?? {}),
      isRequired: json['isRequired'] ?? false,
      isSearchable: json['isSearchable'] ?? false,
      isPublic: json['isPublic'] ?? false,
      sortOrder: json['sortOrder'] ?? 0,
      category: LocalizedApiValue.text(
        json,
        arabicKey: 'category',
        englishKey: 'categoryEn',
      ),
      groupId: json['groupId'],
      isForUnits: json['isForUnits'] ?? false,
      showInCards: json['showInCards'] ?? false,
      isPrimaryFilter: json['isPrimaryFilter'] ?? false,
      priority: json['priority'] ?? 0,
    );
  }

  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'fieldId': fieldId,
      'unitTypeId': unitTypeId,
      'fieldTypeId': fieldTypeId,
      'fieldName': fieldName,
      'displayName': displayName,
      'description': description,
      'fieldOptions': fieldOptions,
      'validationRules': validationRules,
      'isRequired': isRequired,
      'isSearchable': isSearchable,
      'isPublic': isPublic,
      'sortOrder': sortOrder,
      'category': category,
      'groupId': groupId,
      'isForUnits': isForUnits,
      'showInCards': showInCards,
      'isPrimaryFilter': isPrimaryFilter,
      'priority': priority,
    };
  }
}

/// العربية: يمثل نموذج البيانات `SearchFiltersModel`.
class SearchFiltersModel extends SearchFilters {
  /// العربية: ينشئ مثيلًا جديدًا من `SearchFiltersModel`.
  const SearchFiltersModel({
    required super.cities,
    required super.propertyTypes,
    required super.priceRange,
    required super.amenities,
    required super.starRatings,
    required super.starRatingOptions,
    required super.availableCities,
    required super.maxGuestCapacity,
    required super.unitTypes,
    required super.distanceRange,
    required super.supportedCurrencies,
    required super.services,
    required super.dynamicFieldValues,
  });

  /// العربية: ينشئ مثيلًا جديدًا من `SearchFiltersModel.fromJson`.
  factory SearchFiltersModel.fromJson(Map<String, dynamic> json) {
    return SearchFiltersModel(
      cities: (json['cities'] as List?)
              ?.map((e) => CityFilterModel.fromJson(e))
              .toList() ??
          [],
      propertyTypes: (json['propertyTypes'] as List?)
              ?.map((e) => PropertyTypeFilterModel.fromJson(e))
              .toList() ??
          [],
      priceRange: json['priceRange'] != null
          ? PriceRangeModel.fromJson(json['priceRange'])
          : const PriceRangeModel(minPrice: 0, maxPrice: 0, averagePrice: 0),
      amenities: (json['amenities'] as List?)
              ?.map((e) => AmenityFilterModel.fromJson(e))
              .toList() ??
          [],
      starRatings:
          (json['starRatings'] as List?)?.map((e) => e as int).toList() ?? [],
      starRatingOptions: (json['starRatingOptions'] as List?)
              ?.map((e) => StarRatingOptionModel.fromJson(e))
              .toList() ??
          [],
      availableCities: (json['availableCities'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      maxGuestCapacity: json['maxGuestCapacity'] ?? 0,
      unitTypes: (json['unitTypes'] as List?)
              ?.map((e) => UnitTypeFilterModel.fromJson(e))
              .toList() ??
          [],
      distanceRange: json['distanceRange'] != null
          ? DistanceRangeModel.fromJson(json['distanceRange'])
          : const DistanceRangeModel(minDistance: 0, maxDistance: 50),
      supportedCurrencies: (json['supportedCurrencies'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      services: (json['services'] as List?)
              ?.map((e) => ServiceFilterModel.fromJson(e))
              .toList() ??
          [],
      dynamicFieldValues: (json['dynamicFieldValues'] as List?)
              ?.map((e) => DynamicFieldValueFilterModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'cities': cities.map((e) => (e as CityFilterModel).toJson()).toList(),
      'propertyTypes': propertyTypes
          .map((e) => (e as PropertyTypeFilterModel).toJson())
          .toList(),
      'priceRange': (priceRange as PriceRangeModel).toJson(),
      'amenities':
          amenities.map((e) => (e as AmenityFilterModel).toJson()).toList(),
      'starRatings': starRatings,
      'starRatingOptions': starRatingOptions
          .map((e) => (e as StarRatingOptionModel).toJson())
          .toList(),
      'availableCities': availableCities,
      'maxGuestCapacity': maxGuestCapacity,
      'unitTypes':
          unitTypes.map((e) => (e as UnitTypeFilterModel).toJson()).toList(),
      'distanceRange': (distanceRange as DistanceRangeModel).toJson(),
      'supportedCurrencies': supportedCurrencies,
      'services':
          services.map((e) => (e as ServiceFilterModel).toJson()).toList(),
      'dynamicFieldValues': dynamicFieldValues
          .map((e) => (e as DynamicFieldValueFilterModel).toJson())
          .toList(),
    };
  }
}

/// العربية: يمثل نموذج البيانات `CityFilterModel`.
class CityFilterModel extends CityFilter {
  /// العربية: ينشئ مثيلًا جديدًا من `CityFilterModel`.
  const CityFilterModel({
    required super.id,
    required super.name,
    required super.propertiesCount,
  });

  /// العربية: ينشئ مثيلًا جديدًا من `CityFilterModel.fromJson`.
  factory CityFilterModel.fromJson(Map<String, dynamic> json) {
    return CityFilterModel(
      id: json['id'] ?? '',
      name: LocalizedApiValue.text(
        json,
        arabicKey: 'name',
        englishKey: 'nameEn',
      ),
      propertiesCount: json['propertiesCount'] ?? 0,
    );
  }

  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'propertiesCount': propertiesCount,
    };
  }
}

/// العربية: يمثل نموذج البيانات `PropertyTypeFilterModel`.
class PropertyTypeFilterModel extends PropertyTypeFilter {
  /// العربية: يخزن القيمة `icon`.
  final String icon;

  /// العربية: ينشئ مثيلًا جديدًا من `PropertyTypeFilterModel`.
  const PropertyTypeFilterModel({
    required super.id,
    required super.name,
    required super.propertiesCount,
    this.icon = 'home', // Default icon if not provided
  });

  /// العربية: ينشئ مثيلًا جديدًا من `PropertyTypeFilterModel.fromJson`.
  factory PropertyTypeFilterModel.fromJson(Map<String, dynamic> json) {
    return PropertyTypeFilterModel(
      id: json['id'] ?? '',
      name: LocalizedApiValue.text(
        json,
        arabicKey: 'name',
        englishKey: 'nameEn',
      ),
      propertiesCount: json['propertiesCount'] ?? 0,
      icon: json['icon'] ?? 'home', // Default icon if not provided
    );
  }

  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'propertiesCount': propertiesCount,
      'icon': icon,
    };
  }
}

/// العربية: يمثل نموذج البيانات `PriceRangeModel`.
class PriceRangeModel extends PriceRange {
  /// العربية: ينشئ مثيلًا جديدًا من `PriceRangeModel`.
  const PriceRangeModel({
    required super.minPrice,
    required super.maxPrice,
    required super.averagePrice,
  });

  /// العربية: ينشئ مثيلًا جديدًا من `PriceRangeModel.fromJson`.
  factory PriceRangeModel.fromJson(Map<String, dynamic> json) {
    return PriceRangeModel(
      minPrice: (json['minPrice'] ?? 0).toDouble(),
      maxPrice: (json['maxPrice'] ?? 0).toDouble(),
      averagePrice: (json['averagePrice'] ?? 0).toDouble(),
    );
  }

  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'averagePrice': averagePrice,
    };
  }
}

/// العربية: يمثل نموذج البيانات `AmenityFilterModel`.
class AmenityFilterModel extends AmenityFilter {
  /// العربية: ينشئ مثيلًا جديدًا من `AmenityFilterModel`.
  const AmenityFilterModel({
    required super.id,
    required super.name,
    required super.category,
    required super.propertiesCount,
    super.icon = '',
    super.propertyTypeIds = const [],
  });

  /// العربية: ينشئ مثيلًا جديدًا من `AmenityFilterModel.fromJson`.
  factory AmenityFilterModel.fromJson(Map<String, dynamic> json) {
    return AmenityFilterModel(
      id: json['id'] ?? '',
      name: LocalizedApiValue.text(
        json,
        arabicKey: 'name',
        englishKey: 'nameEn',
      ),
      category: json['category'] ?? '',
      propertiesCount: json['propertiesCount'] ?? 0,
      icon: json['icon'] ?? '',
      propertyTypeIds: (json['propertyTypeIds'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'propertiesCount': propertiesCount,
      'icon': icon,
      'propertyTypeIds': propertyTypeIds,
    };
  }
}

/// العربية: يمثل نموذج البيانات `UnitTypeFilterModel`.
class UnitTypeFilterModel extends UnitTypeFilter {
  // The ID of the property type this unit type belongs to
  /// العربية: يخزن القيمة `icon`.
  final String icon;

  /// العربية: ينشئ مثيلًا جديدًا من `UnitTypeFilterModel`.
  const UnitTypeFilterModel({
    required super.id,
    required super.name,
    required super.propertyTypeId,
    required super.unitsCount,
    super.isHasAdults = false,
    super.isHasChildren = false,
    super.isMultiDays = false,
    super.isRequiredToDetermineTheHour = false,
    this.icon = 'home',
  });

  /// العربية: ينشئ مثيلًا جديدًا من `UnitTypeFilterModel.fromJson`.
  factory UnitTypeFilterModel.fromJson(Map<String, dynamic> json) {
    return UnitTypeFilterModel(
        id: json['id'] ?? '',
        name: LocalizedApiValue.text(
          json,
          arabicKey: 'name',
          englishKey: 'nameEn',
        ),
        unitsCount: json['unitsCount'] ?? 0,
        propertyTypeId: json['propertyTypeId'] ?? '',
        icon: json['icon'] ?? 'home',
        isHasAdults: json['isHasAdults'] ?? false,
        isHasChildren: json['isHasChildren'] ?? false,
        isMultiDays: json['isMultiDays'] ?? false,
        isRequiredToDetermineTheHour:
            json['isRequiredToDetermineTheHour'] ?? false);
  }

  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unitsCount': unitsCount,
      'propertyTypeId': propertyTypeId,
      'icon': icon,
      'isHasAdults': isHasAdults,
      'isHasChildren': isHasChildren,
      'isMultiDays': isMultiDays,
      'isRequiredToDetermineTheHour': isRequiredToDetermineTheHour,
    };
  }
}

/// العربية: يمثل نموذج البيانات `DistanceRangeModel`.
class DistanceRangeModel extends DistanceRange {
  /// العربية: ينشئ مثيلًا جديدًا من `DistanceRangeModel`.
  const DistanceRangeModel({
    required super.minDistance,
    required super.maxDistance,
  });

  /// العربية: ينشئ مثيلًا جديدًا من `DistanceRangeModel.fromJson`.
  factory DistanceRangeModel.fromJson(Map<String, dynamic> json) {
    return DistanceRangeModel(
      minDistance: (json['minDistance'] ?? 0).toDouble(),
      maxDistance: (json['maxDistance'] ?? 50).toDouble(),
    );
  }

  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'minDistance': minDistance,
      'maxDistance': maxDistance,
    };
  }
}

/// العربية: يمثل نموذج البيانات `ServiceFilterModel`.
class ServiceFilterModel extends ServiceFilter {
  /// العربية: ينشئ مثيلًا جديدًا من `ServiceFilterModel`.
  const ServiceFilterModel({
    required super.id,
    required super.name,
    required super.propertiesCount,
    super.icon = 'service',
  });

  /// العربية: ينشئ مثيلًا جديدًا من `ServiceFilterModel.fromJson`.
  factory ServiceFilterModel.fromJson(Map<String, dynamic> json) {
    return ServiceFilterModel(
      id: json['id'] ?? '',
      name: LocalizedApiValue.text(
        json,
        arabicKey: 'name',
        englishKey: 'nameEn',
      ),
      propertiesCount: json['propertiesCount'] ?? 0,
      icon: json['icon'] ?? 'service',
    );
  }

  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'propertiesCount': propertiesCount,
      'icon': icon,
    };
  }
}

/// العربية: يمثل نموذج البيانات `DynamicFieldValueFilterModel`.
class DynamicFieldValueFilterModel extends DynamicFieldValueFilter {
  /// العربية: ينشئ مثيلًا جديدًا من `DynamicFieldValueFilterModel`.
  const DynamicFieldValueFilterModel({
    required super.fieldName,
    required super.displayName,
    required super.value,
    required super.count,
  });

  /// العربية: ينشئ مثيلًا جديدًا من `DynamicFieldValueFilterModel.fromJson`.
  factory DynamicFieldValueFilterModel.fromJson(Map<String, dynamic> json) {
    return DynamicFieldValueFilterModel(
      fieldName: json['fieldName'] ?? '',
      displayName: LocalizedApiValue.text(
        json,
        arabicKey: 'displayName',
        englishKey: 'displayNameEn',
        fallbackKey: 'fieldName',
      ),
      value: json['value'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'fieldName': fieldName,
      'displayName': displayName,
      'value': value,
      'count': count,
    };
  }
}

/// العربية: يمثل نموذج البيانات `StarRatingOptionModel`.
class StarRatingOptionModel extends StarRatingOption {
  /// العربية: ينشئ مثيلًا جديدًا من `StarRatingOptionModel`.
  const StarRatingOptionModel({
    required super.value,
    required super.propertiesCount,
  });

  /// العربية: ينشئ مثيلًا جديدًا من `StarRatingOptionModel.fromJson`.
  factory StarRatingOptionModel.fromJson(Map<String, dynamic> json) {
    return StarRatingOptionModel(
      value: json['value'] ?? 0,
      propertiesCount: json['propertiesCount'] ?? 0,
    );
  }

  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'propertiesCount': propertiesCount,
    };
  }
}
