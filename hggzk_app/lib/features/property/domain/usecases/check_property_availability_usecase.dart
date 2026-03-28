import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/property_availability.dart';
import '../repositories/property_repository.dart';

/// Executes the `CheckPropertyAvailabilityUseCase` use case.
/// العربية: ينفذ حالة الاستخدام `CheckPropertyAvailabilityUseCase`.
class CheckPropertyAvailabilityUseCase
    implements UseCase<PropertyAvailability, CheckPropertyAvailabilityParams> {
  /// Keeps the repository value available to this object.
  /// العربية: يخزن القيمة `repository`.
  final PropertyRepository repository;

  /// Constructs the CheckPropertyAvailabilityUseCase value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `CheckPropertyAvailabilityUseCase`.
  CheckPropertyAvailabilityUseCase({required this.repository});

  /// Executes the main behavior exposed by this callable object.
  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, PropertyAvailability>> call(
    CheckPropertyAvailabilityParams params,
  ) async {
    return repository.checkPropertyAvailability(
      propertyId: params.propertyId,
      checkInDate: params.checkInDate,
      checkOutDate: params.checkOutDate,
      guestsCount: params.guestsCount,
    );
  }
}

/// Describes the CheckPropertyAvailabilityParams type used in the property feature.
/// العربية: يمثل `CheckPropertyAvailabilityParams`.
class CheckPropertyAvailabilityParams extends Equatable {
  /// Keeps the propertyId value available to this object.
  /// العربية: يخزن القيمة `propertyId`.
  final String propertyId;

  /// Keeps the checkInDate value available to this object.
  /// العربية: يخزن القيمة `checkInDate`.
  final DateTime checkInDate;

  /// Keeps the checkOutDate value available to this object.
  /// العربية: يخزن القيمة `checkOutDate`.
  final DateTime checkOutDate;

  /// Keeps the guestsCount value available to this object.
  /// العربية: يخزن القيمة `guestsCount`.
  final int guestsCount;

  /// Constructs the CheckPropertyAvailabilityParams value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `CheckPropertyAvailabilityParams`.
  const CheckPropertyAvailabilityParams({
    required this.propertyId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guestsCount,
  });

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props =>
      [propertyId, checkInDate, checkOutDate, guestsCount];
}
