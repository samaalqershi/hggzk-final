import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/favorites_repository.dart';

/// Describes `AddToFavoritesParams`.
/// العربية: يمثل `AddToFavoritesParams`.
class AddToFavoritesParams {
  /// Keeps the `propertyId` value.
  /// العربية: يخزن القيمة `propertyId`.
  final String propertyId;

  /// Keeps the `userId` value.
  /// العربية: يخزن القيمة `userId`.
  final String userId;

  /// Builds a new `AddToFavoritesParams` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `AddToFavoritesParams`.
  AddToFavoritesParams({
    required this.propertyId,
    required this.userId,
  });
}

/// Executes the `AddToFavoritesUseCase` use case.
/// العربية: ينفذ حالة الاستخدام `AddToFavoritesUseCase`.
class AddToFavoritesUseCase implements UseCase<bool, AddToFavoritesParams> {
  /// Keeps the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final FavoritesRepository repository;

  /// Builds a new `AddToFavoritesUseCase` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `AddToFavoritesUseCase`.
  AddToFavoritesUseCase(this.repository);

  /// Executes the main behavior exposed by this callable object.
  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, bool>> call(AddToFavoritesParams params) async {
    return await repository.addToFavorites(
      propertyId: params.propertyId,
      userId: params.userId,
    );
  }
}
