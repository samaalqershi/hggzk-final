import 'package:equatable/equatable.dart';
import 'search_state.dart';

/// Base event for search flows. Concrete events cover executing queries,
/// loading filters or suggestions, changing the view mode, and managing saved
/// searches or recent terms.
/// الحدث الأساسي لمسارات البحث. الأحداث المشتقة تغطي تنفيذ الاستعلامات
/// وجلب الفلاتر أو الاقتراحات وتغيير وضع العرض وإدارة عمليات البحث المحفوظة
/// أو الحديثة.
abstract class SearchEvent extends Equatable {
  /// Builds the shared base for all search events.
  /// ينشئ الأساس المشترك لكل أحداث البحث.
  const SearchEvent();

  /// Search events are compared by their payload so pagination and filters can
  /// be tracked accurately.
  /// تُقارن أحداث البحث بحسب حمولتها حتى يمكن تتبع الترقيم والفلاتر بدقة.
  @override
  List<Object?> get props => [];
}

/// Executes a property search using the currently selected criteria and
/// pagination settings.
/// ينفذ بحثًا عن العقارات باستخدام المعايير المختارة حاليًا وإعدادات الترقيم.
class SearchPropertiesEvent extends SearchEvent {
  /// Free-text query used to narrow the property list.
  /// النص الحر المستخدم لتضييق قائمة العقارات.
  final String? searchTerm;

  /// City filter selected by the user.
  /// فلتر المدينة المختار من المستخدم.
  final String? city;

  /// Property type filter.
  /// فلتر نوع العقار.
  final String? propertyTypeId;

  /// Lower price boundary for the search.
  /// الحد الأدنى للسعر في البحث.
  final double? minPrice;

  /// Upper price boundary for the search.
  /// الحد الأعلى للسعر في البحث.
  final double? maxPrice;

  /// Minimum rating required for matches.
  /// الحد الأدنى للتقييم المطلوب في النتائج.
  final int? minStarRating;

  /// Amenities that must exist for the property to match.
  /// المزايا التي يجب أن تتوفر في العقار ليطابق البحث.
  final List<String>? requiredAmenities;

  /// Unit type filter used by the search form.
  /// فلتر نوع الوحدة المستخدم في نموذج البحث.
  final String? unitTypeId;

  /// Service ids that must be present in the result.
  /// معرّفات الخدمات التي يجب أن تكون متوفرة في النتيجة.
  final List<String>? serviceIds;

  /// Desired check-in date.
  /// تاريخ الدخول المطلوب.
  final DateTime? checkIn;

  /// Desired check-out date.
  /// تاريخ الخروج المطلوب.
  final DateTime? checkOut;

  /// Number of adults in the requested stay.
  /// عدد البالغين في الإقامة المطلوبة.
  final int? adults;

  /// Number of children in the requested stay.
  /// عدد الأطفال في الإقامة المطلوبة.
  final int? children;

  /// Total guest count used when the form captures one combined number.
  /// إجمالي عدد الضيوف المستخدم عندما يرسل النموذج رقمًا واحدًا فقط.
  final int? guestsCount;

  /// Extra dynamic filters defined by the active property form.
  /// فلاتر ديناميكية إضافية يعرّفها نموذج العقار النشط.
  final Map<String, dynamic>? dynamicFieldFilters;

  /// Latitude used by proximity-based search.
  /// خط العرض المستخدم في البحث القائم على القرب.
  final double? latitude;

  /// Longitude used by proximity-based search.
  /// خط الطول المستخدم في البحث القائم على القرب.
  final double? longitude;

  /// Radius in kilometers around the selected coordinates.
  /// نصف القطر بالكيلومترات حول الإحداثيات المختارة.
  final double? radiusKm;

  /// Currency code preferred for price display and filtering.
  /// رمز العملة المفضل لعرض الأسعار وتصفية النتائج.
  final String? preferredCurrency;

  /// Sort key requested by the UI.
  /// مفتاح الترتيب المطلوب من الواجهة.
  final String? sortBy;

  /// True when the caller only wants a result-count preview.
  /// تكون صحيحة عندما يطلب المستدعي معاينة عدد النتائج فقط.
  final bool previewOnly;

  /// Page number for the paginated result set.
  /// رقم الصفحة لمجموعة النتائج المرقمة.
  final int pageNumber;

  /// Number of results requested per page.
  /// عدد النتائج المطلوبة في كل صفحة.
  final int pageSize;

  /// Starts the main property-search request.
  /// ينشئ طلب البحث الرئيسي عن العقارات.
  const SearchPropertiesEvent({
    this.searchTerm,
    this.city,
    this.propertyTypeId,
    this.minPrice,
    this.maxPrice,
    this.minStarRating,
    this.requiredAmenities,
    this.unitTypeId,
    this.serviceIds,
    this.checkIn,
    this.checkOut,
    this.adults,
    this.children,
    this.guestsCount,
    this.dynamicFieldFilters,
    this.latitude,
    this.longitude,
    this.radiusKm,
    this.preferredCurrency,
    this.sortBy,
    this.previewOnly = false,
    this.pageNumber = 1,
    this.pageSize = 20,
  });

  /// True when this request starts a fresh search instead of loading more.
  /// تكون صحيحة عندما يبدأ الطلب بحثًا جديدًا بدل تحميل المزيد.
  bool get isNewSearch => pageNumber == 1;

  /// Search requests are compared by the full filter payload.
  /// تُقارن طلبات البحث بحمولة الفلاتر كاملة.
  @override
  List<Object?> get props => [
        searchTerm,
        city,
        propertyTypeId,
        minPrice,
        maxPrice,
        minStarRating,
        requiredAmenities,
        unitTypeId,
        serviceIds,
        checkIn,
        checkOut,
        adults,
        children,
        guestsCount,
        dynamicFieldFilters,
        latitude,
        longitude,
        radiusKm,
        preferredCurrency,
        sortBy,
        previewOnly,
        pageNumber,
        pageSize,
      ];
}

/// Requests a lightweight preview of what the active filters would match.
/// يطلب معاينة خفيفة لما ستطابقه الفلاتر النشطة.
class PreviewSearchFacetsEvent extends SearchEvent {
  /// Filter map used for the preview request.
  /// خريطة الفلاتر المستخدمة في طلب المعاينة.
  final Map<String, dynamic> filters;

  /// Starts a preview request for filter facets.
  /// ينشئ طلب معاينة لوجوه الفلاتر.
  const PreviewSearchFacetsEvent({required this.filters});

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [filters];
}

/// Loads the next page of search results while keeping the current page on
/// screen.
/// يحمل الصفحة التالية من نتائج البحث مع إبقاء الصفحة الحالية مرئية.
class LoadMoreSearchResultsEvent extends SearchEvent {
  /// Starts pagination for more results.
  /// ينشئ حدث الترقيم لمزيد من النتائج.
  const LoadMoreSearchResultsEvent();
}

/// Fetches the full filter catalog used by the search screens.
/// يجلب كتالوج الفلاتر الكامل الذي تستخدمه شاشات البحث.
class GetSearchFiltersEvent extends SearchEvent {
  /// Starts loading the filter catalog.
  /// ينشئ طلب تحميل الفلاتر.
  const GetSearchFiltersEvent();
}

/// Requests autocomplete suggestions for the current search query.
/// يطلب اقتراحات إكمال تلقائي للاستعلام الحالي.
class GetSearchSuggestionsEvent extends SearchEvent {
  /// Text fragment entered by the user.
  /// المقطع النصي الذي أدخله المستخدم.
  final String query;

  /// Maximum number of suggestions to return.
  /// الحد الأقصى لعدد الاقتراحات المعادة.
  final int limit;

  /// Starts the suggestion request.
  /// ينشئ طلب الاقتراحات.
  const GetSearchSuggestionsEvent({
    required this.query,
    this.limit = 10,
  });

  /// Suggestions are compared by query and limit so repeated lookups remain
  /// deterministic.
  /// تُقارن الاقتراحات بالاستعلام والحد حتى تبقى عمليات البحث المتكررة
  /// حتمية.
  @override
  List<Object> get props => [query, limit];
}

/// Loads recommendation candidates for the current user or guest context.
/// يحمل مرشحي التوصيات للسياق الحالي للمستخدم أو الضيف.
class GetRecommendedPropertiesEvent extends SearchEvent {
  /// Optional user id used to personalize recommendations.
  /// معرّف اختياري للمستخدم يستخدم لتخصيص التوصيات.
  final String? userId;

  /// Maximum number of recommendations to return.
  /// الحد الأقصى لعدد التوصيات المعادة.
  final int limit;

  /// Starts the recommendation request.
  /// ينشئ طلب التوصيات.
  const GetRecommendedPropertiesEvent({
    this.userId,
    this.limit = 10,
  });

  /// Recommendation requests are compared by audience and limit.
  /// تُقارن طلبات التوصية بحسب الجمهور والحد.
  @override
  List<Object?> get props => [userId, limit];
}

/// Fetches popular destination cards for the discovery section.
/// يجلب بطاقات الوجهات الشائعة لقسم الاكتشاف.
class GetPopularDestinationsEvent extends SearchEvent {
  /// Number of destinations to fetch.
  /// عدد الوجهات المطلوب جلبها.
  final int limit;

  /// Starts the discovery request.
  /// ينشئ طلب الاكتشاف.
  const GetPopularDestinationsEvent({
    this.limit = 10,
  });

  /// Destination fetches are compared by the requested limit.
  /// تُقارن عمليات جلب الوجهات بحسب الحد المطلوب.
  @override
  List<Object> get props => [limit];
}

/// Clears the active query, filters, and result list.
/// يمسح الاستعلام النشط والفلاتر وقائمة النتائج.
class ClearSearchEvent extends SearchEvent {
  /// Starts clearing the active search session.
  /// ينشئ طلب مسح البحث.
  const ClearSearchEvent();
}

/// Replaces the active filter map without executing a new search immediately.
/// يستبدل خريطة الفلاتر النشطة دون تنفيذ بحث جديد مباشرة.
class UpdateSearchFiltersEvent extends SearchEvent {
  /// New filter payload selected by the user.
  /// حمولة الفلاتر الجديدة التي اختارها المستخدم.
  final Map<String, dynamic> filters;

  /// Starts updating the active filters.
  /// ينشئ طلب تحديث الفلاتر.
  const UpdateSearchFiltersEvent({required this.filters});

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [filters];
}

/// Switches the current results presentation between list, grid, or map.
/// يبدّل عرض النتائج الحالي بين القائمة أو الشبكة أو الخريطة.
class ToggleViewModeEvent extends SearchEvent {
  /// Requested view mode; null means toggle to the next default mode.
  /// وضع العرض المطلوب؛ والقيمة الفارغة تعني التبديل إلى الوضع الافتراضي
  /// التالي.
  final ViewMode? mode;

  /// Starts a view-mode update.
  /// ينشئ طلب تحديث وضع العرض.
  const ToggleViewModeEvent({this.mode});

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [mode];
}

/// Persists the current search configuration as a named shortcut.
/// يحفظ إعدادات البحث الحالية كاختصار باسم محدد.
class SaveSearchEvent extends SearchEvent {
  /// Friendly name shown in the saved-search list.
  /// الاسم الودود المعروض في قائمة البحث المحفوظ.
  final String name;

  /// Serialized search payload to restore later.
  /// حمولة البحث المسلسلة لاستعادتها لاحقًا.
  final Map<String, dynamic> searchParams;

  /// Starts saving the current search.
  /// ينشئ طلب حفظ البحث.
  const SaveSearchEvent({required this.name, required this.searchParams});

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [name, searchParams];
}

/// Loads one saved search so the user can restore a previous configuration.
/// يحمل بحثًا محفوظًا واحدًا حتى يتمكن المستخدم من استعادة إعداد سابق.
class LoadSavedSearchEvent extends SearchEvent {
  /// Saved-search identifier.
  /// معرّف البحث المحفوظ.
  final String searchId;

  /// Starts loading saved searches.
  /// ينشئ طلب تحميل البحث المحفوظ.
  const LoadSavedSearchEvent({required this.searchId});

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [searchId];
}

/// Clears the suggestion list without affecting the current query.
/// يمسح قائمة الاقتراحات دون التأثير على الاستعلام الحالي.
class ClearSearchSuggestionsEvent extends SearchEvent {
  /// Starts clearing suggestions.
  /// ينشئ طلب مسح الاقتراحات.
  const ClearSearchSuggestionsEvent();
}

/// Clears the currently visible result list.
/// يمسح قائمة النتائج المعروضة حاليًا.
class ClearSearchResultsEvent extends SearchEvent {
  /// Starts clearing visible results.
  /// ينشئ طلب مسح النتائج.
  const ClearSearchResultsEvent();
}

/// Persists one suggestion as a recent-search shortcut.
/// يحفظ اقتراحًا واحدًا كاختصار ضمن عمليات البحث الحديثة.
class AddToRecentSearchesEvent extends SearchEvent {
  /// Search string that should be stored in the recent list.
  /// العبارة البحثية التي يجب تخزينها في قائمة الحديثة.
  final String suggestion;

  /// Starts adding a term to recent searches.
  /// ينشئ طلب الإضافة إلى الحديثة.
  const AddToRecentSearchesEvent({required this.suggestion});

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [suggestion];
}

/// Loads the user's recent search history.
/// يحمل سجل البحث الحديث للمستخدم.
class LoadRecentSearchesEvent extends SearchEvent {
  /// Starts loading recent searches.
  /// ينشئ طلب تحميل عمليات البحث الحديثة.
  const LoadRecentSearchesEvent();
}

/// Removes every item from the recent-search history.
/// يزيل كل العناصر من سجل البحث الحديث.
class ClearRecentSearchesEvent extends SearchEvent {
  /// Starts clearing recent searches.
  /// ينشئ طلب مسح البحث الحديث.
  const ClearRecentSearchesEvent();
}

/// Loads the list of search shortcuts saved by the user.
/// يحمل قائمة اختصارات البحث المحفوظة من المستخدم.
class LoadSavedSearchesEvent extends SearchEvent {
  /// Starts loading saved searches.
  /// ينشئ طلب تحميل عمليات البحث المحفوظة.
  const LoadSavedSearchesEvent();
}

/// Deletes one saved search shortcut.
/// يحذف اختصار بحث محفوظ واحد.
class DeleteSavedSearchEvent extends SearchEvent {
  /// Identifier of the saved search to remove.
  /// معرّف البحث المحفوظ المطلوب حذفه.
  final String searchId;

  /// Starts deleting a saved search.
  /// ينشئ طلب حذف البحث المحفوظ.
  const DeleteSavedSearchEvent({required this.searchId});

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [searchId];
}

/// Restores a saved search payload into the active search form.
/// يستعيد حمولة بحث محفوظ إلى نموذج البحث النشط.
class ApplySavedSearchEvent extends SearchEvent {
  /// Saved payload that should be restored into the filters UI.
  /// الحمولة المحفوظة التي يجب استعادتها في واجهة الفلاتر.
  final Map<String, dynamic> searchParams;

  /// Starts applying a saved search.
  /// ينشئ طلب تطبيق البحث المحفوظ.
  const ApplySavedSearchEvent({required this.searchParams});

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [searchParams];
}
