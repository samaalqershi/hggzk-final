// lib/features/reference/presentation/bloc/reference_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../services/local_storage_service.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/currency.dart';
import '../../domain/usecases/get_cities_usecase.dart';
import '../../domain/usecases/get_currencies_usecase.dart';
import 'reference_event.dart';
import 'reference_state.dart';

/// العربية: يدير تحميل المدن والعملات والتخزين المحلي للاختيار الحالي حتى
/// تبقى شاشات المرجع متسقة ولا تكرر الجلب بلا داعٍ.
/// Manages city and currency loading together with local persistence so reference screens stay consistent without redundant fetches.
class ReferenceBloc extends Bloc<ReferenceEvent, ReferenceState> {
  /// العربية: يستدعي طبقة الدومين لجلب المدن عند الحاجة.
  /// Calls the domain layer to fetch cities when needed.
  final GetCitiesUseCase getCitiesUseCase;

  /// العربية: يستدعي طبقة الدومين لجلب العملات.
  /// Calls the domain layer to fetch currencies.
  final GetCurrenciesUseCase getCurrenciesUseCase;

  /// العربية: يحفظ الاختيار الحالي ويعيده من التخزين المحلي.
  /// Persists and rehydrates the current selection from local storage.
  final LocalStorageService localStorage;

  /// العربية: نسخة محلية من المدن لتقليل الاستدعاءات المتكررة.
  /// Local city cache to avoid repeated fetches.
  List<City>? _cachedCities;

  /// العربية: نسخة محلية من العملات لتسريع إعادة العرض.
  /// Local currency cache to keep re-renders fast.
  List<Currency>? _cachedCurrencies;

  /// العربية: اسم المدينة المختارة حاليًا.
  /// Name of the currently selected city.
  String? _selectedCity;

  /// العربية: رمز العملة المختارة حاليًا.
  /// Code of the currently selected currency.
  String? _selectedCurrency;

  /// العربية: يربط البلوك بمصادر المدن والعملات والتخزين المحلي حتى يكون
  /// قرار التحميل والاختيار مركزيًا.
  /// Connects the bloc to city/currency sources and local storage so loading and selection remain centralized.
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

  /// العربية: يقرر هل يستخدم الكاش أو يجلب المدن من المصدر ثم يضبط الاختيار الحالي قبل الإرسال.
  /// Chooses cache or remote fetch, then aligns the current selection before emitting state.
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
      (failure) => emit(ReferenceError(message: failure.message)),
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

  /// العربية: يطبق منطق المدن نفسه على العملات.
  /// Applies the same cache-first behavior to currencies.
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
      (failure) => emit(ReferenceError(message: failure.message)),
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

  /// العربية: يحمّل المدن والعملات معًا عندما تحتاج الشاشة لقطة مرجعية كاملة.
  /// Loads cities and currencies together when the screen needs one complete reference snapshot.
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
        emit(const ReferenceError(message: 'فشل تحميل البيانات المرجعية'));
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
      emit(ReferenceError(message: e.toString()));
    }
  }

  /// العربية: يحفظ المدينة المختارة ثم يعكسها في الحالة الحالية حتى تبقى الواجهة والتخزين متطابقين.
  /// Persists the chosen city and reflects it back in state so UI and storage stay aligned.
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
        message: 'تم اختيار ${event.city.name}',
      ));

      // العودة للحالة السابقة
      if (_cachedCities != null) {
        emit(CitiesLoaded(
          cities: _cachedCities!,
          selectedCity: _selectedCity,
        ));
      }
    } catch (e) {
      emit(ReferenceError(message: 'فشل حفظ المدينة المختارة'));
    }
  }

  /// العربية: يحفظ العملة المختارة ويعيد بثها إلى الواجهة مع الإبقاء على الكاش.
  /// Persists the selected currency and re-emits it to the UI while keeping the cache intact.
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
        message: 'تم اختيار ${event.currency.arabicName}',
      ));

      // العودة للحالة السابقة
      if (_cachedCurrencies != null) {
        emit(CurrenciesLoaded(
          currencies: _cachedCurrencies!,
          selectedCurrency: _selectedCurrency,
        ));
      }
    } catch (e) {
      emit(ReferenceError(message: 'فشل حفظ العملة المختارة'));
    }
  }

  /// العربية: يفلتر المدن المحفوظة محليًا بحسب النص المدخل ويحدد إن كانت
  /// النتيجة ناتجة عن بحث أم عن تحميل كامل.
  /// Filters the locally cached cities by the typed query and marks whether the result came from search or a full load.
  void _onSearchCities(
    SearchCitiesEvent event,
    Emitter<ReferenceState> emit,
  ) {
    if (_cachedCities == null) {
      emit(const ReferenceError(message: 'لا توجد مدن محملة'));
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

  /// العربية: يطبق فلترة محلية على قائمة العملات دون استدعاء الشبكة.
  /// Applies local filtering to currencies without hitting the network.
  void _onSearchCurrencies(
    SearchCurrenciesEvent event,
    Emitter<ReferenceState> emit,
  ) {
    if (_cachedCurrencies == null) {
      emit(const ReferenceError(message: 'لا توجد عملات محملة'));
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

  /// العربية: يعيد جلب اسم المدينة المحفوظ حتى تستعيد الواجهة آخر اختيار.
  /// Rehydrates the saved city name so the UI restores the last choice.
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

  /// العربية: يعيد جلب رمز العملة المحفوظ ليبقى العرض متسقًا بعد إعادة الفتح.
  /// Rehydrates the saved currency code so the UI stays consistent after relaunch.
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

  /// العربية: يمسح الاختيارين المحفوظين جزئيًا أو كليًا ثم يعكس الحالة
  /// المرجعية الجديدة إن كانت البيانات محملة.
  /// Clears one or both persisted selections and re-emits the current reference snapshot when data is available.
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

  /// العربية: يسقط الكاش ثم يطلب إعادة التحميل الكامل للمدن والعملات.
  /// Drops the cache and requests a full reload of cities and currencies.
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
