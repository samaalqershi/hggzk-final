/// Captures the availability snapshot returned for a property when the app
/// needs to decide whether the booking flow can continue.
/// يلتقط حالة التوفر التي يعيدها النظام حتى تعرف الواجهة ما إذا كان
/// بإمكان المستخدم متابعة مسار الحجز.
class PropertyAvailability {
  /// Signals whether the property currently has units that can be booked.
  /// يوضح ما إذا كان لدى العقار وحدات قابلة للحجز في الوقت الحالي.
  final bool hasAvailableUnits;

  /// Carries the number of bookable units so the UI can show a precise count.
  /// يحمل عدد الوحدات القابلة للحجز حتى تعرض الواجهة رقمًا دقيقًا للمستخدم.
  final int availableUnitsCount;

  /// Exposes the lowest available price for the current booking window.
  /// يعرّف أقل سعر متاح ضمن نافذة الحجز الحالية.
  final double? minAvailablePrice;

  /// Identifies the currency used to present availability pricing.
  /// يحدد العملة المستخدمة في عرض سعر التوفر.
  final String? currency;

  /// Provides the backend message that explains the availability state.
  /// يعرض رسالة الخادم التي تشرح سبب حالة التوفر.
  final String message;

  /// Lists the unit categories that can still be booked for this property.
  /// يسرد أنواع الوحدات التي ما زالت قابلة للحجز لهذا العقار.
  final List<String> availableUnitTypes;

  /// Builds an immutable availability snapshot for property detail and booking screens.
  /// ينشئ لقطة ثابتة لحالة التوفر تستخدمها شاشات التفاصيل والحجز.
  const PropertyAvailability({
    required this.hasAvailableUnits,
    required this.availableUnitsCount,
    required this.minAvailablePrice,
    required this.currency,
    required this.message,
    required this.availableUnitTypes,
  });
}
