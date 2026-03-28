import 'package:dio/dio.dart';
import 'package:hggzk/core/enums/booking_status.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/models/paginated_result.dart';
import '../../../../core/models/result_dto.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/request_logger.dart';
import '../models/booking_model.dart';
import '../models/booking_request_model.dart';
import '../models/unit_available_days_model.dart';
import '../models/unit_availability_model.dart';

/// العربية: يوفر سلوك مصدر البيانات الخاص بـ `BookingRemoteDataSource`.
abstract class BookingRemoteDataSource {
  /// العربية: ينشئ booking.
  Future<ResultDto<BookingModel>> createBooking(BookingRequestModel request);

  /// العربية: يعيد booking details.
  Future<ResultDto<BookingModel>> getBookingDetails({
    required String bookingId,
    required String userId,
  });

  /// العربية: يعالج `cancelBooking`.
  Future<ResultDto<bool>> cancelBooking({
    required String bookingId,
    required String userId,
    required String reason,
    bool refundPayments = false,
  });

  /// العربية: يحدّث booking.
  Future<ResultDto<bool>> updateBooking({
    required String bookingId,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guestsCount,
    List<Map<String, dynamic>>? services,
  });

  /// العربية: يعيد user bookings.
  Future<ResultDto<PaginatedResult<BookingModel>>> getUserBookings({
    required String userId,
    String? status,
    int pageNumber = 1,
    int pageSize = 10,
  });

  /// العربية: يعيد user booking summary.
  Future<ResultDto<Map<String, dynamic>>> getUserBookingSummary({
    required String userId,
    int? year,
  });

  /// العربية: يعالج `addServicesToBooking`.
  Future<ResultDto<BookingModel>> addServicesToBooking({
    required String bookingId,
    required String serviceId,
    required int quantity,
  });

  /// العربية: يتحقق من availability.
  Future<ResultDto<UnitAvailabilityModel>> checkAvailability({
    required String unitId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int adultsCount,
    required int childrenCount,
    required int guestsCount,
    String? excludeBookingId,
  });

  /// العربية: يعيد unit available days.
  Future<ResultDto<UnitAvailableDaysModel>> getUnitAvailableDays({
    required String unitId,
    int months = 3,
    String? excludeBookingId,
  });
}

/// العربية: يمثل `BookingRemoteDataSourceImpl`.
class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  /// العربية: يخزن القيمة `apiClient`.
  final ApiClient apiClient;

  /// العربية: ينشئ مثيلًا جديدًا من `BookingRemoteDataSourceImpl`.
  BookingRemoteDataSourceImpl({required this.apiClient});

  /// العربية: ينشئ booking.
  @override
  Future<ResultDto<BookingModel>> createBooking(
      BookingRequestModel request) async {
    const requestName = 'booking.createBooking';
    logRequestStart(requestName, details: {
      'request': request.toJson(),
    });
    try {
      final response = await apiClient.post(
        '/api/client/booking',
        data: request.toJson(),
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resultDto = ResultDto.fromJson(
          response.data,
          (json) => _parseCreateBookingResponse(json),
        );

        if (resultDto.success && resultDto.data != null) {
          return resultDto;
        } else {
          throw ServerException(
              resultDto.message ?? 'Failed to create booking');
        }
      } else {
        throw ServerException(
            response.data['message'] ?? 'Failed to create booking');
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw ServerException('Unexpected error: $e');
    }
  }

  /// العربية: يعيد unit available days.
  @override
  Future<ResultDto<UnitAvailableDaysModel>> getUnitAvailableDays({
    required String unitId,
    int months = 3,
    String? excludeBookingId,
  }) async {
    const requestName = 'booking.getUnitAvailableDays';
    logRequestStart(requestName, details: {
      'unitId': unitId,
      'months': months,
      if (excludeBookingId != null) 'excludeBookingId': excludeBookingId,
    });

    try {
      final query = <String, dynamic>{
        'months': months,
      };
      if (excludeBookingId != null) {
        query['excludeBookingId'] = excludeBookingId;
      }

      final response = await apiClient.get(
        '/api/client/units/$unitId/available-days',
        queryParameters: query,
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.statusCode == 200) {
        return ResultDto.fromJson(
          response.data,
          (json) => UnitAvailableDaysModel.fromJson(json),
        );
      } else {
        throw ServerException(
            response.data['message'] ?? 'Failed to get available days');
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        throw ServerException(
          data['message'] ?? e.message ?? 'Network error occurred',
          code: data['errorCode']?.toString() ?? data['code']?.toString(),
          showAsDialog: data['showAsDialog'] == true,
        );
      }
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw ServerException('Unexpected error: $e');
    }
  }

  /// العربية: يحدّث booking.
  @override
  Future<ResultDto<bool>> updateBooking({
    required String bookingId,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guestsCount,
    List<Map<String, dynamic>>? services,
  }) async {
    const requestName = 'booking.updateBooking';
    logRequestStart(requestName, details: {
      'bookingId': bookingId,
      if (checkIn != null) 'checkIn': checkIn.toIso8601String(),
      if (checkOut != null) 'checkOut': checkOut.toIso8601String(),
      if (guestsCount != null) 'guestsCount': guestsCount,
    });

    try {
      final data = <String, dynamic>{};
      if (checkIn != null) {
        data['checkIn'] = checkIn.toIso8601String();
      }
      if (checkOut != null) {
        data['checkOut'] = checkOut.toIso8601String();
      }
      if (guestsCount != null) {
        data['guestsCount'] = guestsCount;
      }
      if (services != null) {
        data['services'] = services
            .map((e) => {
                  'serviceId': e['id'] ?? e['serviceId'],
                  'quantity': e['quantity'],
                })
            .toList();
      }

      final response = await apiClient.put(
        '/api/client/booking/$bookingId/update',
        data: data,
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.statusCode == 200) {
        final resultDto = ResultDto.fromJson(
          response.data,
          (json) => json['success'] ?? true,
        );

        if (resultDto.success) {
          return ResultDto<bool>(
            success: true,
            data: resultDto.data ?? true,
            message: resultDto.message,
            errorCode: resultDto.errorCode ?? resultDto.code,
            showAsDialog: resultDto.showAsDialog,
            timestamp: resultDto.timestamp ?? DateTime.now(),
          );
        } else {
          throw ServerException(
            resultDto.message ?? 'Failed to update booking',
            code: resultDto.errorCode ?? resultDto.code,
            showAsDialog: resultDto.showAsDialog,
          );
        }
      } else {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          throw ServerException(
            data['message'] ?? 'Failed to update booking',
            code: data['errorCode']?.toString() ?? data['code']?.toString(),
            showAsDialog: data['showAsDialog'] == true,
          );
        }
        throw const ServerException('Failed to update booking');
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        throw ServerException(
          data['message'] ?? e.message ?? 'Network error occurred',
          code: data['errorCode']?.toString() ?? data['code']?.toString(),
          showAsDialog: data['showAsDialog'] == true,
        );
      }
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw ServerException('Unexpected error: $e');
    }
  }

  /// العربية: يعيد booking details.
  @override
  Future<ResultDto<BookingModel>> getBookingDetails({
    required String bookingId,
    required String userId,
  }) async {
    const requestName = 'booking.getBookingDetails';
    logRequestStart(requestName, details: {
      'bookingId': bookingId,
      'userId': userId,
    });
    try {
      final response = await apiClient.get(
        '/api/client/booking/$bookingId',
        queryParameters: {'userId': userId},
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.statusCode == 200) {
        return ResultDto.fromJson(
          response.data,
          (json) => BookingModel.fromJson(json),
        );
      } else {
        throw ServerException(
            response.data['message'] ?? 'Failed to get booking details');
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw ServerException('Unexpected error: $e');
    }
  }

  /// العربية: يعالج `cancelBooking`.
  @override
  Future<ResultDto<bool>> cancelBooking({
    required String bookingId,
    required String userId,
    required String reason,
    bool refundPayments = false,
  }) async {
    const requestName = 'booking.cancelBooking';
    logRequestStart(requestName, details: {
      'bookingId': bookingId,
      'userId': userId,
      'reason': reason,
    });
    try {
      final response = await apiClient.post(
        '/api/client/booking/cancel',
        data: {
          'bookingId': bookingId,
          'userId': userId,
          'cancellationReason': reason,
          'refundPayments': refundPayments,
        },
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.statusCode == 200) {
        final resultDto = ResultDto.fromJson(
          response.data,
          (json) => json['success'] ?? false,
        );

        if (resultDto.success) {
          return ResultDto<bool>(
            success: true,
            data: true,
            message: resultDto.message,
            timestamp: DateTime.now(),
          );
        } else {
          throw ServerException(
            resultDto.message ?? 'Failed to cancel booking',
            code: resultDto.errorCode ?? resultDto.code,
            showAsDialog: resultDto.showAsDialog,
          );
        }
      } else {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          throw ServerException(
            data['message'] ?? 'Failed to cancel booking',
            code: data['errorCode']?.toString() ?? data['code']?.toString(),
            showAsDialog: data['showAsDialog'] == true,
          );
        }
        throw const ServerException('Failed to cancel booking');
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        throw ServerException(
          data['message'] ?? e.message ?? 'Network error occurred',
          code: data['errorCode']?.toString() ?? data['code']?.toString(),
          showAsDialog: data['showAsDialog'] == true,
        );
      }
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw ServerException('Unexpected error: $e');
    }
  }

  /// العربية: يعيد user bookings.
  @override
  Future<ResultDto<PaginatedResult<BookingModel>>> getUserBookings({
    required String userId,
    String? status,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    const requestName = 'booking.getUserBookings';
    logRequestStart(requestName, details: {
      'userId': userId,
      if (status != null) 'status': status,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    });
    try {
      final queryParams = <String, dynamic>{
        'userId': userId,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      };

      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await apiClient.get(
        '/api/client/booking',
        queryParameters: queryParams,
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.statusCode == 200) {
        return ResultDto.fromJson(
          response.data,
          (json) => PaginatedResult.fromJson(
            json,
            (bookingJson) => BookingModel.fromJson(bookingJson),
          ),
        );
      } else {
        throw ServerException(
            response.data['message'] ?? 'Failed to get user bookings');
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw ServerException('Unexpected error: $e');
    }
  }

  /// العربية: يعيد user booking summary.
  @override
  Future<ResultDto<Map<String, dynamic>>> getUserBookingSummary({
    required String userId,
    int? year,
  }) async {
    const requestName = 'booking.getUserBookingSummary';
    logRequestStart(requestName, details: {
      'userId': userId,
      if (year != null) 'year': year,
    });
    try {
      final queryParams = <String, dynamic>{
        'userId': userId,
      };

      if (year != null) {
        queryParams['year'] = year;
      }

      final response = await apiClient.get(
        '/api/client/booking/summary/$userId',
        queryParameters: queryParams,
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.statusCode == 200) {
        return ResultDto.fromJson(
          response.data,
          (json) => json,
        );
      } else {
        throw ServerException(
            response.data['message'] ?? 'Failed to get booking summary');
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw ServerException('Unexpected error: $e');
    }
  }

  /// العربية: يعالج `addServicesToBooking`.
  @override
  Future<ResultDto<BookingModel>> addServicesToBooking({
    required String bookingId,
    required String serviceId,
    required int quantity,
  }) async {
    const requestName = 'booking.addServicesToBooking';
    logRequestStart(requestName, details: {
      'bookingId': bookingId,
      'serviceId': serviceId,
      'quantity': quantity,
    });
    try {
      final response = await apiClient.post(
        '/api/client/booking/add-service',
        data: {
          'bookingId': bookingId,
          'serviceId': serviceId,
          'quantity': quantity,
        },
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.statusCode == 200) {
        final resultDto = ResultDto.fromJson(
          response.data,
          (json) => _parseAddServiceResponse(json, bookingId),
        );

        if (resultDto.success && resultDto.data != null) {
          return resultDto;
        } else {
          throw ServerException(resultDto.message ?? 'Failed to add service');
        }
      } else {
        throw ServerException(
            response.data['message'] ?? 'Failed to add service to booking');
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw ServerException('Unexpected error: $e');
    }
  }

  /// العربية: يتحقق من availability.
  @override
  Future<ResultDto<UnitAvailabilityModel>> checkAvailability({
    required String unitId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int adultsCount,
    required int childrenCount,
    required int guestsCount,
    String? excludeBookingId,
  }) async {
    const requestName = 'booking.checkAvailability';
    logRequestStart(requestName, details: {
      'unitId': unitId,
      'checkIn': checkIn.toIso8601String(),
      'checkOut': checkOut.toIso8601String(),
      'guestsCount': guestsCount,
      if (excludeBookingId != null) 'excludeBookingId': excludeBookingId,
    });
    try {
      final response = await apiClient.post(
        '/api/client/units/check-availability',
        data: {
          'unitId': unitId,
          'checkInDate': checkIn.toIso8601String(),
          'checkOutDate': checkOut.toIso8601String(),
          'adults': adultsCount,
          'children': childrenCount,
          if (excludeBookingId != null) 'excludeBookingId': excludeBookingId,
        },
      );

      logRequestSuccess(requestName, statusCode: response.statusCode);

      if (response.statusCode == 200) {
        return ResultDto.fromJson(
          response.data,
          (json) => UnitAvailabilityModel.fromJson(json),
        );
      } else {
        throw ServerException(
            response.data['message'] ?? 'Failed to check availability');
      }
    } on DioException catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e, s) {
      logRequestError(requestName, e, stackTrace: s);
      if (e is ServerException) rethrow;
      throw ServerException('Unexpected error: $e');
    }
  }

  // Helper method to parse create booking response
  /// العربية: يحلل create booking response.
  BookingModel _parseCreateBookingResponse(Map<String, dynamic> json) {
    return BookingModel(
      id: json['bookingId'] ?? '',
      bookingNumber: json['bookingNumber'] ?? '',
      userId: '',
      userName: '',
      propertyId: '',
      propertyName: '',
      checkInDate: DateTime.now(),
      checkOutDate: DateTime.now(),
      numberOfNights: 0,
      adultGuests: 0,
      childGuests: 0,
      totalGuests: 0,
      totalAmount: (json['totalPrice']?['amount'] ?? 0).toDouble(),
      currency: json['totalPrice']?['currency'] ?? 'YER',
      status: BookingModel.parseBookingStatus(json['status']),
      bookingDate: DateTime.now(),
      services: const [],
      payments: const [],
      unitImages: const [],
      contactInfo: const ContactInfoModel(
        phoneNumber: '',
        email: '',
      ),
    );
  }

  /// العربية: يحلل add service response.
  BookingModel _parseAddServiceResponse(
      Map<String, dynamic> json, String bookingId) {
    return BookingModel(
      id: bookingId,
      bookingNumber: '',
      userId: '',
      userName: '',
      propertyId: '',
      propertyName: '',
      checkInDate: DateTime.now(),
      checkOutDate: DateTime.now(),
      numberOfNights: 0,
      adultGuests: 0,
      childGuests: 0,
      totalGuests: 0,
      totalAmount: (json['newTotalPrice']?['amount'] ?? 0).toDouble(),
      currency: json['newTotalPrice']?['currency'] ?? 'YER',
      status: BookingStatus.confirmed,
      bookingDate: DateTime.now(),
      services: const [],
      payments: const [],
      unitImages: const [],
      contactInfo: const ContactInfoModel(
        phoneNumber: '',
        email: '',
      ),
    );
  }
}
