import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;
import 'locale_manager.dart';

/// Loads and exposes user-facing translations from external JSON assets.
///
/// يدير تحميل النصوص الظاهرة للمستخدم من ملفات لغة خارجية.
class AppLocalizations {
  AppLocalizations(this.locale, this._localizedValues);

  final Locale locale;
  final Map<String, String> _localizedValues;
  static final Map<String, Map<String, String>> _cache =
      <String, Map<String, String>>{};

  static const String _assetsRoot = 'assets/l10n';
  static const List<String> _localeFiles = <String>[
    'common.json',
    'auth.json',
    'booking.json',
    'chat.json',
    'payment.json',
    'notifications.json',
    'profile.json',
    'settings.json',
    'support.json',
    'ai_chat.json',
    'property.json',
    'reviews.json',
    'search.json',
    'favorites.json',
    'home.json',
    'reference.json',
    'navigation.json',
    'core_runtime.json',
  ];

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  static const Map<String, String> _legacyKeyAliases = {
    'appName': 'app.appName',
    'welcome': 'common.welcome',
    'login': 'common.login',
    'register': 'common.register',
    'email': 'common.email',
    'phone': 'common.phone',
    'password': 'common.password',
    'forgotPassword': 'common.forgotPassword',
    'search': 'common.search',
    'home': 'common.home',
    'favorites': 'common.favorites',
    'bookings': 'common.bookings',
    'profile': 'common.profile',
    'settings': 'common.settings',
    'language': 'common.language',
    'theme': 'common.theme',
    'notifications': 'common.notifications',
    'logout': 'common.logout',
    'cancel': 'common.cancel',
    'confirm': 'common.confirm',
    'save': 'common.save',
    'delete': 'common.delete',
    'edit': 'common.edit',
    'add': 'common.add',
    'remove': 'common.remove',
    'unread': 'common.unread',
    'yes': 'common.yes',
    'no': 'common.no',
    'ok': 'common.ok',
    'close': 'common.close',
    'back': 'common.back',
    'next': 'common.next',
    'done': 'common.done',
    'skip': 'common.skip',
    'retry': 'common.retry',
    'loading': 'common.loading',
    'error': 'common.error',
    'success': 'common.success',
    'warning': 'common.warning',
    'info': 'common.info',
    'noData': 'common.noData',
    'noInternet': 'common.noInternet',
    'somethingWentWrong': 'common.somethingWentWrong',
    'tryAgain': 'common.tryAgain',
    'pullToRefresh': 'common.pullToRefresh',
    'releaseToRefresh': 'common.releaseToRefresh',
    'refreshing': 'common.refreshing',
    'help_support': 'support.help_support',
    'need_help': 'support.need_help',
    'support_description': 'support.support_description',
    'send_message': 'support.send_message',
    'your_name': 'support.your_name',
    'subject': 'support.subject',
    'your_message': 'support.your_message',
    'send': 'support.send',
    'contact_info': 'support.contact_info',
    'working_hours': 'support.working_hours',
    'message_sent': 'support.message_sent',
    'support_success_message': 'support.support_success_message',
    'name_required': 'support.name_required',
    'email_required': 'support.email_required',
    'subject_required': 'support.subject_required',
    'message_required': 'support.message_required',
    'reference': 'support.reference'
  };

  static const Map<String, Map<String, String>> _builtinFallbackValues = {
    'ar': {
      'app.appName': 'حجزك',
      'common.retry': 'إعادة المحاولة',
      'common.error': 'خطأ',
      'common.loading': 'جاري التحميل...',
      'common.somethingWentWrong': 'حدث خطأ ما',
      'common.serverError': 'خطأ في الخادم',
      'common.notFound': 'لم يتم العثور على البيانات',
      'common.permissionDenied': 'ليس لديك صلاحية',
      'common.noInternet': 'لا يوجد اتصال بالإنترنت',
      'common.unexpectedError': 'حدث خطأ غير متوقع',
      'common.cancel': 'إلغاء',
      'common.confirm': 'تأكيد',
      'common.ok': 'موافق',
      'common.close': 'إغلاق',
      'common.back': 'رجوع',
      'common.next': 'التالي',
      'common.done': 'تم',
      'common.skip': 'تخطي',
      'common.login': 'تسجيل الدخول',
      'common.required': 'هذا الحقل مطلوب',
      'common.unread': 'غير مقروء',
      'common.sessionExpired':
          'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى',
      'support.help_support': 'الدعم والمساعدة',
      'support.reference': 'رقم المرجع',
    },
    'en': {
      'app.appName': 'hggzk',
      'common.retry': 'Retry',
      'common.error': 'Error',
      'common.loading': 'Loading...',
      'common.somethingWentWrong': 'Something went wrong',
      'common.serverError': 'Server error',
      'common.notFound': 'Data not found',
      'common.permissionDenied': 'You do not have permission',
      'common.noInternet': 'No internet connection',
      'common.unexpectedError': 'An unexpected error occurred',
      'common.cancel': 'Cancel',
      'common.confirm': 'Confirm',
      'common.ok': 'OK',
      'common.close': 'Close',
      'common.back': 'Back',
      'common.next': 'Next',
      'common.done': 'Done',
      'common.skip': 'Skip',
      'common.login': 'Login',
      'common.required': 'This field is required',
      'common.unread': 'Unread',
      'common.sessionExpired': 'Session expired. Please sign in again',
      'support.help_support': 'Help & Support',
      'support.reference': 'Reference',
    },
  };

  static String _resolveLocalizedValue({
    required String key,
    required String? raw,
    String? fallback,
  }) {
    if (raw != null) {
      return raw;
    }

    // Keep optional fallbacks only for local debug visibility. In normal app
    // execution the visible text must come from external localization assets.
    if (kDebugMode && fallback != null) {
      return fallback;
    }

    return key;
  }

  /// Returns a localized value for [key].
  ///
  /// Supports named placeholders in the form `{name}`.
  String get(
    String key, {
    String? fallback,
    Map<String, Object?> params = const {},
  }) {
    final normalizedKey = _legacyKeyAliases[key] ?? key;
    final raw = _localizedValues[normalizedKey] ??
        _localizedValues[key] ??
        _builtinFallbackValues[locale.languageCode]?[normalizedKey] ??
        _builtinFallbackValues[locale.languageCode]?[key];
    final resolved = _resolveLocalizedValue(
      key: key,
      raw: raw,
      fallback: fallback,
    );

    if (raw == null && kDebugMode) {
      debugPrint(
        '[l10n] Missing key "$normalizedKey" for locale ${locale.languageCode}',
      );
    }

    if (params.isEmpty) {
      return resolved;
    }

    var interpolated = resolved;
    params.forEach((paramKey, value) {
      interpolated =
          interpolated.replaceAll('{$paramKey}', value?.toString() ?? '');
    });
    return interpolated;
  }

  String formatDate(DateTime date) {
    return intl.DateFormat.yMd(locale.languageCode).format(date);
  }

  String formatTime(DateTime time) {
    return intl.DateFormat.Hm(locale.languageCode).format(time);
  }

  static Future<AppLocalizations> load(Locale locale) async {
    final values = await ensureLocaleLoaded(locale);
    return AppLocalizations(locale, values);
  }

  static Future<Map<String, String>> ensureLocaleLoaded(Locale locale) async {
    final code = locale.languageCode;
    final cached = _cache[code];
    if (cached != null) {
      return cached;
    }

    final values = await _loadLocaleValues(code);
    _cache[code] = values;
    return values;
  }

  static Future<String> translate(
    String key, {
    required Locale locale,
    String? fallback,
    Map<String, Object?> params = const {},
  }) async {
    final values = await ensureLocaleLoaded(locale);
    return AppLocalizations(locale, values).get(
      key,
      fallback: fallback,
      params: params,
    );
  }

  static String translateSync(
    String key, {
    Locale? locale,
    String? fallback,
    Map<String, Object?> params = const {},
  }) {
    final resolvedLocale = locale ?? LocaleManager.getCurrentLocale();
    final code = resolvedLocale.languageCode;
    final values = _cache[code];
    final normalizedKey = _legacyKeyAliases[key] ?? key;
    final raw = values?[normalizedKey] ??
        values?[key] ??
        _builtinFallbackValues[code]?[normalizedKey] ??
        _builtinFallbackValues[code]?[key];
    final resolved = _resolveLocalizedValue(
      key: key,
      raw: raw,
      fallback: fallback,
    );

    if (params.isEmpty) {
      return resolved;
    }

    var interpolated = resolved;
    params.forEach((paramKey, value) {
      interpolated =
          interpolated.replaceAll('{$paramKey}', value?.toString() ?? '');
    });
    return interpolated;
  }

  static Future<Map<String, String>> _loadLocaleValues(
      String languageCode) async {
    final merged = <String, String>{};

    for (final fileName in _localeFiles) {
      final assetPath = '$_assetsRoot/$languageCode/$fileName';
      await _mergeJsonAsset(assetPath, merged);
    }

    if (merged.isNotEmpty) {
      if (kDebugMode) {
        debugPrint(
          '[l10n] Loaded ${merged.length} keys for $languageCode from ${_localeFiles.length} files',
        );
      }
      return merged;
    }

    // Fallback for environments where the file set changes and a new JSON file
    // was not yet added to the explicit list above.
    try {
      final manifestJson = await rootBundle.loadString('AssetManifest.json');
      final manifestMap =
          Map<String, dynamic>.from(jsonDecode(manifestJson) as Map);

      final localePrefix = '$_assetsRoot/$languageCode/';
      final localeFiles = manifestMap.keys
          .where(
            (assetPath) =>
                assetPath.startsWith(localePrefix) &&
                assetPath.endsWith('.json'),
          )
          .toList()
        ..sort();

      for (final assetPath in localeFiles) {
        await _mergeJsonAsset(assetPath, merged);
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[l10n] Failed to scan AssetManifest for $languageCode: $error',
        );
      }
    }

    if (kDebugMode) {
      debugPrint(
        '[l10n] Loaded ${merged.length} keys for $languageCode after fallback scan',
      );
    }

    return merged;
  }

  static Future<void> _mergeJsonAsset(
    String assetPath,
    Map<String, String> target,
  ) async {
    try {
      final content = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(content);
      if (decoded is! Map) {
        return;
      }

      decoded.forEach((key, value) {
        if (key is String && value is String) {
          target[key] = value;
        }
      });
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[l10n] Failed to load $assetPath: $error');
      }
    }
  }
}

/// Convenience accessors used throughout widgets during the migration.
extension AppLocalizationsContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  String tr(
    String key, {
    String? fallback,
    Map<String, Object?> params = const {},
  }) {
    return l10n.get(key, fallback: fallback, params: params);
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
        (supported) => supported.languageCode == locale.languageCode,
      );

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
