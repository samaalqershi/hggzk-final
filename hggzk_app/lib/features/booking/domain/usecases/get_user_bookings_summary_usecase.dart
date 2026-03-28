import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/booking_repository.dart';

/// العربية: ينفذ حالة الاستخدام `GetUserBookingsSummaryUseCase`.
class GetUserBookingsSummaryUseCase
    implements UseCase<Map<String, dynamic>, GetUserBookingsSummaryParams> {
  /// العربية: يخزن القيمة `repository`.
  final BookingRepository repository;

  /// العربية: ينشئ مثيلًا جديدًا من `GetUserBookingsSummaryUseCase`.
  GetUserBookingsSummaryUseCase(this.repository);

  /// العربية: ينفذ السلوك الرئيسي الذي يقدمه هذا الكائن القابل للاستدعاء.
  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      GetUserBookingsSummaryParams params) async {
    return await repository.getUserBookingSummary(
      userId: params.userId,
      year: params.year,
    );
  }
}

/// العربية: يمثل `GetUserBookingsSummaryParams`.
class GetUserBookingsSummaryParams extends Equatable {
  /// العربية: يخزن القيمة `userId`.
  final String userId;

  /// العربية: يخزن القيمة `year`.
  final int? year;

  /// العربية: ينشئ مثيلًا جديدًا من `GetUserBookingsSummaryParams`.
  const GetUserBookingsSummaryParams({
    required this.userId,
    this.year,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [userId, year];
}
