import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

/// العربية: ينفذ حالة الاستخدام `GetBookingDetailsUseCase`.
class GetBookingDetailsUseCase
    implements UseCase<Booking, GetBookingDetailsParams> {
  /// العربية: يخزن القيمة `repository`.
  final BookingRepository repository;

  /// العربية: ينشئ مثيلًا جديدًا من `GetBookingDetailsUseCase`.
  GetBookingDetailsUseCase(this.repository);

  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, Booking>> call(GetBookingDetailsParams params) async {
    return await repository.getBookingDetails(
      bookingId: params.bookingId,
      userId: params.userId,
    );
  }
}

/// العربية: يمثل `GetBookingDetailsParams`.
class GetBookingDetailsParams extends Equatable {
  /// العربية: يخزن القيمة `bookingId`.
  final String bookingId;

  /// العربية: يخزن القيمة `userId`.
  final String userId;

  /// العربية: ينشئ مثيلًا جديدًا من `GetBookingDetailsParams`.
  const GetBookingDetailsParams({
    required this.bookingId,
    required this.userId,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [bookingId, userId];
}
