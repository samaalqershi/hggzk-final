import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/paginated_result.dart';
import '../../domain/entities/amenity.dart';
import '../../domain/usecases/create_amenity_usecase.dart';
import '../../domain/usecases/update_amenity_usecase.dart';
import '../../domain/usecases/delete_amenity_usecase.dart';
import '../../domain/usecases/get_all_amenities_usecase.dart';
import '../../domain/usecases/assign_amenity_to_property_usecase.dart';
import '../../domain/repositories/amenities_repository.dart';
import 'amenities_event.dart';
import 'amenities_state.dart';

/// Coordinates amenity loading, CRUD operations, assignment flows, and local UI filters.
/// ينسق تحميل المرافق وعمليات الإنشاء والتعديل والحذف، إضافة إلى الإسناد وفلاتر الواجهة.
class AmenitiesBloc extends Bloc<AmenitiesEvent, AmenitiesState> {
  /// Creates a new amenity in the backend.
  /// ينشئ مرفقًا جديدًا في الخادم.
  final CreateAmenityUseCase createAmenityUseCase;

  /// Updates an existing amenity with new values.
  /// يحدّث المرفق الحالي بقيم جديدة.
  final UpdateAmenityUseCase updateAmenityUseCase;

  /// Deletes the selected amenity.
  /// يحذف المرفق المحدد.
  final DeleteAmenityUseCase deleteAmenityUseCase;

  /// Loads paginated amenities using the active search and filter context.
  /// يجلب المرافق بشكل مُصفّح مع سياق البحث والفلاتر الحالي.
  final GetAllAmenitiesUseCase getAllAmenitiesUseCase;

  /// Assigns an amenity to a property or property-type target.
  /// يربط المرفق بعقار أو بنوع عقار مستهدف.
  final AssignAmenityToPropertyUseCase assignAmenityToPropertyUseCase;

  /// Repository used for stats, toggles, and other amenity-side queries.
  /// مستودع بيانات يُستخدم للإحصائيات والعمليات والطلبات المساندة للمرافق.
  final AmenitiesRepository repository;

  /// Cached search term so refreshes preserve the same query.
  /// نص البحث المخزن حتى تحتفظ التحديثات بنفس الاستعلام.
  String? _currentSearchTerm;

  /// Cached filter that limits results to assigned amenities only.
  /// فلتر مخزن يقصر النتائج على المرافق المعيّنة فقط.
  bool? _currentIsAssigned;

  /// Cached filter that limits results to free amenities only.
  /// فلتر مخزن يقصر النتائج على المرافق المجانية فقط.
  bool? _currentIsFree;

  /// Current page number used for refresh and load-more behavior.
  /// رقم الصفحة الحالي المستخدم في التحديث وتحميل المزيد.
  int _currentPageNumber = 1;

  /// Current page size used for pagination requests.
  /// حجم الصفحة الحالي المستخدم في طلبات التصفح.
  int _currentPageSize = 10;

  /// Builds the bloc with all amenity use cases and repository dependencies.
  /// ينشئ البلوك مع جميع اعتماديات حالات الاستخدام والمستودع الخاصة بالمرافق.
  AmenitiesBloc({
    required this.createAmenityUseCase,
    required this.updateAmenityUseCase,
    required this.deleteAmenityUseCase,
    required this.getAllAmenitiesUseCase,
    required this.assignAmenityToPropertyUseCase,
    required this.repository,
  }) : super(AmenitiesInitial()) {
    on<LoadAmenitiesEvent>(_onLoadAmenities);
    on<CreateAmenityEvent>(_onCreateAmenity);
    on<UpdateAmenityEvent>(_onUpdateAmenity);
    on<DeleteAmenityEvent>(_onDeleteAmenity);
    on<ToggleAmenityStatusEvent>(_onToggleAmenityStatus);
    on<AssignAmenityToPropertyEvent>(_onAssignAmenityToProperty);
    on<AssignAmenityToPropertyTypeEvent>(_onAssignAmenityToPropertyType);
    on<LoadAmenityStatsEvent>(_onLoadAmenityStats);
    on<SearchAmenitiesEvent>(_onSearchAmenities);
    on<SelectAmenityEvent>(_onSelectAmenity);
    on<DeselectAmenityEvent>(_onDeselectAmenity);
    on<LoadPopularAmenitiesEvent>(_onLoadPopularAmenities);
    on<RefreshAmenitiesEvent>(_onRefreshAmenities);
    on<ChangePageEvent>(_onChangePage);
    on<ChangePageSizeEvent>(_onChangePageSize);
    on<ApplyFiltersEvent>(_onApplyFilters);
    on<ClearFiltersEvent>(_onClearFilters);
  }

  /// Assigns an amenity to a property type and emits a success or failure state.
  /// يربط المرفق بنوع عقار ويصدر حالة نجاح أو فشل.
  Future<void> _onAssignAmenityToPropertyType(
    AssignAmenityToPropertyTypeEvent event,
    Emitter<AmenitiesState> emit,
  ) async {
    emit(AmenityOperationInProgress(
      operation: 'assign_property_type',
      amenityId: event.amenityId,
    ));

    final result = await repository.assignAmenityToPropertyType(
      amenityId: event.amenityId,
      propertyTypeId: event.propertyTypeId,
      isDefault: event.isDefault,
    );

    result.fold(
      (failure) => emit(AmenityOperationFailure(
        message: failure.message,
        amenityId: event.amenityId,
      )),
      (_) => emit(AmenityOperationSuccess(
        message: 'تم ربط المرفق بنوع العقار بنجاح',
        amenityId: event.amenityId,
      )),
    );
  }

  /// Loads amenity pages while preserving the current search and filter context.
  /// يحمّل صفحات المرافق مع الحفاظ على سياق البحث والفلاتر الحالي.
  Future<void> _onLoadAmenities(
    LoadAmenitiesEvent event,
    Emitter<AmenitiesState> emit,
  ) async {
    // حفظ قيم البحث والفلاتر
    _currentSearchTerm = event.searchTerm;
    _currentIsAssigned = event.isAssigned;
    _currentIsFree = event.isFree;
    _currentPageNumber = event.pageNumber;
    _currentPageSize = event.pageSize;

    final bool isLoadMore = state is AmenitiesLoaded && event.pageNumber > 1;
    if (!isLoadMore) {
      emit(const AmenitiesLoading());
    }

    final result = await getAllAmenitiesUseCase(
      GetAllAmenitiesParams(
        pageNumber: event.pageNumber,
        pageSize: event.pageSize,
        searchTerm: event.searchTerm,
        propertyId: event.propertyId,
        isAssigned: event.isAssigned,
        isFree: event.isFree,
      ),
    );

    await result.fold(
      (failure) async {
        emit(AmenitiesError(message: failure.message));
      },
      (page) async {
        final popularResult =
            !isLoadMore ? await repository.getPopularAmenities() : null;
        final popularAmenities = popularResult == null
            ? (state is AmenitiesLoaded
                ? (state as AmenitiesLoaded).popularAmenities
                : <Amenity>[])
            : popularResult.fold((_) => <Amenity>[], (amenities) => amenities);

        final statsResult =
            !isLoadMore ? await repository.getAmenityStats() : null;
        final stats = statsResult == null
            ? (state is AmenitiesLoaded
                ? (state as AmenitiesLoaded).stats
                : null)
            : statsResult.fold((_) => null, (s) => s);

        if (!emit.isDone) {
          if (isLoadMore && state is AmenitiesLoaded) {
            final current = state as AmenitiesLoaded;
            final mergedItems = <Amenity>[];
            final existing = current.amenities.items;
            mergedItems.addAll(existing);
            for (final a in page.items) {
              if (!mergedItems.any((x) => x.id == a.id)) mergedItems.add(a);
            }
            final merged = PaginatedResult<Amenity>(
              items: mergedItems,
              pageNumber: page.pageNumber,
              pageSize: page.pageSize,
              totalCount: page.totalCount,
            );
            emit(current.copyWith(
              amenities: merged,
              searchTerm: event.searchTerm,
              isAssigned: event.isAssigned,
              isFree: event.isFree,
              popularAmenities: popularAmenities,
              stats: stats,
            ));
          } else {
            emit(AmenitiesLoaded(
              amenities: page,
              searchTerm: event.searchTerm,
              isAssigned: event.isAssigned,
              isFree: event.isFree,
              popularAmenities: popularAmenities,
              stats: stats,
            ));
          }
        }
      },
    );
  }

  /// Creates a new amenity and then refreshes the current list context.
  /// ينشئ مرفقًا جديدًا ثم يحدّث سياق القائمة الحالي.
  Future<void> _onCreateAmenity(
    CreateAmenityEvent event,
    Emitter<AmenitiesState> emit,
  ) async {
    emit(const AmenityOperationInProgress(operation: 'create'));

    final result = await createAmenityUseCase(
      CreateAmenityParams(
        name: event.name,
        description: event.description,
        icon: event.icon,
        propertyTypeId: event.propertyTypeId,
        isDefaultForType: event.isDefaultForType,
      ),
    );

    result.fold(
      (failure) => emit(AmenityOperationFailure(message: failure.message)),
      (amenityId) {
        emit(AmenityOperationSuccess(
          message: 'تم إنشاء المرفق بنجاح',
          amenityId: amenityId,
        ));
        // إعادة تحميل القائمة
        if (!isClosed) {
          add(LoadAmenitiesEvent(
            pageNumber: _currentPageNumber,
            pageSize: _currentPageSize,
            searchTerm: _currentSearchTerm,
            isAssigned: _currentIsAssigned,
            isFree: _currentIsFree,
          ));
        }
      },
    );
  }

  /// Updates an amenity and refreshes the list with the latest filters.
  /// يحدّث مرفقًا ثم يعيد تحميل القائمة بنفس الفلاتر الحالية.
  Future<void> _onUpdateAmenity(
    UpdateAmenityEvent event,
    Emitter<AmenitiesState> emit,
  ) async {
    emit(AmenityOperationInProgress(
      operation: 'update',
      amenityId: event.amenityId,
    ));

    final result = await updateAmenityUseCase(
      UpdateAmenityParams(
        amenityId: event.amenityId,
        name: event.name,
        description: event.description,
        icon: event.icon,
      ),
    );

    result.fold(
      (failure) => emit(AmenityOperationFailure(
        message: failure.message,
        amenityId: event.amenityId,
      )),
      (_) {
        emit(AmenityOperationSuccess(
          message: 'تم تحديث المرفق بنجاح',
          amenityId: event.amenityId,
        ));
        // إعادة تحميل القائمة
        if (!isClosed) {
          add(LoadAmenitiesEvent(
            pageNumber: _currentPageNumber,
            pageSize: _currentPageSize,
            searchTerm: _currentSearchTerm,
            isAssigned: _currentIsAssigned,
            isFree: _currentIsFree,
          ));
        }
      },
    );
  }

  /// Deletes an amenity and reloads the active list state afterward.
  /// يحذف مرفقًا ثم يعيد تحميل حالة القائمة النشطة بعد ذلك.
  Future<void> _onDeleteAmenity(
    DeleteAmenityEvent event,
    Emitter<AmenitiesState> emit,
  ) async {
    emit(AmenityOperationInProgress(
      operation: 'delete',
      amenityId: event.amenityId,
    ));

    final result = await deleteAmenityUseCase(event.amenityId);

    result.fold(
      (failure) => emit(AmenityOperationFailure(
        message: failure.message,
        amenityId: event.amenityId,
      )),
      (_) {
        emit(AmenityOperationSuccess(
          message: 'تم حذف المرفق بنجاح',
          amenityId: event.amenityId,
        ));
        // إعادة تحميل القائمة
        if (!isClosed) {
          add(LoadAmenitiesEvent(
            pageNumber: _currentPageNumber,
            pageSize: _currentPageSize,
            searchTerm: _currentSearchTerm,
            isAssigned: _currentIsAssigned,
            isFree: _currentIsFree,
          ));
        }
      },
    );
  }

  /// Toggles the amenity status and refreshes the current list after completion.
  /// يبدّل حالة المرفق ثم يحدّث القائمة الحالية بعد الانتهاء.
  Future<void> _onToggleAmenityStatus(
    ToggleAmenityStatusEvent event,
    Emitter<AmenitiesState> emit,
  ) async {
    emit(AmenityOperationInProgress(
      operation: 'toggle',
      amenityId: event.amenityId,
    ));

    final result = await repository.toggleAmenityStatus(event.amenityId);

    result.fold(
      (failure) => emit(AmenityOperationFailure(
        message: failure.message,
        amenityId: event.amenityId,
      )),
      (_) {
        emit(AmenityOperationSuccess(
          message: 'تم تغيير حالة المرفق بنجاح',
          amenityId: event.amenityId,
        ));
        // إعادة تحميل القائمة
        if (!isClosed) {
          add(LoadAmenitiesEvent(
            pageNumber: _currentPageNumber,
            pageSize: _currentPageSize,
            searchTerm: _currentSearchTerm,
            isAssigned: _currentIsAssigned,
            isFree: _currentIsFree,
          ));
        }
      },
    );
  }

  /// Assigns an amenity to a property and reports the operation result.
  /// يربط مرفقًا بعقار ويبلّغ عن نتيجة العملية.
  Future<void> _onAssignAmenityToProperty(
    AssignAmenityToPropertyEvent event,
    Emitter<AmenitiesState> emit,
  ) async {
    emit(AmenityOperationInProgress(
      operation: 'assign',
      amenityId: event.amenityId,
    ));

    final result = await assignAmenityToPropertyUseCase(
      AssignAmenityParams(
        amenityId: event.amenityId,
        propertyId: event.propertyId,
        isAvailable: event.isAvailable,
        extraCost: event.extraCost,
        description: event.description,
      ),
    );

    result.fold(
      (failure) => emit(AmenityOperationFailure(
        message: failure.message,
        amenityId: event.amenityId,
      )),
      (_) {
        emit(AmenityOperationSuccess(
          message: 'تم إسناد المرفق للعقار بنجاح',
          amenityId: event.amenityId,
        ));
      },
    );
  }

  /// Loads amenity statistics and merges them into the current loaded state.
  /// يحمّل إحصائيات المرافق ويدمجها في حالة التحميل الحالية.
  Future<void> _onLoadAmenityStats(
    LoadAmenityStatsEvent event,
    Emitter<AmenitiesState> emit,
  ) async {
    if (state is AmenitiesLoaded) {
      final currentState = state as AmenitiesLoaded;
      final result = await repository.getAmenityStats();

      result.fold(
        (_) {}, // تجاهل الأخطاء
        (stats) {
          emit(currentState.copyWith(stats: stats));
        },
      );
    }
  }

  /// Restarts paging from page one using the new search term.
  /// يعيد التصفح من الصفحة الأولى باستخدام نص البحث الجديد.
  Future<void> _onSearchAmenities(
    SearchAmenitiesEvent event,
    Emitter<AmenitiesState> emit,
  ) async {
    add(LoadAmenitiesEvent(
      pageNumber: 1,
      pageSize: _currentPageSize,
      searchTerm: event.searchTerm,
      isAssigned: _currentIsAssigned,
      isFree: _currentIsFree,
    ));
  }

  /// Marks one amenity as selected so the UI can show its details.
  /// يحدد مرفقًا واحدًا كعنصر مختار حتى تعرض الواجهة تفاصيله.
  Future<void> _onSelectAmenity(
    SelectAmenityEvent event,
    Emitter<AmenitiesState> emit,
  ) async {
    if (state is AmenitiesLoaded) {
      final currentState = state as AmenitiesLoaded;
      final selectedAmenity = currentState.amenities.items
          .firstWhere((amenity) => amenity.id == event.amenityId);
      emit(currentState.copyWith(selectedAmenity: selectedAmenity));
    }
  }

  /// Clears the current amenity selection from the loaded state.
  /// يمسح اختيار المرفق الحالي من حالة التحميل.
  Future<void> _onDeselectAmenity(
    DeselectAmenityEvent event,
    Emitter<AmenitiesState> emit,
  ) async {
    if (state is AmenitiesLoaded) {
      final currentState = state as AmenitiesLoaded;
      emit(currentState.copyWith(clearSelectedAmenity: true));
    }
  }

  /// Loads the most popular amenities and stores them beside the current list.
  /// يحمّل المرافق الأكثر شيوعًا ويخزنها بجانب القائمة الحالية.
  Future<void> _onLoadPopularAmenities(
    LoadPopularAmenitiesEvent event,
    Emitter<AmenitiesState> emit,
  ) async {
    if (state is AmenitiesLoaded) {
      final currentState = state as AmenitiesLoaded;
      final result = await repository.getPopularAmenities(limit: event.limit);

      result.fold(
        (_) {}, // تجاهل الأخطاء
        (amenities) {
          emit(currentState.copyWith(popularAmenities: amenities));
        },
      );
    }
  }

  /// Replays the last known query, filters, and pagination settings.
  /// يعيد تنفيذ آخر استعلام معروف مع الفلاتر وإعدادات التصفح نفسها.
  Future<void> _onRefreshAmenities(
    RefreshAmenitiesEvent event,
    Emitter<AmenitiesState> emit,
  ) async {
    add(LoadAmenitiesEvent(
      pageNumber: _currentPageNumber,
      pageSize: _currentPageSize,
      searchTerm: _currentSearchTerm,
      isAssigned: _currentIsAssigned,
      isFree: _currentIsFree,
    ));
  }

  /// Moves to another page while keeping the current search and filters.
  /// ينتقل إلى صفحة أخرى مع الحفاظ على البحث والفلاتر الحالية.
  Future<void> _onChangePage(
    ChangePageEvent event,
    Emitter<AmenitiesState> emit,
  ) async {
    add(LoadAmenitiesEvent(
      pageNumber: event.pageNumber,
      pageSize: _currentPageSize,
      searchTerm: _currentSearchTerm,
      isAssigned: _currentIsAssigned,
      isFree: _currentIsFree,
    ));
  }

  /// Changes the page size and restarts the list from the first page.
  /// يغيّر حجم الصفحة ويعيد بدء القائمة من الصفحة الأولى.
  Future<void> _onChangePageSize(
    ChangePageSizeEvent event,
    Emitter<AmenitiesState> emit,
  ) async {
    add(LoadAmenitiesEvent(
      pageNumber: 1,
      pageSize: event.pageSize,
      searchTerm: _currentSearchTerm,
      isAssigned: _currentIsAssigned,
      isFree: _currentIsFree,
    ));
  }

  /// Applies the selected filters and reloads from page one.
  /// يطبّق الفلاتر المختارة ويعيد التحميل من الصفحة الأولى.
  Future<void> _onApplyFilters(
    ApplyFiltersEvent event,
    Emitter<AmenitiesState> emit,
  ) async {
    add(LoadAmenitiesEvent(
      pageNumber: 1,
      pageSize: _currentPageSize,
      searchTerm: _currentSearchTerm,
      isAssigned: event.isAssigned,
      isFree: event.isFree,
    ));
  }

  /// Clears filters and reloads the first page without search constraints.
  /// يمسح الفلاتر ويعيد تحميل الصفحة الأولى من دون قيود البحث.
  Future<void> _onClearFilters(
    ClearFiltersEvent event,
    Emitter<AmenitiesState> emit,
  ) async {
    add(LoadAmenitiesEvent(
      pageNumber: 1,
      pageSize: _currentPageSize,
      searchTerm: null,
      isAssigned: null,
      isFree: null,
    ));
  }
}
