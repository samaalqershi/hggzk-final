import '../../domain/entities/unit_type.dart';

/// يمثل هذا الكلاس UnitTypeModel البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitTypeModel in the admin unit workflow.
class UnitTypeModel extends UnitType {
  /// This constructor creates a new UnitTypeModel instance.
  /// ينشئ مثيلًا جديدًا من UnitTypeModel.
  const UnitTypeModel({
    required String id,
    required String propertyTypeId,
    required String name,
    String? nameEn,
    required String description,
    String? descriptionEn,
    required String icon,
    required bool isHasAdults,
    required bool isHasChildren,
    required bool isMultiDays,
    required bool isRequiredToDetermineTheHour,
    required int maxCapacity,
    List<UnitTypeField> fields = const [],
  }) : super(
          id: id,
          propertyTypeId: propertyTypeId,
          name: name,
          nameEn: nameEn,
          description: description,
          descriptionEn: descriptionEn,
          icon: icon,
          isHasAdults: isHasAdults,
          isHasChildren: isHasChildren,
          isMultiDays: isMultiDays,
          isRequiredToDetermineTheHour: isRequiredToDetermineTheHour,
          maxCapacity: maxCapacity,
          fields: fields,
        );

  /// ينشئ هذا المُنشئ مثيلاً من UnitTypeModel.
  /// This constructor creates an instance of UnitTypeModel.
  factory UnitTypeModel.fromJson(Map<String, dynamic> json) {
    return UnitTypeModel(
      id: json['id'] as String,
      propertyTypeId: json['propertyTypeId'] as String,
      name: json['name'] as String,
      nameEn: json['nameEn'] as String?,
      description: json['description'] as String? ?? '',
      descriptionEn: json['descriptionEn'] as String?,
      icon: json['icon'] as String? ?? 'apartment',
      isHasAdults: json['isHasAdults'] as bool? ?? false,
      isHasChildren: json['isHasChildren'] as bool? ?? false,
      isMultiDays: json['isMultiDays'] as bool? ?? false,
      isRequiredToDetermineTheHour:
          json['isRequiredToDetermineTheHour'] as bool? ?? false,
      maxCapacity: json['maxCapacity'] as int? ?? 1,
      fields: (json['fields'] as List?)
              ?.map((e) => UnitTypeFieldModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// يمثل هذا الكلاس UnitTypeFieldModel البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitTypeFieldModel in the admin unit workflow.
class UnitTypeFieldModel extends UnitTypeField {
  /// This constructor creates a new UnitTypeFieldModel instance.
  /// ينشئ مثيلًا جديدًا من UnitTypeFieldModel.
  const UnitTypeFieldModel({
    required String fieldId,
    required String unitTypeId,
    required String fieldTypeId,
    required String fieldName,
    required String displayName,
    String? displayNameEn,
    required String description,
    String? descriptionEn,
    required Map<String, dynamic> fieldOptions,
    Map<String, dynamic>? fieldOptionsEn,
    required Map<String, dynamic> validationRules,
    required bool isRequired,
    required bool isSearchable,
    required bool isPublic,
    required int sortOrder,
    required String category,
    String? categoryEn,
    required bool isForUnits,
    required bool showInCards,
    required bool isPrimaryFilter,
    required int priority,
    String? groupId,
  }) : super(
          fieldId: fieldId,
          unitTypeId: unitTypeId,
          fieldTypeId: fieldTypeId,
          fieldName: fieldName,
          displayName: displayName,
          displayNameEn: displayNameEn,
          description: description,
          descriptionEn: descriptionEn,
          fieldOptions: fieldOptions,
          fieldOptionsEn: fieldOptionsEn,
          validationRules: validationRules,
          isRequired: isRequired,
          isSearchable: isSearchable,
          isPublic: isPublic,
          sortOrder: sortOrder,
          category: category,
          categoryEn: categoryEn,
          isForUnits: isForUnits,
          showInCards: showInCards,
          isPrimaryFilter: isPrimaryFilter,
          priority: priority,
          groupId: groupId,
        );

  /// ينشئ هذا المُنشئ مثيلاً من UnitTypeFieldModel.
  /// This constructor creates an instance of UnitTypeFieldModel.
  factory UnitTypeFieldModel.fromJson(Map<String, dynamic> json) {
    return UnitTypeFieldModel(
      fieldId: json['fieldId'] as String,
      unitTypeId: json['unitTypeId'] as String,
      fieldTypeId: json['fieldTypeId'] as String,
      fieldName: json['fieldName'] as String,
      displayName: json['displayName'] as String,
      displayNameEn: json['displayNameEn'] as String?,
      description: json['description'] as String? ?? '',
      descriptionEn: json['descriptionEn'] as String?,
      fieldOptions: json['fieldOptions'] as Map<String, dynamic>? ?? {},
      fieldOptionsEn: json['fieldOptionsEn'] as Map<String, dynamic>?,
      validationRules: json['validationRules'] as Map<String, dynamic>? ?? {},
      isRequired: json['isRequired'] as bool? ?? false,
      isSearchable: json['isSearchable'] as bool? ?? false,
      isPublic: json['isPublic'] as bool? ?? true,
      sortOrder: json['sortOrder'] as int? ?? 0,
      category: json['category'] as String? ?? '',
      categoryEn: json['categoryEn'] as String?,
      isForUnits: json['isForUnits'] as bool? ?? true,
      showInCards: json['showInCards'] as bool? ?? false,
      isPrimaryFilter: json['isPrimaryFilter'] as bool? ?? false,
      priority: json['priority'] as int? ?? 0,
      groupId: json['groupId'] as String?,
    );
  }
}
