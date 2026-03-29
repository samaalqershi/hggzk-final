import 'dart:ui';

import 'package:hggzk/core/localization/app_localizations.dart';

/// تعداد طرق الدفع
/// Payment Methods enumeration
enum PaymentMethod {
  jwaliWallet,
  cashWallet,
  oneCashWallet,
  floskWallet,
  jaibWallet,
  cash,
  paypal,
  creditCard,

  /// محفظة سبأ كاش
  /// SabaCash wallet
  sabaCashWallet,
}

/// Extension for PaymentMethod enum
/// العربية: يعرّف الامتداد `PaymentMethodExtension`.
extension PaymentMethodExtension on PaymentMethod {
  /// Get the backend value for the payment method
  /// Exposes the `backendValue` value for callers that need it.
  /// العربية: يعيد القيمة `backendValue`.
  int get backendValue {
    switch (this) {
      case PaymentMethod.jwaliWallet:
        return 1;
      case PaymentMethod.cashWallet:
        return 2;
      case PaymentMethod.oneCashWallet:
        return 3;
      case PaymentMethod.floskWallet:
        return 4;
      case PaymentMethod.jaibWallet:
        return 5;
      case PaymentMethod.cash:
        return 6;
      case PaymentMethod.paypal:
        return 7;
      case PaymentMethod.creditCard:
        return 8;
      case PaymentMethod.sabaCashWallet:
        return 10; // يتوافق مع PaymentMethodEnum.SabaCashWallet في الباك-إند
    }
  }

  /// Get display name in Arabic
  /// Exposes the `displayNameAr` value for callers that need it.
  /// العربية: يعيد القيمة `displayNameAr`.
  String get displayNameAr {
    const locale = Locale('ar');
    switch (this) {
      case PaymentMethod.jwaliWallet:
        return AppLocalizations.translateSync(
          'core.paymentMethod.jwaliWallet',
          locale: locale,
        );
      case PaymentMethod.cashWallet:
        return AppLocalizations.translateSync(
          'core.paymentMethod.cashWallet',
          locale: locale,
        );
      case PaymentMethod.oneCashWallet:
        return AppLocalizations.translateSync(
          'core.paymentMethod.oneCashWallet',
          locale: locale,
        );
      case PaymentMethod.floskWallet:
        return AppLocalizations.translateSync(
          'core.paymentMethod.floskWallet',
          locale: locale,
        );
      case PaymentMethod.jaibWallet:
        return AppLocalizations.translateSync(
          'core.paymentMethod.jaibWallet',
          locale: locale,
        );
      case PaymentMethod.cash:
        return AppLocalizations.translateSync(
          'core.paymentMethod.cash',
          locale: locale,
        );
      case PaymentMethod.paypal:
        return AppLocalizations.translateSync(
          'core.paymentMethod.paypal',
          locale: locale,
        );
      case PaymentMethod.creditCard:
        return AppLocalizations.translateSync(
          'core.paymentMethod.creditCard',
          locale: locale,
        );
      case PaymentMethod.sabaCashWallet:
        return AppLocalizations.translateSync(
          'core.paymentMethod.sabaCashWallet',
          locale: locale,
        );
    }
  }

  /// Get display name in English
  /// Exposes the `displayNameEn` value for callers that need it.
  /// العربية: يعيد القيمة `displayNameEn`.
  String get displayNameEn {
    const locale = Locale('en');
    switch (this) {
      case PaymentMethod.jwaliWallet:
        return AppLocalizations.translateSync(
          'core.paymentMethod.jwaliWallet',
          locale: locale,
        );
      case PaymentMethod.cashWallet:
        return AppLocalizations.translateSync(
          'core.paymentMethod.cashWallet',
          locale: locale,
        );
      case PaymentMethod.oneCashWallet:
        return AppLocalizations.translateSync(
          'core.paymentMethod.oneCashWallet',
          locale: locale,
        );
      case PaymentMethod.floskWallet:
        return AppLocalizations.translateSync(
          'core.paymentMethod.floskWallet',
          locale: locale,
        );
      case PaymentMethod.jaibWallet:
        return AppLocalizations.translateSync(
          'core.paymentMethod.jaibWallet',
          locale: locale,
        );
      case PaymentMethod.cash:
        return AppLocalizations.translateSync(
          'core.paymentMethod.cash',
          locale: locale,
        );
      case PaymentMethod.paypal:
        return AppLocalizations.translateSync(
          'core.paymentMethod.paypal',
          locale: locale,
        );
      case PaymentMethod.creditCard:
        return AppLocalizations.translateSync(
          'core.paymentMethod.creditCard',
          locale: locale,
        );
      case PaymentMethod.sabaCashWallet:
        return AppLocalizations.translateSync(
          'core.paymentMethod.sabaCashWallet',
          locale: locale,
        );
    }
  }

  /// Get icon name for the payment method
  /// Exposes the `iconName` value for callers that need it.
  /// العربية: يعيد القيمة `iconName`.
  String get iconName {
    switch (this) {
      case PaymentMethod.jwaliWallet:
        return 'jwali';
      case PaymentMethod.cashWallet:
        return 'cash_wallet';
      case PaymentMethod.oneCashWallet:
        return 'one_cash';
      case PaymentMethod.floskWallet:
        return 'flosk';
      case PaymentMethod.jaibWallet:
        return 'jaib';
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.paypal:
        return 'paypal';
      case PaymentMethod.creditCard:
        return 'credit_card';
      case PaymentMethod.sabaCashWallet:
        return 'sabacash';
    }
  }

  /// Check if the payment method is a wallet
  /// Exposes the `isWallet` value for callers that need it.
  /// العربية: يعيد القيمة `isWallet`.
  bool get isWallet {
    switch (this) {
      case PaymentMethod.jwaliWallet:
      case PaymentMethod.cashWallet:
      case PaymentMethod.oneCashWallet:
      case PaymentMethod.floskWallet:
      case PaymentMethod.jaibWallet:
      case PaymentMethod.sabaCashWallet:
        return true;
      default:
        return false;
    }
  }

  /// Check if the payment method is online
  /// Exposes the `isOnline` value for callers that need it.
  /// العربية: يعيد القيمة `isOnline`.
  bool get isOnline {
    switch (this) {
      case PaymentMethod.cash:
        return false;
      default:
        return true;
    }
  }

  /// Create PaymentMethod from backend value
  /// Processes the `fromBackendValue` flow and maps it into the app-level behavior.
  /// العربية: يعالج `fromBackendValue`.
  static PaymentMethod fromBackendValue(int value) {
    switch (value) {
      case 1:
        return PaymentMethod.jwaliWallet;
      case 2:
        return PaymentMethod.cashWallet;
      case 3:
        return PaymentMethod.oneCashWallet;
      case 4:
        return PaymentMethod.floskWallet;
      case 5:
        return PaymentMethod.jaibWallet;
      case 6:
        return PaymentMethod.cash;
      case 7:
        return PaymentMethod.paypal;
      case 8:
        return PaymentMethod.creditCard;
      case 10:
        return PaymentMethod.sabaCashWallet;
      default:
        return PaymentMethod.cash;
    }
  }

  /// Create PaymentMethod from string
  /// Processes the `fromString` flow and maps it into the app-level behavior.
  /// العربية: يعالج `fromString`.
  static PaymentMethod fromString(String value) {
    final normalizedValue = value.toLowerCase().replaceAll('_', '');
    switch (normalizedValue) {
      case 'jwaliwallet':
      case 'jwali':
        return PaymentMethod.jwaliWallet;
      case 'cashwallet':
        return PaymentMethod.cashWallet;
      case 'onecashwallet':
      case 'onecash':
        return PaymentMethod.oneCashWallet;
      case 'floskwallet':
      case 'flosk':
        return PaymentMethod.floskWallet;
      case 'jaibwallet':
      case 'jaib':
        return PaymentMethod.jaibWallet;
      case 'cash':
        return PaymentMethod.cash;
      case 'paypal':
        return PaymentMethod.paypal;
      case 'creditcard':
      case 'credit':
        return PaymentMethod.creditCard;
      case 'sabacashwallet':
      case 'sabacash':
        return PaymentMethod.sabaCashWallet;
      default:
        return PaymentMethod.cash;
    }
  }
}

/// تعداد حالات الدفع
/// Payment Status enumeration
enum PaymentStatus {
  successful,
  failed,
  pending,
  refunded,
  voided,
  partiallyRefunded,
}

/// Extension for PaymentStatus enum
/// العربية: يعرّف الامتداد `PaymentStatusExtension`.
extension PaymentStatusExtension on PaymentStatus {
  /// Get display name in Arabic
  /// Exposes the `displayNameAr` value for callers that need it.
  /// العربية: يعيد القيمة `displayNameAr`.
  String get displayNameAr {
    const locale = Locale('ar');
    switch (this) {
      case PaymentStatus.successful:
        return AppLocalizations.translateSync(
          'core.paymentStatus.successful',
          locale: locale,
        );
      case PaymentStatus.failed:
        return AppLocalizations.translateSync(
          'core.paymentStatus.failed',
          locale: locale,
        );
      case PaymentStatus.pending:
        return AppLocalizations.translateSync(
          'core.paymentStatus.pending',
          locale: locale,
        );
      case PaymentStatus.refunded:
        return AppLocalizations.translateSync(
          'core.paymentStatus.refunded',
          locale: locale,
        );
      case PaymentStatus.voided:
        return AppLocalizations.translateSync(
          'core.paymentStatus.voided',
          locale: locale,
        );
      case PaymentStatus.partiallyRefunded:
        return AppLocalizations.translateSync(
          'core.paymentStatus.partiallyRefunded',
          locale: locale,
        );
    }
  }

  /// Get display name in English
  /// Exposes the `displayNameEn` value for callers that need it.
  /// العربية: يعيد القيمة `displayNameEn`.
  String get displayNameEn {
    const locale = Locale('en');
    switch (this) {
      case PaymentStatus.successful:
        return AppLocalizations.translateSync(
          'core.paymentStatus.successful',
          locale: locale,
        );
      case PaymentStatus.failed:
        return AppLocalizations.translateSync(
          'core.paymentStatus.failed',
          locale: locale,
        );
      case PaymentStatus.pending:
        return AppLocalizations.translateSync(
          'core.paymentStatus.pending',
          locale: locale,
        );
      case PaymentStatus.refunded:
        return AppLocalizations.translateSync(
          'core.paymentStatus.refunded',
          locale: locale,
        );
      case PaymentStatus.voided:
        return AppLocalizations.translateSync(
          'core.paymentStatus.voided',
          locale: locale,
        );
      case PaymentStatus.partiallyRefunded:
        return AppLocalizations.translateSync(
          'core.paymentStatus.partiallyRefunded',
          locale: locale,
        );
    }
  }

  /// Get color for status
  /// Exposes the `colorCode` value for callers that need it.
  /// العربية: يعيد القيمة `colorCode`.
  String get colorCode {
    switch (this) {
      case PaymentStatus.successful:
        return '#4CAF50';
      case PaymentStatus.failed:
        return '#F44336';
      case PaymentStatus.pending:
        return '#FF9800';
      case PaymentStatus.refunded:
        return '#2196F3';
      case PaymentStatus.voided:
        return '#9E9E9E';
      case PaymentStatus.partiallyRefunded:
        return '#03A9F4';
    }
  }

  /// Check if payment is complete
  /// Exposes the `isComplete` value for callers that need it.
  /// العربية: يعيد القيمة `isComplete`.
  bool get isComplete {
    return this == PaymentStatus.successful;
  }

  /// Check if payment can be refunded
  /// Exposes the `canRefund` value for callers that need it.
  /// العربية: يعيد القيمة `canRefund`.
  bool get canRefund {
    return this == PaymentStatus.successful;
  }

  /// Create PaymentStatus from string
  /// Processes the `fromString` flow and maps it into the app-level behavior.
  /// العربية: يعالج `fromString`.
  static PaymentStatus fromString(String value) {
    final normalizedValue = value.toLowerCase();
    switch (normalizedValue) {
      case 'successful':
      case 'success':
      case 'completed':
        return PaymentStatus.successful;
      case 'failed':
      case 'failure':
        return PaymentStatus.failed;
      case 'pending':
      case 'processing':
        return PaymentStatus.pending;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'voided':
      case 'cancelled':
        return PaymentStatus.voided;
      case 'partiallyrefunded':
      case 'partially_refunded':
        return PaymentStatus.partiallyRefunded;
      default:
        return PaymentStatus.pending;
    }
  }
}
