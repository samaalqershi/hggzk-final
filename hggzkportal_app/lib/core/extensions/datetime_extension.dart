import 'package:hggzkportal/core/utils/timezone_helper.dart';
import 'package:intl/intl.dart';

/// يضيف سلوك تنسيق وتحويل مباشر إلى `DateTime` حتى يبقى التعامل مع
/// الطوابع الزمنية موحدًا في الواجهة وطبقة البيانات.
/// Adds direct formatting and conversion behavior to `DateTime` so timestamp
/// handling stays consistent across the UI and data layers.
extension DateTimeExtension on DateTime {
  /// يحوّل التاريخ من UTC إلى التوقيت المحلي فقط عندما تكون القيمة أصلًا UTC.
  /// Converts the value from UTC to local time only when the source is UTC.
  DateTime get toLocalTime {
    if (isUtc) {
      return TimezoneHelper.convertFromUtc(this);
    }
    return this;
  }

  /// يحوّل التاريخ المحلي إلى UTC قبل إرساله أو تخزينه بشكل موحّد.
  /// Converts a local date to UTC before transport or normalized storage.
  DateTime get toUtcTime {
    if (!isUtc) {
      return TimezoneHelper.convertToUtc(this);
    }
    return this;
  }

  /// ينسّق التاريخ بصيغة قصيرة مناسبة للبطاقات والجداول.
  /// Formats the date in a compact form suitable for cards and tables.
  String toDateString() {
    final local = toLocalTime;
    return DateFormat('dd/MM/yyyy').format(local);
  }

  /// ينسّق الجزء الزمني فقط عندما يكون التاريخ معروفًا في السياق.
  /// Formats the time portion only when the date context is already known.
  String toTimeString() {
    final local = toLocalTime;
    return DateFormat('HH:mm').format(local);
  }

  /// يدمج التاريخ والوقت في تمثيل واحد للعرض في السجلات أو التفاصيل.
  /// Combines date and time into a single display string for records or details.
  String toFormattedString() {
    final local = toLocalTime;
    return DateFormat('dd/MM/yyyy HH:mm').format(local);
  }

  /// يعرض وصفًا نسبيًا للزمن مثل "منذ دقيقة" أو "منذ ساعة".
  /// Produces a relative time label such as "1 minute ago" or "1 hour ago".
  String toRelativeString() {
    final now = DateTime.now();
    final difference = now.difference(toLocalTime);

    if (difference.inDays > 365) {
      return 'منذ ${difference.inDays ~/ 365} سنة';
    } else if (difference.inDays > 30) {
      return 'منذ ${difference.inDays ~/ 30} شهر';
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}

/// يضيف تحويلًا مرنًا إلى النصوص الزمنية الواردة من API أو التخزين المحلي
/// حتى يمكن عرضها أو إعادة تنسيقها بسهولة.
/// Adds flexible conversion helpers for date strings coming from the API or
/// local storage so they can be displayed or reformatted easily.
extension StringDateExtension on String {
  /// يحلل النص إلى DateTime ثم يعيد ضبطه وفق المنطقة الزمنية المحلية.
  /// Parses a string into DateTime and adjusts it to the local timezone.
  DateTime? toDateTime() {
    try {
      final utcDate = DateTime.parse(this);
      return TimezoneHelper.convertFromUtc(utcDate);
    } catch (_) {
      return null;
    }
  }

  /// يحوّل النص الزمني إلى تمثيل منسق، أو يعيده كما هو إذا فشل التحليل.
  /// Converts the date string to a formatted value, or returns the original text on failure.
  String toFormattedDate() {
    final dt = toDateTime();
    if (dt == null) return this;
    return dt.toFormattedString();
  }
}
