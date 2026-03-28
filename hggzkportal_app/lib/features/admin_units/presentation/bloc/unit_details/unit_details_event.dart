part of 'unit_details_bloc.dart';

/// يمثل هذا الكلاس المجرد UnitDetailsEvent العقد المشترك لمسار إدارة الوحدات.
/// This abstract class defines the shared contract for UnitDetailsEvent in the admin unit workflow.
abstract class UnitDetailsEvent extends Equatable {
  /// This constructor creates a new UnitDetailsEvent instance.
  /// ينشئ مثيلًا جديدًا من UnitDetailsEvent.
  const UnitDetailsEvent();

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object> get props => [];
}

/// يمثل هذا الكلاس LoadUnitDetailsEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for LoadUnitDetailsEvent in the admin unit workflow.
class LoadUnitDetailsEvent extends UnitDetailsEvent {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String unitId;

  /// ينشئ هذا المُنشئ مثيلاً من LoadUnitDetailsEvent.
  /// This constructor creates an instance of LoadUnitDetailsEvent.
  const LoadUnitDetailsEvent({required this.unitId});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object> get props => [unitId];
}

/// يمثل هذا الكلاس DeleteUnitDetailsEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for DeleteUnitDetailsEvent in the admin unit workflow.
class DeleteUnitDetailsEvent extends UnitDetailsEvent {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String unitId;

  /// ينشئ هذا المُنشئ مثيلاً من DeleteUnitDetailsEvent.
  /// This constructor creates an instance of DeleteUnitDetailsEvent.
  const DeleteUnitDetailsEvent({required this.unitId});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object> get props => [unitId];
}

/// يمثل هذا الكلاس AssignToSectionsEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for AssignToSectionsEvent in the admin unit workflow.
class AssignToSectionsEvent extends UnitDetailsEvent {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String unitId;

  /// يحتفظ هذا الحقل بقيمة sectionIds التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the sectionIds value used by the admin unit workflow.
  final List<String> sectionIds;

  /// ينشئ هذا المُنشئ مثيلاً من AssignToSectionsEvent.
  /// This constructor creates an instance of AssignToSectionsEvent.
  const AssignToSectionsEvent({
    required this.unitId,
    required this.sectionIds,
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object> get props => [unitId, sectionIds];
}
