import 'package:equatable/equatable.dart';

class UnitAvailableDays extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final List<DateTime> availableDates;
  final List<DateTime> unpricedDates;

  const UnitAvailableDays({
    required this.startDate,
    required this.endDate,
    required this.availableDates,
    this.unpricedDates = const <DateTime>[],
  });

  @override
  List<Object?> get props =>
      [startDate, endDate, availableDates, unpricedDates];
}
