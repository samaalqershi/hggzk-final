import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/property_repository.dart';

/// Executes the `GetPropertyReviewsUseCase` use case.
/// العربية: ينفذ حالة الاستخدام `GetPropertyReviewsUseCase`.
class GetPropertyReviewsUseCase
    implements UseCase<List<PropertyReview>, GetPropertyReviewsParams> {
  /// Keeps the repository value available to this object.
  /// العربية: يخزن القيمة `repository`.
  final PropertyRepository repository;

  /// Constructs the GetPropertyReviewsUseCase value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `GetPropertyReviewsUseCase`.
  GetPropertyReviewsUseCase({required this.repository});

  /// Executes the main behavior exposed by this callable object.
  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, List<PropertyReview>>> call(
      GetPropertyReviewsParams params) async {
    return await repository.getPropertyReviews(
      propertyId: params.propertyId,
      pageNumber: params.pageNumber,
      pageSize: params.pageSize,
      sortBy: params.sortBy,
      sortDirection: params.sortDirection,
      withImagesOnly: params.withImagesOnly,
      userId: params.userId,
    );
  }
}

/// Describes the GetPropertyReviewsParams type used in the property feature.
/// العربية: يمثل `GetPropertyReviewsParams`.
class GetPropertyReviewsParams extends Equatable {
  /// Keeps the propertyId value available to this object.
  /// العربية: يخزن القيمة `propertyId`.
  final String propertyId;

  /// Keeps the pageNumber value available to this object.
  /// العربية: يخزن القيمة `pageNumber`.
  final int pageNumber;

  /// Keeps the pageSize value available to this object.
  /// العربية: يخزن القيمة `pageSize`.
  final int pageSize;

  /// Keeps the sortBy value available to this object.
  /// العربية: يخزن القيمة `sortBy`.
  final String? sortBy;

  /// Keeps the sortDirection value available to this object.
  /// العربية: يخزن القيمة `sortDirection`.
  final String? sortDirection;

  /// Keeps the withImagesOnly value available to this object.
  /// العربية: يخزن القيمة `withImagesOnly`.
  final bool withImagesOnly;

  /// Keeps the userId value available to this object.
  /// العربية: يخزن القيمة `userId`.
  final String? userId;

  /// Constructs the GetPropertyReviewsParams value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `GetPropertyReviewsParams`.
  const GetPropertyReviewsParams({
    required this.propertyId,
    this.pageNumber = 1,
    this.pageSize = 20,
    this.sortBy,
    this.sortDirection,
    this.withImagesOnly = false,
    this.userId,
  });

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [
        propertyId,
        pageNumber,
        pageSize,
        sortBy,
        sortDirection,
        withImagesOnly,
        userId,
      ];
}
