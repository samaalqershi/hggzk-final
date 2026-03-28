import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/property_repository.dart';

/// Executes the `AddToFavoritesUseCase` use case.
/// العربية: ينفذ حالة الاستخدام `AddToFavoritesUseCase`.
class AddToFavoritesUseCase implements UseCase<bool, AddToFavoritesParams> {
  /// Keeps the repository value available to this object.
  /// العربية: يخزن القيمة `repository`.
  final PropertyRepository repository;

  /// Constructs the AddToFavoritesUseCase value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `AddToFavoritesUseCase`.
  AddToFavoritesUseCase({required this.repository});

  /// Executes the main behavior exposed by this callable object.
  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, bool>> call(AddToFavoritesParams params) async {
    return await repository.addToFavorites(
      propertyId: params.propertyId,
      userId: params.userId,
      notes: params.notes,
      desiredVisitDate: params.desiredVisitDate,
      expectedBudget: params.expectedBudget,
      currency: params.currency,
    );
  }
}

/// Describes the AddToFavoritesParams type used in the property feature.
/// العربية: يمثل `AddToFavoritesParams`.
class AddToFavoritesParams extends Equatable {
  /// Keeps the propertyId value available to this object.
  /// العربية: يخزن القيمة `propertyId`.
  final String propertyId;

  /// Keeps the userId value available to this object.
  /// العربية: يخزن القيمة `userId`.
  final String userId;

  /// Keeps the notes value available to this object.
  /// العربية: يخزن القيمة `notes`.
  final String? notes;

  /// Keeps the desiredVisitDate value available to this object.
  /// العربية: يخزن القيمة `desiredVisitDate`.
  final DateTime? desiredVisitDate;

  /// Keeps the expectedBudget value available to this object.
  /// العربية: يخزن القيمة `expectedBudget`.
  final double? expectedBudget;

  /// Keeps the currency value available to this object.
  /// العربية: يخزن القيمة `currency`.
  final String currency;

  /// Constructs the AddToFavoritesParams value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `AddToFavoritesParams`.
  const AddToFavoritesParams({
    required this.propertyId,
    required this.userId,
    this.notes,
    this.desiredVisitDate,
    this.expectedBudget,
    this.currency = 'YER',
  });

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [
        propertyId,
        userId,
        notes,
        desiredVisitDate,
        expectedBudget,
        currency,
      ];
}
