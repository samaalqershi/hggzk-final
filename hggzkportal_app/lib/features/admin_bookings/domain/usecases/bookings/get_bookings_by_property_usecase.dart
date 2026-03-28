import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/models/paginated_result.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../../../../../core/enums/booking_status.dart';
import '../../entities/booking.dart';
import '../../repositories/bookings_repository.dart';

/// Fetches bookings for a specific property with paging and booking filters.
/// يجلب الحجوزات الخاصة بعقار محدد مع التصفح وفلاتر الحجز.
class GetBookingsByPropertyUseCase
    implements UseCase<PaginatedResult<Booking>, GetBookingsByPropertyParams> {
  /// Repository used to query property-scoped bookings.
  /// المستودع المستخدم لاستعلام الحجوزات المرتبطة بعقار.
  final BookingsRepository repository;

  /// Creates the use case with the bookings repository dependency.
  /// ينشئ حالة الاستخدام مع اعتماد مستودع الحجوزات.
  GetBookingsByPropertyUseCase(this.repository);

  @override

  /// Delegates the property-scoped booking query to the repository.
  /// يفوض استعلام الحجوزات المرتبط بالعقار إلى المستودع.
  Future<Either<Failure, PaginatedResult<Booking>>> call(
    GetBookingsByPropertyParams params,
  ) async {
    return await repository.getBookingsByProperty(
      propertyId: params.propertyId,
      startDate: params.startDate,
      endDate: params.endDate,
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
}

/// Parameters for loading bookings by property.
/// معاملات تحميل الحجوزات حسب العقار.
class GetBookingsByPropertyParams extends Equatable {
  /// Identifier of the property whose bookings should be loaded.
  /// معرّف العقار الذي يجب تحميل حجوزاته.
  final String propertyId;

  /// Optional lower bound for the booking date range.
  /// حد سفلي اختياري لنطاق تاريخ الحجز.
  final DateTime? startDate;

  /// Optional upper bound for the booking date range.
  /// حد علوي اختياري لنطاق تاريخ الحجز.
  final DateTime? endDate;

  /// Optional page number for pagination.
  /// رقم الصفحة الاختياري للتصفح.
  final int? pageNumber;

  /// Optional page size for pagination.
  /// حجم الصفحة الاختياري للتصفح.
  final int? pageSize;

  /// Optional booking status filter.
  /// فلتر اختياري لحالة الحجز.
  final BookingStatus? status;

  /// Optional payment status filter.
  /// فلتر اختياري لحالة الدفع.
  final String? paymentStatus;

  /// Optional guest-name search text.
  /// نص بحث اختياري باسم الضيف.
  final String? guestNameOrEmail;

  /// Optional booking source filter.
  /// فلتر اختياري لمصدر الحجز.
  final String? bookingSource;

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

  /// Creates a property-scoped booking query with optional paging and filters.
  /// ينشئ استعلام حجوزات خاصًا بعقار مع التصفح والفلاتر الاختيارية.
  const GetBookingsByPropertyParams({
    required this.propertyId,
    this.startDate,
    this.endDate,
    this.pageNumber,
    this.pageSize,
    this.status,
    this.paymentStatus,
    this.guestNameOrEmail,
    this.bookingSource,
    this.isWalkIn,
    this.minTotalPrice,
    this.minGuestsCount,
    this.sortBy,
  });

  @override

  /// Comparison keys for the property scope and all active filters.
  /// مفاتيح المقارنة لنطاق العقار وكل الفلاتر النشطة.
  List<Object?> get props => [
        propertyId,
        startDate,
        endDate,
        pageNumber,
        pageSize,
        status,
        paymentStatus,
        guestNameOrEmail,
        bookingSource,
        isWalkIn,
        minTotalPrice,
        minGuestsCount,
        sortBy,
      ];
}
