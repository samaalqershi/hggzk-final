import '../../domain/entities/support_message.dart';

/// Serializable support-message payload that mirrors the domain entity and is
/// ready to be posted to the backend.
///
/// حمولة رسالة دعم قابلة للتسلسل تماثل كيان المجال وجاهزة للإرسال إلى الخادم.
class SupportMessageModel extends SupportMessage {
  /// Builds the transport-ready message object from the domain fields.
  ///
  /// يبني كائن الرسالة الجاهز للنقل من حقول المجال.
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

  /// Converts the support message into the API payload shape expected by the
  /// support endpoint.
  ///
  /// يحول رسالة الدعم إلى صيغة الحمولة التي يتوقعها endpoint الخاص بالدعم.
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
