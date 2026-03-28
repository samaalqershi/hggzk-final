import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/favorite.dart';

/// Provides repository behavior for `FavoritesRepository`.
/// العربية: يوفر سلوك المستودع الخاص بـ `FavoritesRepository`.
abstract class FavoritesRepository {
  /// Exposes the favorites.
  /// العربية: يعيد favorites.
  Future<Either<Failure, List<Favorite>>> getFavorites();

  /// Processes `addToFavorites`.
  /// العربية: يعالج `addToFavorites`.
  Future<Either<Failure, bool>> addToFavorites({
    required String propertyId,
    required String userId,
  });

  /// Removes the from favorites.
  /// العربية: يزيل from favorites.
  Future<Either<Failure, void>> removeFromFavorites({
    required String propertyId,
    required String userId,
  });

  /// Checks the favorite status.
  /// العربية: يتحقق من favorite status.
  Future<Either<Failure, bool>> checkFavoriteStatus({
    required String propertyId,
    required String userId,
  });
}
