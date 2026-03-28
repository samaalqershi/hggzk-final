import 'package:equatable/equatable.dart';
import '../../../domain/entities/payment.dart';
import '../../../domain/entities/payment_details.dart';
import '../../../domain/entities/refund.dart';

/// Base state for the payment-details flow.
///
/// حالة الأساس لسير تفاصيل الدفعة. كل الحالات الفرعية ترث هذا الكائن حتى
/// يبقى الانتقال بين التحميل والنجاح والفشل والعمليات الجارية موحدًا داخل
/// الـ BLoC.
abstract class PaymentDetailsState extends Equatable {
  /// Protected constructor for typed payment-details states.
  ///
  /// مُنشئ محمي لحالات تفاصيل الدفع المقيّدة بالنوع.
  const PaymentDetailsState();

  /// States are value objects, so equality is driven by subclasses through
  /// their `props`.
  ///
  /// الحالات هنا كائنات قيمة، لذلك تعتمد المساواة على `props` التي تحددها
  /// الفئات الفرعية.
  @override
  List<Object?> get props => [];
}

/// Emitted before the screen has requested any payment information.
///
/// تُستخدم قبل أن يطلب العرض أي بيانات للدفعة، حتى تميّز الواجهة بين
/// "لم يبدأ الطلب بعد" و"البيانات ما زالت تُحمّل".
class PaymentDetailsInitial extends PaymentDetailsState {}

/// Represents the first network fetch for payment details.
///
/// تمثل الطلب الأول لجلب تفاصيل الدفعة من الخادم.
class PaymentDetailsLoading extends PaymentDetailsState {}

/// Holds the complete payment snapshot once the portal has fetched it.
///
/// تحتفظ بلقطة الدفعة الكاملة بعد أن يجلبها النظام من الخادم، بما في ذلك
/// تفاصيلها الموسعة، وقوائم الاسترداد، وسجل الأنشطة، وحالة التحديث.
class PaymentDetailsLoaded extends PaymentDetailsState {
  /// The canonical payment record shown at the top of the details view.
  ///
  /// سجل الدفعة الأساسي الذي يُعرض في أعلى الشاشة.
  final Payment payment;

  /// Expanded payment metadata returned by the backend when the screen needs
  /// booking context, audit data, or richer relational information.
  ///
  /// بيانات الدفع الموسعة القادمة من الخادم عندما تحتاج الشاشة إلى سياق
  /// إضافي مثل بيانات الحجز أو التدقيق.
  final PaymentDetails? paymentDetails;

  /// Refund entries already attached to this payment.
  ///
  /// سجلات الاسترداد المرتبطة بهذه الدفعة.
  final List<Refund> refunds;

  /// Chronological payment activities used by the audit timeline.
  ///
  /// الأنشطة الزمنية المرتبطة بالدفعة والتي تُستخدم في خط التدقيق الزمني.
  final List<PaymentActivity> activities;

  /// Tells the UI whether a background refresh is currently in flight.
  ///
  /// يوضح للواجهة أن هناك تحديثًا خلفيًا جارٍ الآن.
  final bool isRefreshing;

  /// Creates a fully populated loaded state once all visible payment data is
  /// available.
  ///
  /// ينشئ حالة التحميل المكتمل بعد توفر كل البيانات الظاهرة للمستخدم.
  const PaymentDetailsLoaded({
    required this.payment,
    this.paymentDetails,
    required this.refunds,
    required this.activities,
    this.isRefreshing = false,
  });

  /// Produces a refreshed snapshot while leaving unspecified fields untouched.
  ///
  /// ينتج لقطة محدثة مع الإبقاء على الحقول غير الممررة كما هي.
  PaymentDetailsLoaded copyWith({
    Payment? payment,
    PaymentDetails? paymentDetails,
    List<Refund>? refunds,
    List<PaymentActivity>? activities,
    bool? isRefreshing,
  }) {
    return PaymentDetailsLoaded(
      payment: payment ?? this.payment,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      refunds: refunds ?? this.refunds,
      activities: activities ?? this.activities,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  /// Sums completed refunds using the payment currency so the UI can show how
  /// much has already been returned to the customer.
  ///
  /// يجمع الاستردادات المكتملة وفق عملة الدفعة حتى تعرض الواجهة مقدار ما
  /// عاد إلى العميل بالفعل.
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

  /// Computes the remaining amount after subtracting completed refunds.
  ///
  /// يحسب المبلغ المتبقي بعد طرح الاستردادات المكتملة.
  Money get remainingAmount {
    return payment.amount - totalRefunded;
  }

  /// Loaded-state equality depends on the payment snapshot, related collections,
  /// and the refresh flag.
  ///
  /// تعتمد مساواة حالة التحميل على الدفعة نفسها والقوائم المرتبطة بها وعلم
  /// التحديث.
  @override
  List<Object?> get props => [
        payment,
        paymentDetails,
        refunds,
        activities,
        isRefreshing,
      ];
}

/// Represents a failure to load or mutate payment details.
///
/// تمثل تعذر جلب تفاصيل الدفعة أو فشل إحدى العمليات المرتبطة بها.
class PaymentDetailsError extends PaymentDetailsState {
  /// Human-readable error message that should be shown or logged.
  ///
  /// رسالة الخطأ التي يمكن عرضها أو تسجيلها.
  final String message;

  /// Creates the error state with the message returned by the failure source.
  ///
  /// ينشئ حالة الخطأ مع الرسالة التي جاءت من مصدر الفشل.
  const PaymentDetailsError({required this.message});

  /// Equality only depends on the error message.
  ///
  /// تعتمد المساواة فقط على رسالة الخطأ.
  @override
  List<Object> get props => [message];
}

/// Indicates that a payment action is running while the base snapshot remains
/// on screen.
///
/// تشير إلى أن عملية على الدفعة قيد التنفيذ مع بقاء اللقطة الأساسية ظاهرة
/// في الشاشة.
class PaymentDetailsOperationInProgress extends PaymentDetailsState {
  /// The payment being acted on.
  ///
  /// الدفعة التي تجري عليها العملية.
  final Payment payment;

  /// Expanded context kept alive while the operation is running.
  ///
  /// السياق الموسع الذي يبقى حاضرًا أثناء تنفيذ العملية.
  final PaymentDetails? paymentDetails;

  /// Existing refunds that should remain visible during the action.
  ///
  /// الاستردادات الحالية التي يجب أن تظل مرئية أثناء العملية.
  final List<Refund> refunds;

  /// Existing activities that should remain visible during the action.
  ///
  /// الأنشطة الحالية التي يجب أن تظل ظاهرة أثناء العملية.
  final List<PaymentActivity> activities;

  /// Describes the action currently executing, such as refund, void, or send.
  ///
  /// يصف العملية الجارية مثل الاسترداد أو الإلغاء أو الإرسال.
  final String operation;

  /// Builds a transient state that lets the UI show progress without dropping
  /// the already loaded payment data.
  ///
  /// يبني حالة مؤقتة تسمح للواجهة بعرض التقدم دون فقدان بيانات الدفعة
  /// المحمّلة مسبقًا.
  const PaymentDetailsOperationInProgress({
    required this.payment,
    this.paymentDetails,
    required this.refunds,
    required this.activities,
    required this.operation,
  });

  /// Equality depends on the current payment snapshot plus the active operation
  /// label.
  ///
  /// تعتمد المساواة على اللقطة الحالية للدفعة واسم العملية النشطة.
  @override
  List<Object?> get props => [
        payment,
        paymentDetails,
        refunds,
        activities,
        operation,
      ];
}

/// Emitted when a payment action completes successfully and the screen should
/// reflect the new state.
///
/// تُستخدم عندما تنجح عملية على الدفعة وتحتاج الشاشة إلى عكس الحالة الجديدة.
class PaymentDetailsOperationSuccess extends PaymentDetailsState {
  /// Updated payment snapshot after the operation completes.
  ///
  /// اللقطة المحدثة للدفعة بعد اكتمال العملية.
  final Payment payment;

  /// Expanded details after the operation.
  ///
  /// التفاصيل الموسعة بعد العملية.
  final PaymentDetails? paymentDetails;

  /// Refunds after the operation has been applied.
  ///
  /// الاستردادات بعد تطبيق العملية.
  final List<Refund> refunds;

  /// Activity timeline after the action succeeds.
  ///
  /// خط الأنشطة الزمني بعد نجاح الإجراء.
  final List<PaymentActivity> activities;

  /// Confirmation text that can be shown in a snackbar or dialog.
  ///
  /// نص التأكيد الذي يمكن عرضه في snackbar أو dialog.
  final String message;

  /// Creates a success state that keeps the updated payment data together with
  /// a user-facing confirmation message.
  ///
  /// ينشئ حالة نجاح تحتفظ ببيانات الدفعة المحدثة مع رسالة تأكيد مناسبة
  /// للمستخدم.
  const PaymentDetailsOperationSuccess({
    required this.payment,
    this.paymentDetails,
    required this.refunds,
    required this.activities,
    required this.message,
  });

  /// Equality includes the refreshed payment snapshot, collections, and the
  /// success message.
  ///
  /// تشمل المساواة اللقطة المحدّثة والقوائم ورسالة النجاح.
  @override
  List<Object?> get props => [
        payment,
        paymentDetails,
        refunds,
        activities,
        message,
      ];
}

/// Emitted when an operation against the payment details fails after the user
/// has already initiated it.
///
/// تُستخدم عندما تفشل عملية على تفاصيل الدفعة بعد أن بدأها المستخدم بالفعل.
class PaymentDetailsOperationFailure extends PaymentDetailsState {
  /// Payment snapshot that was being modified.
  ///
  /// لقطة الدفعة التي كانت قيد التعديل.
  final Payment payment;

  /// Expanded context kept with the failure so the UI can still render the
  /// last known snapshot.
  ///
  /// السياق الموسع الذي يبقى مع الفشل حتى تتمكن الواجهة من عرض آخر لقطة
  /// معروفة.
  final PaymentDetails? paymentDetails;

  /// Refund history that was already loaded before the failure occurred.
  ///
  /// سجل الاستردادات الذي كان محمّلًا قبل حدوث الفشل.
  final List<Refund> refunds;

  /// Activity timeline that should remain available in the error view.
  ///
  /// خط الأنشطة الزمني الذي يجب أن يبقى متاحًا في شاشة الخطأ.
  final List<PaymentActivity> activities;

  /// Failure message suitable for the toast, dialog, or error banner.
  ///
  /// رسالة الفشل المناسبة للعرض في toast أو dialog أو شريط خطأ.
  final String message;

  /// Creates the failure state while preserving the payment snapshot that was
  /// active when the action failed.
  ///
  /// ينشئ حالة الفشل مع الإبقاء على لقطة الدفعة التي كانت فعالة لحظة تعثر
  /// العملية.
  const PaymentDetailsOperationFailure({
    required this.payment,
    this.paymentDetails,
    required this.refunds,
    required this.activities,
    required this.message,
  });

  /// Equality follows the same visible data that the UI should react to.
  ///
  /// تعتمد المساواة على نفس البيانات المرئية التي يجب أن تتفاعل معها الواجهة.
  @override
  List<Object?> get props => [
        payment,
        paymentDetails,
        refunds,
        activities,
        message,
      ];
}

/// Indicates that the app is currently preparing a printable receipt.
///
/// تشير إلى أن التطبيق يجهّز إيصالًا قابلًا للطباعة الآن.
class PaymentDetailsPrinting extends PaymentDetailsState {
  /// Payment whose receipt is being prepared.
  ///
  /// الدفعة التي يجري تجهيز إيصالها.
  final Payment payment;

  /// Expanded context kept visible while the print job is prepared.
  ///
  /// السياق الموسع الذي يبقى ظاهرًا أثناء إعداد مهمة الطباعة.
  final PaymentDetails? paymentDetails;

  /// Loaded refunds that remain visible during the print flow.
  ///
  /// الاستردادات المحمّلة التي تبقى ظاهرة أثناء مسار الطباعة.
  final List<Refund> refunds;

  /// Loaded activities that remain visible during the print flow.
  ///
  /// الأنشطة المحمّلة التي تبقى ظاهرة أثناء مسار الطباعة.
  final List<PaymentActivity> activities;

  /// Creates a transient printing state without discarding already loaded
  /// payment data.
  ///
  /// ينشئ حالة طباعة مؤقتة دون فقدان بيانات الدفعة المحمّلة مسبقًا.
  const PaymentDetailsPrinting({
    required this.payment,
    this.paymentDetails,
    required this.refunds,
    required this.activities,
  });

  /// Equality depends on the visible payment snapshot only.
  ///
  /// تعتمد المساواة على لقطة الدفعة الظاهرة فقط.
  @override
  List<Object?> get props => [payment, paymentDetails, refunds, activities];
}

/// Indicates that a receipt or payment message is being sent.
///
/// تشير إلى أن إيصالًا أو رسالة مرتبطة بالدفع قيد الإرسال الآن.
class PaymentDetailsSending extends PaymentDetailsState {
  /// Payment whose receipt or notification is being sent.
  ///
  /// الدفعة التي يجري إرسال إيصالها أو إشعارها.
  final Payment payment;

  /// Expanded context kept during the send operation.
  ///
  /// السياق الموسع الذي يبقى أثناء عملية الإرسال.
  final PaymentDetails? paymentDetails;

  /// Loaded refunds available while the send request is running.
  ///
  /// الاستردادات المحمّلة المتاحة أثناء تنفيذ الإرسال.
  final List<Refund> refunds;

  /// Loaded activities available while the send request is running.
  ///
  /// الأنشطة المحمّلة المتاحة أثناء تنفيذ الإرسال.
  final List<PaymentActivity> activities;

  /// Destination that should receive the receipt or message.
  ///
  /// الجهة التي يجب أن تستقبل الإيصال أو الرسالة.
  final String recipient;

  /// Creates a transient sending state while the delivery request is in
  /// progress.
  ///
  /// ينشئ حالة إرسال مؤقتة أثناء تنفيذ طلب التسليم.
  const PaymentDetailsSending({
    required this.payment,
    this.paymentDetails,
    required this.refunds,
    required this.activities,
    required this.recipient,
  });

  /// Equality includes the recipient because delivery target changes the UI
  /// meaning of the state.
  ///
  /// تتضمن المساواة المستلم لأن تغييره يغير معنى الحالة في الواجهة.
  @override
  List<Object?> get props => [
        payment,
        paymentDetails,
        refunds,
        activities,
        recipient,
      ];
}

/// Indicates that a downloadable invoice artifact is being prepared.
///
/// تشير إلى أن هناك ملف فاتورة قابلًا للتنزيل قيد التجهيز.
class PaymentDetailsDownloading extends PaymentDetailsState {
  /// Payment whose invoice is being prepared for download.
  ///
  /// الدفعة التي يُجهّز ملف فاتورتها للتنزيل.
  final Payment payment;

  /// Expanded context preserved while the invoice is generated.
  ///
  /// السياق الموسع المحفوظ أثناء توليد الفاتورة.
  final PaymentDetails? paymentDetails;

  /// Refund history kept visible during the download flow.
  ///
  /// سجل الاستردادات الذي يبقى ظاهرًا أثناء مسار التنزيل.
  final List<Refund> refunds;

  /// Activity history kept visible during the download flow.
  ///
  /// سجل الأنشطة الذي يبقى ظاهرًا أثناء مسار التنزيل.
  final List<PaymentActivity> activities;

  /// Creates a temporary download state while the invoice artifact is being
  /// generated.
  ///
  /// ينشئ حالة تنزيل مؤقتة أثناء توليد ملف الفاتورة.
  const PaymentDetailsDownloading({
    required this.payment,
    this.paymentDetails,
    required this.refunds,
    required this.activities,
  });

  /// Equality depends on the payment and the supporting collections.
  ///
  /// تعتمد المساواة على الدفعة والقوائم المساندة.
  @override
  List<Object?> get props => [payment, paymentDetails, refunds, activities];
}
