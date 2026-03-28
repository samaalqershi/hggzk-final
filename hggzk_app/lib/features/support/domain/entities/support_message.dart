/// User-submitted support ticket enriched with device context.
/// تذكرة دعم يرسلها المستخدم مع سياق الجهاز.
class SupportMessage {
  /// Name entered by the user.
  /// الاسم الذي أدخله المستخدم.
  final String userName;

  /// Reply address for the support team.
  /// عنوان الرد لفريق الدعم.
  final String userEmail;

  /// Ticket subject that summarizes the issue.
  /// عنوان التذكرة الذي يلخص المشكلة.
  final String subject;

  /// Full body of the support request.
  /// نص طلب الدعم الكامل.
  final String message;

  /// Optional device model or type.
  /// نوع الجهاز أو موديله اختياريًا.
  final String? deviceType;

  /// Optional operating system name.
  /// اسم نظام التشغيل اختياريًا.
  final String? operatingSystem;

  /// Optional operating system version.
  /// نسخة نظام التشغيل اختياريًا.
  final String? osVersion;

  /// Optional app version included for diagnostics.
  /// نسخة التطبيق الاختيارية لأغراض التشخيص.
  final String? appVersion;

  /// Packages the support ticket and its device metadata.
  /// يجمع تذكرة الدعم وبيانات الجهاز المرفقة بها.
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
