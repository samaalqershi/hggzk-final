/// العربية: يمثل `UnitAvailability`.
class UnitAvailability {
  /// العربية: يحدد ما إذا كانت القيمة `isAvailable` مفعلة.
  final bool isAvailable;

  /// العربية: يخزن القيمة `totalDays`.
  final int totalDays;

  /// العربية: يخزن القيمة `availableDays`.
  final int availableDays;

  /// العربية: يخزن القيمة `unavailableDays`.
  final int unavailableDays;

  /// العربية: يخزن القيمة `unavailableDates`.
  final List<DateTime> unavailableDates;

  /// العربية: يخزن القيمة `message`.
  final String? message;

  /// العربية: يخزن القيمة `totalPrice`.
  final double? totalPrice;

  /// العربية: يخزن القيمة `pricePerNight`.
  final double? pricePerNight;

  /// العربية: يخزن القيمة `currency`.
  final String? currency;

  /// العربية: ينشئ مثيلًا جديدًا من `UnitAvailability`.
  const UnitAvailability({
    required this.isAvailable,
    required this.totalDays,
    required this.availableDays,
    required this.unavailableDays,
    required this.unavailableDates,
    this.message,
    this.totalPrice,
    this.pricePerNight,
    this.currency,
  });
}
