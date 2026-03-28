import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/support_message.dart';

/// Contract for submitting support tickets and receiving backend responses.
/// عقد لإرسال تذاكر الدعم واستقبال ردود الخادم.
abstract class SupportRepository {
  /// Sends a support request to the backend.
  /// يرسل طلب دعم إلى الخادم.
  Future<Either<Failure, Map<String, dynamic>>> sendSupportMessage(
    SupportMessage message,
  );
}
