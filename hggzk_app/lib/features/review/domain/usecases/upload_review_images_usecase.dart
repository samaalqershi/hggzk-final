import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/review_image.dart';
import '../repositories/review_repository.dart';

/// Executes the `UploadReviewImagesUseCase` use case.
/// العربية: ينفذ حالة الاستخدام `UploadReviewImagesUseCase`.
class UploadReviewImagesUseCase {
  /// Keeps the `repository` value.
  /// العربية: يخزن القيمة `repository`.
  final ReviewRepository repository;

  /// Builds a new `UploadReviewImagesUseCase` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `UploadReviewImagesUseCase`.
  UploadReviewImagesUseCase(this.repository);

  /// Executes the main behavior exposed by this callable object.
  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  Future<Either<Failure, List<ReviewImage>>> call(
      UploadReviewImagesParams params) async {
    return await repository.uploadReviewImages(
      reviewId: params.reviewId,
      imagesBase64: params.imagesBase64,
    );
  }
}

/// Describes `UploadReviewImagesParams`.
/// العربية: يمثل `UploadReviewImagesParams`.
class UploadReviewImagesParams extends Equatable {
  /// Keeps the `reviewId` value.
  /// العربية: يخزن القيمة `reviewId`.
  final String reviewId;

  /// Keeps the `imagesBase64` value.
  /// العربية: يخزن القيمة `imagesBase64`.
  final List<String> imagesBase64;

  /// Builds a new `UploadReviewImagesParams` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `UploadReviewImagesParams`.
  const UploadReviewImagesParams({
    required this.reviewId,
    required this.imagesBase64,
  });

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [reviewId, imagesBase64];
}
