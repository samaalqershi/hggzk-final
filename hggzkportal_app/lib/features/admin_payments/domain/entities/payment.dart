import 'package:equatable/equatable.dart';
import '../../../../../core/enums/payment_method_enum.dart';

/// Represents a payment record together with its booking linkage, refund
/// eligibility, and void metadata.
///
/// يمثل سجل الدفع مع ارتباطه بالحجز وقابلية الاسترداد وبيانات الإلغاء.
class Payment extends Equatable {
  /// Stable payment identifier used by admin and audit screens.
  ///
  /// المعرّف الثابت للدفع المستخدم في الإدارة والتدقيق.
  final String id;

  /// Booking that owns this payment.
  ///
  /// الحجز الذي تنتمي إليه هذه الدفعة.
  final String bookingId;

  /// Monetary amount captured for the booking.
  ///
  /// المبلغ المالي المحصل للحجز.
  final Money amount;

  /// External gateway or backend transaction reference.
  ///
  /// مرجع المعاملة الخارجي الصادر من بوابة الدفع أو الخادم.
  final String transactionId;

  /// Method used to process the payment.
  ///
  /// الطريقة المستخدمة لمعالجة الدفعة.
  final PaymentMethod method;

  /// Current lifecycle state of the payment.
  ///
  /// الحالة الحالية لدورة حياة الدفع.
  final PaymentStatus status;

  /// Timestamp when the payment was recorded.
  ///
  /// وقت تسجيل الدفعة.
  final DateTime paymentDate;

  /// Optional user linked to the payment.
  ///
  /// المستخدم المرتبط بالدفع إن وُجد.
  final String? userId;

  /// Optional display name for the payer.
  ///
  /// اسم العرض للدافع إن وُجد.
  final String? userName;

  /// Optional email address used for receipts.
  ///
  /// البريد الإلكتروني الاختياري المستخدم للإيصالات.
  final String? userEmail;

  /// Optional unit associated with the booking.
  ///
  /// الوحدة المرتبطة بالحجز إن وُجدت.
  final String? unitId;

  /// Optional unit display name.
  ///
  /// اسم العرض للوحدة اختياريًا.
  final String? unitName;

  /// Optional property associated with the payment.
  ///
  /// العقار المرتبط بالدفع إن وُجد.
  final String? propertyId;

  /// Optional property display name.
  ///
  /// اسم العرض للعقار اختياريًا.
  final String? propertyName;

  /// Human-readable description or purpose of the payment.
  ///
  /// وصف بشري أو سبب الدفع.
  final String? description;

  /// Internal notes attached to the transaction.
  ///
  /// ملاحظات داخلية مرتبطة بالمعاملة.
  final String? notes;

  /// Optional receipt or proof-of-payment URL.
  ///
  /// رابط الإيصال أو إثبات الدفع إن توفر.
  final String? receiptUrl;

  /// Optional invoice number issued for the payment.
  ///
  /// رقم الفاتورة الاختياري الصادر مع الدفعة.
  final String? invoiceNumber;

  /// Free-form metadata returned by the gateway or backend.
  ///
  /// بيانات وصفية حرة يعيدها الخادم أو بوابة الدفع.
  final Map<String, dynamic>? metadata;

  /// Indicates whether a refund can still be requested.
  ///
  /// يوضح ما إذا كان يمكن طلب استرداد للدفع.
  final bool? isRefundable;

  /// Cutoff time after which refunds are no longer allowed.
  ///
  /// وقت الإغلاق الذي بعده لا يسمح بالاسترداد.
  final DateTime? refundDeadline;

  /// Amount already refunded from the original payment.
  ///
  /// المبلغ الذي استُرد بالفعل من الدفعة الأصلية.
  final double? refundedAmount;

  /// Timestamp of the most recent refund action.
  ///
  /// وقت آخر عملية استرداد.
  final DateTime? refundedAt;

  /// Human-readable reason provided for the refund.
  ///
  /// السبب المقروء بشريًا الذي صاحب الاسترداد.
  final String? refundReason;

  /// Reference of the refund transaction if one was created.
  ///
  /// مرجع معاملة الاسترداد إن تم إنشاؤه.
  final String? refundTransactionId;

  /// Indicates whether the payment has been voided.
  ///
  /// يوضح ما إذا كانت الدفعة قد أُلغيت.
  final bool? isVoided;

  /// Timestamp of the void action.
  ///
  /// وقت تنفيذ الإلغاء.
  final DateTime? voidedAt;

  /// Reason recorded when the payment was voided.
  ///
  /// السبب المسجل عند إلغاء الدفعة.
  final String? voidReason;

  /// Creates the immutable payment aggregate used by finance workflows and
  /// audit views.
  ///
  /// ينشئ مجمع الدفع غير القابل للتعديل المستخدم في تدفقات المالية
  /// وشاشات التدقيق.
  const Payment({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.transactionId,
    required this.method,
    required this.status,
    required this.paymentDate,
    this.userId,
    this.userName,
    this.userEmail,
    this.unitId,
    this.unitName,
    this.propertyId,
    this.propertyName,
    this.description,
    this.notes,
    this.receiptUrl,
    this.invoiceNumber,
    this.metadata,
    this.isRefundable,
    this.refundDeadline,
    this.refundedAmount,
    this.refundedAt,
    this.refundReason,
    this.refundTransactionId,
    this.isVoided,
    this.voidedAt,
    this.voidReason,
  });

  /// Indicates whether the payment still qualifies for a refund.
  ///
  /// يحدد ما إذا كانت الدفعة لا تزال مؤهلة للاسترداد.
  bool get canRefund {
    if (status != PaymentStatus.successful) return false;
    if (isVoided == true) return false;
    if (refundedAmount != null && refundedAmount! >= amount.amount)
      return false;
    if (refundDeadline != null && DateTime.now().isAfter(refundDeadline!))
      return false;
    return isRefundable ?? true;
  }

  /// Indicates whether the payment can still be voided instead of refunded.
  ///
  /// يحدد ما إذا كان يمكن إلغاء الدفعة بدلًا من استردادها.
  bool get canVoid {
    if (status != PaymentStatus.pending) return false;
    if (isVoided == true) return false;
    return true;
  }

  ///
  /// يعيد المبلغ المتبقي المتاح للاسترداد.
  double get remainingRefundableAmount {
    if (!canRefund) return 0;
    return amount.amount - (refundedAmount ?? 0);
  }

  /// Returns a copy with selected payment fields replaced.
  ///
  /// يعيد نسخة مع استبدال الحقول المختارة فقط.
  Payment copyWith({
    String? id,
    String? bookingId,
    Money? amount,
    String? transactionId,
    PaymentMethod? method,
    PaymentStatus? status,
    DateTime? paymentDate,
    String? userId,
    String? userName,
    String? userEmail,
    String? unitId,
    String? unitName,
    String? propertyId,
    String? propertyName,
    String? description,
    String? notes,
    String? receiptUrl,
    String? invoiceNumber,
    Map<String, dynamic>? metadata,
    bool? isRefundable,
    DateTime? refundDeadline,
    double? refundedAmount,
    DateTime? refundedAt,
    String? refundReason,
    String? refundTransactionId,
    bool? isVoided,
    DateTime? voidedAt,
    String? voidReason,
  }) {
    return Payment(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      amount: amount ?? this.amount,
      transactionId: transactionId ?? this.transactionId,
      method: method ?? this.method,
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      unitId: unitId ?? this.unitId,
      unitName: unitName ?? this.unitName,
      propertyId: propertyId ?? this.propertyId,
      propertyName: propertyName ?? this.propertyName,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      metadata: metadata ?? this.metadata,
      isRefundable: isRefundable ?? this.isRefundable,
      refundDeadline: refundDeadline ?? this.refundDeadline,
      refundedAmount: refundedAmount ?? this.refundedAmount,
      refundedAt: refundedAt ?? this.refundedAt,
      refundReason: refundReason ?? this.refundReason,
      refundTransactionId: refundTransactionId ?? this.refundTransactionId,
      isVoided: isVoided ?? this.isVoided,
      voidedAt: voidedAt ?? this.voidedAt,
      voidReason: voidReason ?? this.voidReason,
    );
  }

  /// Keeps equality aligned with the full payment record.
  ///
  /// يربط المقارنة بسجل الدفع الكامل.
  @override
  List<Object?> get props => [
        id,
        bookingId,
        amount,
        transactionId,
        method,
        status,
        paymentDate,
        userId,
        userName,
        userEmail,
        unitId,
        unitName,
        propertyId,
        propertyName,
        description,
        notes,
        receiptUrl,
        invoiceNumber,
        metadata,
        isRefundable,
        refundDeadline,
        refundedAmount,
        refundedAt,
        refundReason,
        refundTransactionId,
        isVoided,
        voidedAt,
        voidReason,
      ];
}

/// Captures a monetary amount together with its currency and formatted text.
///
/// يحتفظ بالمبلغ مع العملة والنص المنسق الجاهز للعرض.
class Money extends Equatable {
  /// Numeric value used in calculations.
  ///
  /// القيمة الرقمية المستخدمة في الحسابات.
  final double amount;

  /// Currency code associated with the amount.
  ///
  /// رمز العملة المرتبط بالمبلغ.
  final String currency;

  /// Preformatted display string for the amount.
  ///
  /// النص المنسق مسبقًا لعرض المبلغ.
  final String formattedAmount;

  /// Creates the immutable monetary snapshot used across payment flows.
  ///
  /// ينشئ لقطة مالية غير قابلة للتعديل مستخدمة عبر تدفقات الدفع.
  const Money({
    required this.amount,
    required this.currency,
    required this.formattedAmount,
  });

  /// Returns a copy with selectively replaced monetary fields.
  ///
  /// يعيد نسخة مع استبدال الحقول المالية المحددة فقط.
  Money copyWith({
    double? amount,
    String? currency,
    String? formattedAmount,
  }) {
    return Money(
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      formattedAmount: formattedAmount ?? this.formattedAmount,
    );
  }

  /// Adds two amounts that use the same currency.
  ///
  /// يجمع مبلغين يستخدمان العملة نفسها.
  Money operator +(Money other) {
    if (currency != other.currency) {
      throw Exception('Cannot add amounts with different currencies');
    }
    final newAmount = amount + other.amount;
    return Money(
      amount: newAmount,
      currency: currency,
      formattedAmount: _formatAmount(newAmount, currency),
    );
  }

  /// Subtracts another amount that uses the same currency.
  ///
  /// يطرح مبلغًا آخر يستخدم العملة نفسها.
  Money operator -(Money other) {
    if (currency != other.currency) {
      throw Exception('Cannot subtract amounts with different currencies');
    }
    final newAmount = amount - other.amount;
    return Money(
      amount: newAmount,
      currency: currency,
      formattedAmount: _formatAmount(newAmount, currency),
    );
  }

  /// Scales the amount by a numeric multiplier.
  ///
  /// يضرب المبلغ في معامل عددي.
  Money operator *(double multiplier) {
    final newAmount = amount * multiplier;
    return Money(
      amount: newAmount,
      currency: currency,
      formattedAmount: _formatAmount(newAmount, currency),
    );
  }

  /// Formats the amount for display using the currency code.
  ///
  /// ينسق المبلغ للعرض باستخدام رمز العملة.
  String _formatAmount(double amount, String currency) {
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  /// Keeps equality aligned with the rendered monetary value.
  ///
  /// يربط المقارنة بالقيمة المالية المعروضة.
  @override
  List<Object> get props => [amount, currency, formattedAmount];
}
