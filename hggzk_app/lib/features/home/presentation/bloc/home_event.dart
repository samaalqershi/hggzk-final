// lib/features/home/presentation/bloc/home_event.dart
import 'package:equatable/equatable.dart';

/// يمثّل النوع الأساسي لكل الأوامر التي ترسلها واجهة الصفحة الرئيسية إلى
/// `HomeBloc` من أجل التحميل، التصفية، أو تسجيل التفاعل.
/// Base type for every command that the home UI sends to `HomeBloc` to load
/// data, update filters, or record interaction.
abstract class HomeEvent extends Equatable {
  /// ينشئ الحدث الأساسي الذي ترث منه جميع أحداث الصفحة الرئيسية.
  /// Creates the shared base event from which all home events inherit.
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

/// يطلب تحميل الحزمة الأولية التي تحتاجها الصفحة الرئيسية عند فتحها لأول مرة
/// أو عند إعادة بناء حالتها من البداية.
/// Requests the initial payload required when the home screen first opens or
/// when its state must be rebuilt from scratch.
class LoadHomeDataEvent extends HomeEvent {
  /// يحدد ما إذا كان يجب تجاوز أي بيانات مخزنة مؤقتًا وجلب نسخة جديدة مباشرة.
  /// Determines whether cached data should be bypassed in favor of a fresh
  /// fetch.
  final bool forceRefresh;

  /// ينشئ حدث التحميل الأولي مع خيار فرض التحديث عند الحاجة.
  /// Creates the bootstrap event with an optional forced refresh flag.
  const LoadHomeDataEvent({this.forceRefresh = false});
  @override
  List<Object?> get props => [forceRefresh];
}

/// يطلب جلب تعريفات الأقسام المعروضة في الصفحة الرئيسية مع السياق الحالي
/// للترقيم والتصفية.
/// Requests the section definitions shown on the home screen using the current
/// pagination and filtering context.
class LoadSectionsEvent extends HomeEvent {
  /// الصفحة المطلوبة من دليل الأقسام.
  /// Requested page from the section catalog.
  final int pageNumber;

  /// عدد الأقسام المطلوب إرجاعها في هذا الطلب.
  /// Number of sections requested by this fetch.
  final int pageSize;

  /// يقيّد التحميل على هدف عرض معين إذا كانت الأقسام متعددة السياقات.
  /// Restricts loading to a specific display target when sections support
  /// multiple contexts.
  final String? target;

  /// يفلتر الأقسام بنوع منطقي معين داخل الصفحة الرئيسية.
  /// Filters the section list by a specific logical home-section type.
  final String? type;

  /// يحدد ما إذا كان يجب تجاوز النتائج المخبأة وإعادة القراءة من المصدر.
  /// Indicates whether cached results should be skipped in favor of source data.
  final bool forceRefresh;

  /// ينشئ حدث تحميل الأقسام مع تفاصيل الصفحة ومعايير التصفية.
  /// Creates the section-loading event with paging and filter details.
  const LoadSectionsEvent({
    this.pageNumber = 1,
    this.pageSize = 10,
    this.target,
    this.type,
    this.forceRefresh = false,
  });
  @override
  List<Object?> get props => [pageNumber, pageSize, target, type, forceRefresh];
}

/// يطلب عناصر قسم واحد عندما تحتاج الواجهة إلى بناء بطاقاته أو تحميل دفعة
/// إضافية منه بشكل مستقل.
/// Requests the items of a single section when the UI needs to render its
/// cards or paginate it independently.
class LoadSectionDataEvent extends HomeEvent {
  /// معرّف القسم الذي ستُجلب عناصره.
  /// Identifier of the section whose content should be fetched.
  final String sectionId;

  /// الصفحة المطلوبة من عناصر القسم.
  /// Requested page from the section item feed.
  final int pageNumber;

  /// عدد العناصر المطلوب إرجاعها في كل دفعة.
  /// Number of items requested in each batch.
  final int pageSize;

  /// يحدد ما إذا كان يجب تجاهل النسخة المخزنة لهذا القسم.
  /// Indicates whether the cached section payload should be ignored.
  final bool forceRefresh;

  /// ينشئ حدث تحميل عناصر القسم مع تفاصيل الصفحة الحالية.
  /// Creates the section-item loading event with the current paging details.
  const LoadSectionDataEvent({
    required this.sectionId,
    this.pageNumber = 1,
    this.pageSize = 10,
    this.forceRefresh = false,
  });
  @override
  List<Object?> get props => [sectionId, pageNumber, pageSize, forceRefresh];
}

/// يطلب أنواع العقارات التي تمثل الطبقة الأولى من التصفح في الصفحة الرئيسية.
/// Requests the property types that represent the first browsing layer on the
/// home screen.
class LoadPropertyTypesEvent extends HomeEvent {
  /// ينشئ حدث تحميل أنواع العقارات.
  /// Creates the property-type loading event.
  const LoadPropertyTypesEvent();
}

/// يطلب أنواع الوحدات التابعة لنوع العقار النشط حتى تتسق الفلاتر والحقول
/// المشتقة مع اختيار المستخدم الحالي.
/// Requests the unit types that belong to the active property type so derived
/// filters and fields stay aligned with the current selection.
class LoadUnitTypesEvent extends HomeEvent {
  /// معرّف نوع العقار الأب الذي سنشتق منه أنواع الوحدات.
  /// Identifier of the parent property type from which unit types are derived.
  final String propertyTypeId;

  /// ينشئ حدث تحميل أنواع الوحدات لنوع العقار المحدد.
  /// Creates the unit-type loading event for the selected property type.
  const LoadUnitTypesEvent({required this.propertyTypeId});
  @override
  List<Object?> get props => [propertyTypeId];
}

/// يسجل أن قسمًا معينًا أصبح مرئيًا للمستخدم بما يكفي لاحتسابه ظهورًا تحليليًا.
/// Records that a section became visible to the user long enough to count as an
/// analytics impression.
class RecordSectionImpressionEvent extends HomeEvent {
  /// معرّف القسم الذي حصل له ظهور فعلي.
  /// Identifier of the section that generated the impression.
  final String sectionId;

  /// ينشئ حدث تسجيل ظهور القسم.
  /// Creates the event used to record a section impression.
  const RecordSectionImpressionEvent({required this.sectionId});
  @override
  List<Object?> get props => [sectionId];
}

/// يسجل تفاعلًا أعمق داخل القسم، مثل الضغط على عنصر أو فتحه، حتى يمكن فهم
/// السلوك الذي نتج عن ترتيب المحتوى.
/// Records a deeper interaction within a section, such as tapping or opening
/// an item, so we can understand the behavior driven by content placement.
class RecordSectionInteractionEvent extends HomeEvent {
  /// معرّف القسم الذي وقع فيه التفاعل.
  /// Identifier of the section where the interaction took place.
  final String sectionId;

  /// النوع المنطقي للتفاعل المسجل مثل النقر أو الفتح أو التمرير.
  /// Logical interaction type, such as tap, open, or scroll.
  final String interactionType;

  /// معرّف العنصر المستهدف إذا كان الحدث مرتبطًا بعنصر فرعي داخل القسم.
  /// Optional target item identifier when the interaction concerns a child item.
  final String? itemId;

  /// معلومات إضافية تساعد التحليلات على تفسير ظروف التفاعل.
  /// Extra metadata that helps analytics interpret the interaction context.
  final Map<String, dynamic>? metadata;

  /// ينشئ حدث تسجيل التفاعل مع تمرير كل المعلومات المساندة.
  /// Creates the interaction-recording event with its supporting context.
  const RecordSectionInteractionEvent({
    required this.sectionId,
    required this.interactionType,
    this.itemId,
    this.metadata,
  });
  @override
  List<Object?> get props => [sectionId, interactionType, itemId, metadata];
}

/// يحدّث عبارة البحث الداخلية التي تؤثر في فلاتر الصفحة الرئيسية ومحتواها.
/// Updates the internal search phrase that influences home filtering and
/// content display.
class UpdateSearchQueryEvent extends HomeEvent {
  /// النص الجديد الذي كتبه المستخدم في واجهة البحث.
  /// Latest query text entered by the user.
  final String query;

  /// ينشئ حدث تغيير عبارة البحث النشطة.
  /// Creates the event that replaces the active search phrase.
  const UpdateSearchQueryEvent({required this.query});
  @override
  List<Object?> get props => [query];
}

/// يمسح عبارة البحث الحالية ويعيد الصفحة إلى وضع التصفح العام.
/// Clears the current search phrase and restores generic browsing mode.
class ClearSearchEvent extends HomeEvent {
  /// ينشئ حدث مسح البحث.
  /// Creates the search-clearing event.
  const ClearSearchEvent();
}

/// يغيّر نوع العقار النشط الذي تعتمد عليه بقية الفلاتر والأقسام المشتقة.
/// Changes the active property type that drives dependent filters and derived
/// home content.
class UpdatePropertyTypeFilterEvent extends HomeEvent {
  /// معرّف نوع العقار الجديد أو `null` عند إزالة الفلتر.
  /// Newly selected property type id, or `null` when clearing the filter.
  final String? propertyTypeId;

  /// ينشئ حدث تحديث فلتر نوع العقار.
  /// Creates the property-type filter update event.
  const UpdatePropertyTypeFilterEvent({this.propertyTypeId});
  @override
  List<Object?> get props => [propertyTypeId];
}

/// يغيّر نوع الوحدة المختار وما ينتج عنه من حقول ديناميكية وسعة وقيود عرض.
/// Changes the selected unit type and the dynamic fields, capacity, and
/// display rules that depend on it.
class UpdateUnitTypeSelectionEvent extends HomeEvent {
  /// معرّف نوع الوحدة الجديد أو `null` عندما يتم إلغاء الاختيار.
  /// Newly selected unit type id, or `null` when the selection is cleared.
  final String? unitTypeId;

  /// ينشئ حدث تحديث نوع الوحدة المختار.
  /// Creates the unit-type selection update event.
  const UpdateUnitTypeSelectionEvent({this.unitTypeId});
  @override
  List<Object?> get props => [unitTypeId];
}

/// يمرر القيم الديناميكية التي أدخلها المستخدم في الحقول التابعة لنوع الوحدة
/// الحالي حتى تبقى الحالة المركزية متزامنة مع الواجهة.
/// Carries dynamic values entered in fields tied to the current unit type so
/// central state remains synchronized with the UI.
class UpdateDynamicFieldValuesEvent extends HomeEvent {
  /// الخريطة الحالية لقيم الحقول الديناميكية بعد آخر تعديل من المستخدم.
  /// Current map of dynamic field values after the latest user change.
  final Map<String, dynamic> values;

  /// ينشئ حدث مزامنة القيم الديناميكية.
  /// Creates the event that syncs dynamic values into bloc state.
  const UpdateDynamicFieldValuesEvent({required this.values});
  @override
  List<Object?> get props => [values];
}

/// يطلب إعادة تحميل الصفحة الرئيسية مع الحفاظ قدر الإمكان على سياق التصفح
/// الحالي للمستخدم.
/// Requests a home refresh while preserving as much of the current browsing
/// context as possible.
class RefreshHomeDataEvent extends HomeEvent {
  /// ينشئ حدث التحديث الكامل للصفحة الرئيسية.
  /// Creates the full home refresh event.
  const RefreshHomeDataEvent();
}

/// يطلب الصفحة التالية من عناصر قسم معيّن عند الوصول إلى نهاية القائمة
/// المعروضة لذلك القسم.
/// Requests the next page of items for a specific section when the user reaches
/// the end of its current list.
class LoadMoreSectionDataEvent extends HomeEvent {
  /// معرّف القسم الذي نريد متابعة تحميل عناصره.
  /// Identifier of the section whose items should continue loading.
  final String sectionId;

  /// ينشئ حدث تحميل المزيد لقسم واحد.
  /// Creates the pagination event for one section.
  const LoadMoreSectionDataEvent({required this.sectionId});
  @override
  List<Object?> get props => [sectionId];
}
