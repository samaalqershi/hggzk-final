import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/favorites_repository.dart';

/// Describes `CheckFavoriteStatusParams`.
/// العربية: يمثل `CheckFavoriteStatusParams`.
class CheckFavoriteStatusParams {
  /// Keeps the `propertyId` value.
  /// العربية: يخزن القيمة `propertyId`.
  final String propertyId;

  /// Keeps the `userId` value.
  /// العربية: يخزن القيمة `userId`.
  final String userId;

  /// Builds a new `CheckFavoriteStatusParams` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `CheckFavoriteStatusParams`.
  CheckFavoriteStatusParams({
    required this.propertyId,
    required this.userId,
  });
}

/// Executes the `CheckFavoriteStatusUseCase` use case.
/// العربية: ينفذ حالة الاستخدام `CheckFavoriteStatusUseCase`.
class CheckFavoriteStatusUseCase
    implements UseCase<bool, CheckFavoriteStatusParams> {
  /// Keeps the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final FavoritesRepository repository;

  /// Builds a new `CheckFavoriteStatusUseCase` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `CheckFavoriteStatusUseCase`.
  CheckFavoriteStatusUseCase(this.repository);

  /// Executes the main behavior exposed by this callable object.
  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, bool>> call(CheckFavoriteStatusParams params) async {
    return await repository.checkFavoriteStatus(
      propertyId: params.propertyId,
      userId: params.userId,
    );
  }
}
