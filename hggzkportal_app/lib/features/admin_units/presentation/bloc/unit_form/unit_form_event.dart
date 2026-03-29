part of 'unit_form_bloc.dart';

/// يمثل هذا الكلاس المجرد UnitFormEvent العقد المشترك لمسار إدارة الوحدات.
/// This abstract class defines the shared contract for UnitFormEvent in the admin unit workflow.
abstract class UnitFormEvent extends Equatable {
  /// This constructor creates a new UnitFormEvent instance.
  /// ينشئ مثيلًا جديدًا من UnitFormEvent.
  const UnitFormEvent();

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [];
}

/// يمثل هذا الكلاس InitializeFormEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for InitializeFormEvent in the admin unit workflow.
class InitializeFormEvent extends UnitFormEvent {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String? unitId;

  /// يحتفظ هذا الحقل بقيمة tempKey التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the tempKey value used by the admin unit workflow.
  final String? tempKey;

  /// ينشئ هذا المُنشئ مثيلاً من InitializeFormEvent.
  /// This constructor creates an instance of InitializeFormEvent.
  const InitializeFormEvent({this.unitId, this.tempKey});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [unitId, tempKey];
}

/// يمثل هذا الكلاس PropertySelectedEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for PropertySelectedEvent in the admin unit workflow.
class PropertySelectedEvent extends UnitFormEvent {
  final String? propertyId; // physical property id (used in submission)
  /// يحتفظ هذا الحقل بقيمة propertyTypeId التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the propertyTypeId value used by the admin unit workflow.
  final String? propertyTypeId; // used to load unit types

  /// ينشئ هذا المُنشئ مثيلاً من PropertySelectedEvent.
  /// This constructor creates an instance of PropertySelectedEvent.
  const PropertySelectedEvent({this.propertyId, this.propertyTypeId});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [propertyId, propertyTypeId];
}

/// يمثل هذا الكلاس UnitTypeSelectedEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitTypeSelectedEvent in the admin unit workflow.
class UnitTypeSelectedEvent extends UnitFormEvent {
  /// This field keeps the unitTypeId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitTypeId التي يعتمد عليها مسار إدارة الوحدات.
  final String unitTypeId;

  /// ينشئ هذا المُنشئ مثيلاً من UnitTypeSelectedEvent.
  /// This constructor creates an instance of UnitTypeSelectedEvent.
  const UnitTypeSelectedEvent({required this.unitTypeId});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [unitTypeId];
}

/// يمثل هذا الكلاس UpdateCapacityEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UpdateCapacityEvent in the admin unit workflow.
class UpdateCapacityEvent extends UnitFormEvent {
  /// This field keeps the adultCapacity value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة adultCapacity التي يعتمد عليها مسار إدارة الوحدات.
  final int? adultCapacity;

  /// يحتفظ هذا الحقل بقيمة childrenCapacity التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the childrenCapacity value used by the admin unit workflow.
  final int? childrenCapacity;

  /// ينشئ هذا المُنشئ مثيلاً من UpdateCapacityEvent.
  /// This constructor creates an instance of UpdateCapacityEvent.
  const UpdateCapacityEvent({
    this.adultCapacity,
    this.childrenCapacity,
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [adultCapacity, childrenCapacity];
}

/// يمثل هذا الكلاس UpdateUnitImageEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UpdateUnitImageEvent in the admin unit workflow.
class UpdateUnitImageEvent extends UnitFormEvent {
  /// This field keeps the images value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة images التي يعتمد عليها مسار إدارة الوحدات.
  final List<String>? images;

  /// ينشئ هذا المُنشئ مثيلاً من UpdateUnitImageEvent.
  /// This constructor creates an instance of UpdateUnitImageEvent.
  const UpdateUnitImageEvent({
    this.images,
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [images];
}

/// يمثل هذا الكلاس UpdatePricingEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UpdatePricingEvent in the admin unit workflow.
class UpdatePricingEvent extends UnitFormEvent {
  /// This field keeps the pricingMethod value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة pricingMethod التي يعتمد عليها مسار إدارة الوحدات.
  final PricingMethod pricingMethod;

  /// ينشئ هذا المُنشئ مثيلاً من UpdatePricingEvent.
  /// This constructor creates an instance of UpdatePricingEvent.
  const UpdatePricingEvent({
    required this.pricingMethod,
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [pricingMethod];
}

/// يمثل هذا الكلاس UpdateFeaturesEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UpdateFeaturesEvent in the admin unit workflow.
class UpdateFeaturesEvent extends UnitFormEvent {
  /// This field keeps the features value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة features التي يعتمد عليها مسار إدارة الوحدات.
  final String features;

  /// ينشئ هذا المُنشئ مثيلاً من UpdateFeaturesEvent.
  /// This constructor creates an instance of UpdateFeaturesEvent.
  const UpdateFeaturesEvent({required this.features});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [features];
}

/// يمثل هذا الكلاس UpdateDynamicFieldsEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UpdateDynamicFieldsEvent in the admin unit workflow.
class UpdateDynamicFieldsEvent extends UnitFormEvent {
  /// This field keeps the values value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة values التي يعتمد عليها مسار إدارة الوحدات.
  final Map<String, dynamic> values;

  /// ينشئ هذا المُنشئ مثيلاً من UpdateDynamicFieldsEvent.
  /// This constructor creates an instance of UpdateDynamicFieldsEvent.
  const UpdateDynamicFieldsEvent({required this.values});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [values];
}

/// يمثل هذا الكلاس UpdateUnitNameEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UpdateUnitNameEvent in the admin unit workflow.
class UpdateUnitNameEvent extends UnitFormEvent {
  /// This field keeps the name value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة name التي يعتمد عليها مسار إدارة الوحدات.
  final String name;

  /// ينشئ هذا المُنشئ مثيلاً من UpdateUnitNameEvent.
  /// This constructor creates an instance of UpdateUnitNameEvent.
  const UpdateUnitNameEvent({required this.name});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [name];
}

class UpdateUnitNameEnEvent extends UnitFormEvent {
  final String nameEn;

  const UpdateUnitNameEnEvent({required this.nameEn});

  @override
  List<Object?> get props => [nameEn];
}

/// يمثل هذا الكلاس UpdateDescriptionEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UpdateDescriptionEvent in the admin unit workflow.
class UpdateDescriptionEvent extends UnitFormEvent {
  /// This field keeps the description value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة description التي يعتمد عليها مسار إدارة الوحدات.
  final String description;

  /// ينشئ هذا المُنشئ مثيلاً من UpdateDescriptionEvent.
  /// This constructor creates an instance of UpdateDescriptionEvent.
  const UpdateDescriptionEvent({required this.description});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [description];
}

class UpdateDescriptionEnEvent extends UnitFormEvent {
  final String descriptionEn;

  const UpdateDescriptionEnEvent({required this.descriptionEn});

  @override
  List<Object?> get props => [descriptionEn];
}

/// يمثل هذا الكلاس SubmitFormEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for SubmitFormEvent in the admin unit workflow.
class SubmitFormEvent extends UnitFormEvent {}

/// يمثل هذا الكلاس UpdateCancellationPolicyEvent البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UpdateCancellationPolicyEvent in the admin unit workflow.
class UpdateCancellationPolicyEvent extends UnitFormEvent {
  /// This field keeps the allowsCancellation value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة allowsCancellation التي يعتمد عليها مسار إدارة الوحدات.
  final bool allowsCancellation;

  /// يحتفظ هذا الحقل بقيمة cancellationWindowDays التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the cancellationWindowDays value used by the admin unit workflow.
  final int? cancellationWindowDays;

  /// ينشئ هذا المُنشئ مثيلاً من UpdateCancellationPolicyEvent.
  /// This constructor creates an instance of UpdateCancellationPolicyEvent.
  const UpdateCancellationPolicyEvent({
    required this.allowsCancellation,
    this.cancellationWindowDays,
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [allowsCancellation, cancellationWindowDays];
}
