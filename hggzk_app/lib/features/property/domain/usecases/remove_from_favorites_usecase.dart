import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/property_repository.dart';

/// Executes the `RemoveFromFavoritesUseCase` use case.
/// العربية: ينفذ حالة الاستخدام `RemoveFromFavoritesUseCase`.
class RemoveFromFavoritesUseCase
    implements UseCase<bool, RemoveFromFavoritesParams> {
  /// Keeps the repository value available to this object.
  /// العربية: يخزن القيمة `repository`.
  final PropertyRepository repository;

  /// Constructs the RemoveFromFavoritesUseCase value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `RemoveFromFavoritesUseCase`.
  RemoveFromFavoritesUseCase({required this.repository});

  /// Executes the main behavior exposed by this callable object.
  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, bool>> call(RemoveFromFavoritesParams params) async {
    return await repository.removeFromFavorites(
      propertyId: params.propertyId,
      userId: params.userId,
    );
  }
}

/// Describes the RemoveFromFavoritesParams type used in the property feature.
/// العربية: يمثل `RemoveFromFavoritesParams`.
class RemoveFromFavoritesParams extends Equatable {
  /// Keeps the propertyId value available to this object.
  /// العربية: يخزن القيمة `propertyId`.
  final String propertyId;

  /// Keeps the userId value available to this object.
  /// العربية: يخزن القيمة `userId`.
  final String userId;

  /// Constructs the RemoveFromFavoritesParams value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `RemoveFromFavoritesParams`.
  const RemoveFromFavoritesParams({
    required this.propertyId,
    required this.userId,
  });

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [propertyId, userId];
}
