// lib/features/admin_properties/presentation/bloc/amenities/amenities_state.dart

part of 'amenities_bloc.dart';

abstract class AmenitiesState extends Equatable {
  /// العربية: ينشئ مثيلًا جديدًا من `AmenitiesState`.
  const AmenitiesState();
  @override
  List<Object?> get props => [];
}

class AmenitiesInitial extends AmenitiesState {}

class AmenitiesLoading extends AmenitiesState {}

class AmenitiesLoaded extends AmenitiesState {
  /// العربية: يخزن القيمة `amenities`.
  final List<Amenity> amenities;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;
  const AmenitiesLoaded({
    required this.amenities,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });
  @override
  List<Object> get props => [
        amenities,
        totalCount,
        currentPage,
        totalPages,
        hasNextPage,
        hasPreviousPage,
      ];
}

class AmenitiesError extends AmenitiesState {
  /// العربية: يخزن القيمة `message`.
  final String message;
  const AmenitiesError(this.message);
  @override
  List<Object> get props => [message];
}

class AmenityCreating extends AmenitiesState {}

class AmenityCreated extends AmenitiesState {
  /// العربية: يخزن القيمة `amenityId`.
  final String amenityId;
  const AmenityCreated(this.amenityId);
  @override
  List<Object> get props => [amenityId];
}

class AmenityUpdating extends AmenitiesState {}

class AmenityUpdated extends AmenitiesState {}

class AmenityDeleting extends AmenitiesState {}

class AmenityDeleted extends AmenitiesState {}

class AmenityAssigning extends AmenitiesState {}

class AmenityAssigned extends AmenitiesState {}

class AmenityUnassigning extends AmenitiesState {}

class AmenityUnassigned extends AmenitiesState {}
