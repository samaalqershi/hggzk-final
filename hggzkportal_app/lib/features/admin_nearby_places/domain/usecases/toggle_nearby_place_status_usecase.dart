import 'package:dartz/dartz.dart';
import 'package:hggzkportal/core/error/failures.dart';
import '../repositories/nearby_places_repository.dart';

class ToggleNearbyPlaceStatusUseCase {
  final NearbyPlacesRepository repository;
  ToggleNearbyPlaceStatusUseCase(this.repository);
  Future<Either<Failure, bool>> call(String nearbyPlaceId) {
    return repository.toggleNearbyPlaceStatus(nearbyPlaceId);
  }
}
