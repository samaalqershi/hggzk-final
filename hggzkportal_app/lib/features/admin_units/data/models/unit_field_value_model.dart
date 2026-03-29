import '../../domain/entities/unit_field_value.dart';

/// يمثل هذا الكلاس UnitFieldValueModel البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitFieldValueModel in the admin unit workflow.
class UnitFieldValueModel extends UnitFieldValue {
  /// This constructor creates a new UnitFieldValueModel instance.
  /// ينشئ مثيلًا جديدًا من UnitFieldValueModel.
  const UnitFieldValueModel({
    required super.fieldId,
    required super.fieldValue,
    super.fieldName,
    super.displayName,
    super.displayNameEn,
    super.fieldTypeId,
    super.isPrimaryFilter,
  });

  /// ينشئ هذا المُنشئ مثيلاً من UnitFieldValueModel.
  /// This constructor creates an instance of UnitFieldValueModel.
  factory UnitFieldValueModel.fromJson(Map<String, dynamic> json) {
    final fieldObj = json['field'] as Map<String, dynamic>?;

    bool? _coerceBool(dynamic v) {
      if (v == null) return null;
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) {
        final s = v.toLowerCase().trim();
        if (s == 'true' || s == '1' || s == 'yes' || s == 'y') return true;
        if (s == 'false' || s == '0' || s == 'no' || s == 'n') return false;
      }
      return null;
    }

    String _coerceString(dynamic v) {
      if (v == null) return '';
      return v.toString();
    }

    final rawIsPrimary = json.containsKey('isPrimaryFilter')
        ? json['isPrimaryFilter']
        : fieldObj?['isPrimaryFilter'];

    return UnitFieldValueModel(
      fieldId: json['fieldId'] as String,
      fieldValue: _coerceString(
        json.containsKey('fieldValue')
            ? json['fieldValue']
            : (json.containsKey('value') ? json['value'] : ''),
      ),
      fieldName:
          (json['fieldName'] as String?) ?? fieldObj?['fieldName'] as String?,
      displayName: (json['displayName'] as String?) ??
          fieldObj?['displayName'] as String?,
      displayNameEn: (json['displayNameEn'] as String?) ??
          fieldObj?['displayNameEn'] as String?,
      fieldTypeId: (json['fieldTypeId'] as String?) ??
          (json['fieldType'] as String?) ??
          fieldObj?['fieldTypeId'] as String? ??
          fieldObj?['fieldType'] as String?,
      isPrimaryFilter: _coerceBool(rawIsPrimary),
    );
  }

  /// ينفذ هذا الأسلوب عملية toJson ضمن مسار إدارة الوحدات.
  /// This method performs the toJson operation in the admin unit workflow.
  Map<String, dynamic> toJson() {
    return {
      'fieldId': fieldId,
      'fieldValue': fieldValue,
      if (fieldName != null) 'fieldName': fieldName,
      if (displayName != null) 'displayName': displayName,
      if (displayNameEn != null) 'displayNameEn': displayNameEn,
      if (fieldTypeId != null) 'fieldTypeId': fieldTypeId,
      if (isPrimaryFilter != null) 'isPrimaryFilter': isPrimaryFilter,
    };
  }

  /// ينشئ هذا المُنشئ مثيلاً من UnitFieldValueModel.
  /// This constructor creates an instance of UnitFieldValueModel.
  factory UnitFieldValueModel.fromEntity(UnitFieldValue entity) {
    return UnitFieldValueModel(
      fieldId: entity.fieldId,
      fieldValue: entity.fieldValue,
      fieldName: entity.fieldName,
      displayName: entity.displayName,
      displayNameEn: entity.displayNameEn,
      fieldTypeId: entity.fieldTypeId,
      isPrimaryFilter: entity.isPrimaryFilter,
    );
  }
}

/// يمثل هذا الكلاس FieldGroupWithValuesModel البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for FieldGroupWithValuesModel in the admin unit workflow.
class FieldGroupWithValuesModel extends FieldGroupWithValues {
  /// This constructor creates a new FieldGroupWithValuesModel instance.
  /// ينشئ مثيلًا جديدًا من FieldGroupWithValuesModel.
  const FieldGroupWithValuesModel({
    required super.groupId,
    required super.groupName,
    super.groupNameEn,
    required super.displayName,
    super.displayNameEn,
    required super.description,
    super.descriptionEn,
    required super.fieldValues,
  });

  /// ينشئ هذا المُنشئ مثيلاً من FieldGroupWithValuesModel.
  /// This constructor creates an instance of FieldGroupWithValuesModel.
  factory FieldGroupWithValuesModel.fromJson(Map<String, dynamic> json) {
    return FieldGroupWithValuesModel(
      groupId: json['groupId'] as String,
      groupName: json['groupName'] as String,
      groupNameEn: json['groupNameEn'] as String?,
      displayName: json['displayName'] as String,
      displayNameEn: json['displayNameEn'] as String?,
      description: json['description'] as String,
      descriptionEn: json['descriptionEn'] as String?,
      fieldValues: (json['fieldValues'] as List)
          .map((e) => UnitFieldValueModel.fromJson(e))
          .toList(),
    );
  }

  /// ينفذ هذا الأسلوب عملية toJson ضمن مسار إدارة الوحدات.
  /// This method performs the toJson operation in the admin unit workflow.
  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      if (groupNameEn != null) 'groupNameEn': groupNameEn,
      'displayName': displayName,
      if (displayNameEn != null) 'displayNameEn': displayNameEn,
      'description': description,
      if (descriptionEn != null) 'descriptionEn': descriptionEn,
      'fieldValues': fieldValues
          .map((e) => UnitFieldValueModel.fromEntity(e).toJson())
          .toList(),
    };
  }

  /// ينشئ هذا المُنشئ مثيلاً من FieldGroupWithValuesModel.
  /// This constructor creates an instance of FieldGroupWithValuesModel.
  factory FieldGroupWithValuesModel.fromEntity(FieldGroupWithValues entity) {
    return FieldGroupWithValuesModel(
      groupId: entity.groupId,
      groupName: entity.groupName,
      groupNameEn: entity.groupNameEn,
      displayName: entity.displayName,
      displayNameEn: entity.displayNameEn,
      description: entity.description,
      descriptionEn: entity.descriptionEn,
      fieldValues: entity.fieldValues,
    );
  }
}
