import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../domain/entities/support_message.dart';
import '../../domain/repositories/support_repository.dart';
import '../models/support_message_model.dart';

/// Implements the support repository by translating the domain message into
/// the HTTP payload expected by the backend.
///
/// ينفذ مستودع الدعم عبر تحويل رسالة المجال إلى حمولة HTTP التي يتوقعها
/// الخادم.
class SupportRepositoryImpl implements SupportRepository {
  /// HTTP client used to submit support requests.
  ///
  /// عميل HTTP المستخدم لإرسال طلبات الدعم.
  final ApiClient apiClient;

  /// Wires the repository to the transport client responsible for the API
  /// call.
  ///
  /// يربط المستودع بعميل النقل المسؤول عن استدعاء الـ API.
  SupportRepositoryImpl({required this.apiClient});

  /// Converts the domain message into the backend payload and returns either
  /// the parsed response data or a domain failure.
  ///
  /// يحول رسالة المجال إلى حمولة الخادم ثم يعيد البيانات المحللة أو فشلًا
  /// في المجال.
  @override
  Future<Either<Failure, Map<String, dynamic>>> sendSupportMessage(
    SupportMessage message,
  ) async {
    try {
      final model = SupportMessageModel(
        userName: message.userName,
        userEmail: message.userEmail,
        subject: message.subject,
        message: message.message,
        deviceType: message.deviceType,
        operatingSystem: message.operatingSystem,
        osVersion: message.osVersion,
        appVersion: message.appVersion,
      );

      final response = await apiClient.post(
        '/api/Client/Support/send',
        data: model.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data['data'] != null) {
            return Right(Map<String, dynamic>.from(data['data']));
          }
        }
        return const Right({});
      } else {
        return const Left(ServerFailure(
          'فشل إرسال رسالة الدعم',
        ));
      }
    } on ApiException catch (e) {
      return Left(ServerFailure.meta(
        message: e.message,
        code: e.statusCode?.toString(),
      ));
    } catch (e) {
      return Left(ServerFailure(
        'حدث خطأ غير متوقع: ${e.toString()}',
      ));
    }
  }
}
