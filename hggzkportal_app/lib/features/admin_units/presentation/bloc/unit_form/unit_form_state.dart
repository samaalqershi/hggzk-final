part of 'unit_form_bloc.dart';

/// يمثل هذا الكلاس المجرد UnitFormState العقد المشترك لمسار إدارة الوحدات.
/// This abstract class defines the shared contract for UnitFormState in the admin unit workflow.
abstract class UnitFormState extends Equatable {
  /// This constructor creates a new UnitFormState instance.
  /// ينشئ مثيلًا جديدًا من UnitFormState.
  const UnitFormState();

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [];
}

/// يمثل هذا الكلاس UnitFormInitial البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitFormInitial in the admin unit workflow.
class UnitFormInitial extends UnitFormState {}

/// يمثل هذا الكلاس UnitFormLoading البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitFormLoading in the admin unit workflow.
class UnitFormLoading extends UnitFormState {}

/// يمثل هذا الكلاس UnitFormReady البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitFormReady in the admin unit workflow.
class UnitFormReady extends UnitFormState {
  /// Indicates whether isEditMode is enabled.
  /// يحدد ما إذا كانت القيمة isEditMode مفعلة.
  final bool isEditMode;

  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the unitId value used by the admin unit workflow.
  final String? unitId;

  /// يحتفظ هذا الحقل بقيمة selectedPropertyId التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the selectedPropertyId value used by the admin unit workflow.
  final String? selectedPropertyId;

  /// يحتفظ هذا الحقل بقيمة tempKey التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the tempKey value used by the admin unit workflow.
  final String? tempKey;

  /// يحتفظ هذا الحقل بقيمة availableUnitTypes التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the availableUnitTypes value used by the admin unit workflow.
  final List<UnitType> availableUnitTypes;

  /// يحتفظ هذا الحقل بقيمة selectedUnitType التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the selectedUnitType value used by the admin unit workflow.
  final UnitType? selectedUnitType;

  /// يحتفظ هذا الحقل بقيمة unitTypeFields التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the unitTypeFields value used by the admin unit workflow.
  final List<UnitTypeField> unitTypeFields;

  /// يحتفظ هذا الحقل بقيمة unitName التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the unitName value used by the admin unit workflow.
  final String? unitName;

  /// يحتفظ هذا الحقل بقيمة description التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the description value used by the admin unit workflow.
  final String? description;

  /// يحتفظ هذا الحقل بقيمة pricingMethod التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the pricingMethod value used by the admin unit workflow.
  final PricingMethod? pricingMethod;

  /// يحتفظ هذا الحقل بقيمة customFeatures التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the customFeatures value used by the admin unit workflow.
  final String? customFeatures;

  /// يحتفظ هذا الحقل بقيمة dynamicFieldValues التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the dynamicFieldValues value used by the admin unit workflow.
  final Map<String, dynamic> dynamicFieldValues;

  /// يحتفظ هذا الحقل بقيمة images التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the images value used by the admin unit workflow.
  final List<String>? images;

  /// يحتفظ هذا الحقل بقيمة adultCapacity التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the adultCapacity value used by the admin unit workflow.
  final int? adultCapacity;

  /// يحتفظ هذا الحقل بقيمة childrenCapacity التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the childrenCapacity value used by the admin unit workflow.
  final int? childrenCapacity;

  /// يحتفظ هذا الحقل بقيمة isLoadingUnitTypes التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the isLoadingUnitTypes value used by the admin unit workflow.
  final bool isLoadingUnitTypes;

  /// يحتفظ هذا الحقل بقيمة isLoadingFields التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the isLoadingFields value used by the admin unit workflow.
  final bool isLoadingFields;

  /// يحتفظ هذا الحقل بقيمة allowsCancellation التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the allowsCancellation value used by the admin unit workflow.
  final bool allowsCancellation;

  /// يحتفظ هذا الحقل بقيمة cancellationWindowDays التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the cancellationWindowDays value used by the admin unit workflow.
  final int? cancellationWindowDays;

  /// ينشئ هذا المُنشئ مثيلاً من UnitFormReady.
  /// This constructor creates an instance of UnitFormReady.
  const UnitFormReady({
    this.isEditMode = false,
    this.unitId,
    this.selectedPropertyId,
    this.tempKey,
    this.availableUnitTypes = const [],
    this.selectedUnitType,
    this.unitTypeFields = const [],
    this.unitName,
    this.description,
    this.pricingMethod,
    this.customFeatures,
    this.dynamicFieldValues = const {},
    this.images,
    this.adultCapacity,
    this.childrenCapacity,
    this.isLoadingUnitTypes = false,
    this.isLoadingFields = false,
    this.allowsCancellation = true,
    this.cancellationWindowDays,
  });

  /// ينفذ هذا الأسلوب عملية copyWith ضمن مسار إدارة الوحدات.
  /// This method performs the copyWith operation in the admin unit workflow.
  UnitFormReady copyWith({
    bool? isEditMode,
    String? unitId,
    String? selectedPropertyId,
    String? tempKey,
    List<UnitType>? availableUnitTypes,
    UnitType? selectedUnitType,
    List<UnitTypeField>? unitTypeFields,
    String? unitName,
    String? description,
    PricingMethod? pricingMethod,
    String? customFeatures,
    Map<String, dynamic>? dynamicFieldValues,
    List<String>? images,
    int? adultCapacity,
    int? childrenCapacity,
    bool? isLoadingUnitTypes,
    bool? isLoadingFields,
    bool? allowsCancellation,
    int? cancellationWindowDays,
  }) {
    return UnitFormReady(
      isEditMode: isEditMode ?? this.isEditMode,
      unitId: unitId ?? this.unitId,
      selectedPropertyId: selectedPropertyId ?? this.selectedPropertyId,
      tempKey: tempKey ?? this.tempKey,
      availableUnitTypes: availableUnitTypes ?? this.availableUnitTypes,
      selectedUnitType: selectedUnitType ?? this.selectedUnitType,
      unitTypeFields: unitTypeFields ?? this.unitTypeFields,
      unitName: unitName ?? this.unitName,
      description: description ?? this.description,
      pricingMethod: pricingMethod ?? this.pricingMethod,
      customFeatures: customFeatures ?? this.customFeatures,
      dynamicFieldValues: dynamicFieldValues ?? this.dynamicFieldValues,
      images: images ?? this.images,
      adultCapacity: adultCapacity ?? this.adultCapacity,
      childrenCapacity: childrenCapacity ?? this.childrenCapacity,
      isLoadingUnitTypes: isLoadingUnitTypes ?? this.isLoadingUnitTypes,
      isLoadingFields: isLoadingFields ?? this.isLoadingFields,
      allowsCancellation: allowsCancellation ?? this.allowsCancellation,
      cancellationWindowDays:
          cancellationWindowDays ?? this.cancellationWindowDays,
    );
  }

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [
        isEditMode,
        unitId,
        selectedPropertyId,
        tempKey,
        availableUnitTypes,
        selectedUnitType,
        unitTypeFields,
        unitName,
        description,
        pricingMethod,
        customFeatures,
        dynamicFieldValues,
        images,
        adultCapacity,
        childrenCapacity,
        isLoadingUnitTypes,
        isLoadingFields,
        allowsCancellation,
        cancellationWindowDays,
      ];
}

/// يمثل هذا الكلاس UnitFormSubmitted البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitFormSubmitted in the admin unit workflow.
class UnitFormSubmitted extends UnitFormState {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String? unitId;

  /// ينشئ هذا المُنشئ مثيلاً من UnitFormSubmitted.
  /// This constructor creates an instance of UnitFormSubmitted.
  const UnitFormSubmitted({this.unitId});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [unitId];
}

/// يمثل هذا الكلاس UnitFormError البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitFormError in the admin unit workflow.
class UnitFormError extends UnitFormState {
  /// This field keeps the message value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة message التي يعتمد عليها مسار إدارة الوحدات.
  final String message;

  /// ينشئ هذا المُنشئ مثيلاً من UnitFormError.
  /// This constructor creates an instance of UnitFormError.
  const UnitFormError({required this.message});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object> get props => [message];
}
