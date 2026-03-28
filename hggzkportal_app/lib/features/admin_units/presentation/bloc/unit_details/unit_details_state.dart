part of 'unit_details_bloc.dart';

/// يمثل هذا الكلاس المجرد UnitDetailsState العقد المشترك لمسار إدارة الوحدات.
/// This abstract class defines the shared contract for UnitDetailsState in the admin unit workflow.
abstract class UnitDetailsState extends Equatable {
  /// This constructor creates a new UnitDetailsState instance.
  /// ينشئ مثيلًا جديدًا من UnitDetailsState.
  const UnitDetailsState();

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [];
}

/// يمثل هذا الكلاس UnitDetailsInitial البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitDetailsInitial in the admin unit workflow.
class UnitDetailsInitial extends UnitDetailsState {}

/// يمثل هذا الكلاس UnitDetailsLoading البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitDetailsLoading in the admin unit workflow.
class UnitDetailsLoading extends UnitDetailsState {}

/// يمثل هذا الكلاس UnitDetailsLoaded البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitDetailsLoaded in the admin unit workflow.
class UnitDetailsLoaded extends UnitDetailsState {
  /// This field keeps the unit value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unit التي يعتمد عليها مسار إدارة الوحدات.
  final Unit unit;

  /// يحتفظ هذا الحقل بقيمة analytics التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the analytics value used by the admin unit workflow.
  final UnitAnalytics? analytics;

  /// ينشئ هذا المُنشئ مثيلاً من UnitDetailsLoaded.
  /// This constructor creates an instance of UnitDetailsLoaded.
  const UnitDetailsLoaded({required this.unit, this.analytics});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [unit, analytics];
}

/// يمثل هذا الكلاس UnitDeleted البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitDeleted in the admin unit workflow.
class UnitDeleted extends UnitDetailsState {}

/// يمثل هذا الكلاس UnitDetailsError البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitDetailsError in the admin unit workflow.
class UnitDetailsError extends UnitDetailsState {
  /// This field keeps the message value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة message التي يعتمد عليها مسار إدارة الوحدات.
  final String message;

  /// ينشئ هذا المُنشئ مثيلاً من UnitDetailsError.
  /// This constructor creates an instance of UnitDetailsError.
  const UnitDetailsError({required this.message});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [message];
}
