import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/models/paginated_result.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../entities/booking.dart';
import '../../repositories/bookings_repository.dart';

/// Fetches bookings for a specific unit with optional date and paging filters.
/// يجلب الحجوزات الخاصة بوحدة محددة مع فلاتر اختيارية للتاريخ والتصفح.
class GetBookingsByUnitUseCase
    implements UseCase<PaginatedResult<Booking>, GetBookingsByUnitParams> {
  /// Repository used to query bookings by unit.
  /// المستودع المستخدم لاستعلام الحجوزات بحسب الوحدة.
  final BookingsRepository repository;

  /// Creates the use case with the bookings repository dependency.
  /// ينشئ حالة الاستخدام مع اعتماد مستودع الحجوزات.
  GetBookingsByUnitUseCase(this.repository);

  @override

  /// Delegates the unit-scoped booking query to the repository.
  /// يفوض استعلام الحجوزات المرتبط بالوحدة إلى المستودع.
  Future<Either<Failure, PaginatedResult<Booking>>> call(
    GetBookingsByUnitParams params,
  ) async {
    return await repository.getBookingsByUnit(
      unitId: params.unitId,
      startDate: params.startDate,
      endDate: params.endDate,
      pageNumber: params.pageNumber,
      pageSize: params.pageSize,
    );
  }
}

/// Parameters for loading bookings by unit.
/// معاملات تحميل الحجوزات حسب الوحدة.
class GetBookingsByUnitParams extends Equatable {
  /// Identifier of the unit whose bookings should be loaded.
  /// معرّف الوحدة التي يجب تحميل حجوزاتها.
  final String unitId;

  /// Optional lower bound for the booking date range.
  /// حد سفلي اختياري لنطاق تاريخ الحجز.
  final DateTime? startDate;

  /// Optional upper bound for the booking date range.
  /// حد علوي اختياري لنطاق تاريخ الحجز.
  final DateTime? endDate;

  /// Optional page number for the paginated result.
  /// رقم الصفحة الاختياري للنتيجة المصفّحة.
  final int? pageNumber;

  /// Optional page size for the paginated result.
  /// حجم الصفحة الاختياري للنتيجة المصفّحة.
  final int? pageSize;

  /// Creates a unit-scoped booking query with optional paging and date filters.
  /// ينشئ استعلام حجوزات خاصًا بوحدة مع فلاتر تاريخ وتصفح اختيارية.
  const GetBookingsByUnitParams({
    required this.unitId,
    this.startDate,
    this.endDate,
    this.pageNumber,
    this.pageSize,
  });

  @override

  /// Comparison keys for the targeted unit and any paging or date filters.
  /// مفاتيح المقارنة للوحدة المستهدفة وأي فلاتر للتاريخ أو التصفح.
  List<Object?> get props => [
        unitId,
        startDate,
        endDate,
        pageNumber,
        pageSize,
      ];
}
