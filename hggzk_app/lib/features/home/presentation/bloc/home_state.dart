// lib/features/home/presentation/bloc/home_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/section.dart';
import '../../domain/entities/property_type.dart';
import '../../domain/entities/unit_type.dart';
import '../../../home/data/models/section_item_models.dart';
import '../../../search/data/models/search_result_model.dart';
import '../../../../core/models/paginated_result.dart' as core;

/// يمثّل النوع الأساسي لكل اللقطات التي يمكن أن يمر بها تدفق الصفحة الرئيسية،
/// من التحميل الأولي وحتى النتائج الجزئية والأخطاء.
/// Base type for every snapshot the home flow can move through, from initial
/// loading to partial results and recoverable failures.
abstract class HomeState extends Equatable {
  /// ينشئ الجذر الذي ترث منه جميع حالات الصفحة الرئيسية.
  /// Creates the shared root inherited by all home states.
  const HomeState();
  @override
  List<Object?> get props => [];
}

/// تمثل اللحظة التي لم يبدأ فيها `HomeBloc` أي طلبات أو استرجاع محلي بعد.
/// Represents the moment before `HomeBloc` starts any network or local restore
/// work.
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// تعبّر عن فترة تحميل البيانات الأساسية قبل أن تصبح الصفحة الرئيسية قابلة
/// للتفاعل.
/// Describes the period in which the core home payload is still loading before
/// the screen becomes interactive.
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// تمثل الحالة الجاهزة التي تحمل كل ما تحتاجه الواجهة من أقسام، بيانات
/// مترقمة، فلاتر نشطة، واختيارات تمت استعادتها من الجلسات السابقة.
/// Represents the ready state that carries everything the UI needs: sections,
/// paginated section data, active filters, and selections restored from prior
/// sessions.
class HomeLoaded extends HomeState {
  /// الأقسام النهائية التي يجب رسمها داخل الصفحة الرئيسية.
  /// Final section definitions that should be rendered on the home screen.
  final List<Section> sections;

  /// العناصر المحمّلة لكل قسم مع معلومات الصفحات الخاصة به.
  /// Loaded items for each section together with their pagination metadata.
  final Map<String, core.PaginatedResult<SectionPropertyItemModel>> sectionData;

  /// أنواع العقارات التي تغذي رحلة التصفح السريع والفلاتر الأولية.
  /// Property types that drive quick discovery and the first layer of filters.
  final List<PropertyType> propertyTypes;

  /// أنواع الوحدات المرتبة بحسب نوع العقار الأب حتى تبقى التبعية واضحة.
  /// Unit types grouped by their parent property type so dependencies remain
  /// explicit.
  final Map<String, List<UnitType>> unitTypes;

  /// يبيّن ما إذا كانت الأنواع الأساسية حُمّلت من طلب موحد لتقليل الرحلات
  /// الشبكية.
  /// Indicates whether the foundational type data was loaded through one
  /// combined request to reduce network round trips.
  final bool combinedUnitsPreloaded;

  /// نوع العقار الذي أُعيد من التخزين المحلي إذا بقي صالحًا بعد التحقق.
  /// Property type restored from local storage if it remained valid after
  /// validation.
  final String? selectedPropertyTypeId;

  /// نوع الوحدة الذي بقي صالحًا بعد مراجعة الاختيارات المحفوظة.
  /// Unit type that remained valid after reviewing saved selections.
  final String? selectedUnitTypeId;

  /// القيم الناتجة عن الحقول الديناميكية التابعة لاختيار الوحدة الحالي.
  /// Values captured from dynamic fields tied to the current unit-type
  /// selection.
  final Map<String, dynamic> dynamicFieldValues;

  /// عبارة البحث الداخلية المستخدمة لتصفية المحتوى أو الاقتراحات داخل الصفحة.
  /// Internal search phrase used to filter content or suggestions within the
  /// screen.
  final String searchQuery;

  /// يحدد ما إذا كانت الصفحة تمر الآن بعملية تحديث مرئي للمستخدم.
  /// Indicates whether the screen is currently running a user-visible refresh.
  final bool isRefreshing;

  /// يحدد ما إذا كانت البيانات الحالية وصلت إلى آخر صفحة متاحة.
  /// Indicates whether the current dataset has already reached its final page.
  final bool hasReachedMax;

  /// حالة تحميل المزيد لكل قسم على حدة حتى لا يتعطل باقي العرض.
  /// Per-section load-more state so one list can paginate without blocking the
  /// rest of the screen.
  final Map<String, bool> sectionsLoadingMore;

  /// ينشئ اللقطة الجاهزة التي تعتمد عليها الواجهة في عرض محتوى الصفحة
  /// الرئيسية والتفاعل معه.
  /// Creates the ready snapshot used by the UI to render and interact with
  /// home content.
  const HomeLoaded({
    required this.sections,
    required this.sectionData,
    required this.propertyTypes,
    required this.unitTypes,
    this.combinedUnitsPreloaded = false,
    this.selectedPropertyTypeId,
    this.selectedUnitTypeId,
    this.dynamicFieldValues = const {},
    this.searchQuery = '',
    this.isRefreshing = false,
    this.hasReachedMax = false,
    required this.sectionsLoadingMore,
  });
  @override
  List<Object?> get props => [
        sections,
        sectionData,
        propertyTypes,
        unitTypes,
        combinedUnitsPreloaded,
        selectedPropertyTypeId,
        selectedUnitTypeId,
        dynamicFieldValues,
        searchQuery,
        isRefreshing,
        hasReachedMax,
        sectionsLoadingMore,
      ];

  /// يبني نسخة جديدة من الحالة مع استبدال الحقول المطلوبة فقط والإبقاء على
  /// بقية السياق كما هو.
  /// Builds a new state snapshot while replacing only the requested fields and
  /// keeping the rest of the context intact.
  HomeLoaded copyWith({
    List<Section>? sections,
    Map<String, core.PaginatedResult<SectionPropertyItemModel>>? sectionData,
    List<PropertyType>? propertyTypes,
    Map<String, List<UnitType>>? unitTypes,
    bool? combinedUnitsPreloaded,
    Object? selectedPropertyTypeId = const _Undefined(),
    Object? selectedUnitTypeId = const _Undefined(),
    Map<String, dynamic>? dynamicFieldValues,
    String? searchQuery,
    bool? isRefreshing,
    bool? hasReachedMax,
    Map<String, bool>? sectionsLoadingMore,
  }) {
    return HomeLoaded(
      sections: sections ?? this.sections,
      sectionData: sectionData ?? this.sectionData,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      unitTypes: unitTypes ?? this.unitTypes,
      combinedUnitsPreloaded:
          combinedUnitsPreloaded ?? this.combinedUnitsPreloaded,
      selectedPropertyTypeId: selectedPropertyTypeId is _Undefined
          ? this.selectedPropertyTypeId
          : selectedPropertyTypeId as String?,
      selectedUnitTypeId: selectedUnitTypeId is _Undefined
          ? this.selectedUnitTypeId
          : selectedUnitTypeId as String?,
      dynamicFieldValues: dynamicFieldValues ?? this.dynamicFieldValues,
      searchQuery: searchQuery ?? this.searchQuery,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      sectionsLoadingMore: sectionsLoadingMore ?? this.sectionsLoadingMore,
    );
  }
}

class _Undefined {
  const _Undefined();
}

/// تمثل حالة تحميل قسم واحد فقط بينما تبقى بقية الصفحة الرئيسية جاهزة
/// للاستخدام.
/// Represents the loading state for one section while the rest of the home
/// screen stays usable.
class SectionLoading extends HomeState {
  /// معرّف القسم الذي ما زال يجلب بياناته.
  /// Identifier of the section whose data is still loading.
  final String sectionId;

  /// ينشئ حالة تحميل جزئية لقسم واحد.
  /// Creates the partial-loading state for a single section.
  const SectionLoading({required this.sectionId});
  @override
  List<Object?> get props => [sectionId];
}

/// تمثل اكتمال تحميل قسم واحد مع البيانات المرقمة الخاصة به من دون المساس
/// ببقية الصفحة.
/// Represents a successful load for one section together with its paginated
/// data, without affecting the rest of the screen.
class SectionDataLoaded extends HomeState {
  /// معرّف القسم الذي اكتمل تحميله.
  /// Identifier of the section that finished loading.
  final String sectionId;

  /// الحمولة المرقمة التي ستُعرض داخل ذلك القسم.
  /// Paginated payload that should be rendered inside that section.
  final core.PaginatedResult<SectionPropertyItemModel> data;

  /// ينشئ حالة نجاح جزئية لقسم واحد.
  /// Creates the partial-success state for a single section.
  const SectionDataLoaded({
    required this.sectionId,
    required this.data,
  });
  @override
  List<Object?> get props => [sectionId, data];
}

/// تمثل نجاح تحميل أنواع العقارات التي يعتمد عليها التصفح الأولي والفلاتر.
/// Represents the successful load of property types used by discovery and
/// filtering.
class PropertyTypesLoaded extends HomeState {
  /// أنواع العقارات الجاهزة للاستخدام في الواجهة.
  /// Property types ready to be used by the UI.
  final List<PropertyType> propertyTypes;

  /// ينشئ حالة نجاح تحميل أنواع العقارات.
  /// Creates the success state for property-type loading.
  const PropertyTypesLoaded({required this.propertyTypes});
  @override
  List<Object?> get props => [propertyTypes];
}

/// تمثل نجاح تحميل أنواع الوحدات التابعة لنوع عقار محدد بعد اختيار المستخدم
/// له.
/// Represents the successful load of unit types for the property type selected
/// by the user.
class UnitTypesLoaded extends HomeState {
  /// معرّف نوع العقار الذي اشتُقت منه أنواع الوحدات.
  /// Identifier of the property type from which the unit types were derived.
  final String propertyTypeId;

  /// قائمة أنواع الوحدات الجاهزة للاستخدام ضمن ذلك السياق.
  /// Unit types ready to be used within that property-type context.
  final List<UnitType> unitTypes;

  /// ينشئ حالة نجاح تحميل أنواع الوحدات.
  /// Creates the success state for unit-type loading.
  const UnitTypesLoaded({
    required this.propertyTypeId,
    required this.unitTypes,
  });
  @override
  List<Object?> get props => [propertyTypeId, unitTypes];
}

/// تمثل فشلًا عامًا في تدفق الصفحة الرئيسية مع رسالة قابلة للعرض وشفرة خطأ
/// اختيارية للاستخدام التشخيصي.
/// Represents a general home-flow failure with a user-facing message and an
/// optional diagnostic error code.
class HomeError extends HomeState {
  /// الرسالة التي يمكن عرضها للمستخدم أو تسجيلها في السجلات.
  /// Message that can be shown to the user or written to logs.
  final String message;

  /// رمز اختياري يساعد على تتبع نوع الخطأ أو مصدره.
  /// Optional code that helps trace the error type or source.
  final String? errorCode;

  /// ينشئ حالة الفشل العامة للصفحة الرئيسية.
  /// Creates the generic failure state for the home flow.
  const HomeError({
    required this.message,
    this.errorCode,
  });
  @override
  List<Object?> get props => [message, errorCode];
}

/// تمثل فشل تحميل قسم محدد من دون إسقاط بقية الصفحة أو فقدان البيانات
/// الموجودة بالفعل.
/// Represents a failure to load one section without collapsing the rest of the
/// screen or losing already available data.
class SectionError extends HomeState {
  /// معرّف القسم الذي فشل تحميله.
  /// Identifier of the section that failed to load.
  final String sectionId;

  /// الرسالة المرتبطة بخطأ ذلك القسم.
  /// Message associated with the section-level failure.
  final String message;

  /// ينشئ حالة فشل جزئية لقسم واحد.
  /// Creates the partial failure state for a single section.
  const SectionError({
    required this.sectionId,
    required this.message,
  });
  @override
  List<Object?> get props => [sectionId, message];
}

/// تمثل نتائج البحث الداخلية المستخدمة في الاقتراحات أو المطابقة السريعة
/// داخل الصفحة الرئيسية قبل الانتقال إلى شاشة بحث مستقلة.
/// Represents the internal search results used for suggestions or quick
/// matching inside the home screen before moving into a dedicated search page.
class SearchState extends HomeState {
  /// عبارة البحث التي أنتجت النتائج الحالية.
  /// Query that produced the current results.
  final String query;

  /// النتائج المطابقة التي ستعرض في القائمة أو الاقتراحات.
  /// Matching results that should be shown in lists or suggestion surfaces.
  final List<SearchResultModel> results;

  /// يحدد ما إذا كان البحث ما زال قيد التنفيذ أثناء عرض الحالة.
  /// Indicates whether the search is still running while this state is shown.
  final bool isLoading;

  /// ينشئ حالة نتائج البحث الداخلية.
  /// Creates the internal search-results state.
  const SearchState({
    required this.query,
    required this.results,
    this.isLoading = false,
  });
  @override
  List<Object?> get props => [query, results, isLoading];
}
