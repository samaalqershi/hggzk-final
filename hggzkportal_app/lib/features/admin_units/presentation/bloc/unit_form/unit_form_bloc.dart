import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/unit_type.dart';
import '../../../domain/entities/pricing_method.dart';
import '../../../domain/usecases/create_unit_usecase.dart';
import '../../../domain/usecases/update_unit_usecase.dart';
import '../../../domain/usecases/get_unit_types_by_property_usecase.dart';
import '../../../domain/usecases/get_unit_fields_usecase.dart';

part 'unit_form_event.dart';
part 'unit_form_state.dart';

/// يمثل هذا الكلاس UnitFormBloc البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitFormBloc in the admin unit workflow.
class UnitFormBloc extends Bloc<UnitFormEvent, UnitFormState> {
  /// This field keeps the createUnitUseCase value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة createUnitUseCase التي يعتمد عليها مسار إدارة الوحدات.
  final CreateUnitUseCase createUnitUseCase;

  /// يحتفظ هذا الحقل بقيمة updateUnitUseCase التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the updateUnitUseCase value used by the admin unit workflow.
  final UpdateUnitUseCase updateUnitUseCase;

  /// يحتفظ هذا الحقل بقيمة getUnitTypesByPropertyUseCase التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the getUnitTypesByPropertyUseCase value used by the admin unit workflow.
  final GetUnitTypesByPropertyUseCase getUnitTypesByPropertyUseCase;

  /// يحتفظ هذا الحقل بقيمة getUnitFieldsUseCase التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the getUnitFieldsUseCase value used by the admin unit workflow.
  final GetUnitFieldsUseCase getUnitFieldsUseCase;

  /// ينشئ هذا المُنشئ مثيلاً من UnitFormBloc.
  /// This constructor creates an instance of UnitFormBloc.
  UnitFormBloc({
    required this.createUnitUseCase,
    required this.updateUnitUseCase,
    required this.getUnitTypesByPropertyUseCase,
    required this.getUnitFieldsUseCase,
  }) : super(UnitFormInitial()) {
    on<InitializeFormEvent>(_onInitializeForm);
    on<PropertySelectedEvent>(_onPropertySelected);
    on<UnitTypeSelectedEvent>(_onUnitTypeSelected);
    on<UpdateUnitNameEvent>(_onUpdateUnitName);
    on<UpdateUnitNameEnEvent>(_onUpdateUnitNameEn);
    on<UpdateDescriptionEvent>(_onUpdateDescription);
    on<UpdateDescriptionEnEvent>(_onUpdateDescriptionEn);
    on<UpdateCapacityEvent>(_onUpdateCapacity);
    on<UpdateUnitImageEvent>(_onUpdateUnitImage);
    on<UpdatePricingEvent>(_onUpdatePricing);
    on<UpdateFeaturesEvent>(_onUpdateFeatures);
    on<UpdateDynamicFieldsEvent>(_onUpdateDynamicFields);
    on<SubmitFormEvent>(_onSubmitForm);
    on<UpdateCancellationPolicyEvent>(_onUpdateCancellationPolicy);
  }

  /// ينفذ هذا الأسلوب عملية _onInitializeForm ضمن مسار إدارة الوحدات.
  /// This method performs the _onInitializeForm operation in the admin unit workflow.
  Future<void> _onInitializeForm(
    InitializeFormEvent event,
    Emitter<UnitFormState> emit,
  ) async {
    // لا تستخدم حالة تحميل هنا لتجنب الرجوع البصري ومسح الحقول عند التحرير
    if (event.unitId != null) {
      emit(UnitFormReady(
        isEditMode: true,
        unitId: event.unitId,
      ));
    } else {
      emit(UnitFormReady(tempKey: event.tempKey));
    }
  }

  /// ينفذ هذا الأسلوب عملية _onUpdateUnitName ضمن مسار إدارة الوحدات.
  /// This method performs the _onUpdateUnitName operation in the admin unit workflow.
  Future<void> _onUpdateUnitName(
    UpdateUnitNameEvent event,
    Emitter<UnitFormState> emit,
  ) async {
    if (state is UnitFormReady) {
      final currentState = state as UnitFormReady;
      emit(currentState.copyWith(
        unitName: event.name,
      ));
    }
  }

  Future<void> _onUpdateUnitNameEn(
    UpdateUnitNameEnEvent event,
    Emitter<UnitFormState> emit,
  ) async {
    if (state is UnitFormReady) {
      final currentState = state as UnitFormReady;
      emit(currentState.copyWith(
        unitNameEn: event.nameEn,
      ));
    }
  }

  /// ينفذ هذا الأسلوب عملية _onUpdateDescription ضمن مسار إدارة الوحدات.
  /// This method performs the _onUpdateDescription operation in the admin unit workflow.
  Future<void> _onUpdateDescription(
    UpdateDescriptionEvent event,
    Emitter<UnitFormState> emit,
  ) async {
    if (state is UnitFormReady) {
      final currentState = state as UnitFormReady;
      emit(currentState.copyWith(
        description: event.description,
        customFeatures: event.description,
      ));
    }
  }

  Future<void> _onUpdateDescriptionEn(
    UpdateDescriptionEnEvent event,
    Emitter<UnitFormState> emit,
  ) async {
    if (state is UnitFormReady) {
      final currentState = state as UnitFormReady;
      emit(currentState.copyWith(
        descriptionEn: event.descriptionEn,
      ));
    }
  }

  /// ينفذ هذا الأسلوب عملية _onPropertySelected ضمن مسار إدارة الوحدات.
  /// This method performs the _onPropertySelected operation in the admin unit workflow.
  Future<void> _onPropertySelected(
    PropertySelectedEvent event,
    Emitter<UnitFormState> emit,
  ) async {
    if (state is UnitFormReady) {
      final currentState = state as UnitFormReady;
      emit(currentState.copyWith(isLoadingUnitTypes: true));

      final targetPropertyTypeId = event.propertyTypeId ?? event.propertyId;
      final result = await getUnitTypesByPropertyUseCase(targetPropertyTypeId!);

      result.fold(
        (failure) => emit(UnitFormError(message: failure.message)),
        (unitTypes) => emit(currentState.copyWith(
          selectedPropertyId: event.propertyId,
          availableUnitTypes: unitTypes,
          isLoadingUnitTypes: false,
        )),
      );
    }
  }

  /// ينفذ هذا الأسلوب عملية _onUnitTypeSelected ضمن مسار إدارة الوحدات.
  /// This method performs the _onUnitTypeSelected operation in the admin unit workflow.
  Future<void> _onUnitTypeSelected(
    UnitTypeSelectedEvent event,
    Emitter<UnitFormState> emit,
  ) async {
    if (state is UnitFormReady) {
      final currentState = state as UnitFormReady;
      emit(currentState.copyWith(isLoadingFields: true));

      // Try resolve selected unit type from available list if present (safe for edit mode when list may be empty)
      UnitType? unitType;
      try {
        unitType = currentState.availableUnitTypes
            .firstWhere((type) => type.id == event.unitTypeId);
      } catch (_) {
        unitType =
            currentState.selectedUnitType; // keep previous if any (edit mode)
      }

      // Load fields for this unit type
      final result = await getUnitFieldsUseCase(event.unitTypeId);

      result.fold(
        (failure) => emit(UnitFormError(message: failure.message)),
        (fields) => emit(currentState.copyWith(
          selectedUnitType: unitType,
          unitTypeFields: fields,
          isLoadingFields: false,
        )),
      );
    }
  }

  /// ينفذ هذا الأسلوب عملية _onUpdateCapacity ضمن مسار إدارة الوحدات.
  /// This method performs the _onUpdateCapacity operation in the admin unit workflow.
  Future<void> _onUpdateCapacity(
    UpdateCapacityEvent event,
    Emitter<UnitFormState> emit,
  ) async {
    if (state is UnitFormReady) {
      final currentState = state as UnitFormReady;
      emit(currentState.copyWith(
        adultCapacity: event.adultCapacity,
        childrenCapacity: event.childrenCapacity,
      ));
    }
  }

  /// ينفذ هذا الأسلوب عملية _onUpdateUnitImage ضمن مسار إدارة الوحدات.
  /// This method performs the _onUpdateUnitImage operation in the admin unit workflow.
  Future<void> _onUpdateUnitImage(
    UpdateUnitImageEvent event,
    Emitter<UnitFormState> emit,
  ) async {
    if (state is UnitFormReady) {
      final currentState = state as UnitFormReady;
      emit(currentState.copyWith(
        images: event.images,
      ));
    }
  }

  /// ينفذ هذا الأسلوب عملية _onUpdatePricing ضمن مسار إدارة الوحدات.
  /// This method performs the _onUpdatePricing operation in the admin unit workflow.
  Future<void> _onUpdatePricing(
    UpdatePricingEvent event,
    Emitter<UnitFormState> emit,
  ) async {
    if (state is UnitFormReady) {
      final currentState = state as UnitFormReady;
      emit(currentState.copyWith(
        pricingMethod: event.pricingMethod,
      ));
    }
  }

  /// ينفذ هذا الأسلوب عملية _onUpdateFeatures ضمن مسار إدارة الوحدات.
  /// This method performs the _onUpdateFeatures operation in the admin unit workflow.
  Future<void> _onUpdateFeatures(
    UpdateFeaturesEvent event,
    Emitter<UnitFormState> emit,
  ) async {
    if (state is UnitFormReady) {
      final currentState = state as UnitFormReady;
      emit(currentState.copyWith(
        customFeatures: event.features,
      ));
    }
  }

  /// ينفذ هذا الأسلوب عملية _onUpdateDynamicFields ضمن مسار إدارة الوحدات.
  /// This method performs the _onUpdateDynamicFields operation in the admin unit workflow.
  Future<void> _onUpdateDynamicFields(
    UpdateDynamicFieldsEvent event,
    Emitter<UnitFormState> emit,
  ) async {
    if (state is UnitFormReady) {
      final currentState = state as UnitFormReady;
      emit(currentState.copyWith(
        dynamicFieldValues: event.values,
      ));
    }
  }

  /// ينفذ هذا الأسلوب عملية _onUpdateCancellationPolicy ضمن مسار إدارة الوحدات.
  /// This method performs the _onUpdateCancellationPolicy operation in the admin unit workflow.
  Future<void> _onUpdateCancellationPolicy(
    UpdateCancellationPolicyEvent event,
    Emitter<UnitFormState> emit,
  ) async {
    if (state is UnitFormReady) {
      final currentState = state as UnitFormReady;
      emit(currentState.copyWith(
        allowsCancellation: event.allowsCancellation,
        cancellationWindowDays: event.cancellationWindowDays,
      ));
    }
  }

  /// ينفذ هذا الأسلوب عملية _onSubmitForm ضمن مسار إدارة الوحدات.
  /// This method performs the _onSubmitForm operation in the admin unit workflow.
  Future<void> _onSubmitForm(
    SubmitFormEvent event,
    Emitter<UnitFormState> emit,
  ) async {
    if (state is UnitFormReady) {
      final currentState = state as UnitFormReady;

      // التحقق من البيانات المطلوبة قبل الإرسال
      if (!_validateFormData(currentState)) {
        print('❌ Validation failed');
        print('  - selectedPropertyId: ${currentState.selectedPropertyId}');
        print('  - selectedUnitType: ${currentState.selectedUnitType?.name}');
        print('  - unitName: ${currentState.unitName}');
        print('  - pricingMethod: ${currentState.pricingMethod}');
        emit(const UnitFormError(message: 'الرجاء ملء جميع الحقول المطلوبة'));
        return;
      }

      print('✅ Validation passed - Submitting form');
      emit(UnitFormLoading());

      if (currentState.isEditMode) {
        // Update existing unit
        final result = await updateUnitUseCase(UpdateUnitParams(
          unitId: currentState.unitId!,
          name: currentState.unitName,
          nameEn: currentState.unitNameEn,
          description: currentState.description ?? '',
          customFeatures:
              currentState.description ?? currentState.customFeatures,
          customFeaturesEn: currentState.descriptionEn,
          pricingMethod: currentState.pricingMethod?.value,
          fieldValues:
              _convertDynamicFieldsToList(currentState.dynamicFieldValues),
          images: currentState.images,
          adultCapacity: currentState.adultCapacity,
          childrenCapacity: currentState.childrenCapacity,
          allowsCancellation: currentState.allowsCancellation,
          cancellationWindowDays: currentState.cancellationWindowDays,
        ));

        result.fold(
          (failure) => emit(UnitFormError(message: failure.message)),
          (_) => emit(UnitFormSubmitted(unitId: currentState.unitId)),
        );
      } else {
        // Create new unit - مع التحقق الآمن
        print('🔵 Creating new unit...');
        final result = await createUnitUseCase(CreateUnitParams(
          propertyId: currentState.selectedPropertyId!,
          unitTypeId: currentState.selectedUnitType!.id,
          name: currentState.unitName!,
          nameEn: currentState.unitNameEn,
          description: currentState.description ?? '',
          customFeatures:
              currentState.description ?? currentState.customFeatures ?? '',
          customFeaturesEn: currentState.descriptionEn,
          pricingMethod: currentState.pricingMethod!.value,
          fieldValues:
              _convertDynamicFieldsToList(currentState.dynamicFieldValues),
          images: currentState.images,
          adultCapacity: currentState.adultCapacity ?? 0,
          childrenCapacity: currentState.childrenCapacity ?? 0,
          tempKey: currentState.tempKey,
          allowsCancellation: currentState.allowsCancellation,
          cancellationWindowDays: currentState.cancellationWindowDays,
        ));

        result.fold(
          (failure) {
            print('❌ Create unit failed: ${failure.message}');
            emit(UnitFormError(message: failure.message));
          },
          (newUnitId) {
            print('✅ Unit created successfully: $newUnitId');
            emit(UnitFormSubmitted(unitId: newUnitId));
          },
        );
      }
    }
  }

  // دالة للتحقق من صحة البيانات
  /// ينفذ هذا الأسلوب عملية _validateFormData ضمن مسار إدارة الوحدات.
  /// This method performs the _validateFormData operation in the admin unit workflow.
  bool _validateFormData(UnitFormReady state) {
    if (state.isEditMode) {
      return state.unitId != null;
    }

    // ✅ تحسين: description اختياري، فقط نتحقق من الحقول الأساسية
    return state.selectedPropertyId != null &&
        state.selectedUnitType != null &&
        state.unitName != null &&
        state.unitName!.isNotEmpty &&
        state.pricingMethod != null;
  }

  /// ينفذ هذا الأسلوب عملية _convertDynamicFieldsToList ضمن مسار إدارة الوحدات.
  /// This method performs the _convertDynamicFieldsToList operation in the admin unit workflow.
  List<Map<String, dynamic>> _convertDynamicFieldsToList(
    Map<String, dynamic> fieldValues,
  ) {
    return fieldValues.entries
        .map((entry) => {
              'fieldId': entry.key,
              'fieldValue': entry.value?.toString() ?? '',
            })
        .toList();
  }
}
