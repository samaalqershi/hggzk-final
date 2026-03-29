// lib/features/reference/presentation/bloc/reference_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hggzk/core/error/failure_localizer.dart';
import 'package:hggzk/core/localization/app_localizations.dart';
import '../../../../core/usecases/usecase.dart';
import 'package:hggzk/core/services/local_storage_service.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/currency.dart';
import '../../domain/usecases/get_cities_usecase.dart';
import '../../domain/usecases/get_currencies_usecase.dart';
import 'reference_event.dart';
import 'reference_state.dart';

/// Orchestrates reference data such as cities and currencies, including cache
/// reuse and selection persistence.
/// يدير بيانات المرجع مثل المدن والعملات مع إعادة استخدام الكاش وحفظ
/// الاختيارات.
class ReferenceBloc extends Bloc<ReferenceEvent, ReferenceState> {
  /// Loads cities from the use case when the cache is stale or bypassed.
  /// يجلب المدن من use case عندما يكون الكاش قديمًا أو تم تجاوزه.
  final GetCitiesUseCase getCitiesUseCase;

  /// Loads currencies from the use case when fresh data is required.
  /// يجلب العملات من use case عندما تكون البيانات الجديدة مطلوبة.
  final GetCurrenciesUseCase getCurrenciesUseCase;

  /// Persists and restores the currently selected city and currency.
  /// يحفظ ويسترجع المدينة والعملة المختارتين.
  final LocalStorageService localStorage;

  /// Keeps the last loaded city list so repeated opens stay fast.
  /// يحتفظ بأحدث قائمة مدن محمّلة كي تبقى عمليات الفتح المتكرر سريعة.
  List<City>? _cachedCities;

  /// Keeps the last loaded currency list to avoid unnecessary reloads.
  /// يحتفظ بأحدث قائمة عملات محمّلة لتجنب إعادة التحميل غير الضرورية.
  List<Currency>? _cachedCurrencies;

  /// Mirrors the selected city saved in local storage.
  /// يعكس المدينة المختارة المحفوظة في التخزين المحلي.
  String? _selectedCity;

  /// Mirrors the selected currency saved in local storage.
  /// يعكس العملة المختارة المحفوظة في التخزين المحلي.
  String? _selectedCurrency;

  /// Builds the bloc that coordinates reference lookup and selection state.
  /// يبني الـ bloc الذي ينسق جلب بيانات المرجع وحالة الاختيار.
  ReferenceBloc({
    required this.getCitiesUseCase,
    required this.getCurrenciesUseCase,
    required this.localStorage,
  }) : super(const ReferenceInitial()) {
    on<LoadCitiesEvent>(_onLoadCities);
    on<LoadCurrenciesEvent>(_onLoadCurrencies);
    on<LoadReferenceDataEvent>(_onLoadReferenceData);
    on<SelectCityEvent>(_onSelectCity);
    on<SelectCurrencyEvent>(_onSelectCurrency);
    on<SearchCitiesEvent>(_onSearchCities);
    on<SearchCurrenciesEvent>(_onSearchCurrencies);
    on<LoadSelectedCityEvent>(_onLoadSelectedCity);
    on<LoadSelectedCurrencyEvent>(_onLoadSelectedCurrency);
    on<ClearSelectionEvent>(_onClearSelection);
    on<RefreshReferenceDataEvent>(_onRefreshReferenceData);
  }

  /// Loads the city list, preferring cache unless a refresh is forced.
  /// يحمل قائمة المدن مع تفضيل الكاش ما لم يُطلب التحديث.
  Future<void> _onLoadCities(
    LoadCitiesEvent event,
    Emitter<ReferenceState> emit,
  ) async {
    // استخدم الكاش إذا كان متاحاً ولا يريد المستخدم التحديث القسري
    if (_cachedCities != null && !event.forceRefresh) {
      _selectedCity = localStorage.getSelectedCity();
      emit(CitiesLoaded(
        cities: _cachedCities!,
        selectedCity: _selectedCity,
      ));
      return;
    }

    emit(const ReferenceLoading());

    final result = await getCitiesUseCase(NoParams());

    result.fold(
      (failure) =>
          emit(ReferenceError(message: FailureLocalizer.localize(failure))),
      (cities) {
        _cachedCities = cities;
        _selectedCity = localStorage.getSelectedCity();
        emit(CitiesLoaded(
          cities: cities,
          selectedCity: _selectedCity,
        ));
      },
    );
  }

  /// Loads the currency list, reusing cached data when it is still valid.
  /// يحمل قائمة العملات مع إعادة استخدام الكاش عندما يكون صالحًا.
  Future<void> _onLoadCurrencies(
    LoadCurrenciesEvent event,
    Emitter<ReferenceState> emit,
  ) async {
    // استخدم الكاش إذا كان متاحاً
    if (_cachedCurrencies != null && !event.forceRefresh) {
      _selectedCurrency = localStorage.getSelectedCurrency();
      emit(CurrenciesLoaded(
        currencies: _cachedCurrencies!,
        selectedCurrency: _selectedCurrency,
      ));
      return;
    }

    emit(const ReferenceLoading());

    final result = await getCurrenciesUseCase(NoParams());

    result.fold(
      (failure) =>
          emit(ReferenceError(message: FailureLocalizer.localize(failure))),
      (currencies) {
        _cachedCurrencies = currencies;
        _selectedCurrency = localStorage.getSelectedCurrency();
        emit(CurrenciesLoaded(
          currencies: currencies,
          selectedCurrency: _selectedCurrency,
        ));
      },
    );
  }

  /// Loads cities and currencies together so initial screens can paint once.
  /// يحمل المدن والعملات معًا كي ترسم الشاشات الأولية مرة واحدة.
  Future<void> _onLoadReferenceData(
    LoadReferenceDataEvent event,
    Emitter<ReferenceState> emit,
  ) async {
    emit(const ReferenceLoading());

    try {
      // تحميل البيانات بشكل متوازي
      final citiesResult = await getCitiesUseCase(NoParams());
      final currenciesResult = await getCurrenciesUseCase(NoParams());

      if (citiesResult.isLeft() || currenciesResult.isLeft()) {
        emit(
          ReferenceError(
            message: AppLocalizations.translateSync('common.unexpectedError'),
          ),
        );
        return;
      }

      _cachedCities = citiesResult.getOrElse(() => []);
      _cachedCurrencies = currenciesResult.getOrElse(() => []);
      _selectedCity = localStorage.getSelectedCity();
      _selectedCurrency = localStorage.getSelectedCurrency();

      emit(ReferenceDataLoaded(
        cities: _cachedCities!,
        currencies: _cachedCurrencies!,
        selectedCity: _selectedCity,
        selectedCurrency: _selectedCurrency,
      ));
    } catch (e) {
      emit(
        ReferenceError(
          message: AppLocalizations.translateSync(
            'core.reference.unexpectedError',
          ),
        ),
      );
    }
  }

  /// Persists the chosen city and emits a transient selection confirmation.
  /// يحفظ المدينة المختارة ويصدر تأكيدًا مؤقتًا للاختيار.
  Future<void> _onSelectCity(
    SelectCityEvent event,
    Emitter<ReferenceState> emit,
  ) async {
    try {
      // حفظ المدينة المختارة
      await localStorage.saveSelectedCity(event.city.name);
      _selectedCity = event.city.name;

      // تحديث الحالة
      if (_cachedCities != null) {
        emit(CitiesLoaded(
          cities: _cachedCities!,
          selectedCity: _selectedCity,
        ));
      }

      // إرسال حدث نجاح الاختيار
      emit(CitySelected(
        city: event.city,
        message: AppLocalizations.translateSync(
          'common.selectedValue',
          params: {'value': event.city.name},
        ),
      ));

      // العودة للحالة السابقة
      if (_cachedCities != null) {
        emit(CitiesLoaded(
          cities: _cachedCities!,
          selectedCity: _selectedCity,
        ));
      }
    } catch (e) {
      emit(
        ReferenceError(
          message: AppLocalizations.translateSync('common.localStorageError'),
        ),
      );
    }
  }

  /// Persists the chosen currency and emits a transient selection confirmation.
  /// يحفظ العملة المختارة ويصدر تأكيدًا مؤقتًا للاختيار.
  Future<void> _onSelectCurrency(
    SelectCurrencyEvent event,
    Emitter<ReferenceState> emit,
  ) async {
    try {
      // حفظ العملة المختارة
      await localStorage.saveSelectedCurrency(event.currency.code);
      _selectedCurrency = event.currency.code;

      // تحديث الحالة
      if (_cachedCurrencies != null) {
        emit(CurrenciesLoaded(
          currencies: _cachedCurrencies!,
          selectedCurrency: _selectedCurrency,
        ));
      }

      // إرسال حدث نجاح الاختيار
      emit(CurrencySelected(
        currency: event.currency,
        message: AppLocalizations.translateSync(
          'common.selectedValue',
          params: {'value': event.currency.arabicName},
        ),
      ));

      // العودة للحالة السابقة
      if (_cachedCurrencies != null) {
        emit(CurrenciesLoaded(
          currencies: _cachedCurrencies!,
          selectedCurrency: _selectedCurrency,
        ));
      }
    } catch (e) {
      emit(
        ReferenceError(
          message: AppLocalizations.translateSync('common.localStorageError'),
        ),
      );
    }
  }

  /// Filters the cached city list locally so the UI can search instantly.
  /// يفلتر قائمة المدن المخزنة محليًا كي يظهر البحث فورًا.
  void _onSearchCities(
    SearchCitiesEvent event,
    Emitter<ReferenceState> emit,
  ) {
    if (_cachedCities == null) {
      emit(
        ReferenceError(
          message: AppLocalizations.translateSync('common.noData'),
        ),
      );
      return;
    }

    final query = event.query.toLowerCase();

    if (query.isEmpty) {
      emit(CitiesLoaded(
        cities: _cachedCities!,
        selectedCity: _selectedCity,
      ));
      return;
    }

    final filteredCities = _cachedCities!
        .where((city) =>
            city.name.toLowerCase().contains(query) ||
            city.country.toLowerCase().contains(query))
        .toList();

    emit(CitiesLoaded(
      cities: filteredCities,
      selectedCity: _selectedCity,
      isSearchResult: true,
    ));
  }

  /// Filters the cached currency list locally using code and localized name.
  /// يفلتر قائمة العملات المخزنة محليًا باستخدام الرمز والاسم المحلي.
  void _onSearchCurrencies(
    SearchCurrenciesEvent event,
    Emitter<ReferenceState> emit,
  ) {
    if (_cachedCurrencies == null) {
      emit(
        ReferenceError(
          message: AppLocalizations.translateSync('common.noData'),
        ),
      );
      return;
    }

    final query = event.query.toLowerCase();

    if (query.isEmpty) {
      emit(CurrenciesLoaded(
        currencies: _cachedCurrencies!,
        selectedCurrency: _selectedCurrency,
      ));
      return;
    }

    final filteredCurrencies = _cachedCurrencies!
        .where((currency) =>
            currency.code.toLowerCase().contains(query) ||
            currency.name.toLowerCase().contains(query) ||
            currency.arabicName.toLowerCase().contains(query))
        .toList();

    emit(CurrenciesLoaded(
      currencies: filteredCurrencies,
      selectedCurrency: _selectedCurrency,
      isSearchResult: true,
    ));
  }

  /// Reloads the selected city from storage so reopened screens stay aligned.
  /// يعيد تحميل المدينة المختارة من التخزين كي تظل الشاشات المفتوحة متطابقة.
  void _onLoadSelectedCity(
    LoadSelectedCityEvent event,
    Emitter<ReferenceState> emit,
  ) {
    _selectedCity = localStorage.getSelectedCity();

    if (_cachedCities != null) {
      emit(CitiesLoaded(
        cities: _cachedCities!,
        selectedCity: _selectedCity,
      ));
    }
  }

  /// Reloads the selected currency from storage for the active session.
  /// يعيد تحميل العملة المختارة من التخزين للجلسة الحالية.
  void _onLoadSelectedCurrency(
    LoadSelectedCurrencyEvent event,
    Emitter<ReferenceState> emit,
  ) {
    _selectedCurrency = localStorage.getSelectedCurrency();

    if (_cachedCurrencies != null) {
      emit(CurrenciesLoaded(
        currencies: _cachedCurrencies!,
        selectedCurrency: _selectedCurrency,
      ));
    }
  }

  /// Clears one or both selections and re-emits the current cached data.
  /// يمسح اختيارًا واحدًا أو كليهما ثم يعيد إصدار البيانات المخزنة الحالية.
  Future<void> _onClearSelection(
    ClearSelectionEvent event,
    Emitter<ReferenceState> emit,
  ) async {
    if (event.clearCity) {
      await localStorage.saveSelectedCity('');
      _selectedCity = null;
    }

    if (event.clearCurrency) {
      await localStorage.saveSelectedCurrency('');
      _selectedCurrency = null;
    }

    // إعادة تحميل البيانات الحالية
    if (_cachedCities != null && _cachedCurrencies != null) {
      emit(ReferenceDataLoaded(
        cities: _cachedCities!,
        currencies: _cachedCurrencies!,
        selectedCity: _selectedCity,
        selectedCurrency: _selectedCurrency,
      ));
    }
  }

  /// Invalidates the cache and triggers a full data reload.
  /// يبطل الكاش ويطلق إعادة تحميل كاملة للبيانات.
  Future<void> _onRefreshReferenceData(
    RefreshReferenceDataEvent event,
    Emitter<ReferenceState> emit,
  ) async {
    // مسح الكاش
    _cachedCities = null;
    _cachedCurrencies = null;

    // إعادة تحميل البيانات
    add(const LoadReferenceDataEvent());
  }
}
