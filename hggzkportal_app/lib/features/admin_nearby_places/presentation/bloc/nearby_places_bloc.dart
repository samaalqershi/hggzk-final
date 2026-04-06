import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_nearby_place_usecase.dart';
import '../../domain/usecases/delete_nearby_place_usecase.dart';
import '../../domain/usecases/get_nearby_places_usecase.dart';
import '../../domain/usecases/toggle_nearby_place_status_usecase.dart';
import '../../domain/usecases/update_nearby_place_usecase.dart';
import 'nearby_places_event.dart';
import 'nearby_places_state.dart';

class NearbyPlacesBloc extends Bloc<NearbyPlacesEvent, NearbyPlacesState> {
  final GetNearbyPlacesUseCase getNearbyPlaces;
  final CreateNearbyPlaceUseCase createNearbyPlace;
  final UpdateNearbyPlaceUseCase updateNearbyPlace;
  final DeleteNearbyPlaceUseCase deleteNearbyPlace;
  final ToggleNearbyPlaceStatusUseCase toggleNearbyPlaceStatus;

  String? _selectedPropertyId;
  String? _selectedPropertyName;
  String _searchTerm = '';

  NearbyPlacesBloc({
    required this.getNearbyPlaces,
    required this.createNearbyPlace,
    required this.updateNearbyPlace,
    required this.deleteNearbyPlace,
    required this.toggleNearbyPlaceStatus,
  }) : super(NearbyPlacesInitial()) {
    on<LoadNearbyPlacesEvent>(_onLoadNearbyPlaces);
    on<CreateNearbyPlaceEvent>(_onCreateNearbyPlace);
    on<UpdateNearbyPlaceEvent>(_onUpdateNearbyPlace);
    on<DeleteNearbyPlaceEvent>(_onDeleteNearbyPlace);
    on<ToggleNearbyPlaceStatusEvent>(_onToggleNearbyPlaceStatus);
    on<SelectPropertyForNearbyPlacesEvent>(_onSelectProperty);
  }

  Future<void> _onLoadNearbyPlaces(
    LoadNearbyPlacesEvent event,
    Emitter<NearbyPlacesState> emit,
  ) async {
    if (event.propertyId != null) {
      _selectedPropertyId = event.propertyId;
    }
    if (event.searchTerm != null) {
      _searchTerm = event.searchTerm!;
    }

    emit(NearbyPlacesLoading());
    final result = await getNearbyPlaces(
      GetNearbyPlacesParams(
        propertyId: _selectedPropertyId,
        searchTerm: _searchTerm.isEmpty ? null : _searchTerm,
        isActive: event.isActive,
      ),
    );

    result.fold(
      (failure) => emit(NearbyPlacesError(failure.message)),
      (places) => emit(NearbyPlacesLoaded(
        places: places,
        selectedPropertyId: _selectedPropertyId,
        selectedPropertyName: _selectedPropertyName,
        searchTerm: _searchTerm,
      )),
    );
  }

  Future<void> _onCreateNearbyPlace(
    CreateNearbyPlaceEvent event,
    Emitter<NearbyPlacesState> emit,
  ) async {
    emit(NearbyPlacesOperationInProgress());
    final result = await createNearbyPlace(CreateNearbyPlaceParams(event.data));
    result.fold(
      (failure) => emit(NearbyPlacesError(failure.message)),
      (_) {
        emit(
            const NearbyPlacesOperationSuccess('تم إنشاء المكان القريب بنجاح'));
        add(LoadNearbyPlacesEvent(
            propertyId: _selectedPropertyId, searchTerm: _searchTerm));
      },
    );
  }

  Future<void> _onUpdateNearbyPlace(
    UpdateNearbyPlaceEvent event,
    Emitter<NearbyPlacesState> emit,
  ) async {
    emit(NearbyPlacesOperationInProgress());
    final result = await updateNearbyPlace(UpdateNearbyPlaceParams(
      nearbyPlaceId: event.nearbyPlaceId,
      data: event.data,
    ));
    result.fold(
      (failure) => emit(NearbyPlacesError(failure.message)),
      (_) {
        emit(
            const NearbyPlacesOperationSuccess('تم تحديث المكان القريب بنجاح'));
        add(LoadNearbyPlacesEvent(
            propertyId: _selectedPropertyId, searchTerm: _searchTerm));
      },
    );
  }

  Future<void> _onDeleteNearbyPlace(
    DeleteNearbyPlaceEvent event,
    Emitter<NearbyPlacesState> emit,
  ) async {
    emit(NearbyPlacesOperationInProgress());
    final result = await deleteNearbyPlace(event.nearbyPlaceId);
    result.fold(
      (failure) => emit(NearbyPlacesError(failure.message)),
      (_) {
        emit(const NearbyPlacesOperationSuccess('تم حذف المكان القريب بنجاح'));
        add(LoadNearbyPlacesEvent(
            propertyId: _selectedPropertyId, searchTerm: _searchTerm));
      },
    );
  }

  Future<void> _onToggleNearbyPlaceStatus(
    ToggleNearbyPlaceStatusEvent event,
    Emitter<NearbyPlacesState> emit,
  ) async {
    emit(NearbyPlacesOperationInProgress());
    final result = await toggleNearbyPlaceStatus(event.nearbyPlaceId);
    result.fold(
      (failure) => emit(NearbyPlacesError(failure.message)),
      (_) {
        emit(const NearbyPlacesOperationSuccess('تم تحديث حالة المكان القريب'));
        add(LoadNearbyPlacesEvent(
            propertyId: _selectedPropertyId, searchTerm: _searchTerm));
      },
    );
  }

  Future<void> _onSelectProperty(
    SelectPropertyForNearbyPlacesEvent event,
    Emitter<NearbyPlacesState> emit,
  ) async {
    _selectedPropertyId = event.propertyId;
    _selectedPropertyName = event.propertyName;
    add(LoadNearbyPlacesEvent(
        propertyId: event.propertyId, searchTerm: _searchTerm));
  }
}
