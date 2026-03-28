import '../../domain/entities/review.dart';
import 'review_image_model.dart';

/// Describes the data model `ReviewModel`.
/// العربية: يمثل نموذج البيانات `ReviewModel`.
class ReviewModel extends Review {
  /// Builds a new `ReviewModel` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `ReviewModel`.
  const ReviewModel({
    required super.id,
    required super.userId,
    required super.userName,
    super.userAvatar,
    required super.bookingId,
    required super.propertyId,
    required super.cleanliness,
    required super.service,
    required super.location,
    required super.value,
    required super.rating,
    required super.title,
    required super.comment,
    required super.createdAt,
    super.updatedAt,
    required super.images,
    required super.isUserReview,
    required super.likesCount,
    required super.isLikedByUser,
    super.managementReply,
    super.bookingType,
    required super.isRecommended,
  });

  /// Builds a new `ReviewModel.fromJson` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `ReviewModel.fromJson`.
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'],
      bookingId: json['bookingId'] ?? '',
      propertyId: json['propertyId'] ?? '',
      cleanliness: json['cleanliness'] ?? 0,
      service: json['service'] ?? 0,
      location: json['location'] ?? 0,
      value: json['value'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      title: json['title'] ?? '',
      comment: json['comment'] ?? '',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      images: (json['images'] as List?)
              ?.map((e) => ReviewImageModel.fromJson(e))
              .toList() ??
          [],
      isUserReview: json['isUserReview'] ?? false,
      likesCount: json['likesCount'] ?? 0,
      isLikedByUser: json['isLikedByUser'] ?? false,
      managementReply: json['managementReply'] != null
          ? ReviewReplyModel.fromJson(json['managementReply'])
          : null,
      bookingType: json['bookingType'],
      isRecommended: json['isRecommended'] ?? false,
    );
  }

  /// Converts this instance to a JSON representation.
  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'bookingId': bookingId,
      'propertyId': propertyId,
      'cleanliness': cleanliness,
      'service': service,
      'location': location,
      'value': value,
      'rating': rating,
      'title': title,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'images': images.map((e) => (e as ReviewImageModel).toJson()).toList(),
      'isUserReview': isUserReview,
      'likesCount': likesCount,
      'isLikedByUser': isLikedByUser,
      'managementReply': managementReply != null
          ? (managementReply as ReviewReplyModel).toJson()
          : null,
      'bookingType': bookingType,
      'isRecommended': isRecommended,
    };
  }

  /// Processes `toEntity`.
  /// العربية: يعالج `toEntity`.
  Review toEntity() {
    return Review(
      id: id,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      bookingId: bookingId,
      propertyId: propertyId,
      cleanliness: cleanliness,
      service: service,
      location: location,
      value: value,
      rating: rating,
      title: title,
      comment: comment,
      createdAt: createdAt,
      updatedAt: updatedAt,
      images: images,
      isUserReview: isUserReview,
      likesCount: likesCount,
      isLikedByUser: isLikedByUser,
      managementReply: managementReply,
      bookingType: bookingType,
      isRecommended: isRecommended,
    );
  }
}

/// Describes the data model `ReviewReplyModel`.
/// العربية: يمثل نموذج البيانات `ReviewReplyModel`.
class ReviewReplyModel extends ReviewReply {
  /// Builds a new `ReviewReplyModel` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `ReviewReplyModel`.
  const ReviewReplyModel({
    required super.id,
    required super.content,
    required super.createdAt,
    required super.replierName,
    required super.replierPosition,
  });

  /// Builds a new `ReviewReplyModel.fromJson` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `ReviewReplyModel.fromJson`.
  factory ReviewReplyModel.fromJson(Map<String, dynamic> json) {
    return ReviewReplyModel(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      replierName: json['replierName'] ?? '',
      replierPosition: json['replierPosition'] ?? '',
    );
  }

  /// Converts this instance to a JSON representation.
  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'replierName': replierName,
      'replierPosition': replierPosition,
    };
  }
}

/// Describes the data model `ReviewsSummaryModel`.
/// العربية: يمثل نموذج البيانات `ReviewsSummaryModel`.
class ReviewsSummaryModel extends ReviewsSummary {
  /// Builds a new `ReviewsSummaryModel` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `ReviewsSummaryModel`.
  const ReviewsSummaryModel({
    required super.totalReviews,
    required super.averageRating,
    required super.ratingDistribution,
    required super.ratingPercentages,
    required super.reviewsWithImagesCount,
    required super.recommendedCount,
    required super.latestReviews,
    required super.topReviews,
    required super.commonKeywords,
    required super.managementResponseRate,
  });

  /// Builds a new `ReviewsSummaryModel.fromJson` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `ReviewsSummaryModel.fromJson`.
  factory ReviewsSummaryModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    Map<int, int> parseIntMap(dynamic source) {
      final result = <int, int>{};
      if (source is Map) {
        source.forEach((key, value) {
          final parsedKey = key is int ? key : int.tryParse(key.toString());
          if (parsedKey != null) {
            result[parsedKey] = toInt(value);
          }
        });
      }
      return result;
    }

    Map<int, double> parseDoubleMap(dynamic source) {
      final result = <int, double>{};
      if (source is Map) {
        source.forEach((key, value) {
          final parsedKey = key is int ? key : int.tryParse(key.toString());
          if (parsedKey != null) {
            result[parsedKey] = toDouble(value);
          }
        });
      }
      return result;
    }

    return ReviewsSummaryModel(
      totalReviews: toInt(json['totalReviews']),
      averageRating: toDouble(json['averageRating']),
      ratingDistribution: parseIntMap(json['ratingDistribution'] ?? {}),
      ratingPercentages: parseDoubleMap(json['ratingPercentages'] ?? {}),
      reviewsWithImagesCount: toInt(json['reviewsWithImagesCount']),
      recommendedCount: toInt(json['recommendedCount']),
      latestReviews: (json['latestReviews'] as List?)
              ?.map((e) => ReviewModel.fromJson(e))
              .toList() ??
          [],
      topReviews: (json['topReviews'] as List?)
              ?.map((e) => ReviewModel.fromJson(e))
              .toList() ??
          [],
      commonKeywords: (json['commonKeywords'] as List?)
              ?.map((e) => ReviewKeywordModel.fromJson(e))
              .toList() ??
          [],
      managementResponseRate: toDouble(json['managementResponseRate']),
    );
  }

  /// Converts this instance to a JSON representation.
  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'totalReviews': totalReviews,
      'averageRating': averageRating,
      'ratingDistribution': ratingDistribution,
      'ratingPercentages': ratingPercentages,
      'reviewsWithImagesCount': reviewsWithImagesCount,
      'recommendedCount': recommendedCount,
      'latestReviews':
          latestReviews.map((e) => (e as ReviewModel).toJson()).toList(),
      'topReviews': topReviews.map((e) => (e as ReviewModel).toJson()).toList(),
      'commonKeywords': commonKeywords
          .map((e) => (e as ReviewKeywordModel).toJson())
          .toList(),
      'managementResponseRate': managementResponseRate,
    };
  }

  /// Processes `toEntity`.
  /// العربية: يعالج `toEntity`.
  ReviewsSummary toEntity() {
    return ReviewsSummary(
      totalReviews: totalReviews,
      averageRating: averageRating,
      ratingDistribution: ratingDistribution,
      ratingPercentages: ratingPercentages,
      reviewsWithImagesCount: reviewsWithImagesCount,
      recommendedCount: recommendedCount,
      latestReviews: latestReviews,
      topReviews: topReviews,
      commonKeywords: commonKeywords,
      managementResponseRate: managementResponseRate,
    );
  }
}

/// Describes the data model `ReviewKeywordModel`.
/// العربية: يمثل نموذج البيانات `ReviewKeywordModel`.
class ReviewKeywordModel extends ReviewKeyword {
  /// Builds a new `ReviewKeywordModel` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `ReviewKeywordModel`.
  const ReviewKeywordModel({
    required super.keyword,
    required super.count,
    required super.percentage,
    required super.sentiment,
  });

  /// Builds a new `ReviewKeywordModel.fromJson` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `ReviewKeywordModel.fromJson`.
  factory ReviewKeywordModel.fromJson(Map<String, dynamic> json) {
    return ReviewKeywordModel(
      keyword: json['keyword'] ?? '',
      count: json['count'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      sentiment: json['sentiment'] ?? 'Neutral',
    );
  }

  /// Converts this instance to a JSON representation.
  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'keyword': keyword,
      'count': count,
      'percentage': percentage,
      'sentiment': sentiment,
    };
  }
}
