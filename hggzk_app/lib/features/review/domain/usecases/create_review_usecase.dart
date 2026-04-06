import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

/// Submits a completed booking review to the review repository.
/// يرسل مراجعة الحجز المكتملة إلى مستودع المراجعات.
class CreateReviewUseCase {
  /// Repository bridge that handles review persistence.
  /// جسر المستودع الذي يتولى حفظ المراجعة.
  final ReviewRepository repository;

  /// Creates the use case around the repository contract.
  /// ينشئ حالة الاستخدام اعتمادًا على عقد المستودع.
  CreateReviewUseCase(this.repository);

  /// Sends the review payload and returns the stored review record.
  /// يرسل حمولة المراجعة ويعيد السجل المحفوظ.
  Future<Either<Failure, Review>> call(CreateReviewParams params) async {
    return await repository.createReview(
      bookingId: params.bookingId,
      propertyId: params.propertyId,
      cleanliness: params.cleanliness,
      service: params.service,
      location: params.location,
      value: params.value,
      comment: params.comment,
      imagesBase64: params.imagesBase64,
      videoBase64: params.videoBase64,
      videoThumbnailBase64: params.videoThumbnailBase64,
      onSendProgress: params.onProgress,
    );
  }
}

/// Parameters required to create a booking review.
/// المعطيات المطلوبة لإنشاء مراجعة لحجز.
class CreateReviewParams extends Equatable {
  /// Booking that the review belongs to.
  /// الحجز الذي تنتمي إليه المراجعة.
  final String bookingId;

  /// Property being reviewed.
  /// العقار محل المراجعة.
  final String propertyId;

  /// Cleanliness score on the feature's rating scale.
  /// درجة النظافة وفق مقياس التقييم الخاص بالميزة.
  final int cleanliness;

  /// Service score on the feature's rating scale.
  /// درجة الخدمة وفق مقياس التقييم الخاص بالميزة.
  final int service;

  /// Location score on the feature's rating scale.
  /// درجة الموقع وفق مقياس التقييم الخاص بالميزة.
  final int location;

  /// Value-for-money score on the feature's rating scale.
  /// درجة القيمة مقابل المال وفق مقياس التقييم الخاص بالميزة.
  final int value;

  /// Free-text feedback written by the guest.
  /// التعليق الحر الذي يكتبه الضيف.
  final String comment;

  /// Optional images encoded for upload with the review.
  /// صور اختيارية مشفّرة للرفع مع المراجعة.
  final List<String>? imagesBase64;

  /// Optional review video encoded for upload.
  /// فيديو مراجعة اختياري مشفّر للرفع.
  final String? videoBase64;

  /// Optional thumbnail encoded for the attached review video.
  /// صورة مصغرة اختيارية مشفرة للفيديو المرفق.
  final String? videoThumbnailBase64;

  /// Optional upload progress callback emitted while the payload is sent.
  /// استدعاء اختياري لتقدم الرفع أثناء إرسال الحمولة.
  final void Function(double progress)? onProgress;

  /// Bundles the full review payload used by the submission flow.
  /// يجمع حمولة المراجعة الكاملة المستخدمة في مسار الإرسال.
  const CreateReviewParams({
    required this.bookingId,
    required this.propertyId,
    required this.cleanliness,
    required this.service,
    required this.location,
    required this.value,
    required this.comment,
    this.imagesBase64,
    this.videoBase64,
    this.videoThumbnailBase64,
    this.onProgress,
  });

  /// Keeps request comparisons stable for repeated submissions.
  /// يحافظ على ثبات مقارنة الطلبات عند تكرار الإرسال.
  @override
  List<Object?> get props => [
        bookingId,
        propertyId,
        cleanliness,
        service,
        location,
        value,
        comment,
        imagesBase64,
        videoBase64,
        videoThumbnailBase64,
      ];
}
