import 'dart:ui';

import 'package:hggzk/core/localization/app_localizations.dart';

/// Groups the allowed values for `BookingStatus` so the rest of the app stays type-safe.
/// العربية: يعرّف القيم المتاحة للنوع `BookingStatus`.
enum BookingStatus {
  confirmed,
  pending,
  cancelled,
  completed,
  checkedIn,
}

/// العربية: يعرّف الامتداد `BookingStatusExtension`.
extension BookingStatusExtension on BookingStatus {
  /// Exposes the `displayName` value for callers that need it.
  /// العربية: يعيد القيمة `displayName`.
  String get displayName {
    const locale = Locale('ar');
    switch (this) {
      case BookingStatus.confirmed:
        return AppLocalizations.translateSync(
          'core.bookingStatus.confirmed',
          locale: locale,
        );
      case BookingStatus.pending:
        return AppLocalizations.translateSync(
          'core.bookingStatus.pending',
          locale: locale,
        );
      case BookingStatus.cancelled:
        return AppLocalizations.translateSync(
          'core.bookingStatus.cancelled',
          locale: locale,
        );
      case BookingStatus.completed:
        return AppLocalizations.translateSync(
          'core.bookingStatus.completed',
          locale: locale,
        );
      case BookingStatus.checkedIn:
        return AppLocalizations.translateSync(
          'core.bookingStatus.checkedIn',
          locale: locale,
        );
    }
  }

  /// Exposes the `displayNameEn` value for callers that need it.
  /// العربية: يعيد القيمة `displayNameEn`.
  String get displayNameEn {
    const locale = Locale('en');
    switch (this) {
      case BookingStatus.confirmed:
        return AppLocalizations.translateSync(
          'core.bookingStatus.confirmed',
          locale: locale,
        );
      case BookingStatus.pending:
        return AppLocalizations.translateSync(
          'core.bookingStatus.pending',
          locale: locale,
        );
      case BookingStatus.cancelled:
        return AppLocalizations.translateSync(
          'core.bookingStatus.cancelled',
          locale: locale,
        );
      case BookingStatus.completed:
        return AppLocalizations.translateSync(
          'core.bookingStatus.completed',
          locale: locale,
        );
      case BookingStatus.checkedIn:
        return AppLocalizations.translateSync(
          'core.bookingStatus.checkedIn',
          locale: locale,
        );
    }
  }
}
