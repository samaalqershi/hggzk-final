import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../repositories/bookings_repository.dart';

/// Updates booking timing or guest-count values through the bookings repository.
/// يحدّث أوقات الحجز أو عدد الضيوف عبر مستودع الحجوزات.
class UpdateBookingUseCase implements UseCase<bool, UpdateBookingParams> {
  /// Repository that performs the booking update.
  /// المستودع الذي ينفذ تحديث الحجز.
  final BookingsRepository repository;

  /// Creates the use case with its repository dependency.
  /// ينشئ حالة الاستخدام مع اعتماد المستودع.
  UpdateBookingUseCase(this.repository);

  @override

  /// Delegates the update request for a single booking id.
  /// يفوض طلب التحديث لمعرّف حجز واحد.
  Future<Either<Failure, bool>> call(UpdateBookingParams params) async {
    return await repository.updateBooking(
      bookingId: params.bookingId,
      checkIn: params.checkIn,
      checkOut: params.checkOut,
      guestsCount: params.guestsCount,
    );
  }
}

/// Parameters required to update one booking.
/// المعاملات المطلوبة لتحديث حجز واحد.
class UpdateBookingParams extends Equatable {
  /// Identifier of the booking to update.
  /// معرّف الحجز المطلوب تحديثه.
  final String bookingId;

  /// Optional new check-in time.
  /// وقت تسجيل الوصول الجديد الاختياري.
  final DateTime? checkIn;

  /// Optional new check-out time.
  /// وقت تسجيل المغادرة الجديد الاختياري.
  final DateTime? checkOut;

  /// Optional new guest count.
  /// العدد الجديد للضيوف اختياريًا.
  final int? guestsCount;

  /// Creates the update parameters for a booking.
  /// ينشئ معاملات التحديث لحجز واحد.
  const UpdateBookingParams({
    required this.bookingId,
    this.checkIn,
    this.checkOut,
    this.guestsCount,
  });

  @override

  /// Comparison keys for the booking and any changed timing or guest values.
  /// مفاتيح المقارنة للحجز وأي قيم زمنية أو عدد ضيوف تم تغييرها.
  List<Object?> get props => [bookingId, checkIn, checkOut, guestsCount];
}
