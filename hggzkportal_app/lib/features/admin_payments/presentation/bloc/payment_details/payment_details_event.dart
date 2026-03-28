import 'package:equatable/equatable.dart';
import '../../../../../../core/enums/payment_method_enum.dart';
import '../../../domain/entities/payment.dart';

/// Base event for all payment-details actions.
///
/// الحدث الأساسي لكل عمليات تفاصيل الدفع، ويضمن أن جميع الأوامر المرتبطة
/// بالدفعة تمر عبر قناة BLoC واحدة واضحة.
abstract class PaymentDetailsEvent extends Equatable {
  /// Shared constructor for strongly typed payment-detail events.
  ///
  /// مُنشئ مشترك لأحداث تفاصيل الدفع المقيّدة بالنوع.
  const PaymentDetailsEvent();

  /// Subclasses supply the values that define event equality.
  ///
  /// الفئات الفرعية تحدد القيم التي تعتمد عليها مساواة الحدث.
  @override
  List<Object?> get props => [];
}

/// Requests the full payment snapshot for the given identifier.
///
/// يطلب اللقطة الكاملة للدفعة اعتمادًا على المعرّف المرسل.
class LoadPaymentDetailsEvent extends PaymentDetailsEvent {
  /// Identifier used to fetch the payment details from the backend.
  ///
  /// المعرّف المستخدم لجلب تفاصيل الدفعة من الخادم.
  final String paymentId;

  /// Creates the load request for one payment record.
  ///
  /// ينشئ طلب تحميل لسجل دفعة واحد.
  const LoadPaymentDetailsEvent({required this.paymentId});

  /// Equality depends on the target payment only.
  ///
  /// تعتمد المساواة على الدفعة المستهدفة فقط.
  @override
  List<Object> get props => [paymentId];
}

/// Forces a reload of the current payment snapshot.
///
/// يجبر إعادة تحميل لقطة الدفعة الحالية.
class RefreshPaymentDetailsEvent extends PaymentDetailsEvent {
  /// Triggers a refresh without changing the selected payment.
  ///
  /// يطلق تحديثًا جديدًا دون تغيير الدفعة المحددة.
  const RefreshPaymentDetailsEvent();
}

/// Starts a refund flow for a specific payment and amount.
///
/// يبدأ مسار الاسترداد لدفعة محددة وبمبلغ محدد.
class RefundPaymentDetailsEvent extends PaymentDetailsEvent {
  /// Payment that should be refunded.
  ///
  /// الدفعة المطلوب استردادها.
  final String paymentId;

  /// Exact amount that the operator wants to return.
  ///
  /// المبلغ المحدد الذي يراد استرداده.
  final Money refundAmount;

  /// Operator-provided reason shown in audit and support records.
  ///
  /// سبب الاسترداد الذي يُحفظ في سجلات التدقيق والدعم.
  final String refundReason;

  /// Packages all data needed to request a refund from the payment details
  /// screen.
  ///
  /// يجمع كل البيانات اللازمة لطلب الاسترداد من شاشة تفاصيل الدفع.
  const RefundPaymentDetailsEvent({
    required this.paymentId,
    required this.refundAmount,
    required this.refundReason,
  });

  /// Equality includes the target payment, refund amount, and reason.
  ///
  /// تعتمد المساواة على الدفعة المستهدفة والمبلغ وسبب الاسترداد.
  @override
  List<Object> get props => [paymentId, refundAmount, refundReason];
}

/// Requests that the payment be voided before it is treated as a completed
/// settlement.
///
/// يطلب إلغاء الدفعة قبل اعتبارها تسوية مالية مكتملة.
class VoidPaymentDetailsEvent extends PaymentDetailsEvent {
  /// Payment identifier targeted by the void action.
  ///
  /// معرّف الدفعة المستهدف بعملية الإلغاء.
  final String paymentId;

  /// Creates the command used to void one payment record.
  ///
  /// ينشئ الأمر المستخدم لإلغاء سجل دفعة واحد.
  const VoidPaymentDetailsEvent({required this.paymentId});

  /// Equality depends only on the payment identifier.
  ///
  /// تعتمد المساواة فقط على معرّف الدفعة.
  @override
  List<Object> get props => [paymentId];
}

/// Updates the stored lifecycle state of the payment.
///
/// يحدّث الحالة المخزنة لدورة حياة الدفعة.
class UpdatePaymentStatusDetailsEvent extends PaymentDetailsEvent {
  /// Payment whose status should change.
  ///
  /// الدفعة التي ستتغير حالتها.
  final String paymentId;

  /// New payment status selected by the operator.
  ///
  /// الحالة الجديدة التي يختارها المستخدم.
  final PaymentStatus newStatus;

  /// Creates the event used to apply a backend status change.
  ///
  /// ينشئ الحدث المستخدم لتطبيق تغيير الحالة في الخادم.
  const UpdatePaymentStatusDetailsEvent({
    required this.paymentId,
    required this.newStatus,
  });

  /// Equality includes the payment identifier and the requested status.
  ///
  /// تعتمد المساواة على معرّف الدفعة والحالة المطلوبة.
  @override
  List<Object> get props => [paymentId, newStatus];
}

/// Loads the activity timeline for the specified payment.
///
/// يحمّل خط الأنشطة الزمني للدفعة المحددة.
class LoadPaymentActivitiesEvent extends PaymentDetailsEvent {
  /// Payment whose history should be fetched.
  ///
  /// الدفعة المطلوب جلب سجلها.
  final String paymentId;

  /// Creates the request for payment activity history.
  ///
  /// ينشئ طلب سجل أنشطة الدفعة.
  const LoadPaymentActivitiesEvent({required this.paymentId});

  /// Equality depends on the payment only.
  ///
  /// تعتمد المساواة على الدفعة فقط.
  @override
  List<Object> get props => [paymentId];
}

/// Loads the refund history tied to one payment.
///
/// يحمّل سجل الاستردادات المرتبط بدفعة واحدة.
class LoadRefundHistoryEvent extends PaymentDetailsEvent {
  /// Payment whose refund history is requested.
  ///
  /// الدفعة المطلوب سجل استرداداتها.
  final String paymentId;

  /// Creates the request used to populate refund-related views.
  ///
  /// ينشئ الطلب المستخدم لتغذية شاشات الاسترداد.
  const LoadRefundHistoryEvent({required this.paymentId});

  /// Equality depends on the payment identifier only.
  ///
  /// تعتمد المساواة على معرّف الدفعة فقط.
  @override
  List<Object> get props => [paymentId];
}

/// Opens the receipt printing flow for a payment.
///
/// يفتح مسار طباعة الإيصال الخاص بالدفعة.
class PrintReceiptEvent extends PaymentDetailsEvent {
  /// Payment whose receipt should be printed.
  ///
  /// الدفعة التي سيُطبع إيصالها.
  final String paymentId;

  /// Creates the print command for one payment receipt.
  ///
  /// ينشئ أمر الطباعة لإيصال دفعة واحدة.
  const PrintReceiptEvent({required this.paymentId});

  /// Equality depends on the payment identifier only.
  ///
  /// تعتمد المساواة على معرّف الدفعة فقط.
  @override
  List<Object> get props => [paymentId];
}

/// Sends the receipt to one or more delivery destinations.
///
/// يرسل الإيصال إلى وجهة واحدة أو أكثر.
class SendReceiptEvent extends PaymentDetailsEvent {
  /// Payment whose receipt will be sent.
  ///
  /// الدفعة التي سيُرسل إيصالها.
  final String paymentId;

  /// Optional recipient email if the receipt should be sent by email.
  ///
  /// بريد المستلم الاختياري إذا كان الإرسال بالبريد الإلكتروني.
  final String? email;

  /// Optional phone number for SMS or WhatsApp delivery.
  ///
  /// رقم الهاتف الاختياري للإرسال عبر SMS أو WhatsApp.
  final String? phone;

  /// Creates the payload used to dispatch a receipt through the chosen
  /// channel.
  ///
  /// ينشئ الحمولة المستخدمة لإرسال الإيصال عبر القناة المختارة.
  const SendReceiptEvent({
    required this.paymentId,
    this.email,
    this.phone,
  });

  /// Equality includes the delivery targets as well as the payment id.
  ///
  /// تعتمد المساواة على المعرّف ووسائل الإرسال.
  @override
  List<Object?> get props => [paymentId, email, phone];
}

/// Requests a downloadable invoice artifact for the payment.
///
/// يطلب ملف فاتورة قابلًا للتنزيل للدفعة.
class DownloadInvoiceEvent extends PaymentDetailsEvent {
  /// Payment that should produce the invoice.
  ///
  /// الدفعة التي ستولّد الفاتورة.
  final String paymentId;

  /// Creates the request used by invoice download actions.
  ///
  /// ينشئ الطلب المستخدم لإجراء تنزيل الفاتورة.
  const DownloadInvoiceEvent({required this.paymentId});

  /// Equality depends only on the target payment.
  ///
  /// تعتمد المساواة على الدفعة المستهدفة فقط.
  @override
  List<Object> get props => [paymentId];
}

/// Attaches an internal note to the payment record.
///
/// يضيف ملاحظة داخلية إلى سجل الدفعة.
class AddNoteEvent extends PaymentDetailsEvent {
  /// Payment that receives the note.
  ///
  /// الدفعة التي ستستقبل الملاحظة.
  final String paymentId;

  /// Text entered by the operator for audit or context.
  ///
  /// النص الذي يدخله المستخدم للتدقيق أو التوضيح.
  final String note;

  /// Creates the command used to append a note to the payment trail.
  ///
  /// ينشئ الأمر المستخدم لإضافة ملاحظة إلى سجل الدفعة.
  const AddNoteEvent({
    required this.paymentId,
    required this.note,
  });

  /// Equality depends on both the payment and the note body.
  ///
  /// تعتمد المساواة على الدفعة ونص الملاحظة.
  @override
  List<Object> get props => [paymentId, note];
}

/// Resends a payment-related notification to the original target.
///
/// يعيد إرسال إشعار مرتبط بالدفعة إلى الوجهة الأصلية.
class ResendNotificationEvent extends PaymentDetailsEvent {
  /// Payment tied to the notification that should be resent.
  ///
  /// الدفعة المرتبطة بالإشعار المطلوب إعادة إرساله.
  final String paymentId;

  /// Creates the resend command for one payment notification.
  ///
  /// ينشئ أمر إعادة الإرسال لإشعار دفعة واحدة.
  const ResendNotificationEvent({required this.paymentId});

  /// Equality depends on the payment identifier only.
  ///
  /// تعتمد المساواة على معرّف الدفعة فقط.
  @override
  List<Object> get props => [paymentId];
}
