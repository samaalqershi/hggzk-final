import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../domain/entities/support_message.dart';
import '../../domain/repositories/support_repository.dart';
import '../models/support_message_model.dart';

/// يحول عقد الدعم إلى طلب شبكة فعلي مع إبقاء الأخطاء محصورة
/// داخل طبقة البيانات.
/// Turns the support contract into a real network request while
/// keeping errors contained inside the data layer.
class SupportRepositoryImpl implements SupportRepository {
  /// العميل الذي يتحدث مع نقطة النهاية الخاصة بالدعم.
  /// Client that talks to the support endpoint.
  final ApiClient apiClient;

  /// يربط المستودع بعميل الشبكة المستخدم للإرسال.
  /// Connects the repository to the network client used for
  /// sending.
  SupportRepositoryImpl({required this.apiClient});

  /// يحول الرسالة إلى نموذج إرسال ثم يعيد ما يرجعه الخادم بعد
  /// المعالجة.
  /// Converts the message to a send model and returns what the
  /// server gives back after processing.
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
        '/api/Admin/Support/send',
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
