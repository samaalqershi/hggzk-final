import 'package:equatable/equatable.dart';
import 'payment.dart';

/// Represents a refund request or completed reversal linked to a payment.
///
/// يمثل طلب استرداد أو عملية عكس مرتبطة بدفعة.
class Refund extends Equatable {
  /// Stable refund identifier.
  ///
  /// المعرّف الثابت للاسترداد.
  final String id;

  /// Payment that this refund belongs to.
  ///
  /// الدفعة التي ينتمي إليها هذا الاسترداد.
  final String paymentId;

  /// Refund amount expressed in the original payment currency.
  ///
  /// مبلغ الاسترداد بالعملة الأصلية للدفع.
  final Money amount;

  /// Human-readable reason submitted for the refund.
  ///
  /// السبب المقروء بشريًا المقدم للاسترداد.
  final String reason;

  /// Current lifecycle state of the refund request.
  ///
  /// الحالة الحالية لدورة حياة طلب الاسترداد.
  final RefundStatus status;

  /// Timestamp when the refund was requested.
  ///
  /// وقت طلب الاسترداد.
  final DateTime requestedAt;

  /// Timestamp when the refund was processed, if it has been completed.
  ///
  /// وقت معالجة الاسترداد إن كانت العملية قد اكتملت.
  final DateTime? processedAt;

  /// Processor or gateway reference for the refund transaction.
  ///
  /// مرجع معاملة الاسترداد لدى المعالج أو البوابة.
  final String? transactionId;

  /// User or system actor that handled the refund.
  ///
  /// المستخدم أو النظام الذي عالج الاسترداد.
  final String? processedBy;

  /// Optional free-form notes attached to the refund.
  ///
  /// ملاحظات حرة اختيارية مرفقة بالاسترداد.
  final String? notes;

  /// Refund category such as full, partial, or dispute.
  ///
  /// فئة الاسترداد مثل الكامل أو الجزئي أو النزاع.
  final RefundType? type;

  /// Additional gateway or backend data preserved for audit purposes.
  ///
  /// بيانات إضافية من البوابة أو الخادم محفوظة لأغراض التدقيق.
  final Map<String, dynamic>? metadata;

  /// Creates the immutable refund record used by payment recovery workflows.
  ///
  /// ينشئ سجل الاسترداد غير القابل للتعديل المستخدم في تدفقات استرجاع الدفع.
  const Refund({
    required this.id,
    required this.paymentId,
    required this.amount,
    required this.reason,
    required this.status,
    required this.requestedAt,
    this.processedAt,
    this.transactionId,
    this.processedBy,
    this.notes,
    this.type,
    this.metadata,
  });

  /// Indicates whether the refund has reached the completed state.
  ///
  /// يحدد ما إذا كان الاسترداد قد وصل إلى الحالة المكتملة.
  bool get isCompleted => status == RefundStatus.completed;

  /// Indicates whether the refund request can still be cancelled.
  ///
  /// يحدد ما إذا كان يمكن إلغاء طلب الاسترداد بعد.
  bool get canCancel => status == RefundStatus.pending;

  /// Returns a copy with selected refund fields replaced.
  ///
  /// يعيد نسخة مع استبدال الحقول المختارة فقط.
  Refund copyWith({
    String? id,
    String? paymentId,
    Money? amount,
    String? reason,
    RefundStatus? status,
    DateTime? requestedAt,
    DateTime? processedAt,
    String? transactionId,
    String? processedBy,
    String? notes,
    RefundType? type,
    Map<String, dynamic>? metadata,
  }) {
    return Refund(
      id: id ?? this.id,
      paymentId: paymentId ?? this.paymentId,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      processedAt: processedAt ?? this.processedAt,
      transactionId: transactionId ?? this.transactionId,
      processedBy: processedBy ?? this.processedBy,
      notes: notes ?? this.notes,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Keeps equality aligned with the refund lifecycle record.
  ///
  /// يربط المقارنة بسجل الاسترداد كاملًا.
  @override
  List<Object?> get props => [
        id,
        paymentId,
        amount,
        reason,
        status,
        requestedAt,
        processedAt,
        transactionId,
        processedBy,
        notes,
        type,
        metadata,
      ];
}

/// Lifecycle states that a refund can move through.
///
/// الحالات التي يمكن أن يمر بها الاسترداد.
enum RefundStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
}

/// Business categories used to classify refund intent.
///
/// الفئات التجارية المستخدمة لتصنيف سبب الاسترداد.
enum RefundType {
  full,
  partial,
  cancellation,
  dispute,
  other,
}

/// Human-readable labels for refund status values.
///
/// تسميات مقروءة بشريًا لقيم حالة الاسترداد.
extension RefundStatusExtension on RefundStatus {
  ///
  /// يعيد التسمية العربية للحالة.
  String get displayNameAr {
    switch (this) {
      case RefundStatus.pending:
        return 'معلق';
      case RefundStatus.processing:
        return 'قيد المعالجة';
      case RefundStatus.completed:
        return 'مكتمل';
      case RefundStatus.failed:
        return 'فاشل';
      case RefundStatus.cancelled:
        return 'ملغي';
    }
  }

  ///
  /// يعيد التسمية الإنجليزية للحالة.
  String get displayNameEn {
    switch (this) {
      case RefundStatus.pending:
        return 'Pending';
      case RefundStatus.processing:
        return 'Processing';
      case RefundStatus.completed:
        return 'Completed';
      case RefundStatus.failed:
        return 'Failed';
      case RefundStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Human-readable labels for refund type values.
///
/// تسميات مقروءة بشريًا لأنواع الاسترداد.
extension RefundTypeExtension on RefundType {
  ///
  /// يعيد التسمية العربية لنوع الاسترداد.
  String get displayNameAr {
    switch (this) {
      case RefundType.full:
        return 'استرداد كامل';
      case RefundType.partial:
        return 'استرداد جزئي';
      case RefundType.cancellation:
        return 'إلغاء';
      case RefundType.dispute:
        return 'نزاع';
      case RefundType.other:
        return 'أخرى';
    }
  }

  ///
  /// يعيد التسمية الإنجليزية لنوع الاسترداد.
  String get displayNameEn {
    switch (this) {
      case RefundType.full:
        return 'Full Refund';
      case RefundType.partial:
        return 'Partial Refund';
      case RefundType.cancellation:
        return 'Cancellation';
      case RefundType.dispute:
        return 'Dispute';
      case RefundType.other:
        return 'Other';
    }
  }
}
