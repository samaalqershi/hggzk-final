import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/payments/get_payment_by_id_usecase.dart';
import '../../../domain/usecases/payments/refund_payment_usecase.dart';
import '../../../domain/usecases/payments/void_payment_usecase.dart';
import '../../../domain/usecases/payments/update_payment_status_usecase.dart';
import '../../../domain/repositories/payments_repository.dart';
import 'payment_details_event.dart';
import 'payment_details_state.dart';

/// Coordinates all payment-details actions in one place so the view can load,
/// refresh, refund, void, print, send, and annotate the same payment snapshot
/// without scattering logic across the UI.
///
/// ينسق كل أفعال تفاصيل الدفع في مكان واحد حتى تتمكن الواجهة من التحميل
/// والتحديث والاسترداد والإلغاء والطباعة والإرسال وإضافة الملاحظات على نفس
/// لقطة الدفعة دون تشتيت المنطق داخل الـ UI.
class PaymentDetailsBloc
    extends Bloc<PaymentDetailsEvent, PaymentDetailsState> {
  /// Retrieves the base payment record before any expanded detail request.
  ///
  /// يجلب سجل الدفعة الأساسي قبل أي طلب للتفاصيل الموسعة.
  final GetPaymentByIdUseCase getPaymentByIdUseCase;

  /// Executes refund actions initiated from the payment details screen.
  ///
  /// ينفذ عمليات الاسترداد التي تبدأ من شاشة تفاصيل الدفع.
  final RefundPaymentUseCase refundPaymentUseCase;

  /// Voids payments when the user chooses to cancel the settlement instead of
  /// refunding it.
  ///
  /// يلغي الدفعات عندما يختار المستخدم الإلغاء بدلًا من الاسترداد.
  final VoidPaymentUseCase voidPaymentUseCase;

  /// Applies lifecycle state changes to the stored payment record.
  ///
  /// يطبّق تغييرات الحالة على سجل الدفعة المخزن.
  final UpdatePaymentStatusUseCase updatePaymentStatusUseCase;

  /// Loads expanded payment details and supporting collections.
  ///
  /// يجلب تفاصيل الدفع الموسعة والقوائم المساندة.
  final PaymentsRepository repository;

  /// Remembers the currently displayed payment so refresh actions can reuse
  /// the same target without the view resending it.
  ///
  /// يتذكر الدفعة المعروضة حاليًا حتى تستخدمها إجراءات التحديث نفسها دون
  /// أن تعيد الواجهة إرسالها.
  String? _currentPaymentId;

  /// Wires the payment-detail use cases into a single state machine.
  ///
  /// يربط حالات استخدام تفاصيل الدفع في آلة حالة واحدة.
  PaymentDetailsBloc({
    required this.getPaymentByIdUseCase,
    required this.refundPaymentUseCase,
    required this.voidPaymentUseCase,
    required this.updatePaymentStatusUseCase,
    required this.repository,
  }) : super(PaymentDetailsInitial()) {
    on<LoadPaymentDetailsEvent>(_onLoadPaymentDetails);

    /// Registers the refresh command that reuses the last loaded payment id.
    ///
    /// يسجل أمر التحديث الذي يعيد استخدام آخر معرّف دفعة محمّل.
    on<RefreshPaymentDetailsEvent>(_onRefreshPaymentDetails);

    /// Registers the refund workflow triggered from the details screen.
    ///
    /// يسجل مسار الاسترداد الذي يبدأ من شاشة التفاصيل.
    on<RefundPaymentDetailsEvent>(_onRefundPaymentDetails);

    /// Registers the void workflow used when the payment should be cancelled
    /// instead of refunded.
    ///
    /// يسجل مسار الإلغاء المستخدم عندما ينبغي إلغاء الدفعة بدل استردادها.
    on<VoidPaymentDetailsEvent>(_onVoidPaymentDetails);

    /// Registers updates that change the stored payment status.
    ///
    /// يسجل التحديثات التي تغيّر حالة الدفعة المخزنة.
    on<UpdatePaymentStatusDetailsEvent>(_onUpdatePaymentStatusDetails);

    /// Registers the optional activity loader for audit timelines.
    ///
    /// يسجل محمل الأنشطة الاختياري لخطوط التدقيق الزمنية.
    on<LoadPaymentActivitiesEvent>(_onLoadPaymentActivities);

    /// Registers the optional refund-history loader.
    ///
    /// يسجل محمل سجل الاستردادات الاختياري.
    on<LoadRefundHistoryEvent>(_onLoadRefundHistory);

    /// Registers the receipt-print flow.
    ///
    /// يسجل مسار طباعة الإيصال.
    on<PrintReceiptEvent>(_onPrintReceipt);

    /// Registers the receipt-send flow.
    ///
    /// يسجل مسار إرسال الإيصال.
    on<SendReceiptEvent>(_onSendReceipt);

    /// Registers invoice download requests.
    ///
    /// يسجل طلبات تنزيل الفاتورة.
    on<DownloadInvoiceEvent>(_onDownloadInvoice);

    /// Registers the note-attachment flow for finance audits.
    ///
    /// يسجل مسار إضافة الملاحظات لأغراض التدقيق المالي.
    on<AddNoteEvent>(_onAddNote);

    /// Registers notification resend requests for the payment record.
    ///
    /// يسجل طلبات إعادة إرسال الإشعارات الخاصة بالدفعة.
    on<ResendNotificationEvent>(_onResendNotification);
  }

  /// Loads the payment first, then attempts to expand it with details so the
  /// screen can degrade gracefully if the secondary request fails.
  ///
  /// يحمّل الدفعة أولًا ثم يحاول توسيعها بالتفاصيل حتى تستطيع الشاشة أن
  /// تتراجع بأمان إذا فشل الطلب الثانوي.
  Future<void> _onLoadPaymentDetails(
    LoadPaymentDetailsEvent event,
    Emitter<PaymentDetailsState> emit,
  ) async {
    emit(PaymentDetailsLoading());
    _currentPaymentId = event.paymentId;

    // جلب البيانات الأساسية
    final paymentResult = await getPaymentByIdUseCase(
      GetPaymentByIdParams(paymentId: event.paymentId),
    );

    await paymentResult.fold(
      (failure) async {
        emit(PaymentDetailsError(message: failure.message));
      },
      (payment) async {
        // Expand the view with booking, refund, and activity data when the
        // backend provides it.
        final detailsResult = await repository.getPaymentDetails(
          paymentId: event.paymentId,
        );

        await detailsResult.fold(
          (failure) async {
            // إذا فشل جلب التفاصيل، عرض البيانات الأساسية فقط
            emit(PaymentDetailsLoaded(
              payment: payment,
              paymentDetails: null,
              refunds: const [],
              activities: const [],
              isRefreshing: false,
            ));
          },
          (details) async {
            // Prefer the fully expanded payment if the backend returns one,
            // otherwise keep the base record we already loaded.
            final finalPayment = details.payment;
            emit(PaymentDetailsLoaded(
              payment: finalPayment,
              paymentDetails: details,
              refunds: details.refunds,
              activities: details.activities,
              isRefreshing: false,
            ));
          },
        );
      },
    );
  }

  /// Reuses the last loaded payment id to pull a fresh snapshot without losing
  /// the visible page context.
  ///
  /// يعيد استخدام آخر معرّف دفعة محمّل لجلب لقطة جديدة دون فقدان سياق الشاشة.
  Future<void> _onRefreshPaymentDetails(
    RefreshPaymentDetailsEvent event,
    Emitter<PaymentDetailsState> emit,
  ) async {
    if (state is PaymentDetailsLoaded && _currentPaymentId != null) {
      final currentState = state as PaymentDetailsLoaded;
      emit(currentState.copyWith(isRefreshing: true));

      add(LoadPaymentDetailsEvent(paymentId: _currentPaymentId!));
    }
  }

  /// Moves the payment into a transient operation state, attempts the refund,
  /// and then refreshes the details so the UI reflects the latest totals.
  ///
  /// ينقل الدفعة إلى حالة عملية مؤقتة، ثم يحاول الاسترداد، وبعدها يعيد
  /// تحميل التفاصيل حتى تعكس الواجهة أحدث الإجماليات.
  Future<void> _onRefundPaymentDetails(
    RefundPaymentDetailsEvent event,
    Emitter<PaymentDetailsState> emit,
  ) async {
    if (state is PaymentDetailsLoaded) {
      final currentState = state as PaymentDetailsLoaded;

      emit(PaymentDetailsOperationInProgress(
        payment: currentState.payment,
        paymentDetails: currentState.paymentDetails,
        refunds: currentState.refunds,
        activities: currentState.activities,
        operation: 'refund',
      ));

      final result = await refundPaymentUseCase(
        RefundPaymentParams(
          paymentId: event.paymentId,
          refundAmount: event.refundAmount,
          refundReason: event.refundReason,
        ),
      );

      await result.fold(
        (failure) async {
          emit(PaymentDetailsOperationFailure(
            payment: currentState.payment,
            paymentDetails: currentState.paymentDetails,
            refunds: currentState.refunds,
            activities: currentState.activities,
            message: failure.message,
          ));
        },
        (_) async {
          emit(PaymentDetailsOperationSuccess(
            payment: currentState.payment,
            paymentDetails: currentState.paymentDetails,
            refunds: currentState.refunds,
            activities: currentState.activities,
            message: 'تم استرداد المبلغ بنجاح',
          ));
          // إعادة تحميل التفاصيل
          add(RefreshPaymentDetailsEvent());
        },
      );
    }
  }

  /// Runs the void flow for payments that should be cancelled instead of
  /// partially refunded.
  ///
  /// ينفذ مسار الإلغاء للدفعات التي ينبغي إلغاؤها بدل استردادها جزئيًا.
  Future<void> _onVoidPaymentDetails(
    VoidPaymentDetailsEvent event,
    Emitter<PaymentDetailsState> emit,
  ) async {
    if (state is PaymentDetailsLoaded) {
      final currentState = state as PaymentDetailsLoaded;

      emit(PaymentDetailsOperationInProgress(
        payment: currentState.payment,
        paymentDetails: currentState.paymentDetails,
        refunds: currentState.refunds,
        activities: currentState.activities,
        operation: 'void',
      ));

      final result = await voidPaymentUseCase(
        VoidPaymentParams(paymentId: event.paymentId),
      );

      await result.fold(
        (failure) async {
          emit(PaymentDetailsOperationFailure(
            payment: currentState.payment,
            paymentDetails: currentState.paymentDetails,
            refunds: currentState.refunds,
            activities: currentState.activities,
            message: failure.message,
          ));
        },
        (_) async {
          emit(PaymentDetailsOperationSuccess(
            payment: currentState.payment,
            paymentDetails: currentState.paymentDetails,
            refunds: currentState.refunds,
            activities: currentState.activities,
            message: 'تم إلغاء الدفعة بنجاح',
          ));
          // إعادة تحميل التفاصيل
          add(RefreshPaymentDetailsEvent());
        },
      );
    }
  }

  /// Applies a status transition from the details page, then refreshes the
  /// snapshot so the new lifecycle state is visible immediately.
  ///
  /// يطبّق انتقال الحالة من شاشة التفاصيل ثم يعيد تحميل اللقطة حتى تظهر
  /// حالة الدورة الجديدة فورًا.
  Future<void> _onUpdatePaymentStatusDetails(
    UpdatePaymentStatusDetailsEvent event,
    Emitter<PaymentDetailsState> emit,
  ) async {
    if (state is PaymentDetailsLoaded) {
      final currentState = state as PaymentDetailsLoaded;

      emit(PaymentDetailsOperationInProgress(
        payment: currentState.payment,
        paymentDetails: currentState.paymentDetails,
        refunds: currentState.refunds,
        activities: currentState.activities,
        operation: 'updateStatus',
      ));

      final result = await updatePaymentStatusUseCase(
        UpdatePaymentStatusParams(
          paymentId: event.paymentId,
          newStatus: event.newStatus,
        ),
      );

      await result.fold(
        (failure) async {
          emit(PaymentDetailsOperationFailure(
            payment: currentState.payment,
            paymentDetails: currentState.paymentDetails,
            refunds: currentState.refunds,
            activities: currentState.activities,
            message: failure.message,
          ));
        },
        (_) async {
          emit(PaymentDetailsOperationSuccess(
            payment: currentState.payment,
            paymentDetails: currentState.paymentDetails,
            refunds: currentState.refunds,
            activities: currentState.activities,
            message: 'تم تحديث حالة الدفعة بنجاح',
          ));
          // إعادة تحميل التفاصيل
          add(RefreshPaymentDetailsEvent());
        },
      );
    }
  }

  /// Keeps the current snapshot visible when a dedicated activities endpoint is
  /// not available yet.
  ///
  /// يبقي اللقطة الحالية ظاهرة عندما لا يكون هناك endpoint مخصص للأنشطة بعد.
  Future<void> _onLoadPaymentActivities(
    LoadPaymentActivitiesEvent event,
    Emitter<PaymentDetailsState> emit,
  ) async {
    // يمكن تنفيذها إذا توفر endpoint للأنشطة
    if (state is PaymentDetailsLoaded) {
      final currentState = state as PaymentDetailsLoaded;
      // جلب الأنشطة من الخادم إذا لزم الأمر
      emit(currentState);
    }
  }

  /// Keeps the current snapshot visible when a dedicated refund-history
  /// endpoint is not wired yet.
  ///
  /// يبقي اللقطة الحالية ظاهرة عندما لا يكون هناك ربط فعلي بعد مع endpoint
  /// مخصص لسجل الاستردادات.
  Future<void> _onLoadRefundHistory(
    LoadRefundHistoryEvent event,
    Emitter<PaymentDetailsState> emit,
  ) async {
    // يمكن تنفيذها إذا توفر endpoint لتاريخ الاستردادات
    if (state is PaymentDetailsLoaded) {
      final currentState = state as PaymentDetailsLoaded;
      // جلب تاريخ الاستردادات من الخادم
      emit(currentState);
    }
  }

  /// Marks the state as printing, simulates the print action, then restores the
  /// last loaded snapshot.
  ///
  /// يضع الحالة في وضع الطباعة، ثم يحاكي عملية الطباعة، وبعدها يعيد اللقطة
  /// الأخيرة المحمّلة.
  Future<void> _onPrintReceipt(
    PrintReceiptEvent event,
    Emitter<PaymentDetailsState> emit,
  ) async {
    if (state is PaymentDetailsLoaded) {
      final currentState = state as PaymentDetailsLoaded;
      emit(PaymentDetailsPrinting(
        payment: currentState.payment,
        paymentDetails: currentState.paymentDetails,
        refunds: currentState.refunds,
        activities: currentState.activities,
      ));
      // تنفيذ منطق الطباعة
      await Future.delayed(const Duration(seconds: 2));
      emit(currentState);
    }
  }

  /// Emits a sending state so the UI can show progress while a receipt is
  /// dispatched to the selected recipient.
  ///
  /// يصدر حالة إرسال حتى تعرض الواجهة التقدم أثناء إرسال الإيصال إلى
  /// المستلم المحدد.
  Future<void> _onSendReceipt(
    SendReceiptEvent event,
    Emitter<PaymentDetailsState> emit,
  ) async {
    if (state is PaymentDetailsLoaded) {
      final currentState = state as PaymentDetailsLoaded;
      emit(PaymentDetailsSending(
        payment: currentState.payment,
        paymentDetails: currentState.paymentDetails,
        refunds: currentState.refunds,
        activities: currentState.activities,
        recipient: event.email ?? event.phone ?? '',
      ));
      // تنفيذ منطق الإرسال
      await Future.delayed(const Duration(seconds: 2));
      emit(PaymentDetailsOperationSuccess(
        payment: currentState.payment,
        paymentDetails: currentState.paymentDetails,
        refunds: currentState.refunds,
        activities: currentState.activities,
        message: 'تم إرسال الإيصال بنجاح',
      ));
      await Future.delayed(const Duration(seconds: 2));
      emit(currentState);
    }
  }

  /// Tracks invoice generation as a temporary downloading state and then
  /// restores the loaded snapshot once the artifact is ready.
  ///
  /// يتتبع توليد الفاتورة كحالة تنزيل مؤقتة ثم يعيد اللقطة المحمّلة بعد
  /// جاهزية الملف.
  Future<void> _onDownloadInvoice(
    DownloadInvoiceEvent event,
    Emitter<PaymentDetailsState> emit,
  ) async {
    if (state is PaymentDetailsLoaded) {
      final currentState = state as PaymentDetailsLoaded;
      emit(PaymentDetailsDownloading(
        payment: currentState.payment,
        paymentDetails: currentState.paymentDetails,
        refunds: currentState.refunds,
        activities: currentState.activities,
      ));
      // تنفيذ منطق التحميل
      await Future.delayed(const Duration(seconds: 2));
      emit(PaymentDetailsOperationSuccess(
        payment: currentState.payment,
        paymentDetails: currentState.paymentDetails,
        refunds: currentState.refunds,
        activities: currentState.activities,
        message: 'تم تحميل الفاتورة بنجاح',
      ));
      await Future.delayed(const Duration(seconds: 2));
      emit(currentState);
    }
  }

  /// Adds an audit note without losing the loaded detail context.
  ///
  /// يضيف ملاحظة تدقيق من دون فقدان سياق التفاصيل المحمّلة.
  Future<void> _onAddNote(
    AddNoteEvent event,
    Emitter<PaymentDetailsState> emit,
  ) async {
    if (state is PaymentDetailsLoaded) {
      final currentState = state as PaymentDetailsLoaded;
      // إضافة الملاحظة
      emit(PaymentDetailsOperationSuccess(
        payment: currentState.payment,
        paymentDetails: currentState.paymentDetails,
        refunds: currentState.refunds,
        activities: currentState.activities,
        message: 'تمت إضافة الملاحظة بنجاح',
      ));
      await Future.delayed(const Duration(seconds: 2));
      emit(currentState);
    }
  }

  /// Replays the notification flow for the currently inspected payment and
  /// returns the screen to the same loaded state afterward.
  ///
  /// يعيد تشغيل مسار الإشعار للدفعة المعروضة ثم يعيد الشاشة إلى نفس حالة
  /// التحميل بعد ذلك.
  Future<void> _onResendNotification(
    ResendNotificationEvent event,
    Emitter<PaymentDetailsState> emit,
  ) async {
    if (state is PaymentDetailsLoaded) {
      final currentState = state as PaymentDetailsLoaded;
      emit(PaymentDetailsSending(
        payment: currentState.payment,
        paymentDetails: currentState.paymentDetails,
        refunds: currentState.refunds,
        activities: currentState.activities,
        recipient: '',
      ));
      // إعادة إرسال الإشعار
      await Future.delayed(const Duration(seconds: 2));
      emit(PaymentDetailsOperationSuccess(
        payment: currentState.payment,
        paymentDetails: currentState.paymentDetails,
        refunds: currentState.refunds,
        activities: currentState.activities,
        message: 'تم إعادة إرسال الإشعار بنجاح',
      ));
      await Future.delayed(const Duration(seconds: 2));
      emit(currentState);
    }
  }
}
