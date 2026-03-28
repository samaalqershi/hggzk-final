import 'package:equatable/equatable.dart';

/// العربية: يمثل `BookingRequest`.
class BookingRequest extends Equatable {
  /// العربية: يخزن القيمة `userId`.
  final String userId;

  /// العربية: يخزن القيمة `unitId`.
  final String unitId;

  /// العربية: يخزن القيمة `checkIn`.
  final DateTime checkIn;

  /// العربية: يخزن القيمة `checkOut`.
  final DateTime checkOut;

  /// العربية: يخزن القيمة `guestsCount`.
  final int guestsCount;

  /// العربية: يخزن القيمة `services`.
  final List<BookingServiceRequest> services;

  /// العربية: يخزن القيمة `specialRequests`.
  final String? specialRequests;

  /// العربية: يخزن القيمة `bookingSource`.
  final String bookingSource;

  /// العربية: ينشئ مثيلًا جديدًا من `BookingRequest`.
  const BookingRequest({
    required this.userId,
    required this.unitId,
    required this.checkIn,
    required this.checkOut,
    required this.guestsCount,
    this.services = const [],
    this.specialRequests,
    this.bookingSource = 'MobileApp',
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [
        userId,
        unitId,
        checkIn,
        checkOut,
        guestsCount,
        services,
        specialRequests,
        bookingSource,
      ];
}

/// العربية: يمثل `BookingServiceRequest`.
class BookingServiceRequest extends Equatable {
  /// العربية: يخزن القيمة `serviceId`.
  final String serviceId;

  /// العربية: يخزن القيمة `quantity`.
  final int quantity;

  /// العربية: ينشئ مثيلًا جديدًا من `BookingServiceRequest`.
  const BookingServiceRequest({
    required this.serviceId,
    required this.quantity,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [serviceId, quantity];
}
