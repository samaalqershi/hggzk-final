import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/models/paginated_result.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../../../../../core/enums/booking_status.dart';
import '../../entities/booking.dart';
import '../../repositories/bookings_repository.dart';

/// Fetches bookings for a specific user with optional paging and filters.
/// يجلب الحجوزات الخاصة بمستخدم محدد مع التصفح والفلاتر الاختيارية.
class GetBookingsByUserUseCase
    implements UseCase<PaginatedResult<Booking>, GetBookingsByUserParams> {
  /// Repository used to query bookings by user.
  /// المستودع المستخدم لاستعلام الحجوزات بحسب المستخدم.
  final BookingsRepository repository;

  /// Creates the use case with the bookings repository dependency.
  /// ينشئ حالة الاستخدام مع اعتماد مستودع الحجوزات.
  GetBookingsByUserUseCase(this.repository);

  @override

  /// Delegates the user-scoped booking query to the repository.
  /// يفوض استعلام الحجوزات المرتبط بالمستخدم إلى المستودع.
  Future<Either<Failure, PaginatedResult<Booking>>> call(
    GetBookingsByUserParams params,
  ) async {
    return await repository.getBookingsByUser(
      userId: params.userId,
      pageNumber: params.pageNumber,
      pageSize: params.pageSize,
      status: params.status,
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

/// Parameters for loading bookings by user.
/// معاملات تحميل الحجوزات حسب المستخدم.
class GetBookingsByUserParams extends Equatable {
  /// Identifier of the user whose bookings should be loaded.
  /// معرّف المستخدم الذي يجب تحميل حجوزاته.
  final String userId;

  /// Optional page number for pagination.
  /// رقم الصفحة الاختياري للتصفح.
  final int? pageNumber;

  /// Optional page size for pagination.
  /// حجم الصفحة الاختياري للتصفح.
  final int? pageSize;

  /// Optional booking status filter.
  /// فلتر اختياري لحالة الحجز.
  final BookingStatus? status;

  /// Optional guest-name search text.
  /// نص بحث اختياري باسم الضيف.
  final String? guestNameOrEmail;

  /// Optional unit filter when the user bookings should be narrowed to a unit.
  /// فلتر وحدة اختياري عند تضييق حجوزات المستخدم إلى وحدة محددة.
  final String? unitId;

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

  /// Creates a user-scoped booking query with optional paging and filters.
  /// ينشئ استعلام حجوزات خاصًا بمستخدم مع التصفح والفلاتر الاختيارية.
  const GetBookingsByUserParams({
    required this.userId,
    this.pageNumber,
    this.pageSize,
    this.status,
    this.guestNameOrEmail,
    this.unitId,
    this.bookingSource,
    this.isWalkIn,
    this.minTotalPrice,
    this.minGuestsCount,
    this.sortBy,
  });

  @override

  /// Comparison keys for the user scope and all active filters.
  /// مفاتيح المقارنة لنطاق المستخدم وكل الفلاتر النشطة.
  List<Object?> get props => [
        userId,
        pageNumber,
        pageSize,
        status,
        guestNameOrEmail,
        unitId,
        bookingSource,
        isWalkIn,
        minTotalPrice,
        minGuestsCount,
        sortBy,
      ];
}
