import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hggzkportal/core/error/failures.dart';
import '../repositories/nearby_places_repository.dart';

class UpdateNearbyPlaceParams extends Equatable {
  final String nearbyPlaceId;
  final Map<String, dynamic> data;
  const UpdateNearbyPlaceParams({
    required this.nearbyPlaceId,
    required this.data,
  });
  @override
  List<Object?> get props => [nearbyPlaceId, data];
}

class UpdateNearbyPlaceUseCase {
  final NearbyPlacesRepository repository;
  UpdateNearbyPlaceUseCase(this.repository);
  Future<Either<Failure, bool>> call(UpdateNearbyPlaceParams params) {
    return repository.updateNearbyPlace(params.nearbyPlaceId, params.data);
  }
}
