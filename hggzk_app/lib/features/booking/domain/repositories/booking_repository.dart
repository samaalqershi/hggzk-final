import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../entities/booking.dart';
import '../entities/booking_request.dart';
import '../entities/unit_available_days.dart';
import '../entities/unit_availability.dart';

/// Contract for booking creation, cancellation, lookup, and availability checks.
/// عقد لإنشاء الحجز وإلغائه والبحث عنه وفحص التوفر.
abstract class BookingRepository {
  /// ينشئ حجزًا جديدًا من حمولة الطلب المقدمة.
  Future<Either<Failure, Booking>> createBooking(BookingRequest request);

  /// Loads the detailed booking record for the current viewer.
  /// يجلب سجل الحجز التفصيلي للمستخدم الحالي.
  Future<Either<Failure, Booking>> getBookingDetails({
    required String bookingId,
    required String userId,
  });

  /// Cancels an existing booking and optionally requests a refund.
  /// يلغي حجزًا قائمًا ويمكنه طلب استرداد المبلغ اختياريًا.
  Future<Either<Failure, bool>> cancelBooking({
    required String bookingId,
    required String userId,
    required String reason,
    bool refundPayments = false,
  });

  /// Exposes a paginated list of bookings for one user.
  /// يعيد قائمة مجزأة من حجوزات مستخدم واحد.
  Future<Either<Failure, PaginatedResult<Booking>>> getUserBookings({
    required String userId,
    String? status,
    int pageNumber = 1,
    int pageSize = 10,
  });

  /// Exposes booking aggregates such as counts by status or year.
  /// يعيد ملخصات الحجز مثل العد حسب الحالة أو السنة.
  Future<Either<Failure, Map<String, dynamic>>> getUserBookingSummary({
    required String userId,
    int? year,
  });

  /// Adds additional services to an existing booking.
  /// يضيف خدمات إضافية إلى حجز قائم.
  Future<Either<Failure, Booking>> addServicesToBooking({
    required String bookingId,
    required String serviceId,
    required int quantity,
  });

  /// Checks whether a unit is available for the requested dates and guests.
  /// يتحقق من توفر الوحدة للتواريخ وعدد الضيوف المطلوبين.
  Future<Either<Failure, UnitAvailability>> checkAvailability({
    required String unitId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int adultsCount,
    required int childrenCount,
    required int guestsCount,
    String? excludeBookingId,
  });

  /// يعيد تقويم الأيام المتاحة لوحدة معينة.
  Future<Either<Failure, UnitAvailableDays>> getUnitAvailableDays({
    required String unitId,
    int months = 3,
    String? excludeBookingId,
  });

  /// Updates the booking dates, guests, or services.
  /// يحدّث تواريخ الحجز أو الضيوف أو الخدمات.
  Future<Either<Failure, bool>> updateBooking({
    required String bookingId,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guestsCount,
    List<Map<String, dynamic>>? services,
  });
}
