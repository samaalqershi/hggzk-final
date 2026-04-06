import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hggzkportal/core/error/failures.dart';
import '../repositories/nearby_places_repository.dart';

class CreateNearbyPlaceParams extends Equatable {
  final Map<String, dynamic> data;
  const CreateNearbyPlaceParams(this.data);
  @override
  List<Object?> get props => [data];
}

class CreateNearbyPlaceUseCase {
  final NearbyPlacesRepository repository;
  CreateNearbyPlaceUseCase(this.repository);
  Future<Either<Failure, String>> call(CreateNearbyPlaceParams params) {
    return repository.createNearbyPlace(params.data);
  }
}
