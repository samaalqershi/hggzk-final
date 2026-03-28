import '../../domain/entities/support_message.dart';

/// يكيّف كيان رسالة الدعم بحيث يصبح جاهزًا للإرسال كـ JSON إلى
/// واجهة API.
/// Adapts the support message entity so it can be sent as JSON to
/// the API.
class SupportMessageModel extends SupportMessage {
  /// ينشئ نموذج الرسالة من نفس بيانات الكيان.
  /// Builds the message model from the same entity data.
  SupportMessageModel({
    required super.userName,
    required super.userEmail,
    required super.subject,
    required super.message,
    super.deviceType,
    super.operatingSystem,
    super.osVersion,
    super.appVersion,
  });

  /// يحول الرسالة إلى خريطة JSON جاهزة للطلب الشبكي.
  /// Converts the message into a JSON map ready for the network
  /// request.
  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'userEmail': userEmail,
      'subject': subject,
      'message': message,
      if (deviceType != null) 'deviceType': deviceType,
      if (operatingSystem != null) 'operatingSystem': operatingSystem,
      if (osVersion != null) 'osVersion': osVersion,
      if (appVersion != null) 'appVersion': appVersion,
    };
  }
}
