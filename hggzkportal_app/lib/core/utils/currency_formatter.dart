import 'package:intl/intl.dart';

/// أداة تنسيق مبنية على `intl` لعرض المبالغ بالطريقة المناسبة للواجهة العربية.
/// `intl`-based formatter for displaying money amounts in the portal's Arabic-first UI.
class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    symbol: '',
    decimalDigits: 2,
    locale: 'ar_SA',
  );

  static final _compactFormatter = NumberFormat.compactCurrency(
    symbol: '',
    decimalDigits: 0,
    locale: 'ar_SA',
  );

  /// ينسّق المبلغ كاملًا مع الخانات العشرية القياسية للعرض المالي.
  /// Formats the amount with standard decimal places for financial display.
  static String format(double amount, {String? currency}) {
    final formatted = _formatter.format(amount);
    if (currency != null && currency.isNotEmpty) {
      return '$formatted $currency';
    }
    return '${formatted} ريال';
  }

  /// ينسّق المبلغ بصيغة مختصرة عندما تكون المساحة محدودة.
  /// Formats the amount in a compact form when screen space is limited.
  static String formatCompact(double amount, {String? currency}) {
    final formatted = _compactFormatter.format(amount);
    if (currency != null && currency.isNotEmpty) {
      return '$formatted $currency';
    }
    return '${formatted} ريال';
  }

  /// ينسّق المبلغ بعدد خانات عشرية يحدده المستدعي.
  /// Formats the amount using a caller-defined number of decimal places.
  static String formatWithDecimals(double amount, int decimals,
      {String? currency}) {
    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: decimals,
      locale: 'ar_SA',
    );
    final formatted = formatter.format(amount);
    if (currency != null && currency.isNotEmpty) {
      return '$formatted $currency';
    }
    return '${formatted} ريال';
  }

  /// ينسّق النسبة المئوية بصيغة ثابتة ومختصرة.
  /// Formats a percentage in a consistent compact form.
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  /// يحوّل النص إلى رقم مع تجاهل رموز العملة والمسافات.
  /// Parses a string into a double while ignoring currency symbols and spaces.
  static double? parseAmount(String value) {
    try {
      // Remove currency symbols and spaces
      final cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
      return double.tryParse(cleanValue);
    } catch (e) {
      return null;
    }
  }
}
