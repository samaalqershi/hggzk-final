import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/storage_constants.dart';
import '../../injection_container.dart'; // Ensure sl is initialized before this is used

/// يدير لغة التطبيق المحفوظة والافتراضية حتى تبدأ الواجهة بالاتجاه والنص المناسبين.
/// Resolves and persists the app locale so the first frame reflects user preference or system choice.
class LocaleManager {
  /// يمنع إنشاء مدير اللغة لأن جميع عملياته ثابتة ومشتركة.
  /// Prevents instantiation because all locale operations are static and
  /// shared.
  LocaleManager._();

  /// اللغات التي يستطيع التطبيق عرضها فعليًا داخل `MaterialApp`.
  /// Locales that the app can genuinely render through `MaterialApp`.
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('ar', ''), // Arabic
  ];

  /// رموز اللغات المختصرة المستخدمة للتحقق من التفضيل المحفوظ أو لغة النظام.
  /// Short language codes used to validate saved preferences and the platform locale.
  static const List<String> supportedLocalesShort = ['en', 'ar'];

  /// اللغة الاحتياطية التي تُستخدم عندما لا توجد تفضيلات صالحة أو مدعومة.
  /// Fallback locale used when no valid or supported locale is available.
  static const Locale defaultLocale = Locale('ar', ''); // Default to Arabic

  /// يفضّل اللغة المحفوظة، ثم لغة النظام، ثم اللغة الافتراضية عند غياب الخيارين.
  /// Prefers the saved language, then the system locale, then the default fallback.
  static Future<Locale> getInitialLocale() async {
    final prefs = sl<SharedPreferences>();
    final savedLocale = prefs.getString(StorageConstants.language);

    if (savedLocale != null && supportedLocalesShort.contains(savedLocale)) {
      return Locale(savedLocale, '');
    } else {
      final String systemLocale = PlatformDispatcher.instance.locale.toString();
      if (supportedLocalesShort.contains(systemLocale.split('_')[0])) {
        return Locale(systemLocale.split('_')[0], '');
      }
      return defaultLocale;
    }
  }

  /// يحفظ رمز اللغة فقط لأن هذا المستوى لا يميّز بين النسخ الإقليمية.
  /// Stores only the language code because this layer does not distinguish regional variants.
  static Future<void> setLocale(Locale locale) async {
    final prefs = sl<SharedPreferences>();
    await prefs.setString(StorageConstants.language, locale.languageCode);
  }

  /// يعيد اللغة النشطة من شجرة الواجهات، أو اللغة الاحتياطية إذا لم تتوفر.
  /// Returns the active locale from the widget tree, or the fallback when unavailable.
  static Locale getCurrentLocale([BuildContext? context]) {
    if (context != null) {
      return Localizations.localeOf(context);
    }
    return defaultLocale;
  }
}
