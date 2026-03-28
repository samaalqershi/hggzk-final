import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../entities/booking.dart';
import '../../repositories/bookings_repository.dart';

/// Loads a single booking by its identifier.
/// يحمّل حجزًا واحدًا من خلال معرّفه.
class GetBookingByIdUseCase implements UseCase<Booking, GetBookingByIdParams> {
  /// Repository used to fetch the booking detail record.
  /// المستودع المستخدم لجلب سجل تفاصيل الحجز.
  final BookingsRepository repository;

  /// Creates the use case with the bookings repository dependency.
  /// ينشئ حالة الاستخدام مع اعتماد مستودع الحجوزات.
  GetBookingByIdUseCase(this.repository);

  @override

  /// Delegates the lookup to the repository for the requested booking id.
  /// يفوض عملية البحث إلى المستودع لمعرّف الحجز المطلوب.
  Future<Either<Failure, Booking>> call(GetBookingByIdParams params) async {
    return await repository.getBookingById(bookingId: params.bookingId);
  }
}

/// Parameters required to fetch one booking by id.
/// المعاملات المطلوبة لجلب حجز واحد حسب المعرّف.
class GetBookingByIdParams extends Equatable {
  /// Identifier of the booking to load.
  /// معرّف الحجز المطلوب تحميله.
  final String bookingId;

  /// Creates the lookup parameters for one booking.
  /// ينشئ معاملات البحث لحجز واحد.
  const GetBookingByIdParams({required this.bookingId});

  @override

  /// Comparison key for the booking id.
  /// مفتاح المقارنة لمعرّف الحجز.
  List<Object> get props => [bookingId];
}
