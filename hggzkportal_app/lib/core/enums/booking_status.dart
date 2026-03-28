/// حالات الحجز المعتمدة في واجهة الإدارة وفي التكامل مع الخادم.
/// Booking states used by the admin UI and backend integration.
enum BookingStatus {
  confirmed,
  pending,
  cancelled,
  completed,
  checkedIn,
}

/// يوفّر أسماء عرض عربية وإنجليزية ورمز API ثابت لكل حالة حجز.
/// Provides Arabic and English labels plus a stable API token for each booking status.
extension BookingStatusExtension on BookingStatus {
  /// الاسم العربي الظاهر للمستخدم داخل الشارات والجداول.
  /// Arabic display label shown in badges and tables.
  String get displayName {
    switch (this) {
      case BookingStatus.confirmed:
        return 'مؤكد';
      case BookingStatus.pending:
        return 'معلق';
      case BookingStatus.cancelled:
        return 'ملغى';
      case BookingStatus.completed:
        return 'مكتمل';
      case BookingStatus.checkedIn:
        return 'تم تسجيل الوصول';
    }
  }

  /// الاسم الإنجليزي الذي يفيد عند عرض السجلات أو التصدير.
  /// English display label useful for logs and exports.
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

/// يطابق حالة الحجز مع التمثيل النصي الذي يتوقعه الخادم.
/// Maps a booking status to the string representation expected by the backend.
extension BookingStatusApi on BookingStatus {
  /// يوفّر القيمة النصية المطلوبة من الخادم بدون مسافات داخلية.
  /// Returns the backend string token without spaces, such as `CheckedIn`.
  String get apiValue {
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
        return 'CheckedIn';
    }
  }
}
