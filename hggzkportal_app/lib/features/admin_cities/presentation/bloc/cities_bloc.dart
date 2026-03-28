import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/city.dart';
import '../../domain/usecases/get_cities_usecase.dart';
import '../../domain/usecases/save_cities_usecase.dart';
import '../../domain/usecases/create_city_usecase.dart';
import '../../domain/usecases/update_city_usecase.dart';
import '../../domain/usecases/delete_city_usecase.dart';
import '../../domain/usecases/search_cities_usecase.dart';
import '../../domain/usecases/get_cities_statistics_usecase.dart';
import '../../domain/usecases/upload_city_image_usecase.dart';
import '../../domain/usecases/delete_city_image_usecase.dart';
import 'cities_event.dart';
import 'cities_state.dart';

/// Coordinates city catalog actions, analytics, paging, and image operations.
///
/// ينسق عمليات دليل المدن والتحليلات والترقيم وعمليات الصور.
class CitiesBloc extends Bloc<CitiesEvent, CitiesState> {
  /// Use case that loads the city catalog from the repository.
  ///
  /// use case الذي يجلب دليل المدن من المستودع.
  final GetCitiesUseCase getCities;

  /// Use case that persists a full batch of cities.
  ///
  /// use case الذي يحفظ دفعة كاملة من المدن.
  final SaveCitiesUseCase saveCities;

  /// Use case that creates a single city entry.
  ///
  /// use case الذي ينشئ مدينة واحدة.
  final CreateCityUseCase createCity;

  /// Use case that updates an existing city record.
  ///
  /// use case الذي يحدّث سجل مدينة موجودًا.
  final UpdateCityUseCase updateCity;

  /// Use case that deletes a city from the catalog.
  ///
  /// use case الذي يحذف مدينة من الدليل.
  final DeleteCityUseCase deleteCity;

  /// Use case that performs free-text search over cities.
  ///
  /// use case الذي ينفذ البحث النصي داخل المدن.
  final SearchCitiesUseCase searchCities;

  /// Use case that loads dashboard statistics for cities.
  ///
  /// use case الذي يحمل إحصائيات لوحة المدن.
  final GetCitiesStatisticsUseCase getCitiesStatistics;

  /// Use case that uploads one city image.
  ///
  /// use case الذي يرفع صورة مدينة واحدة.
  final UploadCityImageUseCase uploadCityImage;

  /// Use case that removes a city image.
  ///
  /// use case الذي يحذف صورة مدينة.
  final DeleteCityImageUseCase deleteCityImage;

  /// Number of rows shown on each page of the catalog.
  ///
  /// عدد الصفوف المعروضة في كل صفحة من الدليل.
  static const int _itemsPerPage = 10;

  /// Snapshot of the full city list kept for local paging and filtering.
  ///
  /// لقطة قائمة المدن الكاملة المحفوظة للترقيم والتصفية المحلية.
  List<City> _allCities = [];

  /// Cached statistics used when the loaded state is rebuilt.
  ///
  /// الإحصائيات المخزنة مؤقتًا لإعادة بناء الحالة المحملة.
  Map<String, dynamic>? _statistics;

  /// Wires every use case into the city management event pipeline.
  ///
  /// يربط كل use case بخط معالجة الأحداث الخاص بإدارة المدن.
  CitiesBloc({
    required this.getCities,
    required this.saveCities,
    required this.createCity,
    required this.updateCity,
    required this.deleteCity,
    required this.searchCities,
    required this.getCitiesStatistics,
    required this.uploadCityImage,
    required this.deleteCityImage,
  }) : super(CitiesInitial()) {
    on<LoadCitiesEvent>(_onLoadCities);
    on<SaveCitiesEvent>(_onSaveCities);
    on<CreateCityEvent>(_onCreateCity);
    on<UpdateCityEvent>(_onUpdateCity);
    on<DeleteCityEvent>(_onDeleteCity);
    on<SearchCitiesEvent>(_onSearchCities);
    on<LoadCitiesStatisticsEvent>(_onLoadStatistics);
    on<UploadCityImageEvent>(_onUploadImage);
    on<DeleteCityImageEvent>(_onDeleteImage);
    on<RefreshCitiesEvent>(_onRefreshCities);
    on<ChangeCitiesPageEvent>(_onChangePage);
    on<CityImageProgressInternalEvent>(_onCityImageProgressInternal);
  }

  /// Loads the catalog and calculates the first visible page.
  ///
  /// يحمل الدليل ويحسب الصفحة الأولى المعروضة.
  Future<void> _onLoadCities(
    LoadCitiesEvent event,
    Emitter<CitiesState> emit,
  ) async {
    emit(CitiesLoading());

    final result = await getCities(GetCitiesParams(
      page: event.page,
      limit: event.limit,
      search: event.search,
      country: event.country,
      isActive: event.isActive,
    ));

    result.fold(
      (failure) => emit(CitiesError(message: failure.message)),
      (cities) {
        _allCities = cities;
        final totalPages = (cities.length / _itemsPerPage).ceil();

        final pagedCities = _getPagedCities(1);

        emit(CitiesLoaded(
          cities: cities,
          filteredCities: pagedCities,
          currentPage: 1,
          totalPages: totalPages,
          itemsPerPage: _itemsPerPage,
          statistics: _statistics,
        ));
      },
    );
  }

  /// Saves the edited city snapshot and refreshes the list after success.
  ///
  /// يحفظ لقطة المدن المعدلة ثم يحدّث القائمة بعد النجاح.
  Future<void> _onSaveCities(
    SaveCitiesEvent event,
    Emitter<CitiesState> emit,
  ) async {
    final currentState = state;
    emit(const CityOperationInProgress(operation: 'saving'));

    final result = await saveCities(event.cities);

    result.fold(
      (failure) {
        emit(CityOperationFailure(message: failure.message));
        if (currentState is CitiesLoaded) {
          emit(currentState);
        }
      },
      (success) {
        emit(const CityOperationSuccess(message: 'تم حفظ المدن بنجاح'));
        add(const RefreshCitiesEvent());
      },
    );
  }

  /// Creates one city and then reloads the catalog so the UI stays in sync.
  ///
  /// ينشئ مدينة واحدة ثم يعيد تحميل الدليل حتى تبقى الواجهة متزامنة.
  Future<void> _onCreateCity(
    CreateCityEvent event,
    Emitter<CitiesState> emit,
  ) async {
    final currentState = state;
    emit(CityOperationInProgress(
      operation: 'creating',
      cityName: event.city.name,
    ));

    final result = await createCity(event.city);

    result.fold(
      (failure) {
        emit(CityOperationFailure(message: failure.message));
        if (currentState is CitiesLoaded) {
          emit(currentState);
        }
      },
      (city) {
        emit(const CityOperationSuccess(message: 'تم إضافة المدينة بنجاح'));
        add(const RefreshCitiesEvent());
      },
    );
  }

  /// Replaces an existing city row and refreshes the admin view afterward.
  ///
  /// يستبدل صف مدينة موجودًا ثم يحدّث عرض الإدارة بعد ذلك.
  Future<void> _onUpdateCity(
    UpdateCityEvent event,
    Emitter<CitiesState> emit,
  ) async {
    final currentState = state;
    emit(CityOperationInProgress(
      operation: 'updating',
      cityName: event.oldName,
    ));

    final result = await updateCity(UpdateCityParams(
      oldName: event.oldName,
      city: event.city,
    ));

    result.fold(
      (failure) {
        emit(CityOperationFailure(message: failure.message));
        if (currentState is CitiesLoaded) {
          emit(currentState);
        }
      },
      (city) {
        emit(const CityOperationSuccess(message: 'تم تحديث المدينة بنجاح'));
        add(const RefreshCitiesEvent());
      },
    );
  }

  /// Deletes a city and updates the local pagination snapshot immediately.
  ///
  /// يحذف مدينة ويحدّث لقطة الترقيم المحلية فورًا.
  Future<void> _onDeleteCity(
    DeleteCityEvent event,
    Emitter<CitiesState> emit,
  ) async {
    final currentState = state;
    emit(CityOperationInProgress(
      operation: 'deleting',
      cityName: event.name,
    ));

    final result = await deleteCity(event.name);

    result.fold(
      (failure) {
        emit(CityOperationFailure(message: failure.message));
        if (currentState is CitiesLoaded) {
          emit(currentState);
        }
      },
      (success) {
        emit(const CityOperationSuccess(message: 'تم حذف المدينة بنجاح'));

        // Update local list immediately
        if (currentState is CitiesLoaded) {
          final updatedCities = List<City>.from(currentState.cities)
            ..removeWhere((city) => city.name == event.name);

          final totalPages = (updatedCities.length / _itemsPerPage).ceil();
          var currentPage = currentState.currentPage;

          // Adjust page if necessary
          if (currentPage > totalPages && totalPages > 0) {
            currentPage = totalPages;
          }

          final pagedCities = _getPagedCitiesFromList(
            updatedCities,
            currentPage,
          );

          emit(currentState.copyWith(
            cities: updatedCities,
            filteredCities: pagedCities,
            currentPage: currentPage,
            totalPages: totalPages,
          ));
        }
      },
    );
  }

  /// Filters the in-memory snapshot to keep search responsive.
  ///
  /// يفلتر اللقطة الموجودة في الذاكرة لتبقى تجربة البحث سريعة.
  Future<void> _onSearchCities(
    SearchCitiesEvent event,
    Emitter<CitiesState> emit,
  ) async {
    if (state is CitiesLoaded) {
      final currentState = state as CitiesLoaded;

      if (event.query.isEmpty) {
        // Reset to all cities
        final pagedCities = _getPagedCities(1);
        emit(currentState.copyWith(
          filteredCities: pagedCities,
          currentPage: 1,
          searchQuery: null,
        ));
      } else {
        // Filter cities
        final filteredCities = _allCities
            .where((city) =>
                city.name.toLowerCase().contains(event.query.toLowerCase()) ||
                city.country.toLowerCase().contains(event.query.toLowerCase()))
            .toList();

        final totalPages = (filteredCities.length / _itemsPerPage).ceil();
        final pagedCities = _getPagedCitiesFromList(filteredCities, 1);

        emit(currentState.copyWith(
          filteredCities: pagedCities,
          currentPage: 1,
          totalPages: totalPages,
          searchQuery: event.query,
        ));
      }
    }
  }

  /// Loads the latest statistics for the dashboard cards.
  ///
  /// يحمل أحدث الإحصائيات لبطاقات لوحة التحكم.
  Future<void> _onLoadStatistics(
    LoadCitiesStatisticsEvent event,
    Emitter<CitiesState> emit,
  ) async {
    final now = DateTime.now();
    final last30 = now.subtract(const Duration(days: 30));
    final result = await getCitiesStatistics(
        GetCitiesStatsParams(startDate: last30, endDate: now));

    result.fold(
      (failure) => null, // Silently fail for statistics
      (statistics) {
        _statistics = statistics;
        if (state is CitiesLoaded) {
          final currentState = state as CitiesLoaded;
          emit(currentState.copyWith(statistics: statistics));
        }
      },
    );
  }

  /// Starts the upload flow and converts progress callbacks into bloc events.
  ///
  /// يبدأ مسار الرفع ويحوّل استدعاءات التقدم إلى أحداث داخل الـ BLoC.
  Future<void> _onUploadImage(
    UploadCityImageEvent event,
    Emitter<CitiesState> emit,
  ) async {
    emit(CityImageUploadProgress(
      progress: 0,
      cityName: event.cityName,
    ));

    final result = await uploadCityImage(UploadCityImageParams(
      cityName: event.cityName,
      imagePath: event.imagePath,
      onSendProgress: (sent, total) {
        if (total > 0) {
          final p = sent / total;
          add(CityImageProgressInternalEvent(event.cityName, p));
        }
      },
    ));

    result.fold(
      (failure) => emit(CityOperationFailure(message: failure.message)),
      (imageUrl) {
        // Update city with new image
        final cityIndex = _allCities.indexWhere(
          (city) => city.name == event.cityName,
        );

        if (cityIndex != -1) {
          final updatedCity = _allCities[cityIndex].copyWith(
            images: [..._allCities[cityIndex].images, imageUrl],
          );

          add(UpdateCityEvent(
            oldName: event.cityName,
            city: updatedCity,
          ));
        }
      },
    );
  }

  /// Converts internal progress updates into a visible upload-progress state.
  ///
  /// يحول تحديثات التقدم الداخلية إلى حالة مرئية لتقدم الرفع.
  void _onCityImageProgressInternal(
    CityImageProgressInternalEvent event,
    Emitter<CitiesState> emit,
  ) {
    emit(CityImageUploadProgress(
      progress: event.progress,
      cityName: event.cityName,
    ));
  }

  /// Removes a single city image and propagates the resulting city update.
  ///
  /// يحذف صورة مدينة واحدة ثم يرسل تحديث المدينة الناتج.
  Future<void> _onDeleteImage(
    DeleteCityImageEvent event,
    Emitter<CitiesState> emit,
  ) async {
    final result = await deleteCityImage(DeleteCityImageParams(
      cityName: event.cityName,
      imageUrl: event.imageUrl,
    ));

    result.fold(
      (failure) => emit(CityOperationFailure(message: failure.message)),
      (success) {
        // Update city without the deleted image
        final cityIndex = _allCities.indexWhere(
          (city) => city.name == event.cityName,
        );

        if (cityIndex != -1) {
          final updatedImages = List<String>.from(
            _allCities[cityIndex].images,
          )..remove(event.imageUrl);

          final updatedCity = _allCities[cityIndex].copyWith(
            images: updatedImages,
          );

          add(UpdateCityEvent(
            oldName: event.cityName,
            city: updatedCity,
          ));
        }
      },
    );
  }

  /// Replays the load flow so the screen returns to the default catalog view.
  ///
  /// يعيد تنفيذ مسار التحميل حتى تعود الشاشة إلى عرض الدليل الافتراضي.
  Future<void> _onRefreshCities(
    RefreshCitiesEvent event,
    Emitter<CitiesState> emit,
  ) async {
    add(const LoadCitiesEvent());
    add(LoadCitiesStatisticsEvent());
  }

  /// Moves the visible page forward or backward inside the current snapshot.
  ///
  /// ينقل الصفحة الظاهرة للأمام أو الخلف داخل اللقطة الحالية.
  Future<void> _onChangePage(
    ChangeCitiesPageEvent event,
    Emitter<CitiesState> emit,
  ) async {
    if (state is CitiesLoaded) {
      final currentState = state as CitiesLoaded;
      final pagedCities = currentState.searchQuery != null
          ? _getFilteredPagedCities(currentState.searchQuery!, event.page)
          : _getPagedCities(event.page);

      emit(currentState.copyWith(
        filteredCities: pagedCities,
        currentPage: event.page,
      ));
    }
  }

  /// Returns the slice for a given page from the full in-memory snapshot.
  ///
  /// يعيد الشريحة الخاصة بصفحة معينة من اللقطة الكاملة في الذاكرة.
  List<City> _getPagedCities(int page) {
    return _getPagedCitiesFromList(_allCities, page);
  }

  /// Slices a city list into a single page based on the configured page size.
  ///
  /// يقسّم قائمة المدن إلى صفحة واحدة بحسب حجم الصفحة المهيأ.
  List<City> _getPagedCitiesFromList(List<City> cities, int page) {
    final startIndex = (page - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;

    if (startIndex >= cities.length) {
      return [];
    }

    return cities.sublist(
      startIndex,
      endIndex > cities.length ? cities.length : endIndex,
    );
  }

  /// Paginates the subset that matches the current search query.
  ///
  /// يرقم الجزء الذي يطابق نص البحث الحالي.
  List<City> _getFilteredPagedCities(String query, int page) {
    final filteredCities = _allCities
        .where((city) =>
            city.name.toLowerCase().contains(query.toLowerCase()) ||
            city.country.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _getPagedCitiesFromList(filteredCities, page);
  }
}
