import '../../domain/entities/unit_available_days.dart';

/// العربية: يمثل نموذج البيانات `UnitAvailableDaysModel`.
class UnitAvailableDaysModel extends UnitAvailableDays {
  /// العربية: ينشئ مثيلًا جديدًا من `UnitAvailableDaysModel`.
  const UnitAvailableDaysModel({
    required super.startDate,
    required super.endDate,
    required super.availableDates,
    required super.unpricedDates,
  });

  /// العربية: يحلل date only.
  static DateTime _parseDateOnly(dynamic value) {
    final raw = value?.toString() ?? '';
    if (raw.isEmpty) {
      throw const FormatException('Invalid date value');
    }

    final datePart = raw.length >= 10 ? raw.substring(0, 10) : raw;
    final parts = datePart.split('-');
    if (parts.length == 3) {
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final day = int.tryParse(parts[2]);
      if (year != null && month != null && day != null) {
        return DateTime(year, month, day);
      }
    }

    final parsed = DateTime.parse(raw);
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  /// العربية: ينشئ مثيلًا جديدًا من `UnitAvailableDaysModel.fromJson`.
  factory UnitAvailableDaysModel.fromJson(Map<String, dynamic> json) {
    final availableDates =
        (json['availableDates'] as List?)?.map(_parseDateOnly).toList() ??
            <DateTime>[];
    final unpricedDates =
        (json['unpricedDates'] as List?)?.map(_parseDateOnly).toList() ??
            <DateTime>[];

    return UnitAvailableDaysModel(
      startDate: _parseDateOnly(json['startDate']),
      endDate: _parseDateOnly(json['endDate']),
      availableDates: availableDates,
      unpricedDates: unpricedDates,
    );
  }
}
