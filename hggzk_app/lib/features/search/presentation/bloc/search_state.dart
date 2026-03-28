import 'package:equatable/equatable.dart';
import '../../../../core/models/paginated_result.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/entities/search_relaxation_info.dart';

/// Controls how search results are rendered on screen so the same dataset can
/// be presented as a list, grid, or map.
/// يتحكم في طريقة عرض نتائج البحث حتى يمكن تقديم نفس البيانات كقائمة أو شبكة
/// أو خريطة.
enum ViewMode { list, grid, map }

/// Base state for search flows. The bloc uses specialized states to expose the
/// current page of results, active filters, loading flags, and search
/// relaxation metadata to the UI.
/// الحالة الأساسية لمسارات البحث. يستخدم الـ bloc حالات متخصصة لعرض الصفحة
/// الحالية من النتائج والفلاتر النشطة وأعلام التحميل وبيانات تخفيف معايير البحث.
abstract class SearchState extends Equatable {
  /// Builds the common base for every search state variant.
  /// ينشئ الأساس المشترك لكل حالة من حالات البحث.
  const SearchState();

  /// Search states are compared by content so result screens only rebuild when
  /// their visible inputs actually change.
  /// تُقارن حالات البحث بالمحتوى حتى تعيد الشاشات بناء نفسها فقط عندما تتغير
  /// المدخلات المرئية فعلًا.
  @override
  List<Object?> get props => [];
}

/// Idle state before any query or filter preview has been executed.
/// حالة الخمول قبل تنفيذ أي استعلام أو معاينة للفلاتر.
class SearchInitial extends SearchState {
  /// Builds the initial search state.
  /// ينشئ حالة البحث الابتدائية.
  const SearchInitial();
}

/// Emitted while the search request is still resolving.
/// تصدر أثناء استمرار تنفيذ طلب البحث.
class SearchLoading extends SearchState {
  /// Builds the loading state used while results are being fetched.
  /// ينشئ حالة التحميل المستخدمة أثناء جلب النتائج.
  const SearchLoading();
}

/// Holds a page of search results along with the filter set that produced
/// them, the current view mode, and any relaxation hints.
/// تحتفظ بصفحة من نتائج البحث مع مجموعة الفلاتر التي أنشأتها ووضع العرض
/// الحالي وأي إشارات لتخفيف معايير البحث.
class SearchSuccess extends SearchState {
  /// Page of search results currently shown in the UI.
  /// صفحة نتائج البحث المعروضة حاليًا في الواجهة.
  final PaginatedResult<SearchResult> searchResults;

  /// Filters that produced the current result set.
  /// الفلاتر التي أنتجت مجموعة النتائج الحالية.
  final Map<String, dynamic> currentFilters;

  /// True when no more pages are available from the backend.
  /// تكون صحيحة عندما لا توجد صفحات إضافية يمكن جلبها من الخادم.
  final bool hasReachedMax;

  /// Selected presentation mode for the current search results.
  /// نمط العرض المختار لنتائج البحث الحالية.
  final ViewMode viewMode;

  /// Relaxation metadata returned when the backend broadens the query to
  /// improve result coverage.
  /// بيانات تخفيف المعايير التي تعيدها الواجهة الخلفية عندما توسع الاستعلام
  /// لتحسين تغطية النتائج.
  final SearchRelaxationInfo? relaxationInfo;

  /// Captures a successful search response together with the UI state needed
  /// to render it.
  /// يلتقط نتيجة بحث ناجحة مع حالة الواجهة اللازمة لعرضها.
  const SearchSuccess({
    required this.searchResults,
    required this.currentFilters,
    this.hasReachedMax = false,
    this.viewMode = ViewMode.list,
    this.relaxationInfo,
  });

  /// Returns a new snapshot of the search state while preserving unchanged
  /// values.
  /// يعيد لقطة جديدة لحالة البحث مع الإبقاء على القيم غير المتغيرة.
  SearchSuccess copyWith({
    PaginatedResult<SearchResult>? searchResults,
    Map<String, dynamic>? currentFilters,
    bool? hasReachedMax,
    ViewMode? viewMode,
    SearchRelaxationInfo? relaxationInfo,
  }) {
    return SearchSuccess(
      searchResults: searchResults ?? this.searchResults,
      currentFilters: currentFilters ?? this.currentFilters,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      viewMode: viewMode ?? this.viewMode,
      relaxationInfo: relaxationInfo ?? this.relaxationInfo,
    );
  }

  /// Search results are compared by content so pagination and filters only
  /// trigger rebuilds when their visible output changes.
  /// تُقارن نتائج البحث بالمحتوى حتى لا تُفعّل التحديثات إلا عندما يتغير
  /// الخرج المرئي فعلًا.
  @override
  List<Object?> get props => [
        searchResults,
        currentFilters,
        hasReachedMax,
        viewMode,
        relaxationInfo,
      ];

  /// Convenience alias used by widgets that expect the page payload under a
  /// shorter name.
  /// اسم اختصاري يفيد الواجهات التي تتوقع حمولة الصفحة تحت اسم أقصر.
  PaginatedResult<SearchResult> get results => searchResults;

  /// Convenience alias for the filters that produced the visible result set.
  /// اسم اختصاري للفلاتر التي أنتجت مجموعة النتائج الظاهرة.
  Map<String, dynamic> get appliedFilters => currentFilters;

  /// True when the backend had to loosen the query constraints.
  /// تكون صحيحة عندما يضطر الخادم إلى تخفيف قيود الاستعلام.
  bool get wasRelaxed => relaxationInfo?.wasRelaxed ?? false;

  /// True when relaxed search suggestions are available to present to the
  /// user.
  /// تكون صحيحة عندما تتوفر اقتراحات ناتجة عن تخفيف معايير البحث.
  bool get hasSuggestions => relaxationInfo?.hasSuggestions ?? false;
}

/// Indicates that the search request failed and the UI should surface the
/// message to the user.
/// تشير إلى فشل طلب البحث وأن الواجهة يجب أن تعرض الرسالة للمستخدم.
class SearchError extends SearchState {
  /// User-facing error message explaining why the search failed.
  /// رسالة خطأ موجهة للمستخدم تشرح سبب فشل البحث.
  final String message;

  /// Builds the failure state used by the search bloc.
  /// ينشئ حالة الفشل التي يستخدمها الـ bloc الخاص بالبحث.
  const SearchError({required this.message});

  /// Error states are compared by their message so repeated failures do not
  /// cause unnecessary rebuilds.
  /// تُقارن حالات الخطأ عبر الرسالة حتى لا تسبب الأخطاء المتكررة إعادة بناء
  /// غير ضرورية.
  @override
  List<Object> get props => [message];
}

/// Indicates that the current result list is fetching the next page while
/// keeping the already loaded items visible.
/// تشير إلى أن القائمة الحالية تجلب الصفحة التالية مع إبقاء العناصر
/// المحملة مرئية.
class SearchLoadingMore extends SearchState {
  /// Existing result page that remains on screen during infinite-scroll fetch.
  /// صفحة النتائج الحالية التي تبقى على الشاشة أثناء جلب المزيد.
  final PaginatedResult<SearchResult> currentResults;

  /// Builds the incremental loading state used by pagination flows.
  /// ينشئ حالة التحميل التدريجي المستخدمة في مسارات الترقيم.
  const SearchLoadingMore({required this.currentResults});

  /// Compares loading-more snapshots by the currently visible results.
  /// يقارن لقطات التحميل التدريجي بالنتائج الظاهرة حاليًا.
  @override
  List<Object> get props => [currentResults];
}

/// Emitted while the app is fetching filter metadata or a preview count.
/// تصدر أثناء جلب بيانات الفلاتر أو عدد النتائج المتوقع.
class SearchFiltersLoading extends SearchState {
  /// Builds the loading state for filter discovery.
  /// ينشئ حالة التحميل الخاصة باكتشاف الفلاتر.
  const SearchFiltersLoading();
}

/// Holds the available filters plus an optional preview of how many results
/// would match them.
/// تحتفظ بالفلاتر المتاحة مع معاينة اختيارية لعدد النتائج المطابقة لها.
class SearchFiltersLoaded extends SearchState {
  /// Filter catalog returned by the backend.
  /// كتالوج الفلاتر الذي يعيده الخادم.
  final SearchFilters filters;

  /// Optional preview count used by filter sheets and helper banners.
  /// عدد معاينة اختياري تستخدمه أوراق الفلاتر والرسائل المساعدة.
  final int? matchingResultsCount;

  /// True while the filter preview count is still being resolved.
  /// تكون صحيحة أثناء استمرار حساب عدد المعاينة للفلاتر.
  final bool isPreviewLoading;

  /// Builds the loaded filter state used by the search UI.
  /// ينشئ حالة الفلاتر المحملة التي تستخدمها واجهة البحث.
  const SearchFiltersLoaded({
    required this.filters,
    this.matchingResultsCount,
    this.isPreviewLoading = false,
  });

  /// Returns a new filter snapshot while preserving the fields that did not
  /// change.
  /// يعيد لقطة جديدة للفلاتر مع الإبقاء على الحقول غير المتغيرة.
  SearchFiltersLoaded copyWith({
    SearchFilters? filters,
    int? matchingResultsCount,
    bool? isPreviewLoading,
  }) {
    return SearchFiltersLoaded(
      filters: filters ?? this.filters,
      matchingResultsCount: matchingResultsCount ?? this.matchingResultsCount,
      isPreviewLoading: isPreviewLoading ?? this.isPreviewLoading,
    );
  }

  /// Filter states are compared by payload so helper sheets only rebuild when
  /// the available filters or preview count actually change.
  /// تُقارن حالات الفلاتر بالحمولة حتى تعيد أوراق المساعدة البناء فقط عندما
  /// تتغير الفلاتر أو عدد المعاينة فعلًا.
  @override
  List<Object?> get props => [filters, matchingResultsCount, isPreviewLoading];
}

/// Indicates that the filter metadata request failed.
/// تشير إلى فشل طلب بيانات الفلاتر.
class SearchFiltersError extends SearchState {
  /// User-facing explanation for the filter failure.
  /// شرح موجّه للمستخدم لسبب فشل الفلاتر.
  final String message;

  /// Builds the failure state used by filter-related UI.
  /// ينشئ حالة الفشل التي تعتمد عليها واجهات الفلاتر.
  const SearchFiltersError({required this.message});

  /// Error states are compared by message so repeated failures remain stable
  /// from the bloc's perspective.
  /// تُقارن حالات الخطأ بالرسالة حتى تبقى الأخطاء المتكررة مستقرة من منظور
  /// الـ bloc.
  @override
  List<Object> get props => [message];
}

/// Emitted while autocomplete suggestions are being fetched.
/// تصدر أثناء جلب اقتراحات الإكمال التلقائي.
class SearchSuggestionsLoading extends SearchState {
  /// Builds the suggestion-loading state.
  /// ينشئ حالة تحميل الاقتراحات.
  const SearchSuggestionsLoading();
}

/// Holds the autocomplete suggestions returned for the current query.
/// تحتفظ باقتراحات الإكمال التلقائي المعادة للاستعلام الحالي.
class SearchSuggestionsLoaded extends SearchState {
  /// Ordered suggestion list shown under the search box.
  /// قائمة الاقتراحات المرتبة المعروضة أسفل مربع البحث.
  final List<String> suggestions;

  /// Builds the loaded suggestion state.
  /// ينشئ حالة الاقتراحات المحملة.
  const SearchSuggestionsLoaded({required this.suggestions});

  /// Suggestion states are compared by the returned list.
  /// تُقارن حالات الاقتراحات بقائمة النتائج المعادة.
  @override
  List<Object> get props => [suggestions];
}

/// Indicates that autocomplete suggestions could not be loaded.
/// تشير إلى تعذر تحميل اقتراحات الإكمال التلقائي.
class SearchSuggestionsError extends SearchState {
  /// User-facing explanation for the suggestion failure.
  /// رسالة موجهة للمستخدم لسبب فشل الاقتراحات.
  final String message;

  /// Builds the suggestion failure state.
  /// ينشئ حالة فشل الاقتراحات.
  const SearchSuggestionsError({required this.message});

  /// Error states are compared by message so repeated failures remain stable.
  /// تُقارن حالات الخطأ بالرسالة حتى تبقى الأخطاء المتكررة مستقرة.
  @override
  List<Object> get props => [message];
}

/// Emitted while recommendation candidates are being fetched.
/// تصدر أثناء جلب مرشحي التوصيات.
class RecommendedPropertiesLoading extends SearchState {
  /// Builds the recommendation-loading state.
  /// ينشئ حالة تحميل التوصيات.
  const RecommendedPropertiesLoading();
}

/// Holds the recommended property list for the current user context.
/// تحتفظ بقائمة العقارات المقترحة للسياق الحالي للمستخدم.
class RecommendedPropertiesLoaded extends SearchState {
  /// Recommended property results.
  /// نتائج العقارات المقترحة.
  final List<SearchResult> properties;

  /// Builds the recommendation-loaded state.
  /// ينشئ حالة التوصيات المحملة.
  const RecommendedPropertiesLoaded({required this.properties});

  /// Recommendation states are compared by the returned property list.
  /// تُقارن حالات التوصية بقائمة العقارات المعادة.
  @override
  List<Object> get props => [properties];
}

/// Indicates that recommendation loading failed.
/// تشير إلى فشل تحميل التوصيات.
class RecommendedPropertiesError extends SearchState {
  /// User-facing error message for recommendation loading.
  /// رسالة خطأ موجهة للمستخدم لتحميل التوصيات.
  final String message;

  /// Builds the recommendation failure state.
  /// ينشئ حالة فشل التوصيات.
  const RecommendedPropertiesError({required this.message});

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [message];
}

/// Emitted while popular destinations are being fetched.
/// تصدر أثناء جلب الوجهات الشائعة.
class PopularDestinationsLoading extends SearchState {
  /// Builds the popular-destinations loading state.
  /// ينشئ حالة تحميل الوجهات الشائعة.
  const PopularDestinationsLoading();
}

/// Holds the popular destination cards shown in discovery sections.
/// تحتفظ ببطاقات الوجهات الشائعة المعروضة في أقسام الاكتشاف.
class PopularDestinationsLoaded extends SearchState {
  /// Destination cards currently visible to the user.
  /// بطاقات الوجهات المرئية حاليًا للمستخدم.
  final List<String> destinations;

  /// Builds the loaded popular-destinations state.
  /// ينشئ حالة الوجهات الشائعة المحملة.
  const PopularDestinationsLoaded({required this.destinations});

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [destinations];
}

/// Indicates that the popular destinations feed failed.
/// تشير إلى فشل موجز الوجهات الشائعة.
class PopularDestinationsError extends SearchState {
  /// User-facing explanation for the popular-destinations failure.
  /// رسالة موجهة للمستخدم لسبب فشل الوجهات الشائعة.
  final String message;

  /// Builds the popular-destinations failure state.
  /// ينشئ حالة فشل الوجهات الشائعة.
  const PopularDestinationsError({required this.message});

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [message];
}

/// Aggregates all search-related sub-states so one screen can observe results,
/// filters, suggestions, recommendations, popular destinations, and saved or
/// recent searches together.
/// تجمع كل حالات البحث الفرعية حتى تراقب شاشة واحدة النتائج والفلاتر
/// والاقتراحات والتوصيات والوجهات الشائعة والبحث المحفوظ أو الحديث معًا.
class SearchCombinedState extends SearchState {
  /// Current results sub-state.
  /// حالة النتائج الحالية.
  final SearchState? searchResultsState;

  /// Current filters sub-state.
  /// حالة الفلاتر الحالية.
  final SearchState? filtersState;

  /// Current suggestions sub-state.
  /// حالة الاقتراحات الحالية.
  final SearchState? suggestionsState;

  /// Current recommendations sub-state.
  /// حالة التوصيات الحالية.
  final SearchState? recommendedState;

  /// Current popular-destinations sub-state.
  /// حالة الوجهات الشائعة الحالية.
  final SearchState? popularDestinationsState;

  /// Recent search strings shown in quick access flows.
  /// عبارات البحث الحديثة المعروضة في مسارات الوصول السريع.
  final List<String> recentSearches;

  /// Saved search shortcuts.
  /// اختصارات البحث المحفوظة.
  final List<SavedSearch> savedSearches;

  /// Builds the aggregate search state used by compound screens.
  /// ينشئ حالة البحث المجمعة المستخدمة في الشاشات المركبة.
  const SearchCombinedState({
    this.searchResultsState,
    this.filtersState,
    this.suggestionsState,
    this.recommendedState,
    this.popularDestinationsState,
    this.recentSearches = const [],
    this.savedSearches = const [],
  });

  /// Returns a new aggregate snapshot while preserving the unchanged
  /// sub-states.
  /// يعيد لقطة مجمعة جديدة مع الإبقاء على الحالات الفرعية غير المتغيرة.
  SearchCombinedState copyWith({
    SearchState? searchResultsState,
    SearchState? filtersState,
    SearchState? suggestionsState,
    SearchState? recommendedState,
    SearchState? popularDestinationsState,
    List<String>? recentSearches,
    List<SavedSearch>? savedSearches,
  }) {
    return SearchCombinedState(
      searchResultsState: searchResultsState ?? this.searchResultsState,
      filtersState: filtersState ?? this.filtersState,
      suggestionsState: suggestionsState ?? this.suggestionsState,
      recommendedState: recommendedState ?? this.recommendedState,
      popularDestinationsState:
          popularDestinationsState ?? this.popularDestinationsState,
      recentSearches: recentSearches ?? this.recentSearches,
      savedSearches: savedSearches ?? this.savedSearches,
    );
  }

  /// Aggregate states are compared by the current sub-state values.
  /// تُقارن الحالات المجمعة بقيم الحالات الفرعية الحالية.
  @override
  List<Object?> get props => [
        searchResultsState,
        filtersState,
        suggestionsState,
        recommendedState,
        popularDestinationsState,
        recentSearches,
        savedSearches,
      ];
}

/// A named search payload that can be restored later from the saved-search
/// list.
/// حمولة بحث مسماة يمكن استعادتها لاحقًا من قائمة البحث المحفوظ.
class SavedSearch extends Equatable {
  /// Saved-search identifier.
  /// معرّف البحث المحفوظ.
  final String id;

  /// User-friendly label shown in the saved list.
  /// الاسم الودود الظاهر في القائمة المحفوظة.
  final String name;

  /// Search payload used to restore the configuration.
  /// حمولة البحث المستخدمة لاستعادة الإعدادات.
  final Map<String, dynamic> searchParams;

  /// Time when the search shortcut was saved.
  /// وقت حفظ اختصار البحث.
  final DateTime createdAt;

  /// Creates a saved-search record.
  /// ينشئ سجل بحث محفوظ.
  const SavedSearch({
    required this.id,
    required this.name,
    required this.searchParams,
    required this.createdAt,
  });

  /// Saved searches are compared by their record identity and payload.
  /// تُقارن عمليات البحث المحفوظة بهوية السجل والحمولة.
  @override
  List<Object> get props => [id, name, searchParams, createdAt];
}
