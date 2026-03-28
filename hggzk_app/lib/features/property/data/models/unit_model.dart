import 'dart:convert';
import '../../domain/entities/unit.dart';

/// Describes the UnitModel data model used to parse and emit property API payloads.
/// العربية: يمثل نموذج البيانات `UnitModel`.
class UnitModel extends Unit {
  /// Constructs the UnitModel value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `UnitModel`.
  const UnitModel({
    required super.id,
    required super.propertyId,
    required super.unitTypeId,
    required super.name,
    required super.customFeatures,
    required super.propertyName,
    required super.unitTypeName,
    required super.pricingMethod,
    required super.fieldValues,
    required super.dynamicFields,
    super.distanceKm,
    required super.images,
    super.adultCapacity,
    super.childrenCapacity,
    super.totalPrice,
    super.pricePerNight,
    super.currency,
  });

  /// Constructs the UnitModel.fromJson value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `UnitModel.fromJson`.
  factory UnitModel.fromJson(Map<String, dynamic> json) {
    final unitType = json['unitType'] as Map<String, dynamic>?;
    final unitTypeName =
        (json['unitTypeName'] ?? unitType?['name'] ?? '').toString();
    final unitTypeId =
        (json['unitTypeId'] ?? unitType?['id']?.toString() ?? '').toString();

    final cf = json['customFeatures'];
    final customFeatures =
        cf == null ? '' : (cf is String ? cf : jsonEncode(cf));

    final images = (json['images'] as List?)
            ?.map((e) => UnitImageModel.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];

    final fieldValues = (json['fieldValues'] as List?)
            ?.map((e) =>
                UnitFieldValueModel.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];

    return UnitModel(
      id: (json['id'] ?? '').toString(),
      propertyId: (json['propertyId'] ?? '').toString(),
      unitTypeId: unitTypeId,
      name: (json['name'] ?? '').toString(),
      customFeatures: customFeatures,
      propertyName: (json['propertyName'] ?? '').toString(),
      unitTypeName: unitTypeName,
      pricingMethod: _parsePricingMethod(json['pricingMethod']),
      fieldValues: fieldValues,
      dynamicFields: (json['dynamicFields'] as List?)
              ?.map((e) => FieldGroupWithValuesModel.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      images: images,
      adultCapacity: json['adultCapacity'] as int?,
      childrenCapacity: json['childrenCapacity'] as int?,
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      pricePerNight: (json['pricePerNight'] as num?)?.toDouble(),
      currency: json['currency']?.toString(),
    );
  }

  /// Parses the pricing method.
  /// العربية: يحلل pricing method.
  static PricingMethod _parsePricingMethod(dynamic method) {
    if (method == null) return PricingMethod.daily;
    switch (method.toString().toLowerCase()) {
      case 'hourly':
        return PricingMethod.hourly;
      case 'weekly':
        return PricingMethod.weekly;
      case 'monthly':
        return PricingMethod.monthly;
      default:
        return PricingMethod.daily;
    }
  }

  /// Converts this instance to a JSON representation.
  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propertyId': propertyId,
      'unitTypeId': unitTypeId,
      'name': name,
      'customFeatures': customFeatures,
      'propertyName': propertyName,
      'unitTypeName': unitTypeName,
      'pricingMethod': pricingMethod.name,
      'fieldValues':
          fieldValues.map((e) => (e as UnitFieldValueModel).toJson()).toList(),
      'dynamicFields': dynamicFields
          .map((e) => (e as FieldGroupWithValuesModel).toJson())
          .toList(),
      'distanceKm': distanceKm,
      'images': images.map((e) => (e as UnitImageModel).toJson()).toList(),
      'adultCapacity': adultCapacity,
      'childrenCapacity': childrenCapacity,
      'totalPrice': totalPrice,
      'pricePerNight': pricePerNight,
      'currency': currency,
    };
  }
}

/// Describes the MoneyModel data model used to parse and emit property API payloads.
/// العربية: يمثل نموذج البيانات `MoneyModel`.
class MoneyModel extends Money {
  /// Constructs the MoneyModel value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `MoneyModel`.
  const MoneyModel({
    required super.amount,
    super.currency,
    super.exchangeRate,
  });

  /// Constructs the MoneyModel.fromJson value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `MoneyModel.fromJson`.
  factory MoneyModel.fromJson(Map<String, dynamic> json) {
    return MoneyModel(
      amount: (json['amount'] ?? 0).toDouble(),
      currency: (json['currency'] ?? 'YER').toString(),
      exchangeRate: (json['exchangeRate'] ?? 1.0).toDouble(),
    );
  }

  /// Converts this instance to a JSON representation.
  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency,
      'exchangeRate': exchangeRate,
      'formattedAmount': formattedAmount,
    };
  }
}

/// Describes the UnitFieldValueModel data model used to parse and emit property API payloads.
/// العربية: يمثل نموذج البيانات `UnitFieldValueModel`.
class UnitFieldValueModel extends UnitFieldValue {
  /// Constructs the UnitFieldValueModel value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `UnitFieldValueModel`.
  const UnitFieldValueModel({
    required super.valueId,
    required super.fieldId,
    required super.fieldName,
    required super.displayName,
    required super.value,
    super.fieldTypeId,
    super.isPrimaryFilter,
  });

  /// Constructs the UnitFieldValueModel.fromJson value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `UnitFieldValueModel.fromJson`.
  factory UnitFieldValueModel.fromJson(Map<String, dynamic> json) {
    // Support both detailed and simple shapes
    final hasIds = json.containsKey('valueId') || json.containsKey('fieldId');
    if (hasIds) {
      return UnitFieldValueModel(
        valueId: (json['valueId'] ?? '').toString(),
        fieldId: (json['fieldId'] ?? '').toString(),
        fieldName: (json['fieldName'] ?? '').toString(),
        displayName: (json['displayName'] ?? '').toString(),
        value: (json['value'] ?? '').toString(),
        fieldTypeId: json['fieldTypeId']?.toString(),
        isPrimaryFilter: json['isPrimaryFilter'] as bool?,
      );
    }
    return UnitFieldValueModel(
      valueId: '',
      fieldId: '',
      fieldName: (json['fieldName'] ?? '').toString(),
      displayName: (json['displayName'] ?? '').toString(),
      value: (json['value'] ?? '').toString(),
      fieldTypeId: json['fieldTypeId']?.toString(),
      isPrimaryFilter: json['isPrimaryFilter'] as bool?,
    );
  }

  /// Converts this instance to a JSON representation.
  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'valueId': valueId,
      'fieldId': fieldId,
      'fieldName': fieldName,
      'displayName': displayName,
      'value': value,
      'fieldTypeId': fieldTypeId,
      'isPrimaryFilter': isPrimaryFilter,
    };
  }
}

/// Describes the FieldGroupWithValuesModel data model used to parse and emit property API payloads.
/// العربية: يمثل نموذج البيانات `FieldGroupWithValuesModel`.
class FieldGroupWithValuesModel extends FieldGroupWithValues {
  /// Constructs the FieldGroupWithValuesModel value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `FieldGroupWithValuesModel`.
  const FieldGroupWithValuesModel({
    required super.groupId,
    required super.groupName,
    required super.displayName,
    required super.description,
    required super.fieldValues,
  });

  /// Constructs the FieldGroupWithValuesModel.fromJson value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `FieldGroupWithValuesModel.fromJson`.
  factory FieldGroupWithValuesModel.fromJson(Map<String, dynamic> json) {
    return FieldGroupWithValuesModel(
      groupId: (json['groupId'] ?? '').toString(),
      groupName: (json['groupName'] ?? '').toString(),
      displayName: (json['displayName'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      fieldValues: (json['fieldValues'] as List?)
              ?.map((e) =>
                  UnitFieldValueModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
    );
  }

  /// Converts this instance to a JSON representation.
  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'displayName': displayName,
      'description': description,
      'fieldValues':
          fieldValues.map((e) => (e as UnitFieldValueModel).toJson()).toList(),
    };
  }
}

/// Describes the UnitImageModel data model used to parse and emit property API payloads.
/// العربية: يمثل نموذج البيانات `UnitImageModel`.
class UnitImageModel extends UnitImage {
  /// Constructs the UnitImageModel value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `UnitImageModel`.
  const UnitImageModel({
    required super.id,
    required super.url,
    required super.caption,
    required super.isMain,
    required super.displayOrder,
    super.is360,
  });

  /// Constructs the UnitImageModel.fromJson value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `UnitImageModel.fromJson`.
  factory UnitImageModel.fromJson(Map<String, dynamic> json) {
    return UnitImageModel(
      id: (json['id'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
      caption: (json['caption'] ?? '').toString(),
      isMain: (json['isMain'] ?? false) as bool,
      displayOrder: (json['displayOrder'] ?? 0) as int,
      is360: (json['is360'] ?? false) as bool,
    );
  }

  /// Converts this instance to a JSON representation.
  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'caption': caption,
      'isMain': isMain,
      'displayOrder': displayOrder,
      'is360': is360,
    };
  }
}
