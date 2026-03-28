import 'package:intl/intl.dart'; // Add intl package to pubspec.yaml
import '../constants/app_constants.dart';

/// مجموعة تنسيقات صغيرة موحدة للعرض داخل الواجهة.
/// Shared presentation formatters for currency, dates, phone numbers, and names.
class Formatters {
  /// يمنع إنشاء مثيل لأن جميع الدوال هنا ساكنة.
  /// Prevents instantiation because the class only exposes static helpers.
  Formatters._();

  /// ينسق مبلغًا رقميًا وفق اللغة والعملة المطلوبة مع fallback آمن.
  /// Formats a numeric amount for display with locale-aware currency fallback.
  static String formatCurrency(double amount, String currencySymbol,
      {String locale = 'en_US'}) {
    // Use Intl package for proper localization and currency formatting
    // Example: 'en_US' for USD, 'ar_YE' for YER (Yemen Rial)
    // Ensure you have the necessary locales imported or configured if using specific regions.
    try {
      // For Yemen Rial (YER), locale might be 'ar_YE' or a general Arabic locale
      final localeToUse =
          locale.isEmpty ? 'ar' : locale; // Fallback to 'ar' if locale is empty

      // If Intl doesn't have 'ar_YE', using a generic arabic locale might work or default to English formatting
      final NumberFormat formatter = NumberFormat.currency(
        locale: localeToUse,
        symbol: currencySymbol,
        decimalDigits: 2, // Number of decimal places
      );
      return formatter.format(amount);
    } catch (e) {
      // Fallback formatting if locale is not supported or error occurs
      return '$currencySymbol ${amount.toStringAsFixed(2)}';
    }
  }

  /// يحول التاريخ إلى تمثيل قصير ثابت مناسب لبطاقات القوائم.
  /// Converts a date into a compact display string suitable for list items.
  static String formatDate(DateTime date,
      {String format = AppConstants.dateFormat}) {
    try {
      final formatter = DateFormat(format);
      return formatter.format(date);
    } catch (e) {
      return ''; // Return empty string or handle error appropriately
    }
  }

  /// يعرض الوقت وحده عندما نحتاج إلى فصل الجزء الزمني عن التاريخ.
  /// Formats only the time component when date context is already known.
  static String formatTime(DateTime dateTime,
      {String format = AppConstants.timeFormat}) {
    try {
      final formatter = DateFormat(format);
      return formatter.format(dateTime);
    } catch (e) {
      return ''; // Return empty string or handle error appropriately
    }
  }

  /// يدمج التاريخ والوقت في قيمة واحدة للأحداث والسجلات.
  /// Combines date and time into a single string for events and records.
  static String formatDateTime(DateTime dateTime,
      {String format = AppConstants.dateTimeFormat}) {
    try {
      final formatter = DateFormat(format);
      return formatter.format(dateTime);
    } catch (e) {
      return ''; // Return empty string or handle error appropriately
    }
  }

  /// يخفي الرقم الحقيقي جزئيًا بدل إعادة تنسيقه بالكامل.
  /// Masks the phone number instead of trying to normalize every regional format.
  static String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith('7') && phoneNumber.length == 9) {
      return '7XX XXX XXX'; // Masked phone number example
    }
    return phoneNumber; // Return as is if format is unknown
  }

  /// يوحد الاسم بصيغة عنوان بسيطة عند عرضه في أماكن صغيرة.
  /// Normalizes a display name into a simple title-style format.
  static String formatName(String name) {
    if (name.isEmpty) return '';
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }

  // Add other formatting methods as needed
}
