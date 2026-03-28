import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// يعرّف الكلاس `UpdateProfileUseCase`.
/// Describes the `UpdateProfileUseCase` class.
class UpdateProfileUseCase implements UseCase<void, UpdateProfileParams> {
  /// Holds the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final AuthRepository repository;

  /// ينشئ مثيلاً من `UpdateProfileUseCase`.
  /// Builds an instance of `UpdateProfileUseCase`.
  UpdateProfileUseCase(this.repository);

  /// ينفذ العملية `call`.
  /// Runs the `call` operation.
  @override
  Future<Either<Failure, void>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      name: params.name,
      email: params.email,
      phone: params.phone,
      walletAccounts: params.walletAccounts,
      propertyId: params.propertyId,
      propertyName: params.propertyName,
      propertyAddress: params.propertyAddress,
      propertyCity: params.propertyCity,
      propertyShortDescription: params.propertyShortDescription,
      propertyDescription: params.propertyDescription,
      propertyCurrency: params.propertyCurrency,
      propertyStarRating: params.propertyStarRating,
      propertyLatitude: params.propertyLatitude,
      propertyLongitude: params.propertyLongitude,
    );
  }
}

/// يعرّف الكلاس `UpdateProfileParams`.
/// Describes the `UpdateProfileParams` class.
class UpdateProfileParams extends Equatable {
  /// Holds the `name` value.
  /// العربية: يخزن القيمة `name`.
  final String name;

  /// يخزن العضو `email`.
  /// Holds the `email` member.
  final String? email;

  /// يخزن العضو `phone`.
  /// Holds the `phone` member.
  final String? phone;

  /// يخزن العضو `walletAccounts`.
  /// Holds the `walletAccounts` member.
  final List<Map<String, dynamic>>? walletAccounts;
  // Owner property fields (optional)
  /// يخزن العضو `propertyId`.
  /// Holds the `propertyId` member.
  final String? propertyId;

  /// يخزن العضو `propertyName`.
  /// Holds the `propertyName` member.
  final String? propertyName;

  /// يخزن العضو `propertyAddress`.
  /// Holds the `propertyAddress` member.
  final String? propertyAddress;

  /// يخزن العضو `propertyCity`.
  /// Holds the `propertyCity` member.
  final String? propertyCity;

  /// يخزن العضو `propertyShortDescription`.
  /// Holds the `propertyShortDescription` member.
  final String? propertyShortDescription;

  /// يخزن العضو `propertyDescription`.
  /// Holds the `propertyDescription` member.
  final String? propertyDescription;

  /// يخزن العضو `propertyCurrency`.
  /// Holds the `propertyCurrency` member.
  final String? propertyCurrency;

  /// يخزن العضو `propertyStarRating`.
  /// Holds the `propertyStarRating` member.
  final int? propertyStarRating;

  /// يخزن العضو `propertyLatitude`.
  /// Holds the `propertyLatitude` member.
  final double? propertyLatitude;

  /// يخزن العضو `propertyLongitude`.
  /// Holds the `propertyLongitude` member.
  final double? propertyLongitude;

  /// ينشئ مثيلاً من `UpdateProfileParams`.
  /// Builds an instance of `UpdateProfileParams`.
  const UpdateProfileParams({
    required this.name,
    this.email,
    this.phone,
    this.walletAccounts,
    this.propertyId,
    this.propertyName,
    this.propertyAddress,
    this.propertyCity,
    this.propertyShortDescription,
    this.propertyDescription,
    this.propertyCurrency,
    this.propertyStarRating,
    this.propertyLatitude,
    this.propertyLongitude,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        walletAccounts,
        propertyId,
        propertyName,
        propertyAddress,
        propertyCity,
        propertyShortDescription,
        propertyDescription,
        propertyCurrency,
        propertyStarRating,
        propertyLatitude,
        propertyLongitude,
      ];
}
