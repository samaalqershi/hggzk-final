/// يمثل هذا الكيان عملة مرجعية تُستخدم في صفحات الإعداد والبحث
/// وحتى في بعض حقول التسعير.
/// Represents a reference currency used in settings, search flows,
/// and sometimes pricing fields.
class Currency {
  /// رمز العملة الدولي.
  /// International currency code.
  final String code;

  /// النسخة العربية من رمز العملة عند الحاجة إلى عرض محلي واضح.
  /// Arabic representation of the currency code for localized
  /// display.
  final String arabicCode;

  /// الاسم الإنجليزي الشائع للعملة.
  /// Common English name of the currency.
  final String name;

  /// الاسم العربي للعملة.
  /// Arabic name of the currency.
  final String arabicName;

  /// يوضح إن كانت هذه هي العملة الافتراضية في النظام.
  /// Indicates whether this is the system’s default currency.
  final bool isDefault;

  /// سعر الصرف إن كان متاحًا من المصدر المرجعي.
  /// Exchange rate when the reference source provides it.
  final double? exchangeRate;

  /// آخر وقت تم فيه تحديث بيانات العملة.
  /// Last time the currency data was updated.
  final DateTime? lastUpdated;

  /// يكوّن سجل العملة مع الحقول الأساسية والمعلومات الاختيارية.
  /// Builds the currency record with required fields and optional
  /// metadata.
  const Currency({
    required this.code,
    required this.arabicCode,
    required this.name,
    required this.arabicName,
    required this.isDefault,
    this.exchangeRate,
    this.lastUpdated,
  });
}
