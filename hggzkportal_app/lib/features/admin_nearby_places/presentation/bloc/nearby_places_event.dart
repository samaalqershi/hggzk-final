import 'package:equatable/equatable.dart';
import '../../domain/entities/nearby_place.dart';

abstract class NearbyPlacesEvent extends Equatable {
  const NearbyPlacesEvent();
  @override
  List<Object?> get props => [];
}

class LoadNearbyPlacesEvent extends NearbyPlacesEvent {
  final String? propertyId;
  final String? searchTerm;
  final bool? isActive;
  const LoadNearbyPlacesEvent(
      {this.propertyId, this.searchTerm, this.isActive});
  @override
  List<Object?> get props => [propertyId, searchTerm, isActive];
}

class CreateNearbyPlaceEvent extends NearbyPlacesEvent {
  final Map<String, dynamic> data;
  const CreateNearbyPlaceEvent(this.data);
  @override
  List<Object?> get props => [data];
}

class UpdateNearbyPlaceEvent extends NearbyPlacesEvent {
  final String nearbyPlaceId;
  final Map<String, dynamic> data;
  const UpdateNearbyPlaceEvent(this.nearbyPlaceId, this.data);
  @override
  List<Object?> get props => [nearbyPlaceId, data];
}

class DeleteNearbyPlaceEvent extends NearbyPlacesEvent {
  final String nearbyPlaceId;
  const DeleteNearbyPlaceEvent(this.nearbyPlaceId);
  @override
  List<Object?> get props => [nearbyPlaceId];
}

class ToggleNearbyPlaceStatusEvent extends NearbyPlacesEvent {
  final String nearbyPlaceId;
  const ToggleNearbyPlaceStatusEvent(this.nearbyPlaceId);
  @override
  List<Object?> get props => [nearbyPlaceId];
}

class SelectPropertyForNearbyPlacesEvent extends NearbyPlacesEvent {
  final String? propertyId;
  final String? propertyName;
  const SelectPropertyForNearbyPlacesEvent(
      {this.propertyId, this.propertyName});
  @override
  List<Object?> get props => [propertyId, propertyName];
}

class StartEditingNearbyPlaceEvent extends NearbyPlacesEvent {
  final NearbyPlace nearbyPlace;
  const StartEditingNearbyPlaceEvent(this.nearbyPlace);
  @override
  List<Object?> get props => [nearbyPlace];
}
