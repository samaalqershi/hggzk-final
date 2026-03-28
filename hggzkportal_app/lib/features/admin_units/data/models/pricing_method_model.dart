import '../../domain/entities/pricing_method.dart';

/// يمثل هذا الكلاس PricingMethodModel البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for PricingMethodModel in the admin unit workflow.
class PricingMethodModel {
  /// Converts a stored pricing value into the matching domain enum.
  /// يحول قيمة التسعير المخزنة إلى التعداد المقابل داخل طبقة المجال.
  static PricingMethod fromString(String value) {
    return PricingMethod.values.firstWhere(
      (method) => method.value == value,
      orElse: () => PricingMethod.daily,
    );
  }

  /// ينفذ هذا الأسلوب عملية stringValueOf ضمن مسار إدارة الوحدات.
  /// This method performs the stringValueOf operation in the admin unit workflow.
  static String stringValueOf(PricingMethod method) {
    return method.value;
  }

  /// ينفذ هذا الأسلوب عملية toJson ضمن مسار إدارة الوحدات.
  /// This method performs the toJson operation in the admin unit workflow.
  static Map<String, dynamic> toJson(PricingMethod method) {
    return {
      'value': method.value,
      'arabicLabel': method.arabicLabel,
      'icon': method.icon,
    };
  }
}
