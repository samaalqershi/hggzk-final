import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

/// العربية: ينفذ حالة الاستخدام `GetUserBookingsUseCase`.
class GetUserBookingsUseCase
    implements UseCase<PaginatedResult<Booking>, GetUserBookingsParams> {
  /// العربية: يخزن القيمة `repository`.
  final BookingRepository repository;

  /// العربية: ينشئ مثيلًا جديدًا من `GetUserBookingsUseCase`.
  GetUserBookingsUseCase(this.repository);

  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, PaginatedResult<Booking>>> call(
      GetUserBookingsParams params) async {
    return await repository.getUserBookings(
      userId: params.userId,
      status: params.status,
      pageNumber: params.pageNumber,
      pageSize: params.pageSize,
    );
  }
}

/// العربية: يمثل `GetUserBookingsParams`.
class GetUserBookingsParams extends Equatable {
  /// العربية: يخزن القيمة `userId`.
  final String userId;

  /// العربية: يخزن القيمة `status`.
  final String? status;

  /// العربية: يخزن القيمة `pageNumber`.
  final int pageNumber;

  /// العربية: يخزن القيمة `pageSize`.
  final int pageSize;

  /// العربية: ينشئ مثيلًا جديدًا من `GetUserBookingsParams`.
  const GetUserBookingsParams({
    required this.userId,
    this.status,
    this.pageNumber = 1,
    this.pageSize = 10,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [userId, status, pageNumber, pageSize];
}
