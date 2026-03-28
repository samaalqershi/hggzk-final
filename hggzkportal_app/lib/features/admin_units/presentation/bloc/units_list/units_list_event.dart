// lib/features/admin_units/presentation/bloc/units_list/units_list_event.dart

part of 'units_list_bloc.dart';

/// يمثل هذا الكلاس المجرد UnitsListEvent العقد المشترك لمسار إدارة الوحدات.
/// This abstract class defines the shared contract for UnitsListEvent in the admin unit workflow.
abstract class UnitsListEvent extends Equatable {
  /// This constructor creates a new UnitsListEvent instance.
  /// ينشئ مثيلًا جديدًا من UnitsListEvent.
  const UnitsListEvent();

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [];
}

/// يمثل هذا الكلاس LoadUnitsEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for LoadUnitsEvent in the admin unit workflow.
class LoadUnitsEvent extends UnitsListEvent {
  /// This field keeps the pageNumber value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة pageNumber التي يعتمد عليها مسار إدارة الوحدات.
  final int? pageNumber;

  /// يحتفظ هذا الحقل بقيمة pageSize التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the pageSize value used by the admin unit workflow.
  final int? pageSize;

  /// ينشئ هذا المُنشئ مثيلاً من LoadUnitsEvent.
  /// This constructor creates an instance of LoadUnitsEvent.
  const LoadUnitsEvent({
    this.pageNumber,
    this.pageSize,
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [pageNumber, pageSize];
}

/// يمثل هذا الكلاس LoadMoreUnitsEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for LoadMoreUnitsEvent in the admin unit workflow.
class LoadMoreUnitsEvent extends UnitsListEvent {
  /// This field keeps the pageNumber value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة pageNumber التي يعتمد عليها مسار إدارة الوحدات.
  final int pageNumber;

  /// ينشئ هذا المُنشئ مثيلاً من LoadMoreUnitsEvent.
  /// This constructor creates an instance of LoadMoreUnitsEvent.
  const LoadMoreUnitsEvent({required this.pageNumber});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [pageNumber];
}

/// يمثل هذا الكلاس SearchUnitsEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for SearchUnitsEvent in the admin unit workflow.
class SearchUnitsEvent extends UnitsListEvent {
  /// This field keeps the query value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة query التي يعتمد عليها مسار إدارة الوحدات.
  final String query;

  /// ينشئ هذا المُنشئ مثيلاً من SearchUnitsEvent.
  /// This constructor creates an instance of SearchUnitsEvent.
  const SearchUnitsEvent({required this.query});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [query];
}

/// يمثل هذا الكلاس FilterUnitsEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for FilterUnitsEvent in the admin unit workflow.
class FilterUnitsEvent extends UnitsListEvent {
  /// This field keeps the filters value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة filters التي يعتمد عليها مسار إدارة الوحدات.
  final Map<String, dynamic> filters;

  /// ينشئ هذا المُنشئ مثيلاً من FilterUnitsEvent.
  /// This constructor creates an instance of FilterUnitsEvent.
  const FilterUnitsEvent({required this.filters});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [filters];
}

/// يمثل هذا الكلاس DeleteUnitEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for DeleteUnitEvent in the admin unit workflow.
class DeleteUnitEvent extends UnitsListEvent {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String unitId;

  /// ينشئ هذا المُنشئ مثيلاً من DeleteUnitEvent.
  /// This constructor creates an instance of DeleteUnitEvent.
  const DeleteUnitEvent({required this.unitId});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [unitId];
}

/// يمثل هذا الكلاس RefreshUnitsEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for RefreshUnitsEvent in the admin unit workflow.
class RefreshUnitsEvent extends UnitsListEvent {}

// أحداث التحديد
/// يمثل هذا الكلاس SelectUnitEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for SelectUnitEvent in the admin unit workflow.
class SelectUnitEvent extends UnitsListEvent {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String unitId;

  /// ينشئ هذا المُنشئ مثيلاً من SelectUnitEvent.
  /// This constructor creates an instance of SelectUnitEvent.
  const SelectUnitEvent({required this.unitId});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [unitId];
}

/// يمثل هذا الكلاس DeselectUnitEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for DeselectUnitEvent in the admin unit workflow.
class DeselectUnitEvent extends UnitsListEvent {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String unitId;

  /// ينشئ هذا المُنشئ مثيلاً من DeselectUnitEvent.
  /// This constructor creates an instance of DeselectUnitEvent.
  const DeselectUnitEvent({required this.unitId});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [unitId];
}

/// يمثل هذا الكلاس SelectMultipleUnitsEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for SelectMultipleUnitsEvent in the admin unit workflow.
class SelectMultipleUnitsEvent extends UnitsListEvent {
  /// This field keeps the unitIds value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitIds التي يعتمد عليها مسار إدارة الوحدات.
  final List<String> unitIds;

  /// ينشئ هذا المُنشئ مثيلاً من SelectMultipleUnitsEvent.
  /// This constructor creates an instance of SelectMultipleUnitsEvent.
  const SelectMultipleUnitsEvent({required this.unitIds});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [unitIds];
}

// أحداث الإجراءات الجماعية
/// يمثل هذا الكلاس BulkActivateUnitsEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for BulkActivateUnitsEvent in the admin unit workflow.
class BulkActivateUnitsEvent extends UnitsListEvent {
  /// This field keeps the unitIds value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitIds التي يعتمد عليها مسار إدارة الوحدات.
  final List<String> unitIds;

  /// ينشئ هذا المُنشئ مثيلاً من BulkActivateUnitsEvent.
  /// This constructor creates an instance of BulkActivateUnitsEvent.
  const BulkActivateUnitsEvent({required this.unitIds});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [unitIds];
}

/// يمثل هذا الكلاس BulkDeactivateUnitsEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for BulkDeactivateUnitsEvent in the admin unit workflow.
class BulkDeactivateUnitsEvent extends UnitsListEvent {
  /// This field keeps the unitIds value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitIds التي يعتمد عليها مسار إدارة الوحدات.
  final List<String> unitIds;

  /// ينشئ هذا المُنشئ مثيلاً من BulkDeactivateUnitsEvent.
  /// This constructor creates an instance of BulkDeactivateUnitsEvent.
  const BulkDeactivateUnitsEvent({required this.unitIds});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [unitIds];
}

/// يمثل هذا الكلاس BulkDeleteUnitsEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for BulkDeleteUnitsEvent in the admin unit workflow.
class BulkDeleteUnitsEvent extends UnitsListEvent {
  /// This field keeps the unitIds value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitIds التي يعتمد عليها مسار إدارة الوحدات.
  final List<String> unitIds;

  /// ينشئ هذا المُنشئ مثيلاً من BulkDeleteUnitsEvent.
  /// This constructor creates an instance of BulkDeleteUnitsEvent.
  const BulkDeleteUnitsEvent({required this.unitIds});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [unitIds];
}

/// يمثل هذا الكلاس ExportUnitsEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for ExportUnitsEvent in the admin unit workflow.
class ExportUnitsEvent extends UnitsListEvent {
  /// This field keeps the unitIds value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitIds التي يعتمد عليها مسار إدارة الوحدات.
  final List<String> unitIds;

  /// ينشئ هذا المُنشئ مثيلاً من ExportUnitsEvent.
  /// This constructor creates an instance of ExportUnitsEvent.
  const ExportUnitsEvent({required this.unitIds});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [unitIds];
}
