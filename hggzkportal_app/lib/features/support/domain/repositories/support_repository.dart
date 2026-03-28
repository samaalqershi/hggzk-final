import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/support_message.dart';

/// هذا العقد يحدد ما يحتاجه قسم الدعم من إرسال رسالة واحدة إلى
/// الخادم مع الحفاظ على عزل تفاصيل النقل.
/// This contract defines what the support feature needs to send one
/// message to the server while keeping transport details isolated.
abstract class SupportRepository {
  /// يرسل رسالة الدعم ويعيد ما ينجح الخادم في حفظه أو معالجته.
  /// Sends the support message and returns whatever the server
  /// successfully stores or processes.
  Future<Either<Failure, Map<String, dynamic>>> sendSupportMessage(
    SupportMessage message,
  );
}
