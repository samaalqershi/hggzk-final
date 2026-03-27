import '../../domain/repositories/property_repository.dart';

class ReviewModel extends PropertyReview {
  const ReviewModel({
    required super.id,
    required super.bookingId,
    required super.propertyName,
    required super.userName,
    required super.cleanliness,
    required super.service,
    required super.location,
    required super.value,
    required super.averageRating,
    required super.comment,
    super.responseText,
    super.responseDate,
    required super.createdAt,
    required super.images,
    super.isUserReview,
    super.isPendingApproval,
    super.isDisabled,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final managementReply = json['managementReply'] is Map<String, dynamic>
        ? json['managementReply']
        : null;

    final rawAverage = json['averageRating'] ?? json['rating'] ?? 0;
    final average = rawAverage is num
        ? rawAverage.toDouble()
        : double.tryParse(rawAverage.toString()) ?? 0.0;

    final rawResponseDate =
        json['responseDate'] ?? managementReply?['createdAt'];

    return ReviewModel(
      id: json['id'] ?? '',
      bookingId: json['bookingId'] ?? '',
      propertyName: json['propertyName'] ?? '',
      userName: json['userName'] ?? '',
      cleanliness: json['cleanliness'] ?? 0,
      service: json['service'] ?? 0,
      location: json['location'] ?? 0,
      value: json['value'] ?? 0,
      averageRating: average,
      comment: json['comment'] ?? '',
      responseText: json['responseText'] ?? managementReply?['content'],
      responseDate: rawResponseDate != null
          ? DateTime.parse(rawResponseDate.toString())
          : null,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      images: (json['images'] as List?)
              ?.map((e) => ReviewImageModel.fromJson(e))
              .toList() ??
          [],
      isUserReview: json['isUserReview'] as bool? ?? false,
      isPendingApproval: json['isPendingApproval'] as bool? ?? false,
      isDisabled: json['isDisabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'propertyName': propertyName,
      'userName': userName,
      'cleanliness': cleanliness,
      'service': service,
      'location': location,
      'value': value,
      'averageRating': averageRating,
      'comment': comment,
      'responseText': responseText,
      'responseDate': responseDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'images': images.map((e) => (e as ReviewImageModel).toJson()).toList(),
      'isUserReview': isUserReview,
      'isPendingApproval': isPendingApproval,
      'isDisabled': isDisabled,
    };
  }
}

class ReviewImageModel extends ReviewImage {
  const ReviewImageModel({
    required super.id,
    required super.reviewId,
    required super.name,
    required super.url,
    required super.sizeBytes,
    required super.type,
    required super.category,
    required super.caption,
    required super.altText,
    required super.uploadedAt,
  });

  factory ReviewImageModel.fromJson(Map<String, dynamic> json) {
    final rawSize = json['sizeBytes'];
    final sizeBytes = rawSize is int
        ? rawSize
        : (rawSize is num
            ? rawSize.toInt()
            : int.tryParse(rawSize?.toString() ?? '0') ?? 0);

    final rawUploadedAt = json['uploadedAt'] ?? json['createdAt'];

    return ReviewImageModel(
      id: json['id'] ?? '',
      reviewId: json['reviewId'] ?? '',
      name: json['name'] ?? json['fileName'] ?? '',
      url: json['url'] ?? '',
      sizeBytes: sizeBytes,
      type: json['type'] ?? json['contentType'] ?? '',
      category: json['category']?.toString() ?? 'review',
      caption: json['caption'] ?? '',
      altText: json['altText'] ?? '',
      uploadedAt: DateTime.parse(
        rawUploadedAt?.toString() ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reviewId': reviewId,
      'name': name,
      'url': url,
      'sizeBytes': sizeBytes,
      'type': type,
      'category': category,
      'caption': caption,
      'altText': altText,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }
}
