import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_response.dart';
import '../repositories/auth_repository.dart';

/// يعرّف الكلاس `CompleteOwnerProfileUseCase`.
/// Describes the `CompleteOwnerProfileUseCase` class.
class CompleteOwnerProfileUseCase
    implements UseCase<AuthResponse, CompleteOwnerProfileParams> {
  /// يخزن العضو `repository`.
  /// Holds the `repository` member.
  final AuthRepository repository;

  /// ينشئ مثيلاً من `CompleteOwnerProfileUseCase`.
  /// Builds an instance of `CompleteOwnerProfileUseCase`.
  CompleteOwnerProfileUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
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

/// يعرّف الكلاس `CompleteOwnerProfileParams`.
/// Describes the `CompleteOwnerProfileParams` class.
class CompleteOwnerProfileParams extends Equatable {
  /// Holds the `name` value.
  /// العربية: يخزن القيمة `name`.
  final String name;

  /// يخزن العضو `phone`.
  /// Holds the `phone` member.
  final String phone;

  /// يخزن العضو `propertyTypeId`.
  /// Holds the `propertyTypeId` member.
  final String propertyTypeId;

  /// يخزن العضو `propertyName`.
  /// Holds the `propertyName` member.
  final String propertyName;

  /// يخزن العضو `city`.
  /// Holds the `city` member.
  final String city;

  /// يخزن العضو `address`.
  /// Holds the `address` member.
  final String address;

  /// يخزن العضو `latitude`.
  /// Holds the `latitude` member.
  final double? latitude;

  /// يخزن العضو `longitude`.
  /// Holds the `longitude` member.
  final double? longitude;

  /// يخزن العضو `starRating`.
  /// Holds the `starRating` member.
  final int starRating;

  /// يخزن العضو `description`.
  /// Holds the `description` member.
  final String? description;

  /// يخزن العضو `currency`.
  /// Holds the `currency` member.
  final String? currency;

  /// يخزن العضو `walletAccounts`.
  /// Holds the `walletAccounts` member.
  final List<Map<String, dynamic>>? walletAccounts;

  /// ينشئ مثيلاً من `CompleteOwnerProfileParams`.
  /// Builds an instance of `CompleteOwnerProfileParams`.
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

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
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
