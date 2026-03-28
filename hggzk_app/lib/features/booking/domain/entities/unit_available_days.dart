import 'package:equatable/equatable.dart';

/// العربية: يمثل `UnitAvailableDays`.
class UnitAvailableDays extends Equatable {
  /// العربية: يخزن القيمة `startDate`.
  final DateTime startDate;

  /// العربية: يخزن القيمة `endDate`.
  final DateTime endDate;

  /// العربية: يخزن القيمة `availableDates`.
  final List<DateTime> availableDates;

  /// العربية: يخزن القيمة `unpricedDates`.
  final List<DateTime> unpricedDates;

  /// العربية: ينشئ مثيلًا جديدًا من `UnitAvailableDays`.
  const UnitAvailableDays({
    required this.startDate,
    required this.endDate,
    required this.availableDates,
    this.unpricedDates = const <DateTime>[],
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props =>
      [startDate, endDate, availableDates, unpricedDates];
}
