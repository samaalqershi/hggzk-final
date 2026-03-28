import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/favorites_repository.dart';

/// Describes `RemoveFromFavoritesParams`.
/// العربية: يمثل `RemoveFromFavoritesParams`.
class RemoveFromFavoritesParams {
  /// Keeps the `propertyId` value.
  /// العربية: يخزن القيمة `propertyId`.
  final String propertyId;

  /// Keeps the `userId` value.
  /// العربية: يخزن القيمة `userId`.
  final String userId;

  /// Builds a new `RemoveFromFavoritesParams` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `RemoveFromFavoritesParams`.
  RemoveFromFavoritesParams({
    required this.propertyId,
    required this.userId,
  });
}

/// Executes the `RemoveFromFavoritesUseCase` use case.
/// العربية: ينفذ حالة الاستخدام `RemoveFromFavoritesUseCase`.
class RemoveFromFavoritesUseCase
    implements UseCase<void, RemoveFromFavoritesParams> {
  /// Keeps the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final FavoritesRepository repository;

  /// Builds a new `RemoveFromFavoritesUseCase` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `RemoveFromFavoritesUseCase`.
  RemoveFromFavoritesUseCase(this.repository);

  /// Executes the main behavior exposed by this callable object.
  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, void>> call(RemoveFromFavoritesParams params) async {
    return await repository.removeFromFavorites(
      propertyId: params.propertyId,
      userId: params.userId,
    );
  }
}
