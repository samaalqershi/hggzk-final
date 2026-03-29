import 'package:flutter/widgets.dart';
import 'package:hggzk/core/localization/app_localizations.dart';
import 'package:hggzk/core/localization/locale_manager.dart';

import 'failures.dart';

/// Resolves domain failures into localized user-facing text.
class FailureLocalizer {
  static const Set<String> _genericMessages = <String>{
    'server failure',
    'an unexpected error occurred',
    'unknown failure',
    'network failure',
    'authentication failure',
    'validation failure',
    'resource not found',
    'unauthorized access',
    'request timeout',
    'permission denied',
    'cache failure',
    'server error occurred',
  };

  static String localize(
    Failure failure, {
    Locale? locale,
  }) {
    final resolvedLocale = locale ?? LocaleManager.getCurrentLocale();
    final rawMessage = failure.message.trim();
    final normalized = rawMessage.toLowerCase();

    if (_shouldTranslateTechnicalMessage(normalized)) {
      return _localizedFallback(failure, resolvedLocale, normalized);
    }

    if (rawMessage.isNotEmpty && !_genericMessages.contains(normalized)) {
      return rawMessage;
    }

    return _localizedFallback(failure, resolvedLocale, normalized);
  }

  static bool _shouldTranslateTechnicalMessage(String normalized) {
    if (normalized.isEmpty) {
      return true;
    }

    return normalized.startsWith('failed to ') ||
        normalized.startsWith('unexpected error:') ||
        normalized.startsWith('invalid response') ||
        normalized.startsWith('use instance methods instead') ||
        normalized.endsWith('not implemented') ||
        normalized.contains('network error occurred') ||
        normalized.contains('cache expired') ||
        normalized.contains('no cached ') ||
        normalized.contains('not initialized') ||
        normalized == 'invalid language code';
  }

  static String _localizedFallback(
    Failure failure,
    Locale locale,
    String normalizedMessage,
  ) {
    if (normalizedMessage == 'invalid language code') {
      return AppLocalizations.translateSync(
        'settings.language.invalidCode',
        locale: locale,
      );
    }

    if (normalizedMessage.contains('network error occurred')) {
      return AppLocalizations.translateSync(
        'common.noInternet',
        locale: locale,
      );
    }

    if (normalizedMessage.startsWith('invalid response')) {
      return AppLocalizations.translateSync(
        'common.invalidData',
        locale: locale,
      );
    }

    switch (failure.runtimeType) {
      case NetworkFailure:
        return AppLocalizations.translateSync(
          'common.noInternet',
          locale: locale,
        );
      case CacheFailure:
        return AppLocalizations.translateSync(
          'common.localStorageError',
          locale: locale,
        );
      case ValidationFailure:
      case ValidationFailureWithErrors:
        return AppLocalizations.translateSync(
          'common.invalidData',
          locale: locale,
        );
      case AuthenticationFailure:
      case AuthFailure:
        return AppLocalizations.translateSync(
          'common.invalidCredentials',
          locale: locale,
        );
      case UnauthorizedFailure:
      case PermissionDeniedFailure:
        return AppLocalizations.translateSync(
          'common.unauthorizedAction',
          locale: locale,
        );
      case NotFoundFailure:
        return AppLocalizations.translateSync(
          'common.notFound',
          locale: locale,
        );
      case TimeoutFailure:
        return AppLocalizations.translateSync(
          'common.requestTimeout',
          locale: locale,
        );
      case SessionExpiredFailure:
        return AppLocalizations.translateSync(
          'common.sessionExpired',
          locale: locale,
        );
      case ServerFailure:
      case ApiFailure:
      case UnknownFailure:
      default:
        return AppLocalizations.translateSync(
          'common.unexpectedError',
          locale: locale,
        );
    }
  }
}
