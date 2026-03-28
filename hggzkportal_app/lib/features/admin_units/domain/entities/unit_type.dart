import 'package:equatable/equatable.dart';

/// يمثل هذا الكلاس UnitType البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitType in the admin unit workflow.
class UnitType extends Equatable {
  /// This field keeps the id value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة id التي يعتمد عليها مسار إدارة الوحدات.
  final String id;

  /// يحتفظ هذا الحقل بقيمة propertyTypeId التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the propertyTypeId value used by the admin unit workflow.
  final String propertyTypeId;

  /// يحتفظ هذا الحقل بقيمة name التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the name value used by the admin unit workflow.
  final String name;

  /// يحتفظ هذا الحقل بقيمة description التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the description value used by the admin unit workflow.
  final String description;

  /// يحتفظ هذا الحقل بقيمة icon التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the icon value used by the admin unit workflow.
  final String icon;

  /// يحتفظ هذا الحقل بقيمة systemCommissionRate التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the systemCommissionRate value used by the admin unit workflow.
  final double? systemCommissionRate;

  /// يحتفظ هذا الحقل بقيمة isHasAdults التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the isHasAdults value used by the admin unit workflow.
  final bool isHasAdults;

  /// يحتفظ هذا الحقل بقيمة isHasChildren التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the isHasChildren value used by the admin unit workflow.
  final bool isHasChildren;

  /// يحتفظ هذا الحقل بقيمة isMultiDays التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the isMultiDays value used by the admin unit workflow.
  final bool isMultiDays;

  /// يحتفظ هذا الحقل بقيمة isRequiredToDetermineTheHour التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the isRequiredToDetermineTheHour value used by the admin unit workflow.
  final bool isRequiredToDetermineTheHour;

  /// يحتفظ هذا الحقل بقيمة maxCapacity التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the maxCapacity value used by the admin unit workflow.
  final int maxCapacity;

  /// يحتفظ هذا الحقل بقيمة fields التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the fields value used by the admin unit workflow.
  final List<UnitTypeField> fields;

  /// ينشئ هذا المُنشئ مثيلاً من UnitType.
  /// This constructor creates an instance of UnitType.
  const UnitType({
    required this.id,
    required this.propertyTypeId,
    required this.name,
    required this.description,
    required this.icon,
    this.systemCommissionRate,
    required this.isHasAdults,
    required this.isHasChildren,
    required this.isMultiDays,
    required this.isRequiredToDetermineTheHour,
    required this.maxCapacity,
    this.fields = const [],
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [
        id,
        propertyTypeId,
        name,
        description,
        icon,
        systemCommissionRate,
        isHasAdults,
        isHasChildren,
        isMultiDays,
        isRequiredToDetermineTheHour,
        maxCapacity,
        fields,
      ];
}

/// يمثل هذا الكلاس UnitTypeField البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitTypeField in the admin unit workflow.
class UnitTypeField extends Equatable {
  /// This field keeps the fieldId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة fieldId التي يعتمد عليها مسار إدارة الوحدات.
  final String fieldId;

  /// يحتفظ هذا الحقل بقيمة unitTypeId التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the unitTypeId value used by the admin unit workflow.
  final String unitTypeId;

  /// يحتفظ هذا الحقل بقيمة fieldTypeId التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the fieldTypeId value used by the admin unit workflow.
  final String fieldTypeId;

  /// يحتفظ هذا الحقل بقيمة fieldName التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the fieldName value used by the admin unit workflow.
  final String fieldName;

  /// يحتفظ هذا الحقل بقيمة displayName التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the displayName value used by the admin unit workflow.
  final String displayName;

  /// يحتفظ هذا الحقل بقيمة description التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the description value used by the admin unit workflow.
  final String description;

  /// يحتفظ هذا الحقل بقيمة fieldOptions التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the fieldOptions value used by the admin unit workflow.
  final Map<String, dynamic> fieldOptions;

  /// يحتفظ هذا الحقل بقيمة validationRules التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the validationRules value used by the admin unit workflow.
  final Map<String, dynamic> validationRules;

  /// يحتفظ هذا الحقل بقيمة isRequired التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the isRequired value used by the admin unit workflow.
  final bool isRequired;

  /// يحتفظ هذا الحقل بقيمة isSearchable التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the isSearchable value used by the admin unit workflow.
  final bool isSearchable;

  /// يحتفظ هذا الحقل بقيمة isPublic التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the isPublic value used by the admin unit workflow.
  final bool isPublic;

  /// يحتفظ هذا الحقل بقيمة sortOrder التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the sortOrder value used by the admin unit workflow.
  final int sortOrder;

  /// يحتفظ هذا الحقل بقيمة category التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the category value used by the admin unit workflow.
  final String category;

  /// يحتفظ هذا الحقل بقيمة isForUnits التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the isForUnits value used by the admin unit workflow.
  final bool isForUnits;

  /// يحتفظ هذا الحقل بقيمة showInCards التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the showInCards value used by the admin unit workflow.
  final bool showInCards;

  /// يحتفظ هذا الحقل بقيمة isPrimaryFilter التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the isPrimaryFilter value used by the admin unit workflow.
  final bool isPrimaryFilter;

  /// يحتفظ هذا الحقل بقيمة priority التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the priority value used by the admin unit workflow.
  final int priority;

  /// يحتفظ هذا الحقل بقيمة groupId التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the groupId value used by the admin unit workflow.
  final String? groupId;

  /// ينشئ هذا المُنشئ مثيلاً من UnitTypeField.
  /// This constructor creates an instance of UnitTypeField.
  const UnitTypeField({
    required this.fieldId,
    required this.unitTypeId,
    required this.fieldTypeId,
    required this.fieldName,
    required this.displayName,
    required this.description,
    required this.fieldOptions,
    required this.validationRules,
    required this.isRequired,
    required this.isSearchable,
    required this.isPublic,
    required this.sortOrder,
    required this.category,
    required this.isForUnits,
    required this.showInCards,
    required this.isPrimaryFilter,
    required this.priority,
    this.groupId,
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [
        fieldId,
        unitTypeId,
        fieldTypeId,
        fieldName,
        displayName,
        description,
        fieldOptions,
        validationRules,
        isRequired,
        isSearchable,
        isPublic,
        sortOrder,
        category,
        isForUnits,
        showInCards,
        isPrimaryFilter,
        priority,
        groupId,
      ];
}
