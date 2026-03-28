import '../../domain/entities/booking_request.dart';

/// العربية: يمثل نموذج البيانات `BookingRequestModel`.
class BookingRequestModel extends BookingRequest {
  /// العربية: ينشئ مثيلًا جديدًا من `BookingRequestModel`.
  const BookingRequestModel({
    required super.userId,
    required super.unitId,
    required super.checkIn,
    required super.checkOut,
    required super.guestsCount,
    super.services,
    super.specialRequests,
    super.bookingSource,
  });

  /// العربية: ينشئ مثيلًا جديدًا من `BookingRequestModel.fromEntity`.
  factory BookingRequestModel.fromEntity(BookingRequest entity) {
    return BookingRequestModel(
      userId: entity.userId,
      unitId: entity.unitId,
      checkIn: entity.checkIn,
      checkOut: entity.checkOut,
      guestsCount: entity.guestsCount,
      services: entity.services,
      specialRequests: entity.specialRequests,
      bookingSource: entity.bookingSource,
    );
  }

  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'unitId': unitId,
      'checkIn': checkIn.toIso8601String(),
      'checkOut': checkOut.toIso8601String(),
      'guestsCount': guestsCount,
      'services': services
          .map((e) => BookingServiceRequestModel.fromEntity(e).toJson())
          .toList(),
      'specialRequests': specialRequests,
      'bookingSource': bookingSource,
    };
  }
}

/// العربية: يمثل نموذج البيانات `BookingServiceRequestModel`.
class BookingServiceRequestModel extends BookingServiceRequest {
  /// العربية: ينشئ مثيلًا جديدًا من `BookingServiceRequestModel`.
  const BookingServiceRequestModel({
    required super.serviceId,
    required super.quantity,
  });

  /// العربية: ينشئ مثيلًا جديدًا من `BookingServiceRequestModel.fromEntity`.
  factory BookingServiceRequestModel.fromEntity(BookingServiceRequest entity) {
    return BookingServiceRequestModel(
      serviceId: entity.serviceId,
      quantity: entity.quantity,
    );
  }

  /// العربية: ينشئ مثيلًا جديدًا من `BookingServiceRequestModel.fromJson`.
  factory BookingServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return BookingServiceRequestModel(
      serviceId: json['serviceId'] ?? '',
      quantity: json['quantity'] ?? 1,
    );
  }

  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'quantity': quantity,
    };
  }
}
