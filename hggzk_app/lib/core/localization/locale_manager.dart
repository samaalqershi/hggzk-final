import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/storage_constants.dart';
import 'package:hggzk/app/dependency_injection/injection_container.dart';

/// Represents `LocaleManager`.
/// العربية: يمثل `LocaleManager`.
class LocaleManager {
  /// Builds the `LocaleManager._` instance used by this layer.
  /// العربية: ينشئ مثيلًا جديدًا من `LocaleManager._`.
  LocaleManager._();

  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('ar', ''), // Arabic
    // Add other supported locales here
  ];

  /// Keeps the `supportedLocalesShort` value so this type can use it later.
  /// العربية: يخزن القيمة `supportedLocalesShort`.
  static const List<String> supportedLocalesShort = ['en', 'ar'];

  // Default locale if none is set or supported
  static const Locale defaultLocale = Locale('ar', ''); // Default to Arabic

  /// Exposes the initial locale so callers can read it without depending on implementation details.
  /// العربية: يعيد initial locale.
  static Future<Locale> getInitialLocale() async {
    final prefs = sl<SharedPreferences>();
    final savedLocale = prefs.getString(StorageConstants.language);

    if (savedLocale != null && supportedLocalesShort.contains(savedLocale)) {
      return Locale(savedLocale, '');
    } else {
      // Try to get system locale if available and supported
      final String systemLocale = PlatformDispatcher.instance.locale.toString();
      if (supportedLocalesShort.contains(systemLocale.split('_')[0])) {
        return Locale(systemLocale.split('_')[0], '');
      }
      // Fallback to default locale
      return defaultLocale;
    }
  }

  /// Sets the locale.
  /// العربية: يضبط locale.
  static Future<void> setLocale(Locale locale) async {
    final prefs = sl<SharedPreferences>();
    await prefs.setString(StorageConstants.language, locale.languageCode);
    // Note: Flutter doesn't automatically rebuild widgets when locale changes.
    // The MaterialApp.router should rebuild when the locale state changes (e.g., via Bloc).
  }

  /// Exposes the current locale so callers can read it without depending on implementation details.
  /// العربية: يعيد current locale.
  static Locale getCurrentLocale([BuildContext? context]) {
    if (context != null) {
      // Retrieve locale from MaterialApp's locale setting
      return Localizations.localeOf(context);
    }
    return defaultLocale;
  }
}
