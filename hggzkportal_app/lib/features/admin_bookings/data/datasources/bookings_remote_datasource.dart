import 'package:dio/dio.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/models/paginated_result.dart';
import '../../../../../core/models/result_dto.dart';
import '../../../../../core/enums/booking_status.dart';
import '../../domain/entities/booking_details.dart';
import '../../domain/usecases/register_booking_payment.dart';
import '../models/booking_model.dart';
import '../models/booking_details_model.dart';
import '../models/booking_report_model.dart';
import '../models/booking_trends_model.dart';
import '../models/booking_window_analysis_model.dart';
import '../models/payment_model.dart' as payment_models;

/// يعرّف عمليات الوصول البعيد الخاصة بالحجوزات، من أوامر الحالة إلى
/// التقارير والتحليلات الزمنية.
/// Defines the remote booking operations, from status commands to reports and
/// time-based analyses.
abstract class BookingsRemoteDataSource {
  /// يلغي الحجز مع إرسال سبب الإلغاء وهل يجب استرجاع المدفوعات.
  /// Cancels a booking while sending the cancellation reason and whether
  /// payments should be refunded.
  Future<bool> cancelBooking({
    required String bookingId,
    required String cancellationReason,
    bool refundPayments = false,
  });

  /// يحدّث تواريخ الإقامة أو عدد الضيوف لحجز قائم.
  /// Updates stay dates or guest count for an existing booking.
  Future<bool> updateBooking({
    required String bookingId,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guestsCount,
  });

  /// يؤكد الحجز في المسار التشغيلي الحالي للخادم.
  /// Confirms the booking in the backend's current workflow.
  Future<bool> confirmBooking({required String bookingId});

  /// يسجل دخول الضيف إلى الوحدة بعد الوصول.
  /// Records the guest check-in after arrival.
  Future<bool> checkIn({required String bookingId});

  /// يسجل خروج الضيف من الوحدة بعد انتهاء الإقامة.
  /// Records the guest check-out after the stay ends.
  Future<bool> checkOut({required String bookingId});

  /// يكمل دورة الحجز وينقله إلى الحالة النهائية المنفذة.
  /// Completes the booking lifecycle and moves it to the final executed
  /// state.
  Future<bool> completeBooking({required String bookingId});

  /// يسجل دفعة جديدة مرتبطة بالحجز ويعيد تمثيلها بعد اعتماد الخادم.
  /// Registers a new booking payment and returns the server-approved
  /// representation.
  Future<Payment> registerBookingPayment(RegisterPaymentParams params);

  /// يضيف خدمة اختيارية إلى الحجز الحالي.
  /// Adds an optional service to the current booking.
  Future<bool> addServiceToBooking({
    required String bookingId,
    required String serviceId,
  });

  /// يزيل خدمة مرتبطة بالحجز الحالي.
  /// Removes a service linked to the current booking.
  Future<bool> removeServiceFromBooking({
    required String bookingId,
    required String serviceId,
  });

  /// يجلب الخدمات المضافة إلى الحجز حتى تعرضها شاشة التفاصيل أو التعديل.
  /// Fetches the services attached to a booking so the details or edit view
  /// can render them.
  Future<List<ServiceModel>> getBookingServices({required String bookingId});

  /// يجلب الحجز الأساسي بالمعرف الداخلي.
  /// Fetches the base booking record by its internal identifier.
  Future<BookingModel> getBookingById({required String bookingId});

  /// يجلب تفاصيل الحجز الكاملة بما في ذلك الدفعات والخدمات والبيانات
  /// المساندة.
  /// Fetches the full booking details including payments, services, and
  /// supporting data.
  Future<BookingDetailsModel> getBookingDetails({required String bookingId});

  /// يجلب الحجوزات ضمن نطاق تاريخي مع مرشحات إضافية للعرض الجدولي.
  /// Fetches bookings within a date range with extra filters for table
  /// rendering.
  Future<PaginatedResult<BookingModel>> getBookingsByDateRange({
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
  });

  /// يجلب الحجوزات الخاصة بعقار محدد مع مرشحات الحالة والدفع والتصفح.
  /// Fetches bookings for a specific property with status, payment, and
  /// paging filters.
  Future<PaginatedResult<BookingModel>> getBookingsByProperty({
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
  });

  /// يجلب الحجوزات المطابقة لحالة واحدة محددة.
  /// Fetches bookings that match a single status value.
  Future<PaginatedResult<BookingModel>> getBookingsByStatus({
    required BookingStatus status,
    int? pageNumber,
    int? pageSize,
  });

  /// يجلب الحجوزات المرتبطة بوحدة محددة مع نطاق زمني اختياري.
  /// Fetches bookings linked to a specific unit with an optional time range.
  Future<PaginatedResult<BookingModel>> getBookingsByUnit({
    required String unitId,
    DateTime? startDate,
    DateTime? endDate,
    int? pageNumber,
    int? pageSize,
  });

  /// يجلب الحجوزات الخاصة بمستخدم معيّن مع مرشحات إضافية اختيارية.
  /// Fetches bookings for a specific user with optional extra filters.
  Future<PaginatedResult<BookingModel>> getBookingsByUser({
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
  });

  /// يجلب تقرير الحجوزات الإجمالي ضمن نطاق زمني محدد.
  /// Fetches the aggregate booking report for a specific date range.
  Future<BookingReportModel> getBookingReport({
    required DateTime startDate,
    required DateTime endDate,
    String? propertyId,
  });

  /// يجلب اتجاهات الحجز والإيراد والإشغال ضمن النطاق الزمني المحدد.
  /// Fetches booking, revenue, and occupancy trends for the chosen time range.
  Future<BookingTrendsModel> getBookingTrends({
    String? propertyId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// يجلب تحليل نافذة الحجز للعقار المطلوب.
  /// Fetches the booking-window analysis for the requested property.
  Future<BookingWindowAnalysisModel> getBookingWindowAnalysis({
    required String propertyId,
  });
}

/// ينفذ عمليات الحجوزات البعيدة ويحوّل استجابات الـ API إلى نماذج
/// الحجز المعتمدة داخل البوابة.
/// Implements the remote booking operations and converts API responses into
/// the booking models used by the portal.
class BookingsRemoteDataSourceImpl implements BookingsRemoteDataSource {
  /// عميل الشبكة المشترك الذي يرسل أوامر واستعلامات الحجوزات إلى الخادم.
  /// Shared network client that sends booking commands and queries to the
  /// backend.
  final ApiClient apiClient;

  /// المسار الأساسي الذي تعرض منه واجهة الإدارة عمليات الحجوزات.
  /// Base endpoint through which the admin API exposes booking operations.
  static const String _baseEndpoint = '/api/admin/bookings';

  /// يربط مصدر البيانات البعيد بعميل الشبكة المحقون من طبقة الاعتماد.
  /// Binds the remote datasource to the injected network client from the DI
  /// layer.
  BookingsRemoteDataSourceImpl({required this.apiClient});
  @override

  /// يرسل طلب إلغاء الحجز مع تفاصيل السبب وخيار استرجاع المدفوعات.
  /// Sends the booking-cancellation request with the reason and optional
  /// refund flag.
  Future<bool> cancelBooking({
    required String bookingId,
    required String cancellationReason,
    bool refundPayments = false,
  }) async {
    try {
      final response = await apiClient.post(
        '$_baseEndpoint/$bookingId/cancel',
        data: {
          'bookingId': bookingId,
          'cancellationReason': cancellationReason,
          'refundPayments': refundPayments,
        },
      );

      final result = ResultDto<bool>.fromJson(
        response.data,
        (json) => json as bool,
      );

      if (result.success) {
        return result.data ?? false;
      } else {
        throw ServerException(
          result.message ?? 'Failed to cancel booking',
          code: result.errorCode ?? result.code,
          showAsDialog: result.showAsDialog,
        );
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map<String, dynamic>)
          ? (data['message']?.toString() ?? 'Network error occurred')
          : 'Network error occurred';
      final code = (data is Map<String, dynamic>)
          ? (data['errorCode']?.toString() ?? data['code']?.toString())
          : null;
      final showAsDialog = (data is Map<String, dynamic>)
          ? (data['showAsDialog'] == true)
          : false;
      throw ServerException(msg, code: code, showAsDialog: showAsDialog);
    }
  }

  @override

  /// يرسل التحديث الجزئي للحجز مثل التواريخ أو عدد الضيوف.
  /// Sends a partial booking update such as dates or guest count.
  Future<bool> updateBooking({
    required String bookingId,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guestsCount,
  }) async {
    try {
      final response = await apiClient.put(
        '$_baseEndpoint/$bookingId/update',
        data: {
          'bookingId': bookingId,
          if (checkIn != null) 'checkIn': checkIn.toIso8601String(),
          if (checkOut != null) 'checkOut': checkOut.toIso8601String(),
          if (guestsCount != null) 'guestsCount': guestsCount,
        },
      );

      final result = ResultDto<bool>.fromJson(
        response.data,
        (json) => json as bool,
      );

      if (result.success) {
        return result.data ?? false;
      } else {
        throw ServerException(result.message ?? 'Failed to update booking');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  @override

  /// يرسل طلب تأكيد الحجز إلى المسار التشغيلي المناسب.
  /// Sends the booking confirmation request to the appropriate workflow
  /// endpoint.
  Future<bool> confirmBooking({required String bookingId}) async {
    try {
      final response = await apiClient.post(
        '$_baseEndpoint/$bookingId/confirm',
        data: {'bookingId': bookingId},
      );

      final result = ResultDto<bool>.fromJson(
        response.data,
        (json) => json as bool,
      );

      if (result.success) {
        return result.data ?? false;
      } else {
        throw ServerException(result.message ?? 'Failed to confirm booking');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  @override

  /// يسجل وصول الضيف إلى الوحدة عبر نقطة check-in.
  /// Registers the guest arrival through the check-in endpoint.
  Future<bool> checkIn({required String bookingId}) async {
    try {
      final response = await apiClient.post(
        '$_baseEndpoint/$bookingId/check-in',
        data: {'bookingId': bookingId},
      );

      final result = ResultDto<bool>.fromJson(
        response.data,
        (json) => json as bool,
      );

      if (result.success) {
        return result.data ?? false;
      } else {
        throw ServerException(result.message ?? 'Failed to check in');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  @override

  /// يسجل مغادرة الضيف من الوحدة عبر نقطة check-out.
  /// Registers the guest departure through the check-out endpoint.
  Future<bool> checkOut({required String bookingId}) async {
    try {
      final response = await apiClient.post(
        '$_baseEndpoint/$bookingId/check-out',
        data: {'bookingId': bookingId},
      );

      final result = ResultDto<bool>.fromJson(
        response.data,
        (json) => json as bool,
      );

      if (result.success) {
        return result.data ?? false;
      } else {
        throw ServerException(result.message ?? 'Failed to check out');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  @override

  /// ينهي الحجز ويضعه في الحالة النهائية المكتملة.
  /// Finalizes the booking and moves it to the completed state.
  Future<bool> completeBooking({required String bookingId}) async {
    try {
      final response = await apiClient.post(
        '$_baseEndpoint/$bookingId/complete',
        data: {'bookingId': bookingId},
      );

      final result = ResultDto<bool>.fromJson(
        response.data,
        (json) => json as bool,
      );

      if (result.success) {
        return result.data ?? false;
      } else {
        throw ServerException(result.message ?? 'Failed to complete booking');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  @override

  /// يسجل دفعة الحجز ويحوّل الاستجابة إلى كيان دفعة معتمد.
  /// Registers a booking payment and converts the response into a normalized
  /// payment entity.
  Future<Payment> registerBookingPayment(RegisterPaymentParams params) async {
    try {
      final response = await apiClient.post(
        '$_baseEndpoint/${params.bookingId}/register-payment',
        data: {
          'bookingId': params.bookingId,
          'amount': {
            'amount': params.amount,
            'currency': params.currency,
            'exchangeRate': 1.0,
          },
          'paymentMethod':
              params.paymentMethod.index + 1, // Convert enum to backend value
          'transactionId': params.transactionId ?? '',
          'notes': params.notes ?? '',
          'paymentDate': params.paymentDate?.toIso8601String(),
        },
      );

      final result = ResultDto<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (result.success && result.data != null) {
        return payment_models.PaymentModel.fromJson(result.data!);
      } else {
        throw ServerException(
          result.message ?? 'Failed to register payment',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  @override

  /// يضيف خدمة إلى الحجز الحالي مع تمرير المعرفين المطلوبين.
  /// Adds a service to the current booking while sending both required ids.
  Future<bool> addServiceToBooking({
    required String bookingId,
    required String serviceId,
  }) async {
    try {
      final response = await apiClient.post(
        '$_baseEndpoint/$bookingId/services/add',
        data: {
          'bookingId': bookingId,
          'serviceId': serviceId,
        },
      );

      final result = ResultDto<bool>.fromJson(
        response.data,
        (json) => json as bool,
      );

      if (result.success) {
        return result.data ?? false;
      } else {
        throw ServerException(result.message ?? 'Failed to add service');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  @override

  /// يزيل خدمة من الحجز الحالي عبر نقطة الإزالة المخصصة.
  /// Removes a service from the current booking through the dedicated removal
  /// endpoint.
  Future<bool> removeServiceFromBooking({
    required String bookingId,
    required String serviceId,
  }) async {
    try {
      final response = await apiClient.post(
        '$_baseEndpoint/$bookingId/services/remove',
        data: {
          'bookingId': bookingId,
          'serviceId': serviceId,
        },
      );

      final result = ResultDto<bool>.fromJson(
        response.data,
        (json) => json as bool,
      );

      if (result.success) {
        return result.data ?? false;
      } else {
        throw ServerException(result.message ?? 'Failed to remove service');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  @override

  /// يجلب الخدمات المرتبطة بالحجز لعرضها في شاشة التفاصيل.
  /// Fetches the services linked to the booking so the details screen can
  /// render them.
  Future<List<ServiceModel>> getBookingServices(
      {required String bookingId}) async {
    try {
      final response = await apiClient.get(
        '$_baseEndpoint/$bookingId/services',
      );

      final result = ResultDto<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (result.success) {
        return (result.data ?? [])
            .map((json) => ServiceModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(result.message ?? 'Failed to get services');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  @override

  /// يجلب الحجز الأساسي بالمعرف ويعيده بعد تطبيع الرد من الـ API.
  /// Fetches the base booking by id and returns it after normalizing the API
  /// response.
  Future<BookingModel> getBookingById({required String bookingId}) async {
    try {
      final response = await apiClient.get('$_baseEndpoint/$bookingId');

      final result = ResultDto<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (result.success && result.data != null) {
        return BookingModel.fromJson(result.data!);
      } else {
        final String serverMessage = _joinMessageAndErrors(
          result.message,
          response.data,
        );
        throw ServerException(serverMessage);
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = _joinMessageAndErrors(
        data is Map<String, dynamic> ? data['message'] : null,
        data,
      );
      throw ServerException(message);
    }
  }

  @override

  /// يجلب تفاصيل الحجز الكاملة بما في ذلك العلاقات والسجل الزمني.
  /// Fetches the full booking details including relationships and timeline
  /// data.
  Future<BookingDetailsModel> getBookingDetails(
      {required String bookingId}) async {
    try {
      final response = await apiClient.get('$_baseEndpoint/$bookingId/details');

      final result = ResultDto<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (result.success && result.data != null) {
        return BookingDetailsModel.fromJson(result.data!);
      } else {
        final String serverMessage = _joinMessageAndErrors(
          result.message,
          response.data,
        );
        throw ServerException(serverMessage);
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = _joinMessageAndErrors(
        data is Map<String, dynamic> ? data['message'] : null,
        data,
      );
      throw ServerException(message);
    }
  }

  /// يدمج رسالة الخادم مع قائمة الأخطاء التفصيلية عندما يعيد الـ API
  /// استجابة غنية بالتفاصيل.
  /// Merges the server message with detailed errors when the API returns a
  /// rich error response.
  String _joinMessageAndErrors(String? message, dynamic responseData) {
    try {
      if (responseData is Map<String, dynamic>) {
        final errs = responseData['errors'];
        if (errs is List) {
          final combined = errs
              .map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .join(' / ');
          if (combined.isNotEmpty) {
            if (message != null &&
                message.isNotEmpty &&
                message != 'حدثت أخطاء متعددة') {
              return '$message\n$combined';
            }
            return combined;
          }
        }
      }
    } catch (_) {}
    return message ?? 'Network error occurred';
  }

  @override

  /// يجلب الحجوزات ضمن نطاق تاريخي مع المرشحات الإضافية المطلوبة للعرض
  /// التحليلي.
  /// Fetches bookings within a date range with the extra filters required for
  /// analytical views.
  Future<PaginatedResult<BookingModel>> getBookingsByDateRange({
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
    try {
      final queryParams = <String, dynamic>{
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        if (pageNumber != null) 'pageNumber': pageNumber,
        if (pageSize != null) 'pageSize': pageSize,
        if (userId != null) 'userId': userId,
        if (guestNameOrEmail != null) 'guestNameOrEmail': guestNameOrEmail,
        if (unitId != null) 'unitId': unitId,
        if (bookingSource != null) 'bookingSource': bookingSource,
        if (isWalkIn != null) 'isWalkIn': isWalkIn,
        if (minTotalPrice != null) 'minTotalPrice': minTotalPrice,
        if (minGuestsCount != null) 'minGuestsCount': minGuestsCount,
        if (sortBy != null) 'sortBy': sortBy,
      };

      final response = await apiClient.get(
        '$_baseEndpoint/by-date-range',
        queryParameters: queryParams,
      );

      final raw = response.data;
      final Map<String, dynamic> normalized = raw is List
          ? {
              'items': raw,
              'pageNumber': 1,
              'pageSize': raw.length,
              'totalCount': raw.length,
            }
          : Map<String, dynamic>.from(raw as Map);

      return PaginatedResult<BookingModel>.fromJson(
        normalized,
        (json) => BookingModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  @override

  /// يجلب الحجوزات الخاصة بعقار محدد مع الحفاظ على مرونة المرشحات
  /// الاختيارية.
  /// Fetches bookings for a specific property while keeping optional filters
  /// flexible.
  Future<PaginatedResult<BookingModel>> getBookingsByProperty({
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
    try {
      final queryParams = <String, dynamic>{
        'propertyId': propertyId,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        if (pageNumber != null) 'pageNumber': pageNumber,
        if (pageSize != null) 'pageSize': pageSize,
        if (status != null) 'status': status.displayNameEn,
        if (paymentStatus != null) 'paymentStatus': paymentStatus,
        if (guestNameOrEmail != null) 'guestNameOrEmail': guestNameOrEmail,
        if (bookingSource != null) 'bookingSource': bookingSource,
        if (isWalkIn != null) 'isWalkIn': isWalkIn,
        if (minTotalPrice != null) 'minTotalPrice': minTotalPrice,
        if (minGuestsCount != null) 'minGuestsCount': minGuestsCount,
        if (sortBy != null) 'sortBy': sortBy,
      };

      // Backend route uses path parameter: /api/admin/bookings/property/{propertyId}
      final response = await apiClient.get(
        '$_baseEndpoint/property/$propertyId',
        queryParameters: queryParams,
      );

      final raw = response.data;
      final Map<String, dynamic> normalized = raw is List
          ? {
              'items': raw,
              'pageNumber': 1,
              'pageSize': raw.length,
              'totalCount': raw.length,
            }
          : Map<String, dynamic>.from(raw as Map);

      return PaginatedResult<BookingModel>.fromJson(
        normalized,
        (json) => BookingModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  @override

  /// يجلب الحجوزات المطابقة لحالة واحدة لتغذية القوائم المفلترة.
  /// Fetches bookings matching one status value to power filtered lists.
  Future<PaginatedResult<BookingModel>> getBookingsByStatus({
    required BookingStatus status,
    int? pageNumber,
    int? pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'status': status.apiValue,
        if (pageNumber != null) 'pageNumber': pageNumber,
        if (pageSize != null) 'pageSize': pageSize,
      };

      // Backend route: /api/admin/bookings/status
      final response = await apiClient.get(
        '$_baseEndpoint/status',
        queryParameters: queryParams,
      );

      final raw = response.data;
      final Map<String, dynamic> normalized = raw is List
          ? {
              'items': raw,
              'pageNumber': 1,
              'pageSize': raw.length,
              'totalCount': raw.length,
            }
          : Map<String, dynamic>.from(raw as Map);

      return PaginatedResult<BookingModel>.fromJson(
        normalized,
        (json) => BookingModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  @override

  /// يجلب الحجوزات المرتبطة بوحدة واحدة ضمن نطاق زمني اختياري.
  /// Fetches bookings linked to a single unit within an optional time range.
  Future<PaginatedResult<BookingModel>> getBookingsByUnit({
    required String unitId,
    DateTime? startDate,
    DateTime? endDate,
    int? pageNumber,
    int? pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'unitId': unitId,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        if (pageNumber != null) 'pageNumber': pageNumber,
        if (pageSize != null) 'pageSize': pageSize,
      };

      // Backend route: /api/admin/bookings/unit/{unitId}
      final response = await apiClient.get(
        '$_baseEndpoint/unit/$unitId',
        queryParameters: queryParams,
      );

      final raw = response.data;
      final Map<String, dynamic> normalized = raw is List
          ? {
              'items': raw,
              'pageNumber': 1,
              'pageSize': raw.length,
              'totalCount': raw.length,
            }
          : Map<String, dynamic>.from(raw as Map);

      return PaginatedResult<BookingModel>.fromJson(
        normalized,
        (json) => BookingModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  @override

  /// يجلب الحجوزات الخاصة بمستخدم محدد مع مرشحات تشغيلية إضافية.
  /// Fetches bookings for a specific user with extra operational filters.
  Future<PaginatedResult<BookingModel>> getBookingsByUser({
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
    try {
      final queryParams = <String, dynamic>{
        'userId': userId,
        if (pageNumber != null) 'pageNumber': pageNumber,
        if (pageSize != null) 'pageSize': pageSize,
        if (status != null) 'status': status.apiValue,
        if (guestNameOrEmail != null) 'guestNameOrEmail': guestNameOrEmail,
        if (unitId != null) 'unitId': unitId,
        if (bookingSource != null) 'bookingSource': bookingSource,
        if (isWalkIn != null) 'isWalkIn': isWalkIn,
        if (minTotalPrice != null) 'minTotalPrice': minTotalPrice,
        if (minGuestsCount != null) 'minGuestsCount': minGuestsCount,
        if (sortBy != null) 'sortBy': sortBy,
      };

      // Backend route: /api/admin/bookings/user/{userId}
      final response = await apiClient.get(
        '$_baseEndpoint/user/$userId',
        queryParameters: queryParams,
      );

      final raw = response.data;
      final Map<String, dynamic> normalized = raw is List
          ? {
              'items': raw,
              'pageNumber': 1,
              'pageSize': raw.length,
              'totalCount': raw.length,
            }
          : Map<String, dynamic>.from(raw as Map);

      return PaginatedResult<BookingModel>.fromJson(
        normalized,
        (json) => BookingModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  @override

  /// يجلب تقرير الحجز الإجمالي للعقار أو للنطاق الزمني المطلوب.
  /// Fetches the aggregate booking report for the requested property or date
  /// range.
  Future<BookingReportModel> getBookingReport({
    required DateTime startDate,
    required DateTime endDate,
    String? propertyId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        if (propertyId != null) 'propertyId': propertyId,
      };

      final response = await apiClient.get(
        '$_baseEndpoint/report',
        queryParameters: queryParams,
      );

      final result = ResultDto<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (result.success && result.data != null) {
        return BookingReportModel.fromJson(result.data!);
      } else {
        throw ServerException(result.message ?? 'Failed to get report');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  @override

  /// يجلب مؤشرات الاتجاهات الزمنية الخاصة بالحجوزات والإيرادات والإشغال.
  /// Fetches the time-based trends for bookings, revenue, and occupancy.
  Future<BookingTrendsModel> getBookingTrends({
    String? propertyId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        if (propertyId != null) 'propertyId': propertyId,
      };

      final response = await apiClient.get(
        '$_baseEndpoint/trends',
        queryParameters: queryParams,
      );

      final result = ResultDto<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (result.success && result.data != null) {
        return BookingTrendsModel.fromJson(result.data!);
      } else {
        throw ServerException(result.message ?? 'Failed to get trends');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }

  @override

  /// يجلب تحليل نافذة الحجز للعقار المطلوب حتى يبيّن سلوك الحجز المبكر.
  /// Fetches the booking-window analysis for the requested property to show
  /// early-booking behavior.
  Future<BookingWindowAnalysisModel> getBookingWindowAnalysis({
    required String propertyId,
  }) async {
    try {
      final response = await apiClient.get(
        '$_baseEndpoint/window-analysis',
        queryParameters: {'propertyId': propertyId},
      );

      final result = ResultDto<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (result.success && result.data != null) {
        return BookingWindowAnalysisModel.fromJson(result.data!);
      } else {
        throw ServerException(result.message ?? 'Failed to get analysis');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Network error occurred',
      );
    }
  }
}
