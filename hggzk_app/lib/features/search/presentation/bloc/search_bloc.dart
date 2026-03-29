import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hggzk/core/usecases/usecase.dart';
import 'dart:convert';
import 'package:hggzk/core/localization/app_localizations.dart';
import 'package:hggzk/core/localization/locale_manager.dart';
import '../../../../core/models/paginated_result.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/entities/search_relaxation_info.dart';
import '../../../../core/enums/search_relaxation_level.dart';
import '../../domain/usecases/get_search_filters_usecase.dart';
import '../../domain/usecases/get_search_suggestions_usecase.dart';
import '../../domain/usecases/search_properties_usecase.dart';
import '../../domain/repositories/search_repository.dart';
import 'package:hggzk/core/services/data_sync_service.dart';
import 'package:hggzk/core/services/filter_storage_service.dart';
import 'package:hggzk/features/home/data/models/unit_type_model.dart';
import 'search_event.dart';
import 'search_state.dart';

/// Coordinates search queries, pagination, filters, saved searches, and
/// suggestion loading for the discovery experience.
/// ينسق استعلامات البحث والتصفح الصفحي والفلاتر والبحث المحفوظ والاقتراحات
/// الخاصة بتجربة الاكتشاف.
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  /// Executes property search requests against the domain layer.
  /// ينفذ طلبات البحث عن العقارات من طبقة المجال.
  final SearchPropertiesUseCase searchPropertiesUseCase;

  /// Loads available filters for the current search context.
  /// يجلب الفلاتر المتاحة لسياق البحث الحالي.
  final GetSearchFiltersUseCase getSearchFiltersUseCase;

  /// Produces live suggestions from the user's current query.
  /// ينتج الاقتراحات الحية من استعلام المستخدم الحالي.
  final GetSearchSuggestionsUseCase getSearchSuggestionsUseCase;

  /// Persists saved searches and fetches discovery helpers.
  /// يحفظ عمليات البحث ويجلب أدوات الاكتشاف المساندة.
  final SearchRepository searchRepository;

  /// Stores recent and saved query snapshots locally.
  /// يخزن لقطات الاستعلامات الأخيرة والمحفوطة محليًا.
  final SharedPreferences sharedPreferences;

  /// Supplies supporting metadata such as unit types during search.
  /// يزود البيانات المساندة مثل أنواع الوحدات أثناء البحث.
  final DataSyncService dataSyncService;

  /// Persists filter state so the user can resume a previous search.
  /// يحفظ حالة الفلاتر كي يتمكن المستخدم من استكمال بحث سابق.
  final FilterStorageService filterStorageService;

  /// SharedPreferences key used for recent searches.
  /// مفتاح SharedPreferences المخصص لعمليات البحث الأخيرة.
  static const String _recentSearchesKey = 'recent_searches';

  /// SharedPreferences key used for saved searches.
  /// مفتاح SharedPreferences المخصص لعمليات البحث المحفوظة.
  static const String _savedSearchesKey = 'saved_searches';

  /// Maximum number of recent queries kept in local storage.
  /// الحد الأقصى لعدد الاستعلامات الحديثة المخزنة محليًا.
  static const int _maxRecentSearches = 10;

  /// Holds the latest filter payload used for the next request.
  /// يحتفظ بأحدث حمولة للفلاتر لاستخدامها في الطلب التالي.
  Map<String, dynamic> _currentFilters = {};

  /// Tracks the latest paginated result set for load-more flows.
  /// يتتبع آخر مجموعة نتائج متدرجة لمسارات تحميل المزيد.
  PaginatedResult<SearchResult>? _currentSearchResults;

  /// Guards suggestion updates so stale responses do not overwrite newer text.
  /// يحمي تحديثات الاقتراحات كي لا تطغى الاستجابات القديمة على النص الأحدث.
  int _suggestionsRequestToken = 0;

  /// Builds the bloc that powers search queries and local search memory.
  /// يبني الـ bloc الذي يشغّل استعلامات البحث وذاكرة البحث المحلية.
  SearchBloc({
    required this.searchPropertiesUseCase,
    required this.getSearchFiltersUseCase,
    required this.getSearchSuggestionsUseCase,
    required this.searchRepository,
    required this.sharedPreferences,
    required this.dataSyncService,
    required this.filterStorageService,
  }) : super(const SearchCombinedState()) {
    on<SearchPropertiesEvent>(_onSearchProperties);
    on<PreviewSearchFacetsEvent>(_onPreviewSearchFacets);
    on<LoadMoreSearchResultsEvent>(_onLoadMoreSearchResults);
    on<GetSearchFiltersEvent>(_onGetSearchFilters);
    on<GetSearchSuggestionsEvent>(_onGetSearchSuggestions);
    on<ClearSearchSuggestionsEvent>(_onClearSearchSuggestions);
    on<GetRecommendedPropertiesEvent>(_onGetRecommendedProperties);
    on<GetPopularDestinationsEvent>(_onGetPopularDestinations);
    on<UpdateSearchFiltersEvent>(_onUpdateSearchFilters);
    on<ClearSearchEvent>(_onClearSearch);
    on<ClearSearchResultsEvent>(_onClearSearchResults);
    on<AddToRecentSearchesEvent>(_onAddToRecentSearches);
    on<LoadRecentSearchesEvent>(_onLoadRecentSearches);
    on<ClearRecentSearchesEvent>(_onClearRecentSearches);
    on<SaveSearchEvent>(_onSaveSearch);
    on<LoadSavedSearchesEvent>(_onLoadSavedSearches);
    on<DeleteSavedSearchEvent>(_onDeleteSavedSearch);
    on<ApplySavedSearchEvent>(_onApplySavedSearch);
    on<ToggleViewModeEvent>(_onToggleViewMode);
  }

  /// Switches between list, grid, and map presentation modes.
  /// يبدّل بين أوضاع العرض القائمة والشبكة والخريطة.
  void _onToggleViewMode(
    ToggleViewModeEvent event,
    Emitter<SearchState> emit,
  ) {
    final currentState = state as SearchCombinedState;
    final resultsState = currentState.searchResultsState;
    if (resultsState is SearchSuccess) {
      final currentMode = resultsState.viewMode;
      final nextMode = event.mode ??
          (currentMode == ViewMode.list
              ? ViewMode.grid
              : currentMode == ViewMode.grid
                  ? ViewMode.map
                  : ViewMode.list);

      emit(currentState.copyWith(
        searchResultsState: resultsState.copyWith(viewMode: nextMode),
      ));
    }
  }

  /// Executes a property search and prepares the bloc for either fresh or
  /// paginated results.
  /// ينفذ بحث العقارات ويجهز الـ bloc لنتائج جديدة أو متدرجة.
  Future<void> _onSearchProperties(
    SearchPropertiesEvent event,
    Emitter<SearchState> emit,
  ) async {
    final currentState = state as SearchCombinedState;

    if (event.isNewSearch) {
      emit(currentState.copyWith(
        searchResultsState: const SearchLoading(),
      ));
      _currentSearchResults = null;
    } else {
      emit(currentState.copyWith(
        searchResultsState: SearchLoadingMore(
          currentResults: _currentSearchResults!,
        ),
      ));
    }

    // Determine if selected unit type supports guests (adults/children)
    int? effectiveGuestsCount = event.guestsCount;
    int? effectiveAdults = event.adults;
    int? effectiveChildren = event.children;
    try {
      if (event.propertyTypeId != null && event.unitTypeId != null) {
        final List<UnitTypeModel> unitTypes =
            await dataSyncService.getUnitTypes(
          propertyTypeId: event.propertyTypeId!,
        );
        final UnitTypeModel selectedUnit = unitTypes.firstWhere(
          (u) => u.id == event.unitTypeId,
          orElse: () => UnitTypeModel(
            id: '',
            propertyTypeId: '',
            name: '',
            nameAr: '',
            nameEn: '',
            description: '',
            descriptionAr: '',
            descriptionEn: '',
            maxCapacity: 0,
            icon: '',
            isHasAdults: false,
            isHasChildren: false,
            isMultiDays: false,
            isRequiredToDetermineTheHour: false,
          ),
        );
        final bool supportsGuests = (selectedUnit.id.isNotEmpty) &&
            (selectedUnit.isHasAdults || selectedUnit.isHasChildren);
        // Derive guestsCount from adults+children when provided
        if (effectiveGuestsCount == null &&
            (effectiveAdults != null || effectiveChildren != null)) {
          effectiveGuestsCount =
              (effectiveAdults ?? 0) + (effectiveChildren ?? 0);
        }
        if (!supportsGuests) {
          effectiveGuestsCount = null;
          effectiveAdults = null;
          effectiveChildren = null;
        }
      }
    } catch (_) {
      // Ignore lookup errors; fallback to provided guestsCount
    }

    const String preferredCurrency = 'YER';

    final params = SearchPropertiesParams(
      searchTerm: event.searchTerm,
      city: event.city,
      propertyTypeId: event.propertyTypeId,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
      minStarRating: event.minStarRating,
      requiredAmenities: event.requiredAmenities,
      unitTypeId: event.unitTypeId,
      serviceIds: event.serviceIds,
      checkIn: event.checkIn,
      checkOut: event.checkOut,
      adults: effectiveAdults,
      children: effectiveChildren,
      guestsCount: effectiveGuestsCount,
      dynamicFieldFilters: event.dynamicFieldFilters,
      latitude: event.latitude,
      longitude: event.longitude,
      radiusKm: event.radiusKm,
      preferredCurrency: preferredCurrency,
      sortBy: event.sortBy,
      previewOnly: event.previewOnly,
      pageNumber: event.pageNumber,
      pageSize: event.pageSize,
    );

    final result = await searchPropertiesUseCase(params);

    await result.fold(
      (failure) async {
        emit((state as SearchCombinedState).copyWith(
          searchResultsState: SearchError(message: failure.message),
        ));
      },
      (paginatedResult) async {
        if (event.isNewSearch) {
          _currentSearchResults = paginatedResult;
          _currentFilters = _buildFiltersMap(event);
          // Sanitize guests fields for non-guest unit types
          if (effectiveGuestsCount == null) {
            _currentFilters.remove('guestsCount');
          } else {
            _currentFilters['guestsCount'] = effectiveGuestsCount;
          }
          if (effectiveAdults == null) {
            _currentFilters.remove('adults');
          } else {
            _currentFilters['adults'] = effectiveAdults;
          }
          if (effectiveChildren == null) {
            _currentFilters.remove('children');
          } else {
            _currentFilters['children'] = effectiveChildren;
          }
          // Persist current filters
          await filterStorageService.saveCurrentFilters(_currentFilters);
        } else {
          // Append new results to existing ones
          final updatedItems = [
            ..._currentSearchResults!.items,
            ...paginatedResult.items,
          ];
          _currentSearchResults = PaginatedResult(
            items: updatedItems,
            pageNumber: paginatedResult.pageNumber,
            pageSize: paginatedResult.pageSize,
            totalCount: paginatedResult.totalCount,
            metadata: paginatedResult.metadata,
          );
        }

        final hasReachedMax = _currentSearchResults!.items.length >=
            _currentSearchResults!.totalCount;

        final relaxationInfo = _extractRelaxationInfo(_currentSearchResults!);
        final liveFacets = _extractFacets(_currentSearchResults!);

        emit((state as SearchCombinedState).copyWith(
          searchResultsState: SearchSuccess(
            searchResults: _currentSearchResults!,
            currentFilters: _currentFilters,
            hasReachedMax: hasReachedMax,
            relaxationInfo: relaxationInfo,
          ),
          filtersState: liveFacets != null
              ? SearchFiltersLoaded(
                  filters: liveFacets,
                  matchingResultsCount: _currentSearchResults!.totalCount,
                )
              : currentState.filtersState,
        ));

        // Add to recent searches if it's a new search with query
        if (event.isNewSearch &&
            event.searchTerm != null &&
            event.searchTerm!.isNotEmpty) {
          add(AddToRecentSearchesEvent(suggestion: event.searchTerm!));
        }
      },
    );
  }

  /// Recomputes filter facets against the current payload without loading the
  /// full result list.
  /// يعيد حساب فلاتر الواجهة على الحمولة الحالية دون تحميل قائمة النتائج
  /// كاملة.
  Future<void> _onPreviewSearchFacets(
    PreviewSearchFacetsEvent event,
    Emitter<SearchState> emit,
  ) async {
    final currentState = state as SearchCombinedState;
    final existingFiltersState = currentState.filtersState;

    if (existingFiltersState is SearchFiltersLoaded) {
      emit(currentState.copyWith(
        filtersState: existingFiltersState.copyWith(isPreviewLoading: true),
      ));
    } else {
      emit(currentState.copyWith(
        filtersState: const SearchFiltersLoading(),
      ));
    }

    const preferredCurrency = 'YER';

    final params = _buildSearchParamsFromFilters(
      event.filters,
      preferredCurrency: preferredCurrency,
      previewOnly: true,
      pageNumber: 1,
      pageSize: 1,
    );

    final result = await searchPropertiesUseCase(params);

    await result.fold(
      (failure) async {
        if (existingFiltersState is SearchFiltersLoaded) {
          emit((state as SearchCombinedState).copyWith(
            filtersState:
                existingFiltersState.copyWith(isPreviewLoading: false),
          ));
        } else {
          emit((state as SearchCombinedState).copyWith(
            filtersState: SearchFiltersError(message: failure.message),
          ));
        }
      },
      (paginatedResult) async {
        _currentFilters = Map<String, dynamic>.from(event.filters);
        await filterStorageService.saveCurrentFilters(_currentFilters);

        final liveFacets = _extractFacets(paginatedResult);
        if (liveFacets == null && existingFiltersState is SearchFiltersLoaded) {
          emit((state as SearchCombinedState).copyWith(
            filtersState: existingFiltersState.copyWith(
              isPreviewLoading: false,
              matchingResultsCount: paginatedResult.totalCount,
            ),
          ));
          return;
        }

        if (liveFacets != null) {
          emit((state as SearchCombinedState).copyWith(
            filtersState: SearchFiltersLoaded(
              filters: liveFacets,
              matchingResultsCount: paginatedResult.totalCount,
              isPreviewLoading: false,
            ),
          ));
        }
      },
    );
  }

  /// Requests the next page using the last successful filter snapshot.
  /// يطلب الصفحة التالية باستخدام آخر لقطة فلاتر ناجحة.
  void _onLoadMoreSearchResults(
    LoadMoreSearchResultsEvent event,
    Emitter<SearchState> emit,
  ) {
    final currentState = state as SearchCombinedState;
    if (currentState.searchResultsState is SearchSuccess) {
      final successState = currentState.searchResultsState as SearchSuccess;

      if (!successState.hasReachedMax) {
        final nextPage = successState.searchResults.pageNumber + 1;

        add(SearchPropertiesEvent(
          searchTerm: _currentFilters['searchTerm'] as String?,
          city: _currentFilters['city'] as String?,
          propertyTypeId: _currentFilters['propertyTypeId'] as String?,
          minPrice: _currentFilters['minPrice'] as double?,
          maxPrice: _currentFilters['maxPrice'] as double?,
          minStarRating: _currentFilters['minStarRating'] as int?,
          requiredAmenities:
              _currentFilters['requiredAmenities'] as List<String>?,
          unitTypeId: _currentFilters['unitTypeId'] as String?,
          serviceIds: _currentFilters['serviceIds'] as List<String>?,
          checkIn: _currentFilters['checkIn'] as DateTime?,
          checkOut: _currentFilters['checkOut'] as DateTime?,
          adults: _currentFilters['adults'] as int?,
          children: _currentFilters['children'] as int?,
          guestsCount: _currentFilters['guestsCount'] as int?,
          dynamicFieldFilters:
              _currentFilters['dynamicFieldFilters'] as Map<String, dynamic>?,
          latitude: _currentFilters['latitude'] as double?,
          longitude: _currentFilters['longitude'] as double?,
          radiusKm: _currentFilters['radiusKm'] as double?,
          preferredCurrency: _currentFilters['preferredCurrency'] as String?,
          sortBy: _currentFilters['sortBy'] as String?,
          pageNumber: nextPage,
          pageSize: successState.searchResults.pageSize,
        ));
      }
    }
  }

  /// Loads the filter catalog from the backend and falls back to local data
  /// when the network path fails.
  /// يحمل كتالوج الفلاتر من الخلفية ويعود إلى البيانات المحلية عند فشل
  /// المسار الشبكي.
  Future<void> _onGetSearchFilters(
    GetSearchFiltersEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit((state as SearchCombinedState).copyWith(
      filtersState: const SearchFiltersLoading(),
    ));

    try {
      // محاولة جلب الفلاتر من الباك اند
      final result = await getSearchFiltersUseCase(NoParams());

      await result.fold(
        (failure) async {
          // في حالة الفشل، محاولة استخدام البيانات المحفوظة محلياً
          await _loadFiltersFromLocalData(emit);
        },
        (filters) {
          emit((state as SearchCombinedState).copyWith(
            filtersState: SearchFiltersLoaded(filters: filters),
          ));
          // Try preload saved filters for continuity
          final saved = filterStorageService.getCurrentFilters();
          if (saved != null && saved.isNotEmpty) {
            _currentFilters = saved;
          }
        },
      );
    } catch (e) {
      // في حالة الخطأ، محاولة استخدام البيانات المحفوظة محلياً
      await _loadFiltersFromLocalData(emit);
    }
  }

  /// Builds a lightweight filter set from cached property-type data.
  /// يبني مجموعة فلاتر خفيفة من بيانات أنواع العقارات المخزنة.
  Future<void> _loadFiltersFromLocalData(Emitter<SearchState> emit) async {
    try {
      // جلب أنواع العقارات المحفوظة (تُعاد كـ Future لذلك نستخدم await)
      final propertyTypes = await dataSyncService.getPropertyTypes();

      // إنشاء فلاتر بسيطة من البيانات المحفوظة
      final localFilters = SearchFilters(
        propertyTypes: propertyTypes
            .map((pt) => PropertyTypeFilter(
                  id: pt.id,
                  name: pt.name,
                  propertiesCount: pt.propertiesCount,
                ))
            .toList(),
        unitTypes: [],
        amenities: [],
        priceRange: const PriceRange(
            minPrice: 0.0, maxPrice: 1000000.0, averagePrice: 500000.0),
        cities: [],
        services: [],
        // القيم المضافة لتلبية المعاملات المطلوبة الجديدة
        starRatings: const [1, 2, 3, 4, 5],
        starRatingOptions: const [],
        availableCities: const [],
        maxGuestCapacity: 0,
        distanceRange: const DistanceRange(minDistance: 0, maxDistance: 0),
        supportedCurrencies: const [],
        dynamicFieldValues: const [],
      );

      emit((state as SearchCombinedState).copyWith(
        filtersState: SearchFiltersLoaded(filters: localFilters),
      ));
    } catch (e) {
      emit((state as SearchCombinedState).copyWith(
        filtersState: SearchFiltersError(
          message: await AppLocalizations.translate(
            'search.filters.loadFailed',
            locale: LocaleManager.getCurrentLocale(),
          ),
        ),
      ));
    }
  }

  /// Fetches live suggestions for the current query and ignores stale results.
  /// يجلب اقتراحات حية للاستعلام الحالي ويتجاهل النتائج القديمة.
  Future<void> _onGetSearchSuggestions(
    GetSearchSuggestionsEvent event,
    Emitter<SearchState> emit,
  ) async {
    final normalizedQuery = event.query.trim();
    if (normalizedQuery.length < 2) {
      _suggestionsRequestToken++;
      emit((state as SearchCombinedState).copyWith(
        suggestionsState: const SearchSuggestionsLoaded(suggestions: []),
      ));
      return;
    }

    final requestToken = ++_suggestionsRequestToken;

    emit((state as SearchCombinedState).copyWith(
      suggestionsState: const SearchSuggestionsLoading(),
    ));

    final params = SearchSuggestionsParams(
      query: normalizedQuery,
      limit: event.limit,
    );

    final result = await getSearchSuggestionsUseCase(params);

    if (requestToken != _suggestionsRequestToken) {
      // Ignore out-of-order responses.
      return;
    }

    result.fold(
      (failure) {
        emit((state as SearchCombinedState).copyWith(
          suggestionsState: SearchSuggestionsError(message: failure.message),
        ));
      },
      (suggestions) {
        emit((state as SearchCombinedState).copyWith(
          suggestionsState: SearchSuggestionsLoaded(suggestions: suggestions),
        ));
      },
    );
  }

  /// Clears the suggestion overlay and invalidates older suggestion responses.
  /// يمسح طبقة الاقتراحات ويبطل الاستجابات الأقدم.
  void _onClearSearchSuggestions(
    ClearSearchSuggestionsEvent event,
    Emitter<SearchState> emit,
  ) {
    _suggestionsRequestToken++;
    emit((state as SearchCombinedState).copyWith(
      suggestionsState: const SearchSuggestionsLoaded(suggestions: []),
    ));
  }

  /// Loads personalized properties that help the user continue exploring.
  /// يحمل عقارات مخصصة تساعد المستخدم على مواصلة الاستكشاف.
  Future<void> _onGetRecommendedProperties(
    GetRecommendedPropertiesEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit((state as SearchCombinedState).copyWith(
      recommendedState: const RecommendedPropertiesLoading(),
    ));

    final result = await searchRepository.getRecommendedProperties(
      userId: event.userId,
      limit: event.limit,
    );

    result.fold(
      (failure) {
        emit((state as SearchCombinedState).copyWith(
          recommendedState:
              RecommendedPropertiesError(message: failure.message),
        ));
      },
      (properties) {
        emit((state as SearchCombinedState).copyWith(
          recommendedState: RecommendedPropertiesLoaded(properties: properties),
        ));
      },
    );
  }

  /// Loads destination suggestions that are popular for discovery screens.
  /// يحمل اقتراحات وجهات شائعة لشاشات الاكتشاف.
  Future<void> _onGetPopularDestinations(
    GetPopularDestinationsEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit((state as SearchCombinedState).copyWith(
      popularDestinationsState: const PopularDestinationsLoading(),
    ));

    final result = await searchRepository.getPopularDestinations(
      limit: event.limit,
    );

    result.fold(
      (failure) {
        emit((state as SearchCombinedState).copyWith(
          popularDestinationsState:
              PopularDestinationsError(message: failure.message),
        ));
      },
      (destinations) {
        emit((state as SearchCombinedState).copyWith(
          popularDestinationsState:
              PopularDestinationsLoaded(destinations: destinations),
        ));
      },
    );
  }

  /// Persists the latest filter payload without firing a new search yet.
  /// يحفظ آخر حمولة للفلاتر دون إطلاق بحث جديد بعد.
  Future<void> _onUpdateSearchFilters(
    UpdateSearchFiltersEvent event,
    Emitter<SearchState> emit,
  ) async {
    _currentFilters = _buildFiltersMap(event);
    await filterStorageService.saveCurrentFilters(_currentFilters);
  }

  /// Resets the search results view but keeps the current filter memory.
  /// يعيد ضبط عرض النتائج مع الإبقاء على ذاكرة الفلاتر الحالية.
  void _onClearSearchResults(
    ClearSearchResultsEvent event,
    Emitter<SearchState> emit,
  ) {
    _currentSearchResults = null;
    _currentFilters = {};
    emit((state as SearchCombinedState).copyWith(
      searchResultsState: const SearchInitial(),
    ));
  }

  /// Clears the active search session and removes stored filter state.
  /// يمسح جلسة البحث النشطة ويزيل حالة الفلاتر المخزنة.
  Future<void> _onClearSearch(
    ClearSearchEvent event,
    Emitter<SearchState> emit,
  ) async {
    _currentSearchResults = null;
    _currentFilters = {};
    await filterStorageService.clearCurrentFilters();

    emit((state as SearchCombinedState).copyWith(
      searchResultsState: const SearchInitial(),
    ));
  }

  /// Adds the current query to the top of the recent-search history.
  /// يضيف الاستعلام الحالي إلى أعلى سجل البحث الأخير.
  Future<void> _onAddToRecentSearches(
    AddToRecentSearchesEvent event,
    Emitter<SearchState> emit,
  ) async {
    final recentSearches =
        List<String>.from((state as SearchCombinedState).recentSearches);

    // Remove if already exists
    recentSearches.remove(event.suggestion);

    // Add to beginning
    recentSearches.insert(0, event.suggestion);

    // Keep only max allowed
    if (recentSearches.length > _maxRecentSearches) {
      recentSearches.removeRange(_maxRecentSearches, recentSearches.length);
    }

    // Save to local storage
    await sharedPreferences.setStringList(_recentSearchesKey, recentSearches);

    emit((state as SearchCombinedState)
        .copyWith(recentSearches: recentSearches));
  }

  /// Restores the recent-search list from local storage.
  /// يسترجع قائمة البحث الأخير من التخزين المحلي.
  void _onLoadRecentSearches(
    LoadRecentSearchesEvent event,
    Emitter<SearchState> emit,
  ) {
    final recentSearches =
        sharedPreferences.getStringList(_recentSearchesKey) ?? [];
    emit((state as SearchCombinedState)
        .copyWith(recentSearches: recentSearches));
  }

  /// Removes the recent-search history from local storage and UI state.
  /// يزيل سجل البحث الأخير من التخزين المحلي وحالة الواجهة.
  Future<void> _onClearRecentSearches(
    ClearRecentSearchesEvent event,
    Emitter<SearchState> emit,
  ) async {
    await sharedPreferences.remove(_recentSearchesKey);
    emit((state as SearchCombinedState).copyWith(recentSearches: []));
  }

  /// Saves the current search payload so the user can replay it later.
  /// يحفظ حمولة البحث الحالية كي يتمكن المستخدم من إعادة تشغيلها لاحقًا.
  Future<void> _onSaveSearch(
    SaveSearchEvent event,
    Emitter<SearchState> emit,
  ) async {
    final savedSearches =
        List<SavedSearch>.from((state as SearchCombinedState).savedSearches);

    final newSearch = SavedSearch(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: event.name,
      searchParams: event.searchParams,
      createdAt: DateTime.now(),
    );

    savedSearches.add(newSearch);

    // Save to local storage
    final savedSearchesJson = savedSearches
        .map((search) => {
              'id': search.id,
              'name': search.name,
              'searchParams': search.searchParams,
              'createdAt': search.createdAt.toIso8601String(),
            })
        .toList();

    await sharedPreferences.setString(
      _savedSearchesKey,
      json.encode(savedSearchesJson),
    );

    emit((state as SearchCombinedState).copyWith(savedSearches: savedSearches));
  }

  /// Restores saved searches from the local JSON snapshot.
  /// يسترجع عمليات البحث المحفوظة من لقطة JSON المحلية.
  void _onLoadSavedSearches(
    LoadSavedSearchesEvent event,
    Emitter<SearchState> emit,
  ) {
    final savedSearchesJson = sharedPreferences.getString(_savedSearchesKey);

    if (savedSearchesJson != null) {
      final decoded = json.decode(savedSearchesJson) as List;
      final savedSearches = decoded
          .map((item) => SavedSearch(
                id: item['id'],
                name: item['name'],
                searchParams: Map<String, dynamic>.from(item['searchParams']),
                createdAt: DateTime.parse(item['createdAt']),
              ))
          .toList();

      emit((state as SearchCombinedState)
          .copyWith(savedSearches: savedSearches));
    }
  }

  /// Removes one saved search and writes the updated list back to storage.
  /// يحذف عملية بحث محفوظة واحدة ويعيد كتابة القائمة المحدّثة إلى التخزين.
  Future<void> _onDeleteSavedSearch(
    DeleteSavedSearchEvent event,
    Emitter<SearchState> emit,
  ) async {
    final savedSearches = (state as SearchCombinedState)
        .savedSearches
        .where((search) => search.id != event.searchId)
        .toList();

    // Save updated list to local storage
    final savedSearchesJson = savedSearches
        .map((search) => {
              'id': search.id,
              'name': search.name,
              'searchParams': search.searchParams,
              'createdAt': search.createdAt.toIso8601String(),
            })
        .toList();

    await sharedPreferences.setString(
      _savedSearchesKey,
      json.encode(savedSearchesJson),
    );

    emit((state as SearchCombinedState).copyWith(savedSearches: savedSearches));
  }

  /// Converts a saved payload back into a live search request.
  /// يحول الحمولة المحفوظة إلى طلب بحث حي من جديد.
  void _onApplySavedSearch(
    ApplySavedSearchEvent event,
    Emitter<SearchState> emit,
  ) {
    add(SearchPropertiesEvent(
      searchTerm: event.searchParams['searchTerm'] as String?,
      city: event.searchParams['city'] as String?,
      propertyTypeId: event.searchParams['propertyTypeId'] as String?,
      minPrice: event.searchParams['minPrice'] as double?,
      maxPrice: event.searchParams['maxPrice'] as double?,
      minStarRating: event.searchParams['minStarRating'] as int?,
      requiredAmenities: event.searchParams['requiredAmenities'] != null
          ? List<String>.from(event.searchParams['requiredAmenities'])
          : null,
      unitTypeId: event.searchParams['unitTypeId'] as String?,
      serviceIds: event.searchParams['serviceIds'] != null
          ? List<String>.from(event.searchParams['serviceIds'])
          : null,
      checkIn: event.searchParams['checkIn'] != null
          ? DateTime.parse(event.searchParams['checkIn'])
          : null,
      checkOut: event.searchParams['checkOut'] != null
          ? DateTime.parse(event.searchParams['checkOut'])
          : null,
      guestsCount: event.searchParams['guestsCount'] as int?,
      dynamicFieldFilters: event.searchParams['dynamicFieldFilters'] != null
          ? Map<String, dynamic>.from(
              event.searchParams['dynamicFieldFilters'] as Map,
            )
          : null,
      latitude: event.searchParams['latitude'] as double?,
      longitude: event.searchParams['longitude'] as double?,
      radiusKm: event.searchParams['radiusKm'] as double?,
      preferredCurrency: event.searchParams['preferredCurrency'] as String?,
      sortBy: event.searchParams['sortBy'] as String?,
    ));
  }

  /// Converts the search event payload into a serializable filter snapshot.
  /// يحول حمولة حدث البحث إلى لقطة فلاتر قابلة للتخزين.
  Map<String, dynamic> _buildFiltersMap(dynamic event) {
    final filters = <String, dynamic>{};

    if (event is SearchPropertiesEvent) {
      if (event.searchTerm != null) filters['searchTerm'] = event.searchTerm;
      if (event.city != null) filters['city'] = event.city;
      if (event.propertyTypeId != null)
        filters['propertyTypeId'] = event.propertyTypeId;
      if (event.minPrice != null) filters['minPrice'] = event.minPrice;
      if (event.maxPrice != null) filters['maxPrice'] = event.maxPrice;
      if (event.minStarRating != null)
        filters['minStarRating'] = event.minStarRating;
      if (event.requiredAmenities != null)
        filters['requiredAmenities'] = event.requiredAmenities;
      if (event.unitTypeId != null) filters['unitTypeId'] = event.unitTypeId;
      if (event.serviceIds != null) filters['serviceIds'] = event.serviceIds;
      if (event.checkIn != null) filters['checkIn'] = event.checkIn;
      if (event.checkOut != null) filters['checkOut'] = event.checkOut;
      if (event.adults != null) filters['adults'] = event.adults;
      if (event.children != null) filters['children'] = event.children;
      if (event.guestsCount != null) filters['guestsCount'] = event.guestsCount;
      if (event.dynamicFieldFilters != null &&
          event.dynamicFieldFilters!.isNotEmpty) {
        filters['dynamicFieldFilters'] = event.dynamicFieldFilters;
      }
      if (event.latitude != null) filters['latitude'] = event.latitude;
      if (event.longitude != null) filters['longitude'] = event.longitude;
      if (event.radiusKm != null) filters['radiusKm'] = event.radiusKm;
      if (event.sortBy != null) filters['sortBy'] = event.sortBy;
    } else if (event is UpdateSearchFiltersEvent) {
      // Merge new filters into current filters
      filters.addAll(event.filters);
    }

    return filters;
  }

  /// Extracts the backend relaxation metadata that explains why results were
  /// broadened.
  /// يستخرج بيانات التخفيف من الخلفية التي تشرح لماذا تم توسيع النتائج.
  SearchRelaxationInfo? _extractRelaxationInfo(
      PaginatedResult<SearchResult> result) {
    print('🔍 [SearchBloc] Extracting relaxation info from result...');

    if (result.metadata == null) {
      print('⚠️ [SearchBloc] No metadata found');
      return null;
    }

    final metadata = result.metadata as Map<String, dynamic>;
    print('📊 [SearchBloc] Metadata keys: ${metadata.keys.toList()}');
    print('📊 [SearchBloc] Full metadata: $metadata');

    final wasRelaxed = metadata['wasRelaxed'] as bool? ?? false;
    print('📊 [SearchBloc] wasRelaxed from metadata: $wasRelaxed');

    if (!wasRelaxed) {
      print(
          '⚠️ [SearchBloc] No relaxation (wasRelaxed=false) - returning null');
      return null;
    }

    try {
      final relaxationLevelRaw = metadata['relaxationLevel'];
      print(
          '📊 [SearchBloc] relaxationLevel (raw): $relaxationLevelRaw (${relaxationLevelRaw.runtimeType})');

      final relaxationLevel =
          SearchRelaxationLevelExtension.fromString(relaxationLevelRaw);
      print('📊 [SearchBloc] Parsed relaxationLevel: $relaxationLevel');

      final relaxationInfo = SearchRelaxationInfo.fromResponse(
        relaxationLevel: relaxationLevel,
        relaxedFilters: metadata['relaxedFilters'] != null
            ? List<String>.from(metadata['relaxedFilters'] as List)
            : [],
        searchStrategy: metadata['searchStrategy'] as String? ??
            AppLocalizations.translateSync('core.searchRelaxation.exact'),
        originalCriteria: metadata['originalCriteria'] != null
            ? Map<String, dynamic>.from(metadata['originalCriteria'] as Map)
            : {},
        actualCriteria: metadata['actualCriteria'] != null
            ? Map<String, dynamic>.from(metadata['actualCriteria'] as Map)
            : {},
        userMessage: metadata['userMessage'] as String?,
        suggestedActions: metadata['suggestedActions'] != null
            ? List<String>.from(metadata['suggestedActions'] as List)
            : [],
      );

      print('✅ [SearchBloc] Relaxation info extracted successfully');
      print('   - Level: ${relaxationInfo.relaxationLevel}');
      print('   - wasRelaxed: ${relaxationInfo.wasRelaxed}');
      print('   - Relaxed filters: ${relaxationInfo.relaxedFilters.length}');
      print('   - User message: ${relaxationInfo.userMessage}');

      return relaxationInfo;
    } catch (e, stackTrace) {
      debugPrint('⚠️ [SearchBloc] Error extracting relaxation info: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Pulls facet data out of the paginated response metadata when available.
  /// يستخرج بيانات الفلاتر من بيانات التعريف في الاستجابة المتدرجة عندما
  /// تكون متاحة.
  SearchFilters? _extractFacets(PaginatedResult<SearchResult> result) {
    final metadata = result.metadata;
    if (metadata is! Map) {
      return null;
    }

    final facets = metadata['facets'];
    if (facets is SearchFilters) {
      return facets;
    }

    return null;
  }

  /// Converts the active filter map into a searchable request payload.
  /// يحول خريطة الفلاتر النشطة إلى حمولة طلب قابلة للبحث.
  SearchPropertiesParams _buildSearchParamsFromFilters(
    Map<String, dynamic> filters, {
    required String preferredCurrency,
    bool previewOnly = false,
    int pageNumber = 1,
    int pageSize = 20,
  }) {
    int? asInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    double? asDouble(dynamic value) {
      if (value is double) return value;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    DateTime? asDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return SearchPropertiesParams(
      searchTerm: filters['searchTerm'] as String?,
      city: filters['city'] as String?,
      propertyTypeId: filters['propertyTypeId'] as String?,
      minPrice: asDouble(filters['minPrice']),
      maxPrice: asDouble(filters['maxPrice']),
      minStarRating: asInt(filters['minStarRating']),
      requiredAmenities: filters['requiredAmenities'] != null
          ? List<String>.from(filters['requiredAmenities'] as List)
          : null,
      unitTypeId: filters['unitTypeId'] as String?,
      serviceIds: filters['serviceIds'] != null
          ? List<String>.from(filters['serviceIds'] as List)
          : null,
      checkIn: asDate(filters['checkIn']),
      checkOut: asDate(filters['checkOut']),
      adults: asInt(filters['adults']),
      children: asInt(filters['children']),
      guestsCount: asInt(filters['guestsCount']),
      dynamicFieldFilters: filters['dynamicFieldFilters'] != null
          ? Map<String, dynamic>.from(filters['dynamicFieldFilters'] as Map)
          : null,
      latitude: asDouble(filters['latitude']),
      longitude: asDouble(filters['longitude']),
      radiusKm: asDouble(filters['radiusKm']),
      preferredCurrency: preferredCurrency,
      sortBy: filters['sortBy'] as String?,
      previewOnly: previewOnly,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
