import 'package:equatable/equatable.dart';

/// يمثل هذا الكلاس UnitFieldValue البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitFieldValue in the admin unit workflow.
class UnitFieldValue extends Equatable {
  /// This field keeps the fieldId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة fieldId التي يعتمد عليها مسار إدارة الوحدات.
  final String fieldId;

  /// يحتفظ هذا الحقل بقيمة fieldValue التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the fieldValue value used by the admin unit workflow.
  final String fieldValue;

  /// يحتفظ هذا الحقل بقيمة fieldName التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the fieldName value used by the admin unit workflow.
  final String? fieldName;

  /// يحتفظ هذا الحقل بقيمة displayName التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the displayName value used by the admin unit workflow.
  final String? displayName;
  final String? displayNameEn;

  /// يحتفظ هذا الحقل بقيمة fieldTypeId التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the fieldTypeId value used by the admin unit workflow.
  final String? fieldTypeId;

  /// يحتفظ هذا الحقل بقيمة isPrimaryFilter التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the isPrimaryFilter value used by the admin unit workflow.
  final bool? isPrimaryFilter; // new

  /// ينشئ هذا المُنشئ مثيلاً من UnitFieldValue.
  /// This constructor creates an instance of UnitFieldValue.
  const UnitFieldValue({
    required this.fieldId,
    required this.fieldValue,
    this.fieldName,
    this.displayName,
    this.displayNameEn,
    this.fieldTypeId,
    this.isPrimaryFilter, // new
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [
        fieldId,
        fieldValue,
        fieldName,
        displayName,
        displayNameEn,
        fieldTypeId,
        isPrimaryFilter, // new
      ];
}

/// يمثل هذا الكلاس FieldGroupWithValues البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for FieldGroupWithValues in the admin unit workflow.
class FieldGroupWithValues extends Equatable {
  /// This field keeps the groupId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة groupId التي يعتمد عليها مسار إدارة الوحدات.
  final String groupId;

  /// يحتفظ هذا الحقل بقيمة groupName التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the groupName value used by the admin unit workflow.
  final String groupName;
  final String? groupNameEn;

  /// يحتفظ هذا الحقل بقيمة displayName التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the displayName value used by the admin unit workflow.
  final String displayName;
  final String? displayNameEn;

  /// يحتفظ هذا الحقل بقيمة description التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the description value used by the admin unit workflow.
  final String description;
  final String? descriptionEn;

  /// يحتفظ هذا الحقل بقيمة fieldValues التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the fieldValues value used by the admin unit workflow.
  final List<UnitFieldValue> fieldValues;

  /// ينشئ هذا المُنشئ مثيلاً من FieldGroupWithValues.
  /// This constructor creates an instance of FieldGroupWithValues.
  const FieldGroupWithValues({
    required this.groupId,
    required this.groupName,
    this.groupNameEn,
    required this.displayName,
    this.displayNameEn,
    required this.description,
    this.descriptionEn,
    required this.fieldValues,
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [
        groupId,
        groupName,
        groupNameEn,
        displayName,
        displayNameEn,
        description,
        descriptionEn,
        fieldValues,
      ];
}
