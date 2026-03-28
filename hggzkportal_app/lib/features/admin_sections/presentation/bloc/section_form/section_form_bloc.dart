import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/enums/section_content_type.dart';
import '../../../../../core/enums/section_display_style.dart';
import '../../../../../core/enums/section_target.dart';
import '../../../../../core/enums/section_type.dart';
import '../../../domain/entities/section.dart' as domain;
import '../../../domain/usecases/sections/create_section_usecase.dart';
import '../../../domain/usecases/sections/update_section_usecase.dart';
import '../../../domain/usecases/sections/get_section_by_id_usecase.dart';
import 'section_form_event.dart';
import 'section_form_state.dart';

/// يدير نموذج إنشاء الأقسام وتعديلها وتحميل بياناتها الأولية.
class SectionFormBloc extends Bloc<SectionFormEvent, SectionFormState> {
  /// ينشئ قسمًا جديدًا.
  final CreateSectionUseCase createSection;

  /// يحدث قسمًا موجودًا.
  final UpdateSectionUseCase updateSection;

  /// يجلب بيانات قسم محدد لملء النموذج عند التعديل.
  final GetSectionByIdUseCase getSectionById;

  // Store form data internally
  SectionFormReady _formData = const SectionFormReady(
    type: SectionTypeEnum.grid,
    contentType: SectionContentType.properties,
    displayStyle: SectionDisplayStyle.grid,
    target: SectionTarget.properties,
    displayOrder: 0,
    isActive: true,
    columnsCount: 2,
    itemsToShow: 10,
    isVisibleToGuests: true,
    isVisibleToRegistered: true,
  );

  /// يبني البلوك مع الاعتماديات الخاصة به.
  SectionFormBloc({
    required this.createSection,
    required this.updateSection,
    required this.getSectionById,
  }) : super(SectionFormInitial()) {
    on<InitializeSectionFormEvent>(_onInit);
    on<AttachSectionTempKeyEvent>(_onAttachTempKey);
    on<UpdateSectionBasicInfoEvent>(_onUpdateBasic);
    on<UpdateSectionConfigEvent>(_onUpdateConfig);
    on<UpdateSectionAppearanceEvent>(_onUpdateAppearance);
    on<UpdateSectionFiltersEvent>(_onUpdateFilters);
    on<UpdateSectionVisibilityEvent>(_onUpdateVisibility);
    on<UpdateSectionMetadataEvent>(_onUpdateMetadata);
    on<SubmitSectionFormEvent>(_onSubmit);
  }

  /// يهيئ النموذج عند الإنشاء أو التعديل.
  Future<void> _onInit(
    InitializeSectionFormEvent event,
    Emitter<SectionFormState> emit,
  ) async {
    // If we have a sectionId, we're editing - load the section data
    if (event.sectionId != null && event.sectionId!.isNotEmpty) {
      emit(SectionFormLoading());

      try {
        // Load section data from repository
        final result =
            await getSectionById(GetSectionByIdParams(event.sectionId!));

        result.fold((failure) {
          emit(SectionFormError(message: failure.message));
        }, (section) {
          // Map section entity to form data
          _formData = SectionFormReady(
            sectionId: section.id,
            name: section.name,
            title: section.title,
            subtitle: section.subtitle,
            description: section.description,
            shortDescription: section.shortDescription,
            type: section.type,
            contentType: section.contentType,
            displayStyle: section.displayStyle,
            target: section.target,
            displayOrder: section.displayOrder,
            isActive: section.isActive,
            columnsCount: section.columnsCount,
            itemsToShow: section.itemsToShow,
            categoryClass: section.categoryClass,
            homeItemsCount: section.homeItemsCount,
            icon: section.icon,
            colorTheme: section.colorTheme,
            backgroundImage: section.backgroundImage,
            filterCriteriaJson: section.filterCriteria,
            sortCriteriaJson: section.sortCriteria,
            cityName: section.cityName,
            propertyTypeId: section.propertyTypeId,
            unitTypeId: section.unitTypeId,
            minPrice: section.minPrice,
            maxPrice: section.maxPrice,
            minRating: section.minRating,
            isVisibleToGuests: section.isVisibleToGuests,
            isVisibleToRegistered: section.isVisibleToRegistered,
            requiresPermission: section.requiresPermission,
            startDate: section.startDate,
            endDate: section.endDate,
            metadataJson: section.metadata,
          );

          emit(_formData);
        });
      } catch (e) {
        emit(const SectionFormError(message: 'حدث خطأ في تحميل بيانات القسم'));
      }
    } else {
      // Creating new section - use defaults
      _formData = const SectionFormReady(
        type: SectionTypeEnum.grid,
        contentType: SectionContentType.properties,
        displayStyle: SectionDisplayStyle.grid,
        target: SectionTarget.properties,
        displayOrder: 0,
        isActive: true,
        columnsCount: 2,
        itemsToShow: 10,
        isVisibleToGuests: true,
        isVisibleToRegistered: true,
      );
      emit(_formData);
    }
  }

  /// يربط مفتاحًا مؤقتًا بالبيانات الداخلية للنموذج.
  Future<void> _onAttachTempKey(
    AttachSectionTempKeyEvent event,
    Emitter<SectionFormState> emit,
  ) async {
    _formData = _formData.copyWith(tempKey: event.tempKey);
    emit(_formData);
  }

  /// يحدّث البيانات الأساسية للقسم.
  Future<void> _onUpdateBasic(
    UpdateSectionBasicInfoEvent event,
    Emitter<SectionFormState> emit,
  ) async {
    _formData = _formData.copyWith(
      name: event.name ?? _formData.name,
      title: event.title ?? _formData.title,
      subtitle: event.subtitle ?? _formData.subtitle,
      description: event.description ?? _formData.description,
      shortDescription: event.shortDescription ?? _formData.shortDescription,
    );
    emit(_formData);
  }

  /// يحدّث إعدادات القسم وسلوكه العام.
  Future<void> _onUpdateConfig(
    UpdateSectionConfigEvent event,
    Emitter<SectionFormState> emit,
  ) async {
    _formData = _formData.copyWith(
      type: event.type ?? _formData.type,
      contentType: event.contentType ?? _formData.contentType,
      displayStyle: event.displayStyle ?? _formData.displayStyle,
      target: event.target ?? _formData.target,
      displayOrder: event.displayOrder ?? _formData.displayOrder,
      columnsCount: event.columnsCount ?? _formData.columnsCount,
      itemsToShow: event.itemsToShow ?? _formData.itemsToShow,
      isActive: event.isActive ?? _formData.isActive,
      categoryClass: event.categoryClass ?? _formData.categoryClass,
      homeItemsCount: event.homeItemsCount ?? _formData.homeItemsCount,
    );
    emit(_formData);
  }

  /// يحدّث مظهر القسم والعناصر البصرية المرتبطة به.
  Future<void> _onUpdateAppearance(
    UpdateSectionAppearanceEvent event,
    Emitter<SectionFormState> emit,
  ) async {
    _formData = _formData.copyWith(
      icon: event.icon ?? _formData.icon,
      colorTheme: event.colorTheme ?? _formData.colorTheme,
      backgroundImage: event.backgroundImage ?? _formData.backgroundImage,
    );
    emit(_formData);
  }

  /// يحدّث معايير التصفية والفرز والربط.
  Future<void> _onUpdateFilters(
    UpdateSectionFiltersEvent event,
    Emitter<SectionFormState> emit,
  ) async {
    _formData = _formData.copyWith(
      filterCriteriaJson:
          event.filterCriteriaJson ?? _formData.filterCriteriaJson,
      sortCriteriaJson: event.sortCriteriaJson ?? _formData.sortCriteriaJson,
      cityName: event.cityName ?? _formData.cityName,
      propertyTypeId: event.propertyTypeId ?? _formData.propertyTypeId,
      unitTypeId: event.unitTypeId ?? _formData.unitTypeId,
      minPrice: event.minPrice ?? _formData.minPrice,
      maxPrice: event.maxPrice ?? _formData.maxPrice,
      minRating: event.minRating ?? _formData.minRating,
    );
    emit(_formData);
  }

  /// يحدّث حالة الظهور والصلاحيات والفترة الزمنية.
  Future<void> _onUpdateVisibility(
    UpdateSectionVisibilityEvent event,
    Emitter<SectionFormState> emit,
  ) async {
    _formData = _formData.copyWith(
      isVisibleToGuests: event.isVisibleToGuests ?? _formData.isVisibleToGuests,
      isVisibleToRegistered:
          event.isVisibleToRegistered ?? _formData.isVisibleToRegistered,
      requiresPermission:
          event.requiresPermission ?? _formData.requiresPermission,
      startDate: event.startDate ?? _formData.startDate,
      endDate: event.endDate ?? _formData.endDate,
    );
    emit(_formData);
  }

  /// يحدّث الحمولة الوصفية للنموذج.
  Future<void> _onUpdateMetadata(
    UpdateSectionMetadataEvent event,
    Emitter<SectionFormState> emit,
  ) async {
    _formData = _formData.copyWith(
        metadataJson: event.metadataJson ?? _formData.metadataJson);
    emit(_formData);
  }

  Future<void> _onSubmit(
    SubmitSectionFormEvent event,
    Emitter<SectionFormState> emit,
  ) async {
    // التحقق من الحقول المطلوبة
    if (_formData.name == null || _formData.name!.isEmpty) {
      emit(const SectionFormError(message: 'اسم القسم مطلوب'));
      await Future.delayed(const Duration(milliseconds: 100));
      emit(_formData);
      return;
    }

    if (_formData.title == null || _formData.title!.isEmpty) {
      emit(const SectionFormError(message: 'عنوان القسم مطلوب'));
      await Future.delayed(const Duration(milliseconds: 100));
      emit(_formData);
      return;
    }

    emit(SectionFormLoading());

    try {
      final payload = domain.Section(
        id: _formData.sectionId ?? '',
        type: _formData.type ?? SectionTypeEnum.grid,
        contentType: _formData.contentType ?? SectionContentType.properties,
        displayStyle: _formData.displayStyle ?? SectionDisplayStyle.grid,
        name: _formData.name!,
        title: _formData.title!,
        subtitle: _formData.subtitle,
        description: _formData.description,
        shortDescription: _formData.shortDescription,
        displayOrder: _formData.displayOrder ?? 0,
        target: _formData.target ?? SectionTarget.properties,
        isActive: _formData.isActive ?? true,
        columnsCount: _formData.columnsCount ?? 2,
        itemsToShow: _formData.itemsToShow ?? 10,
        categoryClass: _formData.categoryClass,
        homeItemsCount: _formData.homeItemsCount,
        icon: _formData.icon,
        colorTheme: _formData.colorTheme,
        backgroundImage: _formData.backgroundImage,
        filterCriteria: _formData.filterCriteriaJson,
        sortCriteria: _formData.sortCriteriaJson,
        cityName: _formData.cityName,
        propertyTypeId: _formData.propertyTypeId,
        unitTypeId: _formData.unitTypeId,
        minPrice: _formData.minPrice,
        maxPrice: _formData.maxPrice,
        minRating: _formData.minRating,
        isVisibleToGuests: _formData.isVisibleToGuests ?? true,
        isVisibleToRegistered: _formData.isVisibleToRegistered ?? true,
        requiresPermission: _formData.requiresPermission,
        startDate: _formData.startDate,
        endDate: _formData.endDate,
        metadata: _formData.metadataJson,
      );

      if ((_formData.sectionId ?? '').isEmpty) {
        // إنشاء قسم جديد
        final res = await createSection(CreateSectionParams(
          payload,
          tempKey: _formData.tempKey,
        ));

        res.fold(
          (failure) {
            emit(SectionFormError(message: failure.message));
            // ✅ إصلاح: استخدام emit.isDone للتحقق قبل emit
          },
          (created) {
            emit(SectionFormSubmitted(sectionId: created.id));
          },
        );
      } else {
        // تحديث قسم موجود
        final res = await updateSection(UpdateSectionParams(
          sectionId: _formData.sectionId!,
          section: payload,
        ));

        res.fold(
          (failure) {
            emit(SectionFormError(message: failure.message));
            // ✅ إصلاح: إزالة Future.delayed بدون await
          },
          (updated) {
            emit(SectionFormSubmitted(sectionId: updated.id));
          },
        );
      }
    } catch (e) {
      emit(SectionFormError(message: 'حدث خطأ: ${e.toString()}'));
      await Future.delayed(const Duration(milliseconds: 100));
      emit(_formData);
    }
  }
}
