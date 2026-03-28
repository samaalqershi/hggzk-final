import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/favorite.dart';
import '../repositories/favorites_repository.dart';

/// Executes the `GetFavoritesUseCase` use case.
/// العربية: ينفذ حالة الاستخدام `GetFavoritesUseCase`.
class GetFavoritesUseCase implements UseCase<List<Favorite>, NoParams> {
  /// Keeps the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final FavoritesRepository repository;

  /// Builds a new `GetFavoritesUseCase` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `GetFavoritesUseCase`.
  GetFavoritesUseCase(this.repository);

  /// Executes the main behavior exposed by this callable object.
  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, List<Favorite>>> call(NoParams params) async {
    return await repository.getFavorites();
  }
}
