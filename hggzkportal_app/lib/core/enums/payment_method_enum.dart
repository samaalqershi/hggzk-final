/// يعرّف طرق الدفع المعتمدة في النظام مع تمثيل عرضي وBackend ثابت.
/// Defines the payment methods supported by the system with display and backend mappings.
enum PaymentMethod {
  jwaliWallet,
  cashWallet,
  oneCashWallet,
  floskWallet,
  jaibWallet,
  cash,
  paypal,
  creditCard,
  eWallet,
  sabaCashWallet,
}

/// يربط طريقة الدفع بالمعرّف الخلفي واسم العرض وأيقونة التمثيل.
/// Maps payment methods to backend ids, display names, and icon keys.
extension PaymentMethodExtension on PaymentMethod {
  /// يعيد القيمة الرقمية التي يتوقعها الخادم لهذه الطريقة.
  /// Returns the numeric backend value expected for this method.
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
      case PaymentMethod.eWallet:
        return 9;
      case PaymentMethod.sabaCashWallet:
        return 10;
    }
  }

  /// يعيد الاسم العربي الظاهر للمستخدم.
  /// Returns the Arabic label shown to users.
  String get displayNameAr {
    switch (this) {
      case PaymentMethod.jwaliWallet:
        return 'محفظة جوالي';
      case PaymentMethod.cashWallet:
        return 'كاش محفظة';
      case PaymentMethod.oneCashWallet:
        return 'محفظة ون كاش';
      case PaymentMethod.floskWallet:
        return 'محفظة فلوس';
      case PaymentMethod.jaibWallet:
        return 'محفظة جيب';
      case PaymentMethod.cash:
        return 'نقداً';
      case PaymentMethod.paypal:
        return 'باي بال';
      case PaymentMethod.creditCard:
        return 'بطاقة ائتمان';
      case PaymentMethod.eWallet:
        return 'محفظة إلكترونية';
      case PaymentMethod.sabaCashWallet:
        return 'محفظة سبأ كاش';
    }
  }

  /// يعيد الاسم الإنجليزي الظاهر في السجلات أو الواجهات الثنائية.
  /// Returns the English label used in logs or bilingual UIs.
  String get displayNameEn {
    switch (this) {
      case PaymentMethod.jwaliWallet:
        return 'Jwali Wallet';
      case PaymentMethod.cashWallet:
        return 'Cash Wallet';
      case PaymentMethod.oneCashWallet:
        return 'OneCash Wallet';
      case PaymentMethod.floskWallet:
        return 'Flosk Wallet';
      case PaymentMethod.jaibWallet:
        return 'Jaib Wallet';
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.eWallet:
        return 'E-Wallet';
      case PaymentMethod.sabaCashWallet:
        return 'SabaCash Wallet';
    }
  }

  /// يعيد اسم الأيقونة أو المفتاح البصري المرتبط بطريقة الدفع.
  /// Returns the icon or visual key associated with the payment method.
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
      case PaymentMethod.eWallet:
        return 'e_wallet';
      case PaymentMethod.sabaCashWallet:
        return 'saba_cash';
    }
  }

  /// يحدد ما إذا كانت طريقة الدفع من فئة المحافظ.
  /// Indicates whether the method belongs to the wallet family.
  bool get isWallet {
    switch (this) {
      case PaymentMethod.jwaliWallet:
      case PaymentMethod.cashWallet:
      case PaymentMethod.oneCashWallet:
      case PaymentMethod.floskWallet:
      case PaymentMethod.jaibWallet:
      case PaymentMethod.eWallet:
      case PaymentMethod.sabaCashWallet:
        return true;
      default:
        return false;
    }
  }

  /// يحدد ما إذا كانت طريقة الدفع تعتمد على قناة إلكترونية.
  /// Indicates whether the method is processed online.
  bool get isOnline {
    switch (this) {
      case PaymentMethod.cash:
        return false;
      default:
        return true;
    }
  }

  /// يحول القيمة الرقمية القادمة من الخادم إلى طريقة الدفع المناسبة.
  /// Converts a backend integer into the matching payment method.
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
      case 9:
        return PaymentMethod.eWallet;
      case 10:
        return PaymentMethod.sabaCashWallet;
      default:
        return PaymentMethod.cash;
    }
  }

  /// يحول النص الحر أو المختصر إلى طريقة الدفع المطابقة.
  /// Converts a free-form or shortened string into the matching payment method.
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
      case 'ewallet':
        return PaymentMethod.eWallet;
      case 'sabacashwallet':
      case 'sabacash':
        return PaymentMethod.sabaCashWallet;
      default:
        return PaymentMethod.cash;
    }
  }
}

/// يصف الحالات النهائية أو المرحلية لعملية الدفع.
/// Describes the final or transitional states of a payment transaction.
enum PaymentStatus {
  successful,
  failed,
  pending,
  refunded,
  voided,
  partiallyRefunded,
}

/// يربط حالة الدفع بالنصوص وخصائص السلوك المطلوبة في الواجهة والخادم.
/// Maps payment status to display labels and behavioral helpers.
extension PaymentStatusExtension on PaymentStatus {
  /// يعيد المفتاح النصي الذي يستخدمه الخادم في الـ APIs.
  /// Returns the backend key used by APIs.
  String get backendKey {
    switch (this) {
      case PaymentStatus.successful:
        return 'successful';
      case PaymentStatus.failed:
        return 'failed';
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.refunded:
        return 'refunded';
      case PaymentStatus.voided:
        return 'voided';
      case PaymentStatus.partiallyRefunded:
        return 'partially_refunded';
    }
  }

  /// يعيد الاسم العربي الظاهر للمستخدم.
  /// Returns the Arabic display label for the status.
  String get displayNameAr {
    switch (this) {
      case PaymentStatus.successful:
        return 'ناجح';
      case PaymentStatus.failed:
        return 'فاشل';
      case PaymentStatus.pending:
        return 'معلق';
      case PaymentStatus.refunded:
        return 'مسترد';
      case PaymentStatus.voided:
        return 'ملغي';
      case PaymentStatus.partiallyRefunded:
        return 'مسترد جزئياً';
    }
  }

  /// يعيد الاسم الإنجليزي المقابل للحالة.
  /// Returns the matching English label for the status.
  String get displayNameEn {
    switch (this) {
      case PaymentStatus.successful:
        return 'Successful';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.refunded:
        return 'Refunded';
      case PaymentStatus.voided:
        return 'Voided';
      case PaymentStatus.partiallyRefunded:
        return 'Partially Refunded';
    }
  }

  /// يعيد كود اللون المرتبط بالحالة لعرضها بصريًا.
  /// Returns the color code used to visualize the status.
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

  /// يحدد ما إذا كانت العملية وصلت إلى حالة نجاح نهائية.
  /// Indicates whether the payment has reached a final successful state.
  bool get isComplete {
    return this == PaymentStatus.successful;
  }

  /// يحدد ما إذا كانت الحالة تسمح باسترداد المبلغ.
  /// Indicates whether the payment can still be refunded.
  bool get canRefund {
    return this == PaymentStatus.successful;
  }

  /// يحول النص القادم من الخادم أو الواجهة إلى حالة دفع معروفة.
  /// Converts a backend or UI string into a known payment status.
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
