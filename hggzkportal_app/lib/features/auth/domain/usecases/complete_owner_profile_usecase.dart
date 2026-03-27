import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_response.dart';
import '../repositories/auth_repository.dart';

class CompleteOwnerProfileUseCase
    implements UseCase<AuthResponse, CompleteOwnerProfileParams> {
  final AuthRepository repository;

  CompleteOwnerProfileUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResponse>> call(
    CompleteOwnerProfileParams params,
  ) async {
    return await repository.completeOwnerProfile(
      name: params.name,
      phone: params.phone,
      propertyTypeId: params.propertyTypeId,
      propertyName: params.propertyName,
      city: params.city,
      address: params.address,
      latitude: params.latitude,
      longitude: params.longitude,
      starRating: params.starRating,
      description: params.description,
      currency: params.currency,
      walletAccounts: params.walletAccounts,
    );
  }
}

class CompleteOwnerProfileParams extends Equatable {
  final String name;
  final String phone;
  final String propertyTypeId;
  final String propertyName;
  final String city;
  final String address;
  final double? latitude;
  final double? longitude;
  final int starRating;
  final String? description;
  final String? currency;
  final List<Map<String, dynamic>>? walletAccounts;

  const CompleteOwnerProfileParams({
    required this.name,
    required this.phone,
    required this.propertyTypeId,
    required this.propertyName,
    required this.city,
    required this.address,
    this.latitude,
    this.longitude,
    this.starRating = 3,
    this.description,
    this.currency,
    this.walletAccounts,
  });

  @override
  List<Object?> get props => [
        name,
        phone,
        propertyTypeId,
        propertyName,
        city,
        address,
        latitude,
        longitude,
        starRating,
        description,
        currency,
        walletAccounts,
      ];
}
