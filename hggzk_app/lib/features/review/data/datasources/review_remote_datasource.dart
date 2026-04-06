import 'package:dio/dio.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/models/paginated_result.dart';
import '../../../../core/models/result_dto.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/request_logger.dart';
import '../models/review_model.dart';
import '../models/review_image_model.dart';

/// Provides the data-source behavior for `ReviewRemoteDataSource`.
/// العربية: يوفر سلوك مصدر البيانات الخاص بـ `ReviewRemoteDataSource`.
abstract class ReviewRemoteDataSource {
  /// Builds the review.
  /// العربية: ينشئ review.
  Future<ReviewModel> createReview({
    required String bookingId,
    required String propertyId,
    required int cleanliness,
    required int service,
    required int location,
    required int value,
    required String comment,
    List<String>? imagesBase64,
    String? videoBase64,
    String? videoThumbnailBase64,
    void Function(double progress)? onSendProgress,
  });

  /// Exposes the property reviews.
  /// العربية: يعيد property reviews.
  Future<PaginatedResult<ReviewModel>> getPropertyReviews({
    required String propertyId,
    required int pageNumber,
    required int pageSize,
    int? rating,
    String? sortBy,
    String? sortDirection,
    bool? withImagesOnly,
    String? userId,
  });

  /// Exposes the property reviews summary.
  /// العربية: يعيد property reviews summary.
  Future<ReviewsSummaryModel> getPropertyReviewsSummary({
    required String propertyId,
  });

  /// Processes `uploadReviewImages`.
  /// العربية: يعالج `uploadReviewImages`.
  Future<List<ReviewImageModel>> uploadReviewImages({
    required String reviewId,
    required List<String> imagesBase64,
  });
}

/// Describes `ReviewRemoteDataSourceImpl`.
/// العربية: يمثل `ReviewRemoteDataSourceImpl`.
class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  /// Keeps the `apiClient` value.
  /// العربية: يخزن القيمة `apiClient`.
  final ApiClient apiClient;

  /// Builds a new `ReviewRemoteDataSourceImpl` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `ReviewRemoteDataSourceImpl`.
  ReviewRemoteDataSourceImpl({required this.apiClient});

  /// Builds the review.
  /// العربية: ينشئ review.
  @override
  Future<ReviewModel> createReview({
    required String bookingId,
    required String propertyId,
    required int cleanliness,
    required int service,
    required int location,
    required int value,
    required String comment,
    List<String>? imagesBase64,
    String? videoBase64,
    String? videoThumbnailBase64,
    void Function(double progress)? onSendProgress,
  }) async {
    const requestName = 'review.createReview';
    logRequestStart(requestName, details: {
      'bookingId': bookingId,
      'propertyId': propertyId,
      'cleanliness': cleanliness,
      'service': service,
      'location': location,
      'value': value,
    });
    try {
      final response = await apiClient.post(
        '/api/client/Reviews',
        data: {
          'bookingId': bookingId,
          'propertyId': propertyId,
          'cleanliness': cleanliness,
          'service': service,
          'location': location,
          'value': value,
          'comment': comment,
          'imagesBase64': imagesBase64 ?? [],
          'videoBase64': videoBase64,
          'videoThumbnailBase64': videoThumbnailBase64,
        },
        onSendProgress: (sent, total) {
          if (onSendProgress == null || total <= 0) return;
          onSendProgress((sent / total).clamp(0.0, 1.0));
        },
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      final resultDto = ResultDto<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json,
      );

      if (resultDto.success && resultDto.data != null) {
        final payload = resultDto.data!;
        final nestedReview = payload['review'];
        if (nestedReview is Map<String, dynamic>) {
          return ReviewModel.fromJson(nestedReview);
        }

        if (payload.containsKey('rating') ||
            payload.containsKey('averageRating')) {
          return ReviewModel.fromJson(payload);
        }

        final averageRating =
            ((cleanliness + service + location + value) / 4).toDouble();
        return ReviewModel.fromJson({
          'id': (payload['reviewId'] ?? '').toString(),
          'userId': '',
          'userName': AppLocalizations.translateSync('chat.message.you'),
          'bookingId': bookingId,
          'propertyId': propertyId,
          'cleanliness': cleanliness,
          'service': service,
          'location': location,
          'value': value,
          'rating': averageRating,
          'title': '',
          'comment': comment,
          'createdAt': DateTime.now().toIso8601String(),
          'images': const [],
          'isUserReview': true,
          'likesCount': 0,
          'isLikedByUser': false,
          'isRecommended': averageRating >= 4,
        });
      } else {
        throw ServerException(
          resultDto.message ??
              AppLocalizations.translateSync('common.unexpectedError'),
        );
      }
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw ServerException(
        AppLocalizations.translateSync('common.unexpectedError'),
      );
    }
  }

  /// Exposes the property reviews.
  /// العربية: يعيد property reviews.
  @override
  Future<PaginatedResult<ReviewModel>> getPropertyReviews({
    required String propertyId,
    required int pageNumber,
    required int pageSize,
    int? rating,
    String? sortBy,
    String? sortDirection,
    bool? withImagesOnly,
    String? userId,
  }) async {
    const requestName = 'review.getPropertyReviews';
    logRequestStart(requestName, details: {
      'propertyId': propertyId,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      if (rating != null) 'rating': rating,
      if (sortBy != null) 'sortBy': sortBy,
      if (sortDirection != null) 'sortDirection': sortDirection,
      if (withImagesOnly != null) 'withImagesOnly': withImagesOnly,
      if (userId != null) 'userId': userId,
    });
    try {
      final queryParams = {
        'propertyId': propertyId,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (rating != null) 'rating': rating,
        if (sortBy != null) 'sortBy': sortBy,
        if (sortDirection != null) 'sortDirection': sortDirection,
        if (withImagesOnly != null) 'withImagesOnly': withImagesOnly,
        if (userId != null) 'userId': userId,
      };

      final response = await apiClient.get(
        '/api/client/Reviews/property',
        queryParameters: queryParams,
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      final body = response.data;

      // 🔍 نحاول دعم أكثر من شكل لاستجابة الباكند
      // 1) { success, data: { items, pageNumber, pageSize, totalCount, ... } }
      // 2) { items, pageNumber, pageSize, totalCount, ... }

      Map<String, dynamic>? paginatedJson;

      if (body is Map<String, dynamic>) {
        // حالة وجود data
        final data = body['data'];
        if (data is Map) {
          paginatedJson = Map<String, dynamic>.from(data);
        } else if (body['items'] is List) {
          // حالة أن النتيجة المرقمة في الجذر مباشرة
          paginatedJson = Map<String, dynamic>.from(body);
        }

        if (paginatedJson != null) {
          return PaginatedResult<ReviewModel>.fromJson(
            paginatedJson,
            (json) => ReviewModel.fromJson(
              Map<String, dynamic>.from(json),
            ),
          );
        }

        // إذا لم نجد items إطلاقًا نحاول قراءة الرسالة
        final message = (body['message'] ?? '').toString();
        if (message.contains('لم يتم العثور على البيانات')) {
          return PaginatedResult<ReviewModel>.empty(
            pageNumber: pageNumber,
            pageSize: pageSize,
          );
        }
      }

      // في حال كان الشكل غير متوقع نرمي استثناء مع بعض التفاصيل للمطور
      throw ServerException(
        AppLocalizations.translateSync('common.unexpectedError'),
      );
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      final message = e.toString();
      if (message.contains('لم يتم العثور على البيانات')) {
        return PaginatedResult<ReviewModel>.empty(
          pageNumber: pageNumber,
          pageSize: pageSize,
        );
      }

      if (e is ServerException) rethrow;
      throw ServerException(
        AppLocalizations.translateSync('common.unexpectedError'),
      );
    }
  }

  /// Exposes the property reviews summary.
  /// العربية: يعيد property reviews summary.
  @override
  Future<ReviewsSummaryModel> getPropertyReviewsSummary({
    required String propertyId,
  }) async {
    const requestName = 'review.getPropertyReviewsSummary';
    logRequestStart(requestName, details: {
      'propertyId': propertyId,
    });
    try {
      final response = await apiClient.get(
        '/api/client/Reviews/summary',
        queryParameters: {'propertyId': propertyId},
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      final resultDto = ResultDto<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json,
      );

      if (resultDto.success && resultDto.data != null) {
        return ReviewsSummaryModel.fromJson(resultDto.data!);
      } else {
        throw ServerException(
          resultDto.message ??
              AppLocalizations.translateSync('common.unexpectedError'),
        );
      }
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw ServerException(
        AppLocalizations.translateSync('common.unexpectedError'),
      );
    }
  }

  /// Processes `uploadReviewImages`.
  /// العربية: يعالج `uploadReviewImages`.
  @override
  Future<List<ReviewImageModel>> uploadReviewImages({
    required String reviewId,
    required List<String> imagesBase64,
  }) async {
    const requestName = 'review.uploadReviewImages';
    logRequestStart(requestName, details: {
      'reviewId': reviewId,
      'imagesCount': imagesBase64.length,
    });
    try {
      final formData = FormData();

      for (int i = 0; i < imagesBase64.length; i++) {
        final bytes = imagesBase64[i].split(',').last;
        formData.files.add(
          MapEntry(
            'files',
            MultipartFile.fromString(
              bytes,
              filename: 'review_image_$i.jpg',
            ),
          ),
        );
      }

      formData.fields.add(const MapEntry('category', 'review'));
      formData.fields.add(MapEntry('reviewId', reviewId));

      final response = await apiClient.upload(
        '/Reviews/upload',
        formData: formData,
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      final resultDto = ResultDto<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (resultDto.success && resultDto.data != null) {
        return resultDto.data!
            .map((item) => ReviewImageModel.fromJson(item))
            .toList();
      } else {
        throw ServerException(
          resultDto.message ??
              AppLocalizations.translateSync('common.operationFailed'),
        );
      }
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw ServerException(
        AppLocalizations.translateSync('common.unexpectedError'),
      );
    }
  }
}
