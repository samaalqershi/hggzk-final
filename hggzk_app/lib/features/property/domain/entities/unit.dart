import 'package:equatable/equatable.dart';

/// Lists the supported PricingMethod values used by this feature.
/// العربية: يعرّف القيم المتاحة للنوع `PricingMethod`.
enum PricingMethod { hourly, daily, weekly, monthly }

/// Describes the Unit type used in the property feature.
/// العربية: يمثل `Unit`.
class Unit extends Equatable {
  /// Keeps the id value available to this object.
  /// العربية: يخزن القيمة `id`.
  final String id;

  /// Keeps the propertyId value available to this object.
  /// العربية: يخزن القيمة `propertyId`.
  final String propertyId;

  /// Keeps the unitTypeId value available to this object.
  /// العربية: يخزن القيمة `unitTypeId`.
  final String unitTypeId;

  /// Keeps the name value available to this object.
  /// العربية: يخزن القيمة `name`.
  final String name;

  /// Keeps the customFeatures value available to this object.
  /// العربية: يخزن القيمة `customFeatures`.
  final String customFeatures;

  /// Keeps the propertyName value available to this object.
  /// العربية: يخزن القيمة `propertyName`.
  final String propertyName;

  /// Keeps the unitTypeName value available to this object.
  /// العربية: يخزن القيمة `unitTypeName`.
  final String unitTypeName;

  /// Keeps the pricingMethod value available to this object.
  /// العربية: يخزن القيمة `pricingMethod`.
  final PricingMethod pricingMethod;

  /// Keeps the fieldValues value available to this object.
  /// العربية: يخزن القيمة `fieldValues`.
  final List<UnitFieldValue> fieldValues;

  /// Keeps the dynamicFields value available to this object.
  /// العربية: يخزن القيمة `dynamicFields`.
  final List<FieldGroupWithValues> dynamicFields;

  /// Keeps the distanceKm value available to this object.
  /// العربية: يخزن القيمة `distanceKm`.
  final double? distanceKm;

  /// Keeps the images value available to this object.
  /// العربية: يخزن القيمة `images`.
  final List<UnitImage> images;

  /// Keeps the adultCapacity value available to this object.
  /// العربية: يخزن القيمة `adultCapacity`.
  final int? adultCapacity;

  /// Keeps the childrenCapacity value available to this object.
  /// العربية: يخزن القيمة `childrenCapacity`.
  final int? childrenCapacity;

  /// Keeps the totalPrice value available to this object.
  /// العربية: يخزن القيمة `totalPrice`.
  final double? totalPrice;

  /// Keeps the pricePerNight value available to this object.
  /// العربية: يخزن القيمة `pricePerNight`.
  final double? pricePerNight;

  /// Keeps the currency value available to this object.
  /// العربية: يخزن القيمة `currency`.
  final String? currency;

  /// Constructs the Unit value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `Unit`.
  const Unit({
    required this.id,
    required this.propertyId,
    required this.unitTypeId,
    required this.name,
    required this.customFeatures,
    required this.propertyName,
    required this.unitTypeName,
    required this.pricingMethod,
    required this.fieldValues,
    required this.dynamicFields,
    this.distanceKm,
    required this.images,
    this.adultCapacity,
    this.childrenCapacity,
    this.totalPrice,
    this.pricePerNight,
    this.currency,
  });

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [
        id,
        propertyId,
        unitTypeId,
        name,
        customFeatures,
        propertyName,
        unitTypeName,
        pricingMethod,
        fieldValues,
        dynamicFields,
        distanceKm,
        images,
        adultCapacity,
        childrenCapacity,
        totalPrice,
        pricePerNight,
        currency,
      ];
}

/// Describes the Money type used in the property feature.
/// العربية: يمثل `Money`.
class Money extends Equatable {
  /// Keeps the amount value available to this object.
  /// العربية: يخزن القيمة `amount`.
  final double amount;

  /// Keeps the currency value available to this object.
  /// العربية: يخزن القيمة `currency`.
  final String currency;

  /// Keeps the exchangeRate value available to this object.
  /// العربية: يخزن القيمة `exchangeRate`.
  final double exchangeRate;

  /// Constructs the Money value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `Money`.
  const Money({
    required this.amount,
    this.currency = 'YER',
    this.exchangeRate = 1.0,
  });

  /// Exposes the formattedAmount value to callers that need it.
  /// العربية: يعيد القيمة `formattedAmount`.
  String get formattedAmount => '${amount.toStringAsFixed(2)} $currency';

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [amount, currency, exchangeRate];
}

/// Describes the UnitFieldValue type used in the property feature.
/// العربية: يمثل `UnitFieldValue`.
class UnitFieldValue extends Equatable {
  /// Keeps the valueId value available to this object.
  /// العربية: يخزن القيمة `valueId`.
  final String valueId;

  /// Keeps the fieldId value available to this object.
  /// العربية: يخزن القيمة `fieldId`.
  final String fieldId;

  /// Keeps the fieldName value available to this object.
  /// العربية: يخزن القيمة `fieldName`.
  final String fieldName;

  /// Keeps the displayName value available to this object.
  /// العربية: يخزن القيمة `displayName`.
  final String displayName;

  /// Keeps the value value available to this object.
  /// العربية: يخزن القيمة `value`.
  final String value;

  /// Keeps the fieldTypeId value available to this object.
  /// العربية: يخزن القيمة `fieldTypeId`.
  final String? fieldTypeId;

  /// Indicates whether `isPrimaryFilter` is enabled.
  /// العربية: يحدد ما إذا كانت القيمة `isPrimaryFilter` مفعلة.
  final bool? isPrimaryFilter;

  /// Constructs the UnitFieldValue value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `UnitFieldValue`.
  const UnitFieldValue({
    required this.valueId,
    required this.fieldId,
    required this.fieldName,
    required this.displayName,
    required this.value,
    this.fieldTypeId,
    this.isPrimaryFilter,
  });

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [
        valueId,
        fieldId,
        fieldName,
        displayName,
        value,
        fieldTypeId,
        isPrimaryFilter
      ];
}

/// Describes the FieldGroupWithValues type used in the property feature.
/// العربية: يمثل `FieldGroupWithValues`.
class FieldGroupWithValues extends Equatable {
  /// Keeps the groupId value available to this object.
  /// العربية: يخزن القيمة `groupId`.
  final String groupId;

  /// Keeps the groupName value available to this object.
  /// العربية: يخزن القيمة `groupName`.
  final String groupName;

  /// Keeps the displayName value available to this object.
  /// العربية: يخزن القيمة `displayName`.
  final String displayName;

  /// Keeps the description value available to this object.
  /// العربية: يخزن القيمة `description`.
  final String description;

  /// Keeps the fieldValues value available to this object.
  /// العربية: يخزن القيمة `fieldValues`.
  final List<UnitFieldValue> fieldValues;

  /// Constructs the FieldGroupWithValues value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `FieldGroupWithValues`.
  const FieldGroupWithValues({
    required this.groupId,
    required this.groupName,
    required this.displayName,
    required this.description,
    required this.fieldValues,
  });

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [
        groupId,
        groupName,
        displayName,
        description,
        fieldValues,
      ];
}

/// Describes the UnitImage type used in the property feature.
/// العربية: يمثل `UnitImage`.
class UnitImage extends Equatable {
  /// Keeps the id value available to this object.
  /// العربية: يخزن القيمة `id`.
  final String id;

  /// Keeps the url value available to this object.
  /// العربية: يخزن القيمة `url`.
  final String url;

  /// Keeps the caption value available to this object.
  /// العربية: يخزن القيمة `caption`.
  final String caption;

  /// Indicates whether `isMain` is enabled.
  /// العربية: يحدد ما إذا كانت القيمة `isMain` مفعلة.
  final bool isMain;

  /// Keeps the displayOrder value available to this object.
  /// العربية: يخزن القيمة `displayOrder`.
  final int displayOrder;

  /// Keeps the is360 value available to this object.
  /// العربية: يخزن القيمة `is360`.
  final bool is360;

  /// Constructs the UnitImage value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `UnitImage`.
  const UnitImage({
    required this.id,
    required this.url,
    required this.caption,
    required this.isMain,
    required this.displayOrder,
    this.is360 = false,
  });

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [id, url, caption, isMain, displayOrder, is360];
}
