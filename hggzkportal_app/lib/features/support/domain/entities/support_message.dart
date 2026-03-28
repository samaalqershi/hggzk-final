/// العربية: تمثل الرسالة التي يرسلها المستخدم إلى فريق الدعم مع سياق
/// الجهاز والإصدار حتى تصبح المتابعة أسرع وأوضح.
/// Represents the support request submitted by the user, including device and app-version context so follow-up is faster and clearer.
class SupportMessage {
  /// العربية: اسم المستخدم الذي أرسل الرسالة.
  /// Name of the user who submitted the message.
  final String userName;

  /// العربية: البريد الإلكتروني الذي سيعود إليه الرد.
  /// Email address that should receive the reply.
  final String userEmail;

  /// العربية: عنوان الرسالة أو موضوعها.
  /// Subject line of the support message.
  final String subject;

  /// العربية: نص المشكلة أو الطلب نفسه.
  /// The actual problem description or request body.
  final String message;

  /// العربية: نوع الجهاز عند توفره.
  /// Device model when available.
  final String? deviceType;

  /// العربية: نظام التشغيل المستخدم.
  /// Operating system in use.
  final String? operatingSystem;

  /// العربية: إصدار نظام التشغيل.
  /// Operating system version.
  final String? osVersion;

  /// العربية: إصدار التطبيق المثبت.
  /// Installed app version.
  final String? appVersion;

  /// العربية: يجمع بيانات الدعم الأساسية مع السياق التقني المرافق لها.
  /// Bundles the core support fields together with the accompanying technical context.
  SupportMessage({
    required this.userName,
    required this.userEmail,
    required this.subject,
    required this.message,
    this.deviceType,
    this.operatingSystem,
    this.osVersion,
    this.appVersion,
  });
}
