import 'package:equatable/equatable.dart';
import '../../../domain/entities/payment_analytics.dart';
import 'payment_analytics_event.dart';

abstract class PaymentAnalyticsState extends Equatable {
  /// العربية: ينشئ مثيلًا جديدًا من `PaymentAnalyticsState`.
  const PaymentAnalyticsState();
  @override
  List<Object?> get props => [];
}

/// 🎬 الحالة الابتدائية
class PaymentAnalyticsInitial extends PaymentAnalyticsState {}

/// ⏳ حالة التحميل
class PaymentAnalyticsLoading extends PaymentAnalyticsState {}

/// ✅ حالة نجاح التحميل
class PaymentAnalyticsLoaded extends PaymentAnalyticsState {
  /// العربية: يخزن القيمة `analytics`.
  final PaymentAnalytics analytics;
  final List<PaymentTrend> trends;
  final RefundAnalytics? refundStatistics;
  final Map<String, dynamic>? revenueReport;
  final DateTime startDate;
  final DateTime endDate;
  final String? propertyId;
  final AnalyticsPeriod currentPeriod;
  final ChartType chartType;
  final List<String> selectedMetrics;
  final bool isLoadingReport;
  final bool isLoadingTrends;
  final bool isLoadingRefundStats;
  const PaymentAnalyticsLoaded({
    required this.analytics,
    required this.trends,
    this.refundStatistics,
    this.revenueReport,
    required this.startDate,
    required this.endDate,
    this.propertyId,
    required this.currentPeriod,
    required this.chartType,
    required this.selectedMetrics,
    this.isLoadingReport = false,
    this.isLoadingTrends = false,
    this.isLoadingRefundStats = false,
  });
  PaymentAnalyticsLoaded copyWith({
    PaymentAnalytics? analytics,
    List<PaymentTrend>? trends,
    RefundAnalytics? refundStatistics,
    Map<String, dynamic>? revenueReport,
    DateTime? startDate,
    DateTime? endDate,
    String? propertyId,
    AnalyticsPeriod? currentPeriod,
    ChartType? chartType,
    List<String>? selectedMetrics,
    bool? isLoadingReport,
    bool? isLoadingTrends,
    bool? isLoadingRefundStats,
  }) {
    return PaymentAnalyticsLoaded(
      analytics: analytics ?? this.analytics,
      trends: trends ?? this.trends,
      refundStatistics: refundStatistics ?? this.refundStatistics,
      revenueReport: revenueReport ?? this.revenueReport,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      propertyId: propertyId ?? this.propertyId,
      currentPeriod: currentPeriod ?? this.currentPeriod,
      chartType: chartType ?? this.chartType,
      selectedMetrics: selectedMetrics ?? this.selectedMetrics,
      isLoadingReport: isLoadingReport ?? this.isLoadingReport,
      isLoadingTrends: isLoadingTrends ?? this.isLoadingTrends,
      isLoadingRefundStats: isLoadingRefundStats ?? this.isLoadingRefundStats,
    );
  }

  /// حساب مؤشرات الأداء الرئيسية
  Map<String, dynamic> get kpis {
    return {
      'totalTransactions': analytics.summary.totalTransactions,
      'totalRevenue': analytics.summary.totalAmount.amount,
      'averageTransactionValue':
          analytics.summary.averageTransactionValue.amount,
      'successRate': analytics.summary.successRate,
      'successfulTransactions': analytics.summary.successfulTransactions,
      'failedTransactions': analytics.summary.failedTransactions,
      'pendingTransactions': analytics.summary.pendingTransactions,
      'totalRefunded': analytics.summary.totalRefunded.amount,
      'refundCount': analytics.summary.refundCount,
      'refundRate': refundStatistics?.refundRate ?? 0,
    };
  }

  /// حساب معدل النمو
  double get growthRate {
    if (trends.length < 2) return 0;

    final firstPeriod = trends.first;
    final lastPeriod = trends.last;

    if (firstPeriod.totalAmount.amount == 0) return 100;

    return ((lastPeriod.totalAmount.amount - firstPeriod.totalAmount.amount) /
            firstPeriod.totalAmount.amount) *
        100;
  }

  @override
  List<Object?> get props => [
        analytics,
        trends,
        refundStatistics,
        revenueReport,
        startDate,
        endDate,
        propertyId,
        currentPeriod,
        chartType,
        selectedMetrics,
        isLoadingReport,
        isLoadingTrends,
        isLoadingRefundStats,
      ];
}

/// ❌ حالة الخطأ
class PaymentAnalyticsError extends PaymentAnalyticsState {
  /// العربية: يخزن القيمة `message`.
  final String message;
  const PaymentAnalyticsError({required this.message});
  @override
  List<Object> get props => [message];
}

/// 📤 حالة التصدير
class PaymentAnalyticsExporting extends PaymentAnalyticsState {
  /// العربية: يخزن القيمة `analytics`.
  final PaymentAnalytics analytics;
  final List<PaymentTrend> trends;
  final RefundAnalytics? refundStatistics;
  final ExportFormat format;
  const PaymentAnalyticsExporting({
    required this.analytics,
    required this.trends,
    this.refundStatistics,
    required this.format,
  });
  @override
  List<Object?> get props => [analytics, trends, refundStatistics, format];
}

/// ✅ حالة نجاح التصدير
class PaymentAnalyticsExportSuccess extends PaymentAnalyticsState {
  /// العربية: يخزن القيمة `analytics`.
  final PaymentAnalytics analytics;
  final List<PaymentTrend> trends;
  final RefundAnalytics? refundStatistics;
  final String message;
  const PaymentAnalyticsExportSuccess({
    required this.analytics,
    required this.trends,
    this.refundStatistics,
    required this.message,
  });
  @override
  List<Object?> get props => [analytics, trends, refundStatistics, message];
}

/// 🔄 حالة المقارنة
class PaymentAnalyticsComparison extends PaymentAnalyticsState {
  /// العربية: يخزن القيمة `period1Analytics`.
  final PaymentAnalytics period1Analytics;
  final PaymentAnalytics period2Analytics;
  final Map<String, dynamic> comparison;
  final DateTime period1Start;
  final DateTime period1End;
  final DateTime period2Start;
  final DateTime period2End;
  const PaymentAnalyticsComparison({
    required this.period1Analytics,
    required this.period2Analytics,
    required this.comparison,
    required this.period1Start,
    required this.period1End,
    required this.period2Start,
    required this.period2End,
  });
  @override
  List<Object> get props => [
        period1Analytics,
        period2Analytics,
        comparison,
        period1Start,
        period1End,
        period2Start,
        period2End,
      ];
}
