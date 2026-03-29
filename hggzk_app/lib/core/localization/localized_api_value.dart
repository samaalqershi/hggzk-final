import 'dart:convert';

import 'locale_manager.dart';

/// Picks bilingual payload values based on the active app locale.
///
/// يدير اختيار القيم الثنائية اللغة القادمة من الـ API بحسب لغة التطبيق.
class LocalizedApiValue {
  LocalizedApiValue._();

  static bool get isEnglish =>
      LocaleManager.getCurrentLocale().languageCode.toLowerCase() == 'en';

  static String text(
    Map<String, dynamic> json, {
    required String arabicKey,
    String? englishKey,
    String? fallbackKey,
    String defaultValue = '',
  }) {
    final arabic = _string(json[arabicKey]);
    final english = englishKey == null ? null : _string(json[englishKey]);
    final fallback = fallbackKey == null ? null : _string(json[fallbackKey]);

    if (isEnglish) {
      return _firstNonEmpty([english, arabic, fallback]) ?? defaultValue;
    }

    return _firstNonEmpty([arabic, english, fallback]) ?? defaultValue;
  }

  static Map<String, dynamic> map(
    Map<String, dynamic> json, {
    required String arabicKey,
    String? englishKey,
  }) {
    final arabic = _asMap(json[arabicKey]);
    final english = englishKey == null ? null : _asMap(json[englishKey]);

    if (isEnglish) {
      return english ?? arabic ?? const <String, dynamic>{};
    }

    return arabic ?? english ?? const <String, dynamic>{};
  }

  static List<String> stringList(
    Map<String, dynamic> json, {
    required String arabicKey,
    String? englishKey,
  }) {
    final arabic = _asStringList(json[arabicKey]);
    final english = englishKey == null ? null : _asStringList(json[englishKey]);

    if (isEnglish) {
      return english ?? arabic ?? const <String>[];
    }

    return arabic ?? english ?? const <String>[];
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  static String? _string(dynamic value) {
    if (value == null) {
      return null;
    }

    final normalized = value.toString().trim();
    return normalized.isEmpty ? null : normalized;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }

    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map) {
          return decoded.map((key, item) => MapEntry(key.toString(), item));
        }
      } catch (_) {}
    }

    return null;
  }

  static List<String>? _asStringList(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is List) {
      return value.map((item) => item.toString()).toList(growable: false);
    }

    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.map((item) => item.toString()).toList(growable: false);
        }
      } catch (_) {}
    }

    return null;
  }
}
