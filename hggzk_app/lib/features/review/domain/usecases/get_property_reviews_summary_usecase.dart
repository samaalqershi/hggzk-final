import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

/// Executes the `GetPropertyReviewsSummaryUseCase` use case.
/// العربية: ينفذ حالة الاستخدام `GetPropertyReviewsSummaryUseCase`.
class GetPropertyReviewsSummaryUseCase {
  /// Keeps the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final ReviewRepository repository;

  /// Builds a new `GetPropertyReviewsSummaryUseCase` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `GetPropertyReviewsSummaryUseCase`.
  GetPropertyReviewsSummaryUseCase(this.repository);

  /// Executes the main behavior exposed by this callable object.
  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  Future<Either<Failure, ReviewsSummary>> call(
      GetPropertyReviewsSummaryParams params) async {
    return await repository.getPropertyReviewsSummary(
      propertyId: params.propertyId,
    );
  }
}

/// Describes `GetPropertyReviewsSummaryParams`.
/// العربية: يمثل `GetPropertyReviewsSummaryParams`.
class GetPropertyReviewsSummaryParams extends Equatable {
  /// Keeps the `propertyId` value.
  /// العربية: يخزن القيمة `propertyId`.
  final String propertyId;

  /// Builds a new `GetPropertyReviewsSummaryParams` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `GetPropertyReviewsSummaryParams`.
  const GetPropertyReviewsSummaryParams({required this.propertyId});

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [propertyId];
}
