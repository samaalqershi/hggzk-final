import 'package:dartz/dartz.dart';
import 'package:hggzkportal/core/error/failures.dart';
import '../entities/nearby_place.dart';

abstract class NearbyPlacesRepository {
  Future<Either<Failure, List<NearbyPlace>>> getNearbyPlaces({
    String? propertyId,
    String? searchTerm,
    bool? isActive,
  });

  Future<Either<Failure, NearbyPlace>> getNearbyPlaceById(String nearbyPlaceId);

  Future<Either<Failure, String>> createNearbyPlace(Map<String, dynamic> data);

  Future<Either<Failure, bool>> updateNearbyPlace(
      String nearbyPlaceId, Map<String, dynamic> data);

  Future<Either<Failure, bool>> deleteNearbyPlace(String nearbyPlaceId);

  Future<Either<Failure, bool>> toggleNearbyPlaceStatus(String nearbyPlaceId);
}
