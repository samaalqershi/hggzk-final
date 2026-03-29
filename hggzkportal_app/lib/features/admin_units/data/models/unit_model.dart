import 'package:hggzkportal/features/admin_units/domain/entities/unit_field_value.dart';

import '../../domain/entities/unit.dart';
import '../../domain/entities/pricing_method.dart';
import 'unit_field_value_model.dart';

/// يمثل هذا الكلاس UnitModel البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitModel in the admin unit workflow.
class UnitModel extends Unit {
  /// This constructor creates a new UnitModel instance.
  /// ينشئ مثيلًا جديدًا من UnitModel.
  const UnitModel({
    required String id,
    required String propertyId,
    required String unitTypeId,
    required String name,
    String? nameEn,
    int maxCapacity = 2,
    double discountPercentage = 0.0,
    required String customFeatures,
    String? customFeaturesEn,
    int viewCount = 0,
    int bookingCount = 0,
    int? adultsCapacity,
    int? childrenCapacity,
    required String propertyName,
    String? propertyNameEn,
    required String unitTypeName,
    String? unitTypeNameEn,
    required PricingMethod pricingMethod,
    List<UnitFieldValue> fieldValues = const [],
    List<FieldGroupWithValues> dynamicFields = const [],
    double? distanceKm,
    List<String>? images,
    bool allowsCancellation = true,
    int? cancellationWindowDays,
  }) : super(
          id: id,
          propertyId: propertyId,
          unitTypeId: unitTypeId,
          name: name,
          nameEn: nameEn,
          maxCapacity: maxCapacity,
          discountPercentage: discountPercentage,
          customFeatures: customFeatures,
          customFeaturesEn: customFeaturesEn,
          viewCount: viewCount,
          bookingCount: bookingCount,
          adultsCapacity: adultsCapacity,
          childrenCapacity: childrenCapacity,
          propertyName: propertyName,
          propertyNameEn: propertyNameEn,
          unitTypeName: unitTypeName,
          unitTypeNameEn: unitTypeNameEn,
          pricingMethod: pricingMethod,
          fieldValues: fieldValues,
          dynamicFields: dynamicFields,
          distanceKm: distanceKm,
          images: images,
          allowsCancellation: allowsCancellation,
          cancellationWindowDays: cancellationWindowDays,
        );

  /// ينشئ هذا المُنشئ مثيلاً من UnitModel.
  /// This constructor creates an instance of UnitModel.
  factory UnitModel.fromJson(Map<String, dynamic> json) {
    int? readNullableInt(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value == null) continue;
        if (value is int) return value;
        if (value is num) return value.toInt();
        final parsed = int.tryParse(value.toString());
        if (parsed != null) return parsed;
      }
      return null;
    }

    final dynamic cancellationWindowRaw = json['cancellationWindowDays'];
    final int? cancellationWindowDays = cancellationWindowRaw == null
        ? null
        : (cancellationWindowRaw is int
            ? cancellationWindowRaw
            : (cancellationWindowRaw is num
                ? cancellationWindowRaw.toInt()
                : (int.tryParse(cancellationWindowRaw.toString()))));
    final adultsCapacity = readNullableInt([
      'adultsCapacity',
      'adultCapacity',
      'AdultsCapacity',
      'AdultCapacity',
    ]);
    final childrenCapacity = readNullableInt([
      'childrenCapacity',
      'ChildrenCapacity',
    ]);
    final resolvedMaxCapacity = readNullableInt([
          'maxCapacity',
          'MaxCapacity',
        ]) ??
        ((adultsCapacity ?? 0) + (childrenCapacity ?? 0));

    return UnitModel(
      id: json['id'] as String,
      propertyId: json['propertyId'] as String,
      unitTypeId: json['unitTypeId'] as String,
      name: json['name'] as String,
      nameEn: json['nameEn'] as String?,
      maxCapacity: resolvedMaxCapacity,
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      customFeatures: json['customFeatures'] as String? ?? '',
      customFeaturesEn: json['customFeaturesEn'] as String?,
      viewCount: json['viewCount'] as int? ?? 0,
      bookingCount: json['bookingCount'] as int? ?? 0,
      adultsCapacity: adultsCapacity,
      childrenCapacity: childrenCapacity,
      propertyName: json['propertyName'] as String,
      propertyNameEn: json['propertyNameEn'] as String?,
      unitTypeName: json['unitTypeName'] as String,
      unitTypeNameEn: json['unitTypeNameEn'] as String?,
      pricingMethod: PricingMethod.fromString(json['pricingMethod'] as String),
      fieldValues: (json['fieldValues'] as List?)
              ?.map((e) => UnitFieldValueModel.fromJson(e))
              .toList() ??
          [],
      dynamicFields: (json['dynamicFields'] as List?)
              ?.map((e) => FieldGroupWithValuesModel.fromJson(e))
              .toList() ??
          [],
      distanceKm: json['distanceKm'] as double?,
      images:
          (json['images'] as List?)?.map((e) => e['url'] as String).toList() ??
              [],
      allowsCancellation: json['allowsCancellation'] as bool? ?? true,
      cancellationWindowDays: cancellationWindowDays,
    );
  }

  /// ينفذ هذا الأسلوب عملية toJson ضمن مسار إدارة الوحدات.
  /// This method performs the toJson operation in the admin unit workflow.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propertyId': propertyId,
      'unitTypeId': unitTypeId,
      'name': name,
      if (nameEn != null) 'nameEn': nameEn,
      'maxCapacity': maxCapacity,
      'discountPercentage': discountPercentage,
      'customFeatures': customFeatures,
      if (customFeaturesEn != null) 'customFeaturesEn': customFeaturesEn,
      'viewCount': viewCount,
      'bookingCount': bookingCount,
      if (adultsCapacity != null) 'adultsCapacity': adultsCapacity,
      if (childrenCapacity != null) 'childrenCapacity': childrenCapacity,
      'propertyName': propertyName,
      if (propertyNameEn != null) 'propertyNameEn': propertyNameEn,
      'unitTypeName': unitTypeName,
      if (unitTypeNameEn != null) 'unitTypeNameEn': unitTypeNameEn,
      'pricingMethod': pricingMethod.value,
      'fieldValues': fieldValues
          .map((e) => UnitFieldValueModel.fromEntity(e).toJson())
          .toList(),
      'dynamicFields': dynamicFields
          .map((e) => FieldGroupWithValuesModel.fromEntity(e).toJson())
          .toList(),
      if (distanceKm != null) 'distanceKm': distanceKm,
      if (images != null) 'images': images,
      'allowsCancellation': allowsCancellation,
      if (cancellationWindowDays != null)
        'cancellationWindowDays': cancellationWindowDays,
    };
  }
}
