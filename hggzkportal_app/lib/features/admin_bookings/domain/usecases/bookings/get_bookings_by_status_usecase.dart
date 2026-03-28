import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/models/paginated_result.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../../../../../core/enums/booking_status.dart';
import '../../entities/booking.dart';
import '../../repositories/bookings_repository.dart';

/// Fetches bookings for a specific status with optional paging.
/// يجلب الحجوزات لحالة محددة مع ترقيم صفحات اختياري.
class GetBookingsByStatusUseCase
    implements UseCase<PaginatedResult<Booking>, GetBookingsByStatusParams> {
  /// Repository used to query bookings by status.
  /// المستودع المستخدم لاستعلام الحجوزات بحسب الحالة.
  final BookingsRepository repository;

  /// Creates the use case with the bookings repository dependency.
  /// ينشئ حالة الاستخدام مع اعتماد مستودع الحجوزات.
  GetBookingsByStatusUseCase(this.repository);

  @override

  /// Delegates the status-based booking query to the repository.
  /// يفوض استعلام الحجوزات بحسب الحالة إلى المستودع.
  Future<Either<Failure, PaginatedResult<Booking>>> call(
    GetBookingsByStatusParams params,
  ) async {
    return await repository.getBookingsByStatus(
      status: params.status,
      pageNumber: params.pageNumber,
      pageSize: params.pageSize,
    );
  }
}

/// Parameters for loading bookings by status.
/// معاملات تحميل الحجوزات بحسب الحالة.
class GetBookingsByStatusParams extends Equatable {
  /// The booking status to filter by.
  /// حالة الحجز المطلوب التصفية بها.
  final BookingStatus status;

  /// Optional page number for pagination.
  /// رقم الصفحة الاختياري للتصفح.
  final int? pageNumber;

  /// Optional page size for pagination.
  /// حجم الصفحة الاختياري للتصفح.
  final int? pageSize;

  /// Creates a status-based booking query with optional paging.
  /// ينشئ استعلام حجوزات بحسب الحالة مع ترقيم صفحات اختياري.
  const GetBookingsByStatusParams({
    required this.status,
    this.pageNumber,
    this.pageSize,
  });

  @override

  /// Comparison keys for the selected status and any paging values.
  /// مفاتيح المقارنة للحالة المختارة وأي قيم للتصفح.
  List<Object?> get props => [status, pageNumber, pageSize];
}
