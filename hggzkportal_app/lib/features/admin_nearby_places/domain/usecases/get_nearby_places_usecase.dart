import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hggzkportal/core/error/failures.dart';
import '../entities/nearby_place.dart';
import '../repositories/nearby_places_repository.dart';

class GetNearbyPlacesParams extends Equatable {
  final String? propertyId;
  final String? searchTerm;
  final bool? isActive;

  const GetNearbyPlacesParams({
    this.propertyId,
    this.searchTerm,
    this.isActive,
  });

  @override
  List<Object?> get props => [propertyId, searchTerm, isActive];
}

class GetNearbyPlacesUseCase {
  final NearbyPlacesRepository repository;

  GetNearbyPlacesUseCase(this.repository);

  Future<Either<Failure, List<NearbyPlace>>> call(
      GetNearbyPlacesParams params) {
    return repository.getNearbyPlaces(
      propertyId: params.propertyId,
      searchTerm: params.searchTerm,
      isActive: params.isActive,
    );
  }
}
