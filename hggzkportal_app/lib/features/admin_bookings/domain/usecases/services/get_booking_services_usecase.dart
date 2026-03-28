import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../entities/booking_details.dart';
import '../../repositories/bookings_repository.dart';

/// Loads the list of services attached to one booking.
/// يحمّل قائمة الخدمات المرتبطة بحجز واحد.
class GetBookingServicesUseCase
    implements UseCase<List<Service>, GetBookingServicesParams> {
  /// Repository used to fetch the booking's services.
  /// المستودع المستخدم لجلب خدمات الحجز.
  final BookingsRepository repository;

  /// Creates the use case with its repository dependency.
  /// ينشئ حالة الاستخدام مع اعتماد المستودع.
  GetBookingServicesUseCase(this.repository);

  @override

  /// Delegates the booking-services lookup to the repository.
  /// يفوض عملية جلب خدمات الحجز إلى المستودع.
  Future<Either<Failure, List<Service>>> call(
      GetBookingServicesParams params) async {
    return await repository.getBookingServices(bookingId: params.bookingId);
  }
}

/// Parameters required to load services for one booking.
/// المعاملات المطلوبة لتحميل خدمات حجز واحد.
class GetBookingServicesParams extends Equatable {
  /// Identifier of the booking whose services should be loaded.
  /// معرّف الحجز الذي يجب تحميل خدماته.
  final String bookingId;

  /// Creates the lookup parameters for one booking.
  /// ينشئ معاملات البحث لحجز واحد.
  const GetBookingServicesParams({required this.bookingId});

  @override

  /// Comparison key for the booking id.
  /// مفتاح المقارنة لمعرّف الحجز.
  List<Object> get props => [bookingId];
}
