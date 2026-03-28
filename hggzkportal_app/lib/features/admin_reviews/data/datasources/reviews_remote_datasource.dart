// lib/features/admin_reviews/data/datasources/reviews_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:hggzkportal/core/network/api_client.dart';
import 'package:hggzkportal/core/error/exceptions.dart';
import 'package:hggzkportal/services/local_storage_service.dart';
import 'package:hggzkportal/core/constants/storage_constants.dart';
import 'package:hggzkportal/core/models/paginated_result.dart';
import '../models/review_model.dart';
import '../models/review_response_model.dart';

/// Arabic: يعرّف الكلاس المجرد `ReviewsRemoteDataSource`.
/// English: Defines the abstract `ReviewsRemoteDataSource` class.
abstract class ReviewsRemoteDataSource {
  /// English: Returns the all reviews.
  /// العربية: يعيد all reviews.
  Future<PaginatedResult<ReviewModel>> getAllReviews({
    String? status,
    double? minRating,
    double? maxRating,
    bool? hasImages,
    String? propertyId,
    String? unitId,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? pageNumber,
    int? pageSize,
    bool? includeStats,
  });

  // Not available in backend; kept for interface compatibility but unused
  /// Arabic: ينفذ العملية `getReviewDetails`.
  /// English: Executes the `getReviewDetails` operation.
  Future<ReviewModel> getReviewDetails(String reviewId);

  /// Arabic: ينفذ العملية `getReviewByBooking`.
  /// English: Executes the `getReviewByBooking` operation.
  Future<ReviewModel?> getReviewByBooking(String bookingId);

  /// Arabic: ينفذ العملية `approveReview`.
  /// English: Executes the `approveReview` operation.
  Future<bool> approveReview(String reviewId);
  // Currently not supported by backend (no endpoint). Keep for future.
  /// Arabic: ينفذ العملية `rejectReview`.
  /// English: Executes the `rejectReview` operation.
  Future<bool> rejectReview(String reviewId);

  /// Arabic: ينفذ العملية `deleteReview`.
  /// English: Executes the `deleteReview` operation.
  Future<bool> deleteReview(String reviewId);

  /// Arabic: ينفذ العملية `disableReview`.
  /// English: Executes the `disableReview` operation.
  Future<bool> disableReview(String reviewId);

  /// Arabic: ينفذ العملية `respondToReview`.
  /// English: Executes the `respondToReview` operation.
  Future<ReviewResponseModel> respondToReview({
    required String reviewId,
    required String responseText,
    required String respondedBy,
  });

  /// Arabic: ينفذ العملية `getReviewResponses`.
  /// English: Executes the `getReviewResponses` operation.
  Future<List<ReviewResponseModel>> getReviewResponses(String reviewId);

  /// Arabic: ينفذ العملية `deleteReviewResponse`.
  /// English: Executes the `deleteReviewResponse` operation.
  Future<bool> deleteReviewResponse(String responseId);
}

/// Arabic: يعرّف الكلاس `ReviewsRemoteDataSourceImpl`.
/// English: Defines the `ReviewsRemoteDataSourceImpl` class.
class ReviewsRemoteDataSourceImpl implements ReviewsRemoteDataSource {
  /// English: Stores the `apiClient` value.
  /// العربية: يخزن القيمة `apiClient`.
  final ApiClient apiClient;

  /// Arabic: يخزن العضو `localStorage`.
  /// English: Stores the `localStorage` member.
  final LocalStorageService localStorage;

  /// Arabic: ينشئ مثيلاً من `ReviewsRemoteDataSourceImpl`.
  /// English: Creates an instance of `ReviewsRemoteDataSourceImpl`.
  ReviewsRemoteDataSourceImpl(
      {required this.apiClient, required this.localStorage});

  /// Arabic: ينفذ العملية `getAllReviews`.
  /// English: Executes the `getAllReviews` operation.
  @override
  Future<PaginatedResult<ReviewModel>> getAllReviews({
    String? status,
    double? minRating,
    double? maxRating,
    bool? hasImages,
    String? propertyId,
    String? unitId,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? pageNumber,
    int? pageSize,
    bool? includeStats,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (status != null) queryParams['status'] = status;
      if (minRating != null) queryParams['minRating'] = minRating;
      if (maxRating != null) queryParams['maxRating'] = maxRating;
      if (hasImages != null) queryParams['hasImages'] = hasImages;
      if (propertyId != null) queryParams['propertyId'] = propertyId;
      if (unitId != null) queryParams['unitId'] = unitId;
      if (userId != null) queryParams['userId'] = userId;
      // Align with backend query contract: ReviewedAfter/ReviewedBefore
      if (startDate != null)
        queryParams['reviewedAfter'] = startDate.toIso8601String();
      if (endDate != null)
        queryParams['reviewedBefore'] = endDate.toIso8601String();
      if (pageNumber != null) queryParams['pageNumber'] = pageNumber;
      if (pageSize != null) queryParams['pageSize'] = pageSize;
      if (includeStats != null) queryParams['includeStats'] = includeStats;

      final response = await apiClient.get(
        '/api/admin/reviews',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final body = response.data;
        // Backend now returns PaginatedResult<ReviewDto>
        return PaginatedResult<ReviewModel>.fromJson(
          body is Map<String, dynamic> ? body : {},
          (json) => ReviewModel.fromJson(json),
        );
      }
      throw ServerException('Failed to load reviews');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error occurred');
    }
  }

  /// Arabic: ينفذ العملية `getReviewDetails`.
  /// English: Executes the `getReviewDetails` operation.
  @override
  Future<ReviewModel> getReviewDetails(String reviewId) async {
    try {
      final response = await apiClient.get('/api/admin/reviews/$reviewId');
      if (response.statusCode == 200) {
        final body = response.data;
        final success = (body is Map<String, dynamic>) &&
            (body['success'] == true || body['isSuccess'] == true);
        if (success) {
          final data = body['data'] as Map<String, dynamic>;
          return ReviewModel.fromJson(data);
        }
        throw ServerException((body is Map && body['message'] is String)
            ? body['message'] as String
            : 'Failed to load review details');
      }
      throw ServerException('Failed to load review details');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to load review details');
    }
  }

  /// Arabic: ينفذ العملية `getReviewByBooking`.
  /// English: Executes the `getReviewByBooking` operation.
  @override
  Future<ReviewModel?> getReviewByBooking(String bookingId) async {
    try {
      final response =
          await apiClient.get('/api/admin/reviews/by-booking/$bookingId');
      if (response.statusCode == 200) {
        final body = response.data;
        final success = (body is Map<String, dynamic>) &&
            (body['success'] == true || body['isSuccess'] == true);
        if (success) {
          final data = body['data'];
          if (data == null) return null;
          return ReviewModel.fromJson(data as Map<String, dynamic>);
        }
        throw ServerException((body is Map && body['message'] is String)
            ? body['message'] as String
            : 'Failed to load review by booking');
      }
      throw ServerException('Failed to load review by booking');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to load review by booking');
    }
  }

  /// Arabic: ينفذ العملية `approveReview`.
  /// English: Executes the `approveReview` operation.
  @override
  Future<bool> approveReview(String reviewId) async {
    try {
      final String? adminId =
          localStorage.getData(StorageConstants.userId)?.toString();
      if (adminId == null || adminId.isEmpty) {
        throw ServerException('AdminId is missing');
      }
      final response = await apiClient.post(
        '/api/admin/reviews/$reviewId/approve',
        data: {
          // Matches ApproveReviewCommand AdminId
          'adminId': adminId,
        },
      );

      if (response.statusCode == 200) {
        final body = response.data;
        final success = (body is Map<String, dynamic>) &&
            (body['success'] == true || body['isSuccess'] == true);
        if (success) {
          // Prefer returned data if present, else true
          if (body['data'] is bool) {
            return body['data'] as bool;
          }
          return true;
        }
        throw ServerException((body is Map && body['message'] is String)
            ? body['message'] as String
            : 'Failed to approve review');
      }
      throw ServerException('Failed to approve review');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to approve review');
    }
  }

  /// Arabic: ينفذ العملية `rejectReview`.
  /// English: Executes the `rejectReview` operation.
  @override
  Future<bool> rejectReview(String reviewId) async {
    // Not supported by backend as of now
    throw ServerException('Reject review is not supported by backend');
  }

  /// Arabic: ينفذ العملية `deleteReview`.
  /// English: Executes the `deleteReview` operation.
  @override
  Future<bool> deleteReview(String reviewId) async {
    try {
      final response = await apiClient.delete('/api/admin/reviews/$reviewId');

      if (response.statusCode == 200) {
        final body = response.data;
        final success = (body is Map<String, dynamic>) &&
            (body['success'] == true || body['isSuccess'] == true);
        if (success) {
          if (body['data'] is bool) {
            return body['data'] as bool;
          }
          return true;
        }
        throw ServerException((body is Map && body['message'] is String)
            ? body['message'] as String
            : 'Failed to delete review');
      }
      throw ServerException('Failed to delete review');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete review');
    }
  }

  /// Arabic: ينفذ العملية `disableReview`.
  /// English: Executes the `disableReview` operation.
  @override
  Future<bool> disableReview(String reviewId) async {
    try {
      final response =
          await apiClient.post('/api/admin/reviews/$reviewId/disable');

      if (response.statusCode == 200) {
        final body = response.data;
        final success = (body is Map<String, dynamic>) &&
            (body['success'] == true || body['isSuccess'] == true);
        if (success) {
          if (body['data'] is bool) {
            return body['data'] as bool;
          }
          return true;
        }
        throw ServerException((body is Map && body['message'] is String)
            ? body['message'] as String
            : 'Failed to disable review');
      }
      throw ServerException('Failed to disable review');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to disable review');
    }
  }

  /// Arabic: ينفذ العملية `respondToReview`.
  /// English: Executes the `respondToReview` operation.
  @override
  Future<ReviewResponseModel> respondToReview({
    required String reviewId,
    required String responseText,
    required String respondedBy,
  }) async {
    try {
      // Backend expects OwnerId as GUID. If client passes a non-GUID placeholder, omit it to let backend use current user.
      String? ownerIdToSend;
      final trimmed = respondedBy.trim();
      final guidRegex = RegExp(
          r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12} ?$');
      if (trimmed.isNotEmpty && guidRegex.hasMatch(trimmed)) {
        ownerIdToSend = trimmed;
      } else {
        // Try to read from local storage if present
        final stored =
            localStorage.getData(StorageConstants.userId)?.toString();
        if (stored != null &&
            stored.isNotEmpty &&
            RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(stored)) {
          ownerIdToSend = stored;
        }
      }

      final Map<String, dynamic> payload = {
        'responseText': responseText,
      };
      if (ownerIdToSend != null && ownerIdToSend.isNotEmpty) {
        payload['ownerId'] = ownerIdToSend;
      }

      final response = await apiClient.post(
        '/api/admin/reviews/$reviewId/respond',
        data: payload,
      );

      if (response.statusCode == 200) {
        final body = response.data;
        final success = (body is Map<String, dynamic>) &&
            (body['success'] == true || body['isSuccess'] == true);
        if (success) {
          return ReviewResponseModel.fromJson(
              body['data'] as Map<String, dynamic>);
        }
        throw ServerException((body is Map && body['message'] is String)
            ? body['message'] as String
            : 'Failed to add response');
      }
      throw ServerException('Failed to add response');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to respond to review');
    }
  }

  /// Arabic: ينفذ العملية `getReviewResponses`.
  /// English: Executes the `getReviewResponses` operation.
  @override
  Future<List<ReviewResponseModel>> getReviewResponses(String reviewId) async {
    try {
      final response = await apiClient.get(
        '/api/admin/reviews/$reviewId/responses',
      );

      if (response.statusCode == 200) {
        final body = response.data;
        final success = (body is Map<String, dynamic>) &&
            (body['success'] == true || body['isSuccess'] == true);
        if (success) {
          final data = (body['data'] as List?) ?? const [];
          return data
              .map((json) => ReviewResponseModel.fromJson(json))
              .toList();
        }
        throw ServerException((body is Map && body['message'] is String)
            ? body['message'] as String
            : 'Failed to load responses');
      }
      throw ServerException('Failed to load responses');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error occurred');
    }
  }

  /// Arabic: ينفذ العملية `deleteReviewResponse`.
  /// English: Executes the `deleteReviewResponse` operation.
  @override
  Future<bool> deleteReviewResponse(String responseId) async {
    try {
      final response = await apiClient.delete(
        '/api/admin/reviews/responses/$responseId',
      );

      if (response.statusCode == 200) {
        final body = response.data;
        final success = (body is Map<String, dynamic>) &&
            (body['success'] == true || body['isSuccess'] == true);
        if (success) {
          if (body['data'] is bool) {
            return body['data'] as bool;
          }
          return true;
        }
        throw ServerException((body is Map && body['message'] is String)
            ? body['message'] as String
            : 'Failed to delete response');
      }
      throw ServerException('Failed to delete response');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete response');
    }
  }
}
