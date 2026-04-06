import 'package:equatable/equatable.dart';
import '../../domain/entities/nearby_place.dart';

abstract class NearbyPlacesState extends Equatable {
  const NearbyPlacesState();
  @override
  List<Object?> get props => [];
}

class NearbyPlacesInitial extends NearbyPlacesState {}

class NearbyPlacesLoading extends NearbyPlacesState {}

class NearbyPlacesLoaded extends NearbyPlacesState {
  final List<NearbyPlace> places;
  final String? selectedPropertyId;
  final String? selectedPropertyName;
  final String searchTerm;

  const NearbyPlacesLoaded({
    required this.places,
    this.selectedPropertyId,
    this.selectedPropertyName,
    this.searchTerm = '',
  });

  NearbyPlacesLoaded copyWith({
    List<NearbyPlace>? places,
    String? selectedPropertyId,
    String? selectedPropertyName,
    String? searchTerm,
  }) {
    return NearbyPlacesLoaded(
      places: places ?? this.places,
      selectedPropertyId: selectedPropertyId ?? this.selectedPropertyId,
      selectedPropertyName: selectedPropertyName ?? this.selectedPropertyName,
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }

  @override
  List<Object?> get props =>
      [places, selectedPropertyId, selectedPropertyName, searchTerm];
}

class NearbyPlacesOperationInProgress extends NearbyPlacesState {}

class NearbyPlacesOperationSuccess extends NearbyPlacesState {
  final String message;
  const NearbyPlacesOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class NearbyPlacesError extends NearbyPlacesState {
  final String message;
  const NearbyPlacesError(this.message);
  @override
  List<Object?> get props => [message];
}
