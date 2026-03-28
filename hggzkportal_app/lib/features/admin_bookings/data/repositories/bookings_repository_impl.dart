import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/models/paginated_result.dart';
import '../../../../../core/enums/booking_status.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_details.dart';
import '../../domain/entities/booking_report.dart';
import '../../domain/entities/booking_trends.dart';
import '../../domain/entities/booking_window_analysis.dart';
import '../../domain/repositories/bookings_repository.dart';
import '../../domain/usecases/register_booking_payment.dart';
import '../datasources/bookings_local_datasource.dart';
import '../datasources/bookings_remote_datasource.dart';

/// يربط مستودع الحجوزات بين المصدر البعيد والكاش المحلي مع مراعاة حالة
/// الاتصال قبل اتخاذ مسار التنفيذ.
/// Bridges the bookings repository between the remote source and the local
/// cache while considering connectivity before choosing a code path.
class BookingsRepositoryImpl implements BookingsRepository {
  /// المصدر البعيد الذي ينفذ أوامر واستعلامات الحجوزات الفعلية.
  /// Remote datasource that performs the actual booking commands and queries.
  final BookingsRemoteDataSource remoteDataSource;

  /// المصدر المحلي الذي يحتفظ بلقطات الحجز القابلة للاسترجاع.
  /// Local datasource that keeps recoverable booking snapshots.
  final BookingsLocalDataSource localDataSource;

  /// فاحص الاتصال الذي يحدد هل نستخدم الشبكة أم الكاش.
  /// Connectivity checker that decides whether to use the network or cache.
  final NetworkInfo networkInfo;

  /// يربط المستودع بالمصادر المحقونة التي يعتمد عليها في الجلب والتخزين.
  /// Binds the repository to the injected sources it uses for fetching and
  /// caching.
  BookingsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  @override

  /// يلغي الحجز عبر الشبكة عندما تكون متاحة، وإلا يرجع فشل اتصال.
  /// Cancels the booking over the network when available, otherwise returns a
  /// connectivity failure.
  Future<Either<Failure, bool>> cancelBooking({
    required String bookingId,
    required String cancellationReason,
    bool refundPayments = false,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.cancelBooking(
          bookingId: bookingId,
          cancellationReason: cancellationReason,
          refundPayments: refundPayments,
        );
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure.meta(
          message: e.message,
          code: e.code,
          showAsDialog: e.showAsDialog,
        ));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override

  /// يحدث الحجز عبر الشبكة مع تحويل أي استثناءات إلى فشل نطاقي.
  /// Updates the booking over the network while mapping exceptions to domain
  /// failures.
  Future<Either<Failure, bool>> updateBooking({
    required String bookingId,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guestsCount,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.updateBooking(
          bookingId: bookingId,
          checkIn: checkIn,
          checkOut: checkOut,
          guestsCount: guestsCount,
        );
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override

  /// يؤكد الحجز عند توفر الاتصال وإلا يرجع فشل شبكة مباشر.
  /// Confirms the booking when connected, otherwise returns a direct network
  /// failure.
  Future<Either<Failure, bool>> confirmBooking(
      {required String bookingId}) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.confirmBooking(
          bookingId: bookingId,
        );
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override

  /// يسجل وصول الضيف إذا كانت الشبكة متاحة.
  /// Records guest check-in when the network is available.
  Future<Either<Failure, bool>> checkIn({required String bookingId}) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.checkIn(
          bookingId: bookingId,
        );
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override

  /// يسجل خروج الضيف إذا كانت الشبكة متاحة.
  /// Records guest check-out when the network is available.
  Future<Either<Failure, bool>> checkOut({required String bookingId}) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.checkOut(
          bookingId: bookingId,
        );
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override

  /// يكمل الحجز ويعيد النتيجة داخل `Either` وفق حالة الاتصال.
  /// Completes the booking and returns the result inside an `Either`
  /// depending on connectivity.
  Future<Either<Failure, bool>> completeBooking(
      {required String bookingId}) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.completeBooking(
          bookingId: bookingId,
        );
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override

  /// يسجل دفعة الحجز عبر الشبكة ويعيد كيان الدفع الناتج.
  /// Registers a booking payment over the network and returns the resulting
  /// payment entity.
  Future<Either<Failure, Payment>> registerBookingPayment(
      RegisterPaymentParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.registerBookingPayment(params);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override

  /// يضيف خدمة إلى الحجز عبر الخادم عندما يكون الاتصال متاحًا.
  /// Adds a service to the booking on the server when connectivity exists.
  Future<Either<Failure, bool>> addServiceToBooking({
    required String bookingId,
    required String serviceId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.addServiceToBooking(
          bookingId: bookingId,
          serviceId: serviceId,
        );
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override

  /// يزيل خدمة من الحجز عبر الخادم أو يرجع فشل شبكة إذا تعذر الوصول.
  /// Removes a service from the booking on the server or returns a network
  /// failure when unreachable.
  Future<Either<Failure, bool>> removeServiceFromBooking({
    required String bookingId,
    required String serviceId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.removeServiceFromBooking(
          bookingId: bookingId,
          serviceId: serviceId,
        );
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override

  /// يجلب خدمات الحجز ويعيدها ككيانات نطاقية جاهزة للاستهلاك.
  /// Fetches booking services and returns them as ready-to-consume domain
  /// entities.
  Future<Either<Failure, List<Service>>> getBookingServices({
    required String bookingId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getBookingServices(
          bookingId: bookingId,
        );
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override

  /// يجلب الحجز من الشبكة ويخزنه محليًا، ثم يعود للكاش عند انقطاع الاتصال.
  /// Fetches the booking from the network and caches it locally, then falls
  /// back to the cache when offline.
  Future<Either<Failure, Booking>> getBookingById({
    required String bookingId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getBookingById(
          bookingId: bookingId,
        );
        // Cache the booking
        await localDataSource.cacheBookingDetails(bookingId, result);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      // Try to get from cache
      try {
        final cachedBooking =
            await localDataSource.getCachedBookingDetails(bookingId);
        if (cachedBooking != null) {
          return Right(cachedBooking);
        } else {
          return const Left(CacheFailure('No cached data available'));
        }
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override

  /// يجلب تفاصيل الحجز الكاملة من الشبكة عندما تكون متاحة.
  /// Fetches the full booking details from the network when available.
  Future<Either<Failure, BookingDetails>> getBookingDetails({
    required String bookingId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getBookingDetails(
          bookingId: bookingId,
        );
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override

  /// يجلب الحجوزات ضمن نطاق تاريخي ويحوّل النتيجة إلى كيان صفحات نطاقي.
  /// Fetches bookings within a date range and converts the result into a
  /// domain paginated entity.
  Future<Either<Failure, PaginatedResult<Booking>>> getBookingsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int? pageNumber,
    int? pageSize,
    String? userId,
    String? guestNameOrEmail,
    String? unitId,
    String? bookingSource,
    bool? isWalkIn,
    double? minTotalPrice,
    int? minGuestsCount,
    String? sortBy,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteBookings = await remoteDataSource.getBookingsByDateRange(
          startDate: startDate,
          endDate: endDate,
          pageNumber: pageNumber,
          pageSize: pageSize,
          userId: userId,
          guestNameOrEmail: guestNameOrEmail,
          unitId: unitId,
          bookingSource: bookingSource,
          isWalkIn: isWalkIn,
          minTotalPrice: minTotalPrice,
          minGuestsCount: minGuestsCount,
          sortBy: sortBy,
        );

        return Right(PaginatedResult<Booking>(
          items: remoteBookings.items,
          pageNumber: remoteBookings.pageNumber,
          pageSize: remoteBookings.pageSize,
          totalCount: remoteBookings.totalCount,
          metadata: remoteBookings.metadata,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      // Try to get from cache
      try {
        final cachedBookings = await localDataSource.getCachedBookings();
        return Right(PaginatedResult<Booking>(
          items: cachedBookings,
          totalCount: cachedBookings.length,
          pageNumber: 1,
          pageSize: cachedBookings.length,
        ));
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override

  /// يجلب الحجوزات الخاصة بعقار محدد ويحوّلها إلى صفحات نطاقية.
  /// Fetches bookings for a specific property and converts them into domain
  /// pages.
  Future<Either<Failure, PaginatedResult<Booking>>> getBookingsByProperty({
    required String propertyId,
    DateTime? startDate,
    DateTime? endDate,
    int? pageNumber,
    int? pageSize,
    BookingStatus? status,
    String? paymentStatus,
    String? guestNameOrEmail,
    String? bookingSource,
    bool? isWalkIn,
    double? minTotalPrice,
    int? minGuestsCount,
    String? sortBy,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getBookingsByProperty(
          propertyId: propertyId,
          startDate: startDate,
          endDate: endDate,
          pageNumber: pageNumber,
          pageSize: pageSize,
          status: status,
          paymentStatus: paymentStatus,
          guestNameOrEmail: guestNameOrEmail,
          bookingSource: bookingSource,
          isWalkIn: isWalkIn,
          minTotalPrice: minTotalPrice,
          minGuestsCount: minGuestsCount,
          sortBy: sortBy,
        );

        return Right(PaginatedResult<Booking>(
          items: result.items,
          totalCount: result.totalCount,
          pageNumber: result.pageNumber,
          pageSize: result.pageSize,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override

  /// يجلب الحجوزات حسب الحالة المطلوبة.
  /// Fetches bookings by the requested status.
  Future<Either<Failure, PaginatedResult<Booking>>> getBookingsByStatus({
    required BookingStatus status,
    int? pageNumber,
    int? pageSize,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getBookingsByStatus(
          status: status,
          pageNumber: pageNumber,
          pageSize: pageSize,
        );

        return Right(PaginatedResult<Booking>(
          items: result.items,
          totalCount: result.totalCount,
          pageNumber: result.pageNumber,
          pageSize: result.pageSize,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override

  /// يجلب الحجوزات المرتبطة بوحدة محددة ضمن فترة اختيارية.
  /// Fetches bookings linked to a specific unit within an optional period.
  Future<Either<Failure, PaginatedResult<Booking>>> getBookingsByUnit({
    required String unitId,
    DateTime? startDate,
    DateTime? endDate,
    int? pageNumber,
    int? pageSize,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getBookingsByUnit(
          unitId: unitId,
          startDate: startDate,
          endDate: endDate,
          pageNumber: pageNumber,
          pageSize: pageSize,
        );

        return Right(PaginatedResult<Booking>(
          items: result.items,
          totalCount: result.totalCount,
          pageNumber: result.pageNumber,
          pageSize: result.pageSize,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override

  /// يجلب الحجوزات الخاصة بمستخدم محدد ويعيدها كصفحات نطاقية.
  /// Fetches bookings for a specific user and returns them as paginated
  /// domain data.
  Future<Either<Failure, PaginatedResult<Booking>>> getBookingsByUser({
    required String userId,
    int? pageNumber,
    int? pageSize,
    BookingStatus? status,
    String? guestNameOrEmail,
    String? unitId,
    String? bookingSource,
    bool? isWalkIn,
    double? minTotalPrice,
    int? minGuestsCount,
    String? sortBy,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getBookingsByUser(
          userId: userId,
          pageNumber: pageNumber,
          pageSize: pageSize,
          status: status,
          guestNameOrEmail: guestNameOrEmail,
          unitId: unitId,
          bookingSource: bookingSource,
          isWalkIn: isWalkIn,
          minTotalPrice: minTotalPrice,
          minGuestsCount: minGuestsCount,
          sortBy: sortBy,
        );

        return Right(PaginatedResult<Booking>(
          items: result.items,
          totalCount: result.totalCount,
          pageNumber: result.pageNumber,
          pageSize: result.pageSize,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override

  /// يجلب تقرير الحجوزات الإجمالي أو يرجع خطأ شبكة عند غياب الاتصال.
  /// Fetches the aggregate booking report or returns a network failure when
  /// offline.
  Future<Either<Failure, BookingReport>> getBookingReport({
    required DateTime startDate,
    required DateTime endDate,
    String? propertyId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getBookingReport(
          startDate: startDate,
          endDate: endDate,
          propertyId: propertyId,
        );
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override

  /// يجلب بيانات الاتجاهات الزمنية للحجوزات والإيرادات والإشغال.
  /// Fetches the time-series trends for bookings, revenue, and occupancy.
  Future<Either<Failure, BookingTrends>> getBookingTrends({
    String? propertyId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getBookingTrends(
          propertyId: propertyId,
          startDate: startDate,
          endDate: endDate,
        );
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override

  /// يجلب تحليل نافذة الحجز الخاص بالعقار المطلوب.
  /// Fetches the booking-window analysis for the requested property.
  Future<Either<Failure, BookingWindowAnalysis>> getBookingWindowAnalysis({
    required String propertyId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getBookingWindowAnalysis(
          propertyId: propertyId,
        );
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
