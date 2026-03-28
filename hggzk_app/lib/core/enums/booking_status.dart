/// Groups the allowed values for `BookingStatus` so the rest of the app stays type-safe.
/// العربية: يعرّف القيم المتاحة للنوع `BookingStatus`.
enum BookingStatus {
  confirmed,
  pending,
  cancelled,
  completed,
  checkedIn,
}

/// العربية: يعرّف الامتداد `BookingStatusExtension`.
extension BookingStatusExtension on BookingStatus {
  /// Exposes the `displayName` value for callers that need it.
  /// العربية: يعيد القيمة `displayName`.
  String get displayName {
    switch (this) {
      case BookingStatus.confirmed:
        return 'مؤكد';
      case BookingStatus.pending:
        return 'في انتظار التأكيد';
      case BookingStatus.cancelled:
        return 'ملغى';
      case BookingStatus.completed:
        return 'مكتمل';
      case BookingStatus.checkedIn:
        return 'تم تسجيل الوصول';
    }
  }

  /// Exposes the `displayNameEn` value for callers that need it.
  /// العربية: يعيد القيمة `displayNameEn`.
  String get displayNameEn {
    switch (this) {
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.checkedIn:
        return 'Checked In';
    }
  }
}
