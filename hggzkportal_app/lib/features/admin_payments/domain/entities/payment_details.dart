import 'package:equatable/equatable.dart';
import 'payment.dart';
import 'refund.dart';

/// Combines a payment with its refund history, activity timeline, and booking
/// context so the portal can render a single finance detail view.
///
/// يجمع الدفعة مع سجل الاستردادات والتسلسل الزمني وسياق الحجز حتى تعرض
/// البوابة شاشة تفاصيل مالية واحدة.
class PaymentDetails extends Equatable {
  /// Primary payment record being inspected.
  ///
  /// سجل الدفع الأساسي الذي تتم مراجعته.
  final Payment payment;

  /// Refund records associated with the payment.
  ///
  /// سجلات الاسترداد المرتبطة بالدفع.
  final List<Refund> refunds;

  /// Timeline events for the payment lifecycle.
  ///
  /// أحداث التسلسل الزمني لدورة حياة الدفع.
  final List<PaymentActivity> activities;

  /// Lightweight booking context shown beside the payment.
  ///
  /// سياق الحجز المختصر المعروض بجانب الدفع.
  final BookingInfo? bookingInfo;

  /// Customer identity and contact snapshot.
  ///
  /// لقطة هوية العميل وبيانات الاتصال.
  final CustomerInfo? customerInfo;

  /// Metadata returned by the payment gateway.
  ///
  /// البيانات الوصفية المعادة من بوابة الدفع.
  final PaymentGatewayInfo? gatewayInfo;

  /// Any extra data the backend attaches for diagnostics or extensions.
  ///
  /// أي بيانات إضافية يرفقها الخادم لأغراض تشخيصية أو توسعية.
  final Map<String, dynamic>? additionalData;

  /// Creates the full payment snapshot used by the finance detail page.
  ///
  /// ينشئ لقطة الدفع الكاملة المستخدمة في صفحة التفاصيل المالية.
  const PaymentDetails({
    required this.payment,
    required this.refunds,
    required this.activities,
    this.bookingInfo,
    this.customerInfo,
    this.gatewayInfo,
    this.additionalData,
  });

  /// Sums completed refunds so the portal can show how much has been returned.
  ///
  /// يجمع الاستردادات المكتملة حتى تعرض البوابة ما تم إرجاعه بالفعل.
  Money get totalRefunded {
    if (refunds.isEmpty) {
      return Money(
        amount: 0,
        currency: payment.amount.currency,
        formattedAmount: '${payment.amount.currency} 0.00',
      );
    }

    final total = refunds
        .where((r) => r.status == RefundStatus.completed)
        .fold(0.0, (sum, refund) => sum + refund.amount.amount);

    return Money(
      amount: total,
      currency: payment.amount.currency,
      formattedAmount: '${payment.amount.currency} ${total.toStringAsFixed(2)}',
    );
  }

  ///
  /// يعيد المبلغ المتبقي بعد خصم الاستردادات المكتملة.
  Money get netAmount {
    return payment.amount - totalRefunded;
  }

  /// Indicates whether refunds have fully covered the original payment.
  ///
  /// يحدد ما إذا كانت الاستردادات قد غطت الدفعة الأصلية بالكامل.
  bool get isFullyRefunded {
    return totalRefunded.amount >= payment.amount.amount;
  }

  /// Indicates whether only part of the payment has been refunded so far.
  ///
  /// يحدد ما إذا كان جزء فقط من الدفعة قد استُرد.
  bool get isPartiallyRefunded {
    return totalRefunded.amount > 0 &&
        totalRefunded.amount < payment.amount.amount;
  }

  /// Keeps equality aligned with the full payment detail snapshot.
  ///
  /// يربط المقارنة بلقطة تفاصيل الدفع الكاملة.
  @override
  List<Object?> get props => [
        payment,
        refunds,
        activities,
        bookingInfo,
        customerInfo,
        gatewayInfo,
        additionalData,
      ];
}

/// Describes a payment lifecycle event such as capture, refund, or void.
///
/// يصف حدثًا من دورة حياة الدفع مثل التحصيل أو الاسترداد أو الإلغاء.
class PaymentActivity extends Equatable {
  /// Stable activity identifier.
  ///
  /// المعرّف الثابت للنشاط.
  final String id;

  /// Action label for the event.
  ///
  /// تسمية الإجراء الخاص بالحدث.
  final String action;

  /// Human-readable explanation of the event.
  ///
  /// شرح بشري للحدث.
  final String description;

  /// Timestamp when the event occurred.
  ///
  /// وقت وقوع الحدث.
  final DateTime timestamp;

  /// Optional user who triggered the action.
  ///
  /// المستخدم الذي قد يكون قد سبب الإجراء.
  final String? userId;

  /// Optional display name for the actor.
  ///
  /// اسم العرض للمستخدم المرتبط بالنشاط.
  final String? userName;

  /// Additional metadata captured with the event.
  ///
  /// بيانات وصفية إضافية مرتبطة بالحدث.
  final Map<String, dynamic>? data;

  /// Creates one immutable payment timeline entry.
  ///
  /// ينشئ سجلًا زمنيًا غير قابل للتعديل للدفع.
  const PaymentActivity({
    required this.id,
    required this.action,
    required this.description,
    required this.timestamp,
    this.userId,
    this.userName,
    this.data,
  });

  /// Keeps equality aligned with the activity payload.
  ///
  /// يربط المقارنة بحمولة النشاط.
  @override
  List<Object?> get props => [
        id,
        action,
        description,
        timestamp,
        userId,
        userName,
        data,
      ];
}

/// Summarizes the booking linked to the payment for display in finance views.
///
/// يلخص الحجز المرتبط بالدفع للعرض داخل الشاشات المالية.
class BookingInfo extends Equatable {
  /// Booking identifier.
  ///
  /// معرّف الحجز.
  final String bookingId;

  /// Human-readable booking reference.
  ///
  /// مرجع الحجز المقروء بشريًا.
  final String bookingReference;

  /// Planned arrival date.
  ///
  /// تاريخ الوصول المخطط.
  final DateTime checkIn;

  /// Planned departure date.
  ///
  /// تاريخ المغادرة المخطط.
  final DateTime checkOut;

  /// Name of the booked unit.
  ///
  /// اسم الوحدة المحجوزة.
  final String unitName;

  /// Name of the property that owns the booking.
  ///
  /// اسم العقار الذي يملك الحجز.
  final String propertyName;

  /// Number of guests in the booking.
  ///
  /// عدد الضيوف في الحجز.
  final int guestsCount;

  /// Creates the compact booking context shown in payment details.
  ///
  /// ينشئ سياق الحجز المختصر المعروض في تفاصيل الدفع.
  const BookingInfo({
    required this.bookingId,
    required this.bookingReference,
    required this.checkIn,
    required this.checkOut,
    required this.unitName,
    required this.propertyName,
    required this.guestsCount,
  });

  /// Keeps equality aligned with the booking summary.
  ///
  /// يربط المقارنة بملخص الحجز.
  @override
  List<Object> get props => [
        bookingId,
        bookingReference,
        checkIn,
        checkOut,
        unitName,
        propertyName,
        guestsCount,
      ];
}

/// Holds the customer identity and contact snapshot associated with a payment.
///
/// يحتفظ بلقطة هوية العميل وبيانات الاتصال المرتبطة بالدفع.
class CustomerInfo extends Equatable {
  /// Customer identifier.
  ///
  /// معرّف العميل.
  final String customerId;

  /// Customer display name.
  ///
  /// اسم عرض العميل.
  final String name;

  /// Customer email address.
  ///
  /// البريد الإلكتروني للعميل.
  final String email;

  /// Optional contact phone number.
  ///
  /// رقم الهاتف الاختياري للاتصال.
  final String? phone;

  /// Optional customer address.
  ///
  /// عنوان العميل الاختياري.
  final String? address;

  /// Optional nationality captured during booking or payment.
  ///
  /// الجنسية الاختيارية الملتقطة أثناء الحجز أو الدفع.
  final String? nationality;

  /// Free-form additional customer metadata.
  ///
  /// بيانات وصفية إضافية حرة خاصة بالعميل.
  final Map<String, dynamic>? additionalInfo;

  /// Creates the customer snapshot shown in payment details.
  ///
  /// ينشئ لقطة العميل المعروضة في تفاصيل الدفع.
  const CustomerInfo({
    required this.customerId,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.nationality,
    this.additionalInfo,
  });

  /// Keeps equality aligned with the customer snapshot.
  ///
  /// يربط المقارنة بلقطة العميل.
  @override
  List<Object?> get props => [
        customerId,
        name,
        email,
        phone,
        address,
        nationality,
        additionalInfo,
      ];
}

/// Captures gateway metadata returned with a payment, including the provider
/// reference and raw response payload when present.
///
/// يحتفظ ببيانات البوابة المرتبطة بالدفع، بما في ذلك مرجع المزود والرد الخام
/// عند توفره.
class PaymentGatewayInfo extends Equatable {
  /// Gateway provider name.
  ///
  /// اسم مزود بوابة الدفع.
  final String gatewayName;

  /// Gateway transaction reference.
  ///
  /// مرجع معاملة البوابة.
  final String gatewayTransactionId;

  /// Authorization code returned by the gateway.
  ///
  /// رمز التفويض المعاد من البوابة.
  final String? authorizationCode;

  /// Response code returned by the gateway.
  ///
  /// رمز الاستجابة المعاد من البوابة.
  final String? responseCode;

  /// Human-readable message returned by the gateway.
  ///
  /// رسالة مقروءة بشريًا معادة من البوابة.
  final String? responseMessage;

  /// Raw provider response preserved for troubleshooting.
  ///
  /// الرد الخام للمزود محفوظ لأغراض التشخيص.
  final Map<String, dynamic>? rawResponse;

  /// Creates the payment gateway snapshot consumed by finance screens.
  ///
  /// ينشئ لقطة بوابة الدفع المستخدمة في الشاشات المالية.
  const PaymentGatewayInfo({
    required this.gatewayName,
    required this.gatewayTransactionId,
    this.authorizationCode,
    this.responseCode,
    this.responseMessage,
    this.rawResponse,
  });

  /// Keeps equality aligned with the gateway payload.
  ///
  /// يربط المقارنة بحمولة البوابة.
  @override
  List<Object?> get props => [
        gatewayName,
        gatewayTransactionId,
        authorizationCode,
        responseCode,
        responseMessage,
        rawResponse,
      ];
}
