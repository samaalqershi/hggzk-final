/// يمثل هذا التعداد PricingMethod القيم التي تضبط سلوك إدارة الوحدات.
/// This enum represents the values that drive PricingMethod in the admin unit workflow.
enum PricingMethod {
  hourly('Hourly', 'بالساعة', '⏰'),
  daily('Daily', 'يومي', '📅'),
  weekly('Weekly', 'أسبوعي', '📆'),

  /// ينفذ هذا الأسلوب عملية monthly ضمن مسار إدارة الوحدات.
  /// This method performs the monthly operation in the admin unit workflow.
  monthly('Monthly', 'شهري', '🗓️');

  /// يحتفظ هذا الحقل بقيمة value التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the value value used by the admin unit workflow.
  final String value;

  /// يحتفظ هذا الحقل بقيمة arabicLabel التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the arabicLabel value used by the admin unit workflow.
  final String arabicLabel;

  /// يحتفظ هذا الحقل بقيمة icon التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the icon value used by the admin unit workflow.
  final String icon;

  /// ينشئ هذا المُنشئ مثيلاً من PricingMethod.
  /// This constructor creates an instance of PricingMethod.
  const PricingMethod(this.value, this.arabicLabel, this.icon);

  /// ينفذ هذا الأسلوب عملية fromString ضمن مسار إدارة الوحدات.
  /// This method performs the fromString operation in the admin unit workflow.
  static PricingMethod fromString(String value) {
    return PricingMethod.values.firstWhere(
      (method) => method.value == value,
      orElse: () => PricingMethod.daily,
    );
  }
}
