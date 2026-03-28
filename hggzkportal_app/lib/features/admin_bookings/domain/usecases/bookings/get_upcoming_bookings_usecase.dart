import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/models/paginated_result.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../entities/booking.dart';
import '../../repositories/bookings_repository.dart';
import '../../../../../../core/enums/booking_status.dart';

/// Retrieves upcoming bookings within a configurable horizon window.
/// يسترجع الحجوزات القادمة ضمن نافذة زمنية قابلة للضبط.
class GetUpcomingBookingsUseCase
    extends UseCase<PaginatedResult<Booking>, GetUpcomingBookingsParams> {
  /// Repository used to query either property-based or date-range bookings.
  /// المستودع المستخدم للاستعلام عن الحجوزات حسب العقار أو النطاق الزمني.
  final BookingsRepository repository;

  /// Creates the use case with the bookings repository dependency.
  /// ينشئ حالة الاستخدام مع اعتماد مستودع الحجوزات.
  GetUpcomingBookingsUseCase(this.repository);

  @override

  /// Chooses the correct repository query for upcoming bookings and forwards all optional filters.
  /// يختار استعلام المستودع المناسب للحجوزات القادمة ويمرر جميع الفلاتر الاختيارية.
  Future<Either<Failure, PaginatedResult<Booking>>> call(
    GetUpcomingBookingsParams params,
  ) async {
    final DateTime now = params.now ?? DateTime.now();
    final DateTime end = now.add(Duration(days: params.horizonDays));

    if (params.propertyId != null) {
      return repository.getBookingsByProperty(
        propertyId: params.propertyId!,
        startDate: now,
        endDate: end,
        pageNumber: params.pageNumber,
        pageSize: params.pageSize,
        status: params.status,
        paymentStatus: params.paymentStatus,
        guestNameOrEmail: params.guestNameOrEmail,
        bookingSource: params.bookingSource,
        isWalkIn: params.isWalkIn,
        minTotalPrice: params.minTotalPrice,
        minGuestsCount: params.minGuestsCount,
        sortBy: params.sortBy,
      );
    }

    // fallback to date-range query with optional filters
    return repository.getBookingsByDateRange(
      startDate: now,
      endDate: end,
      pageNumber: params.pageNumber,
      pageSize: params.pageSize,
      userId: params.userId,
      guestNameOrEmail: params.guestNameOrEmail,
      unitId: params.unitId,
      bookingSource: params.bookingSource,
    );
  }
}

/// Parameters for loading upcoming bookings.
/// معاملات تحميل الحجوزات القادمة.
class GetUpcomingBookingsParams extends Equatable {
  /// Number of days ahead to treat as the upcoming horizon.
  /// عدد الأيام للأمام الذي يمثل نافذة الحجوزات القادمة.
  final int horizonDays;

  /// Optional reference timestamp used instead of the current time.
  /// مرجع زمني اختياري يستخدم بدل الوقت الحالي.
  final DateTime? now;

  /// Optional page number for pagination.
  /// رقم الصفحة الاختياري للتصفح.
  final int? pageNumber;

  /// Optional page size for pagination.
  /// حجم الصفحة الاختياري للتصفح.
  final int? pageSize;

  /// Optional property scope for property-based queries.
  /// نطاق عقار اختياري للاستعلامات المرتبطة بعقار.
  final String? propertyId;

  /// Optional user scope for date-range queries.
  /// نطاق مستخدم اختياري لاستعلامات النطاق الزمني.
  final String? userId;

  /// Optional unit scope for date-range queries.
  /// نطاق وحدة اختياري لاستعلامات النطاق الزمني.
  final String? unitId;

  /// Optional guest-name search text.
  /// نص بحث اختياري باسم الضيف.
  final String? guestNameOrEmail;

  /// Optional booking source filter.
  /// فلتر اختياري لمصدر الحجز.
  final String? bookingSource;

  /// Optional booking status filter.
  /// فلتر اختياري لحالة الحجز.
  final BookingStatus? status;

  /// Optional payment status filter.
  /// فلتر اختياري لحالة الدفع.
  final String? paymentStatus;

  /// Optional flag limiting results to walk-in bookings.
  /// علم اختياري يقصر النتائج على الحجوزات المباشرة.
  final bool? isWalkIn;

  /// Optional minimum total price filter.
  /// فلتر اختياري للحد الأدنى من السعر الإجمالي.
  final double? minTotalPrice;

  /// Optional minimum guests-count filter.
  /// فلتر اختياري للحد الأدنى من عدد الضيوف.
  final int? minGuestsCount;

  /// Optional sort expression applied by the backend.
  /// تعبير فرز اختياري يطبقه الخادم.
  final String? sortBy;

  /// Creates an upcoming-bookings query with optional paging and filters.
  /// ينشئ استعلام الحجوزات القادمة مع خيارات التصفح والفلاتر.
  const GetUpcomingBookingsParams({
    this.horizonDays = 30,
    this.now,
    this.pageNumber,
    this.pageSize,
    this.propertyId,
    this.userId,
    this.unitId,
    this.guestNameOrEmail,
    this.bookingSource,
    this.status,
    this.paymentStatus,
    this.isWalkIn,
    this.minTotalPrice,
    this.minGuestsCount,
    this.sortBy,
  });

  @override

  /// Comparison keys for the horizon window and all active filters.
  /// مفاتيح المقارنة لنافذة الأيام وكل الفلاتر النشطة.
  List<Object?> get props => [
        horizonDays,
        now,
        pageNumber,
        pageSize,
        propertyId,
        userId,
        unitId,
        guestNameOrEmail,
        bookingSource,
        status,
        paymentStatus,
        isWalkIn,
        minTotalPrice,
        minGuestsCount,
        sortBy,
      ];
}
