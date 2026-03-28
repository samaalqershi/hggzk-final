import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/models/paginated_result.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../entities/booking.dart';
import '../../repositories/bookings_repository.dart';

/// Fetches bookings that fall within a given date window, with optional search and paging filters.
/// يجلب الحجوزات الواقعة ضمن نافذة زمنية محددة مع فلاتر اختيارية للبحث والتصفح.
class GetBookingsByDateRangeUseCase
    implements UseCase<PaginatedResult<Booking>, GetBookingsByDateRangeParams> {
  /// Repository used to request the filtered booking page.
  /// المستودع المستخدم لطلب صفحة الحجوزات المفلترة.
  final BookingsRepository repository;

  /// Creates the use case with the bookings repository dependency.
  /// ينشئ حالة الاستخدام مع اعتماد المستودع الخاص بالحجوزات.
  GetBookingsByDateRangeUseCase(this.repository);

  @override

  /// Delegates the date-range query to the repository with all optional filters.
  /// يفوض استعلام النطاق الزمني إلى المستودع مع جميع الفلاتر الاختيارية.
  Future<Either<Failure, PaginatedResult<Booking>>> call(
    GetBookingsByDateRangeParams params,
  ) async {
    return await repository.getBookingsByDateRange(
      startDate: params.startDate,
      endDate: params.endDate,
      pageNumber: params.pageNumber,
      pageSize: params.pageSize,
      userId: params.userId,
      guestNameOrEmail: params.guestNameOrEmail,
      unitId: params.unitId,
      bookingSource: params.bookingSource,
      isWalkIn: params.isWalkIn,
      minTotalPrice: params.minTotalPrice,
      minGuestsCount: params.minGuestsCount,
      sortBy: params.sortBy,
    );
  }
}

/// Parameters that define a date-range booking query and its optional filters.
/// معاملات تحدد استعلام الحجوزات بحسب النطاق الزمني والفلاتر الاختيارية.
class GetBookingsByDateRangeParams extends Equatable {
  /// Inclusive start of the booking search window.
  /// بداية نافذة البحث عن الحجوزات بشكل شامل.
  final DateTime startDate;

  /// Inclusive end of the booking search window.
  /// نهاية نافذة البحث عن الحجوزات بشكل شامل.
  final DateTime endDate;

  /// Optional page number requested from the backend.
  /// رقم الصفحة المطلوب من الخادم بشكل اختياري.
  final int? pageNumber;

  /// Optional page size requested from the backend.
  /// حجم الصفحة المطلوب من الخادم بشكل اختياري.
  final int? pageSize;

  /// Optional user filter when results should be scoped to one user.
  /// فلتر مستخدم اختياري عندما تُحصر النتائج في مستخدم واحد.
  final String? userId;

  /// Optional guest name or email search text.
  /// نص بحث اختياري لاسم الضيف أو بريده الإلكتروني.
  final String? guestNameOrEmail;

  /// Optional unit identifier to narrow the result set.
  /// معرّف الوحدة الاختياري لتضييق النتائج.
  final String? unitId;

  /// Optional booking source filter such as website or walk-in.
  /// فلتر اختياري لمصدر الحجز مثل الموقع أو الحجز المباشر.
  final String? bookingSource;

  /// Optional flag that limits results to walk-in bookings.
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

  /// Creates a date-range booking query with paging and filter options.
  /// ينشئ استعلام حجوزات بالنطاق الزمني مع خيارات التصفح والفلاتر.
  const GetBookingsByDateRangeParams({
    required this.startDate,
    required this.endDate,
    this.pageNumber,
    this.pageSize,
    this.userId,
    this.guestNameOrEmail,
    this.unitId,
    this.bookingSource,
    this.isWalkIn,
    this.minTotalPrice,
    this.minGuestsCount,
    this.sortBy,
  });

  @override

  /// Comparison keys for the date range and every active filter.
  /// مفاتيح المقارنة للنطاق الزمني وكل فلتر نشط.
  List<Object?> get props => [
        startDate,
        endDate,
        pageNumber,
        pageSize,
        userId,
        guestNameOrEmail,
        unitId,
        bookingSource,
        isWalkIn,
        minTotalPrice,
        minGuestsCount,
        sortBy,
      ];
}
