/// حالات الإتاحة القياسية التي يعتمد عليها العرض والفلترة ومنطق الحجز.
/// Canonical availability states used by display, filtering, and booking logic.
class AvailabilityStatus {
  /// Arabic: الحالة التي تعني أن العقار متاح للحجز أو الاستخدام.
  /// English: Status used when the property is open for booking or use.
  static const String available = 'Available';

  /// Arabic: الحالة التي تعني أن العقار محجوز بالفعل.
  /// English: Status used when the property is already booked.
  static const String booked = 'Booked';

  /// Arabic: الحالة التي تعني أن العقار محظور مؤقتًا أو غير قابل للحجز.
  /// English: Status used when the property is temporarily blocked or unavailable.
  static const String blocked = 'Blocked';

  /// Arabic: الحالة التي تعني أن العقار خارج الخدمة بسبب الصيانة.
  /// English: Status used when the property is unavailable because of maintenance.
  static const String maintenance = 'Maintenance';

  /// Arabic: الحالة التي تعني أن العقار مستخدم من قبل المالك.
  /// English: Status used when the property is reserved for owner use.
  static const String ownerUse = 'OwnerUse';

  /// Arabic labels shown in badges, tables, and summaries.
  /// التسميات العربية المعروضة في الشارات والجداول والملخصات.
  static const Map<String, String> arabicNames = {
    available: 'متاح',
    booked: 'محجوز',
    blocked: 'محظور',
    maintenance: 'صيانة',
    ownerUse: 'استخدام المالك',
  };

  /// Color coding used to make each availability state obvious at a glance.
  /// التلوين المرئي المستخدم لتمييز كل حالة بسرعة.
  static const Map<String, int> statusColors = {
    available: 0xFF4CAF50, // Green
    booked: 0xFFFF9800, // Orange
    blocked: 0xFFF44336, // Red
    maintenance: 0xFF9E9E9E, // Grey
    ownerUse: 0xFF2196F3, // Blue
  };

  /// Returns true when the token matches one of the supported availability states.
  /// يعيد true عندما تطابق القيمة إحدى حالات الإتاحة المدعومة.
  static bool isValidStatus(String status) {
    return status == available ||
        status == booked ||
        status == blocked ||
        status == maintenance ||
        status == ownerUse;
  }

  /// Returns Arabic display label or the original token if unknown.
  /// يعيد الاسم العربي أو يعيد الرمز الأصلي إذا لم يكن معروفًا.
  static String getArabicName(String status) {
    return arabicNames[status] ?? status;
  }

  /// Returns color associated with the supplied availability state.
  /// يعيد اللون المرتبط بحالة الإتاحة المطلوبة.
  static int getStatusColor(String status) {
    return statusColors[status] ?? 0xFF9E9E9E;
  }

  /// Returns all availability tokens in their canonical order.
  /// يعيد جميع رموز الحالات بالترتيب القياسي.
  static List<String> getAllStatuses() {
    return [available, booked, blocked, maintenance, ownerUse];
  }
}
