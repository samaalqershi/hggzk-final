import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// يقرأ المنطقة الزمنية للجهاز ويقدمها بصيغ جاهزة للطلب أو العرض.
/// Reads the device timezone and exposes it in API-friendly and UI-friendly forms.
class TimezoneHelper {
  /// اسم المنطقة الزمنية بعد أول قراءة ناجحة لتجنب إعادة الاستعلام.
  /// Cached timezone name so we don't query the platform repeatedly.
  static String? _cachedTimezone;

  /// فرق التوقيت بالدقائق المرتبط بالمنطقة الزمنية الحالية.
  /// Cached offset in minutes for the current timezone.
  static int? _cachedOffset;

  /// يمنع تهيئة حزم التوقيت أكثر من مرة.
  /// Guards one-time initialization of the timezone packages.
  static bool _isInitialized = false;

  /// يهيئ بيانات المناطق الزمنية ويجلب المنطقة الحالية مبكرًا.
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();
      _isInitialized = true;

      // الحصول على timezone مباشرة عند التهيئة
      await getDeviceTimezone();
    } catch (e) {
      print('Error initializing timezone: $e');
    }
  }

  /// يعيد اسم المنطقة الزمنية التي يعمل عليها الجهاز.
  /// Exposes the device's timezone identifier so callers can read it without depending on implementation details.
  static Future<String> getDeviceTimezone() async {
    if (_cachedTimezone != null) return _cachedTimezone!;

    try {
      // الحصول على timezone ID (مثل: Asia/Riyadh)
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      _cachedTimezone = timezoneInfo.identifier;

      // حساب الـ offset بالدقائق
      final now = DateTime.now();
      _cachedOffset = now.timeZoneOffset.inMinutes;

      print('📍 Device Timezone: $_cachedTimezone');
      print('⏰ UTC Offset: $_cachedOffset minutes');

      return _cachedTimezone!;
    } catch (e) {
      print('Error getting timezone: $e');

      // في حالة الفشل، استخدم UTC offset
      final offset = DateTime.now().timeZoneOffset;
      _cachedOffset = offset.inMinutes;
      _cachedTimezone = 'UTC${_formatOffset(offset)}';

      return _cachedTimezone!;
    }
  }

  /// يعيد فرق التوقيت بالدقائق، مع حفظه عند أول قراءة.
  static int getTimezoneOffset() {
    if (_cachedOffset != null) return _cachedOffset!;

    final offset = DateTime.now().timeZoneOffset;
    _cachedOffset = offset.inMinutes;
    return _cachedOffset!;
  }

  /// يحول فرق التوقيت إلى صيغة `+03:00` أو `-05:30`.
  static String _formatOffset(Duration offset) {
    final hours = offset.inHours;
    final minutes = offset.inMinutes.remainder(60).abs();
    final sign = offset.isNegative ? '-' : '+';

    if (minutes == 0) {
      return '$sign${hours.abs().toString().padLeft(2, '0')}:00';
    } else {
      return '$sign${hours.abs().toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    }
  }

  /// يمسح القيم المحفوظة عند الحاجة إلى إعادة اكتشاف المنطقة الزمنية.
  static void clearCache() {
    _cachedTimezone = null;
    _cachedOffset = null;
  }

  /// يبني الرؤوس التي يحتاجها الخادم لمعالجة التواريخ بشكل صحيح.
  static Map<String, String> getTimezoneHeaders() {
    return {
      'X-TimeZone': _cachedTimezone ?? 'UTC',
      'X-TimeZone-Offset': (_cachedOffset ?? 0).toString(),
    };
  }

  /// يحول تاريخ UTC إلى التوقيت المحلي باستخدام الإزاحة المخزنة.
  static DateTime convertFromUtc(DateTime utcDateTime) {
    if (_cachedOffset == null) {
      getTimezoneOffset();
    }

    return utcDateTime.add(Duration(minutes: _cachedOffset ?? 0));
  }

  /// يحول التوقيت المحلي إلى UTC اعتمادًا على الإزاحة الحالية.
  static DateTime convertToUtc(DateTime localDateTime) {
    if (_cachedOffset == null) {
      getTimezoneOffset();
    }

    return localDateTime.subtract(Duration(minutes: _cachedOffset ?? 0));
  }
}
