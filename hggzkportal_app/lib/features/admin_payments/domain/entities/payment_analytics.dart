import 'package:hggzkportal/core/enums/payment_method_enum.dart';
import 'package:equatable/equatable.dart';
import 'payment.dart';

/// Aggregates all payment analytics needed by the admin dashboards, including
/// totals, time-series trends, and breakdowns by method and status.
///
/// يجمع كل تحليلات الدفع المطلوبة للوحـات الإدارة، بما فيها الإجماليات
/// والاتجاهات الزمنية والتقسيمات حسب الطريقة والحالة.
class PaymentAnalytics extends Equatable {
  /// Overall summary metrics shown at the top of the dashboard.
  ///
  /// مؤشرات الملخص العامة الظاهرة أعلى اللوحة.
  final PaymentSummary summary;

  /// Time-series data used to draw payment trend charts.
  ///
  /// بيانات زمنية تُستخدم لرسم مخططات اتجاهات الدفع.
  final List<PaymentTrend> trends;

  /// Breakdowns grouped by payment method.
  ///
  /// التقسيمات بحسب طريقة الدفع.
  final Map<PaymentMethod, MethodAnalytics> methodAnalytics;

  /// Breakdowns grouped by payment status.
  ///
  /// التقسيمات بحسب حالة الدفع.
  final Map<PaymentStatus, StatusAnalytics> statusAnalytics;

  /// Summary of refund activity.
  ///
  /// ملخص نشاط الاسترداد.
  final RefundAnalytics refundAnalytics;

  /// Beginning of the reporting window.
  ///
  /// بداية نافذة التقرير.
  final DateTime startDate;

  /// End of the reporting window.
  ///
  /// نهاية نافذة التقرير.
  final DateTime endDate;

  /// Creates the complete analytics snapshot consumed by dashboard pages.
  ///
  /// ينشئ لقطة التحليلات الكاملة المستخدمة في صفحات اللوحة.
  const PaymentAnalytics({
    required this.summary,
    required this.trends,
    required this.methodAnalytics,
    required this.statusAnalytics,
    required this.refundAnalytics,
    required this.startDate,
    required this.endDate,
  });

  /// Keeps equality aligned with the analytics snapshot.
  ///
  /// يربط المقارنة بلقطة التحليلات.
  @override
  List<Object> get props => [
        summary,
        trends,
        methodAnalytics,
        statusAnalytics,
        refundAnalytics,
        startDate,
        endDate,
      ];
}

/// Holds the top-line financial metrics that appear in the summary cards.
///
/// يحتفظ بالمؤشرات المالية العليا التي تظهر في بطاقات الملخص.
class PaymentSummary extends Equatable {
  /// Total number of payment records in the reporting window.
  ///
  /// إجمالي عدد سجلات الدفع ضمن نافذة التقرير.
  final int totalTransactions;

  /// Gross revenue captured during the period.
  ///
  /// إجمالي الإيرادات المحصلة خلال الفترة.
  final Money totalAmount;

  /// Average value per payment transaction.
  ///
  /// متوسط قيمة معاملة الدفع.
  final Money averageTransactionValue;

  /// Percentage of transactions that succeeded.
  ///
  /// نسبة المعاملات الناجحة.
  final double successRate;

  /// Count of successful transactions.
  ///
  /// عدد المعاملات الناجحة.
  final int successfulTransactions;

  /// Count of failed transactions.
  ///
  /// عدد المعاملات الفاشلة.
  final int failedTransactions;

  /// Count of transactions still pending.
  ///
  /// عدد المعاملات المعلقة.
  final int pendingTransactions;

  /// Total refunded amount across the period.
  ///
  /// إجمالي المبلغ المسترد خلال الفترة.
  final Money totalRefunded;

  /// Number of completed refund actions.
  ///
  /// عدد عمليات الاسترداد المكتملة.
  final int refundCount;

  /// Creates the summary block used by the payment dashboard.
  ///
  /// ينشئ كتلة الملخص المستخدمة في لوحة الدفع.
  const PaymentSummary({
    required this.totalTransactions,
    required this.totalAmount,
    required this.averageTransactionValue,
    required this.successRate,
    required this.successfulTransactions,
    required this.failedTransactions,
    required this.pendingTransactions,
    required this.totalRefunded,
    required this.refundCount,
  });

  /// Keeps equality aligned with the summary metrics.
  ///
  /// يربط المقارنة بمؤشرات الملخص.
  @override
  List<Object> get props => [
        totalTransactions,
        totalAmount,
        averageTransactionValue,
        successRate,
        successfulTransactions,
        failedTransactions,
        pendingTransactions,
        totalRefunded,
        refundCount,
      ];
}

/// Represents one time bucket in the payment trend chart.
///
/// يمثل فترة زمنية واحدة في مخطط اتجاه المدفوعات.
class PaymentTrend extends Equatable {
  /// Start date of the bucket.
  ///
  /// تاريخ بدء الفترة.
  final DateTime date;

  /// Number of transactions during the bucket.
  ///
  /// عدد المعاملات خلال الفترة.
  final int transactionCount;

  /// Total amount for the bucket.
  ///
  /// إجمالي المبلغ داخل الفترة.
  final Money totalAmount;

  /// Success percentage for the bucket.
  ///
  /// نسبة النجاح خلال الفترة.
  final double successRate;

  /// Count breakdown by payment method.
  ///
  /// تفصيل العدد حسب طريقة الدفع.
  final Map<PaymentMethod, int> methodBreakdown;

  /// Creates a single time-series point for analytics charts.
  ///
  /// ينشئ نقطة زمنية واحدة لرسوم التحليلات.
  const PaymentTrend({
    required this.date,
    required this.transactionCount,
    required this.totalAmount,
    required this.successRate,
    required this.methodBreakdown,
  });

  /// Keeps equality aligned with the trend bucket.
  ///
  /// يربط المقارنة بوعاء الاتجاه الزمني.
  @override
  List<Object> get props => [
        date,
        transactionCount,
        totalAmount,
        successRate,
        methodBreakdown,
      ];
}

/// Summarizes usage of a specific payment method.
///
/// يلخص استخدام طريقة دفع محددة.
class MethodAnalytics extends Equatable {
  /// Payment method represented by this block.
  ///
  /// طريقة الدفع الممثلة في هذه الكتلة.
  final PaymentMethod method;

  /// Number of transactions for the method.
  ///
  /// عدد المعاملات لهذه الطريقة.
  final int transactionCount;

  /// Total amount processed with the method.
  ///
  /// إجمالي المبلغ المعالج بهذه الطريقة.
  final Money totalAmount;

  /// Share of all transactions represented by the method.
  ///
  /// النسبة من إجمالي المعاملات التي تمثلها الطريقة.
  final double percentage;

  /// Success rate for this method.
  ///
  /// معدل النجاح لهذه الطريقة.
  final double successRate;

  /// Average amount processed per transaction.
  ///
  /// متوسط المبلغ لكل معاملة.
  final Money averageAmount;

  /// Creates the breakdown used by method-specific analytics widgets.
  ///
  /// ينشئ التقسيم المستخدم في عناصر التحليلات الخاصة بالطريقة.
  const MethodAnalytics({
    required this.method,
    required this.transactionCount,
    required this.totalAmount,
    required this.percentage,
    required this.successRate,
    required this.averageAmount,
  });

  /// Keeps equality aligned with the method analytics block.
  ///
  /// يربط المقارنة بكتلة تحليلات الطريقة.
  @override
  List<Object> get props => [
        method,
        transactionCount,
        totalAmount,
        percentage,
        successRate,
        averageAmount,
      ];
}

/// Summarizes transactions grouped by payment status.
///
/// يلخص المعاملات المجمعة حسب حالة الدفع.
class StatusAnalytics extends Equatable {
  /// Payment status represented by this block.
  ///
  /// حالة الدفع الممثلة في هذه الكتلة.
  final PaymentStatus status;

  /// Number of transactions in this status bucket.
  ///
  /// عدد المعاملات داخل فئة الحالة هذه.
  final int count;

  /// Total amount represented by the bucket.
  ///
  /// إجمالي المبلغ الذي تمثله الفئة.
  final Money totalAmount;

  /// Share of all transactions in the reporting window.
  ///
  /// النسبة من إجمالي المعاملات ضمن نافذة التقرير.
  final double percentage;

  /// Creates the status breakdown used by charts and cards.
  ///
  /// ينشئ التقسيم حسب الحالة المستخدم في الرسوم والبطاقات.
  const StatusAnalytics({
    required this.status,
    required this.count,
    required this.totalAmount,
    required this.percentage,
  });

  /// Keeps equality aligned with the status analytics block.
  ///
  /// يربط المقارنة بكتلة تحليلات الحالة.
  @override
  List<Object> get props => [status, count, totalAmount, percentage];
}

/// Summarizes refund activity for the reporting window.
///
/// يلخص نشاط الاسترداد خلال نافذة التقرير.
class RefundAnalytics extends Equatable {
  /// Total number of refunds processed.
  ///
  /// إجمالي عدد الاستردادات المعالجة.
  final int totalRefunds;

  /// Total amount refunded across all refund events.
  ///
  /// إجمالي المبلغ المسترد عبر جميع عمليات الاسترداد.
  final Money totalRefundedAmount;

  /// Refund count as a percentage of all payments.
  ///
  /// نسبة الاستردادات من إجمالي المدفوعات.
  final double refundRate;

  /// Average time needed to complete a refund.
  ///
  /// متوسط الوقت اللازم لإكمال الاسترداد.
  final double averageRefundTime;

  /// Count grouped by refund reason.
  ///
  /// عدد الاستردادات مجمعة بحسب السبب.
  final Map<String, int> refundReasons;

  /// Time-series points for refund charts.
  ///
  /// نقاط زمنية لرسوم الاسترداد.
  final List<RefundTrend> trends;

  /// Creates the refund analytics block used by finance dashboards.
  ///
  /// ينشئ كتلة تحليلات الاسترداد المستخدمة في لوحات المالية.
  const RefundAnalytics({
    required this.totalRefunds,
    required this.totalRefundedAmount,
    required this.refundRate,
    required this.averageRefundTime,
    required this.refundReasons,
    required this.trends,
  });

  /// Keeps equality aligned with the refund analytics block.
  ///
  /// يربط المقارنة بكتلة تحليلات الاسترداد.
  @override
  List<Object> get props => [
        totalRefunds,
        totalRefundedAmount,
        refundRate,
        averageRefundTime,
        refundReasons,
        trends,
      ];
}

/// Represents one point in the refund trend chart.
///
/// يمثل نقطة واحدة في مخطط اتجاه الاسترداد.
class RefundTrend extends Equatable {
  /// Start date of the refund bucket.
  ///
  /// تاريخ بدء فترة الاسترداد.
  final DateTime date;

  /// Number of refunds in the bucket.
  ///
  /// عدد الاستردادات داخل الفترة.
  final int refundCount;

  /// Refunded amount for the bucket.
  ///
  /// المبلغ المسترد داخل الفترة.
  final Money refundedAmount;

  /// Creates a single chart point for refund analytics.
  ///
  /// ينشئ نقطة واحدة لرسوم تحليلات الاسترداد.
  const RefundTrend({
    required this.date,
    required this.refundCount,
    required this.refundedAmount,
  });

  /// Keeps equality aligned with the trend point.
  ///
  /// يربط المقارنة بالنقطة الزمنية.
  @override
  List<Object> get props => [date, refundCount, refundedAmount];
}
