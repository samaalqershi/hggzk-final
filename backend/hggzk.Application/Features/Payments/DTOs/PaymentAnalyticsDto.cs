using System;
using System.Collections.Generic;
using YemenBooking.Core.Enums;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Payments.DTOs
{
    /// <summary>
    /// Represents aggregated payment and revenue analytics for a reporting window.
    /// يمثل تحليلات مجمعة للمدفوعات والإيرادات ضمن فترة تقرير محددة.
    /// </summary>
    public class PaymentAnalyticsDto
    {
        /// <summary>
        /// Gets or sets the overall payment summary.
        /// يحصل أو يعيّن الملخص العام للمدفوعات.
        /// </summary>
        public PaymentSummaryDto Summary { get; set; }

        /// <summary>
        /// Gets or sets the time-based payment trends.
        /// يحصل أو يعيّن اتجاهات المدفوعات عبر الزمن.
        /// </summary>
        public List<PaymentTrendDto> Trends { get; set; }

        /// <summary>
        /// Gets or sets analytics grouped by payment method.
        /// يحصل أو يعيّن التحليلات المجمعة حسب طريقة الدفع.
        /// </summary>
        public Dictionary<string, MethodAnalyticsDto> MethodAnalytics { get; set; }

        /// <summary>
        /// Gets or sets analytics grouped by payment status.
        /// يحصل أو يعيّن التحليلات المجمعة حسب حالة الدفع.
        /// </summary>
        public Dictionary<string, StatusAnalyticsDto> StatusAnalytics { get; set; }

        /// <summary>
        /// Gets or sets refund-related analytics.
        /// يحصل أو يعيّن التحليلات المرتبطة بعمليات الاسترداد.
        /// </summary>
        public RefundAnalyticsDto RefundAnalytics { get; set; }

        /// <summary>
        /// Gets or sets the inclusive report start date.
        /// يحصل أو يعيّن تاريخ بداية التقرير بشكل شامل.
        /// </summary>
        public DateTime StartDate { get; set; }

        /// <summary>
        /// Gets or sets the inclusive report end date.
        /// يحصل أو يعيّن تاريخ نهاية التقرير بشكل شامل.
        /// </summary>
        public DateTime EndDate { get; set; }
    }

    /// <summary>
    /// Represents the high-level summary metrics for payments.
    /// يمثل مؤشرات الملخص عالية المستوى للمدفوعات.
    /// </summary>
    public class PaymentSummaryDto
    {
        /// <summary>
        /// Gets or sets the total number of transactions.
        /// يحصل أو يعيّن العدد الإجمالي للمعاملات.
        /// </summary>
        public int TotalTransactions { get; set; }

        /// <summary>
        /// Gets or sets the total processed amount.
        /// يحصل أو يعيّن إجمالي المبلغ المعالج.
        /// </summary>
        public MoneyDto TotalAmount { get; set; }

        /// <summary>
        /// Gets or sets the average transaction value.
        /// يحصل أو يعيّن متوسط قيمة المعاملة.
        /// </summary>
        public MoneyDto AverageTransactionValue { get; set; }

        /// <summary>
        /// Gets or sets the success rate across transactions.
        /// يحصل أو يعيّن معدل نجاح المعاملات.
        /// </summary>
        public double SuccessRate { get; set; }

        /// <summary>
        /// Gets or sets the count of successful transactions.
        /// يحصل أو يعيّن عدد المعاملات الناجحة.
        /// </summary>
        public int SuccessfulTransactions { get; set; }

        /// <summary>
        /// Gets or sets the count of failed transactions.
        /// يحصل أو يعيّن عدد المعاملات الفاشلة.
        /// </summary>
        public int FailedTransactions { get; set; }

        /// <summary>
        /// Gets or sets the count of pending transactions.
        /// يحصل أو يعيّن عدد المعاملات المعلقة.
        /// </summary>
        public int PendingTransactions { get; set; }

        /// <summary>
        /// Gets or sets the total refunded amount.
        /// يحصل أو يعيّن إجمالي المبالغ المستردة.
        /// </summary>
        public MoneyDto TotalRefunded { get; set; }

        /// <summary>
        /// Gets or sets the number of refund operations.
        /// يحصل أو يعيّن عدد عمليات الاسترداد.
        /// </summary>
        public int RefundCount { get; set; }

        /// <summary>
        /// Gets or sets the daily revenue value.
        /// يحصل أو يعيّن قيمة الإيرادات اليومية.
        /// </summary>
        public decimal DailyRevenue { get; set; }

        /// <summary>
        /// Gets or sets the weekly revenue value.
        /// يحصل أو يعيّن قيمة الإيرادات الأسبوعية.
        /// </summary>
        public decimal WeeklyRevenue { get; set; }

        /// <summary>
        /// Gets or sets the monthly revenue value.
        /// يحصل أو يعيّن قيمة الإيرادات الشهرية.
        /// </summary>
        public decimal MonthlyRevenue { get; set; }

        /// <summary>
        /// Gets or sets the growth rate for the selected period.
        /// يحصل أو يعيّن معدل النمو للفترة المحددة.
        /// </summary>
        public double GrowthRate { get; set; }

        /// <summary>
        /// Gets or sets revenue generated from bookings.
        /// يحصل أو يعيّن الإيرادات الناتجة عن الحجوزات.
        /// </summary>
        public decimal BookingsRevenue { get; set; }

        /// <summary>
        /// Gets or sets revenue generated from services.
        /// يحصل أو يعيّن الإيرادات الناتجة عن الخدمات.
        /// </summary>
        public decimal ServicesRevenue { get; set; }

        /// <summary>
        /// Gets or sets revenue generated from other sources.
        /// يحصل أو يعيّن الإيرادات الناتجة عن مصادر أخرى.
        /// </summary>
        public decimal OtherRevenue { get; set; }
    }

    /// <summary>
    /// Represents a time-series payment trend entry.
    /// يمثل عنصرًا واحدًا من اتجاهات المدفوعات عبر الزمن.
    /// </summary>
    public class PaymentTrendDto
    {
        /// <summary>
        /// Gets or sets the trend date.
        /// يحصل أو يعيّن تاريخ العنصر.
        /// </summary>
        public DateTime Date { get; set; }

        /// <summary>
        /// Gets or sets the number of transactions on the date.
        /// يحصل أو يعيّن عدد المعاملات في ذلك التاريخ.
        /// </summary>
        public int TransactionCount { get; set; }

        /// <summary>
        /// Gets or sets the total amount for the date.
        /// يحصل أو يعيّن إجمالي المبلغ لذلك التاريخ.
        /// </summary>
        public MoneyDto TotalAmount { get; set; }

        /// <summary>
        /// Gets or sets the success rate for the date.
        /// يحصل أو يعيّن معدل النجاح لذلك التاريخ.
        /// </summary>
        public double SuccessRate { get; set; }

        /// <summary>
        /// Gets or sets the breakdown of transactions by payment method.
        /// يحصل أو يعيّن توزيع المعاملات حسب طريقة الدفع.
        /// </summary>
        public Dictionary<string, int> MethodBreakdown { get; set; }
    }

    /// <summary>
    /// Represents analytics for a single payment method.
    /// يمثل التحليلات الخاصة بطريقة دفع واحدة.
    /// </summary>
    public class MethodAnalyticsDto
    {
        /// <summary>
        /// Gets or sets the payment method identifier or name.
        /// يحصل أو يعيّن اسم أو معرف طريقة الدفع.
        /// </summary>
        public string Method { get; set; }

        /// <summary>
        /// Gets or sets the number of transactions for the method.
        /// يحصل أو يعيّن عدد المعاملات لهذه الطريقة.
        /// </summary>
        public int TransactionCount { get; set; }

        /// <summary>
        /// Gets or sets the total amount processed by the method.
        /// يحصل أو يعيّن إجمالي المبلغ المعالج عبر هذه الطريقة.
        /// </summary>
        public MoneyDto TotalAmount { get; set; }

        /// <summary>
        /// Gets or sets the relative percentage for the method.
        /// يحصل أو يعيّن النسبة المئوية لهذه الطريقة.
        /// </summary>
        public double Percentage { get; set; }

        /// <summary>
        /// Gets or sets the success rate for the method.
        /// يحصل أو يعيّن معدل النجاح لهذه الطريقة.
        /// </summary>
        public double SuccessRate { get; set; }

        /// <summary>
        /// Gets or sets the average processed amount for the method.
        /// يحصل أو يعيّن متوسط المبلغ المعالج لهذه الطريقة.
        /// </summary>
        public MoneyDto AverageAmount { get; set; }
    }

    /// <summary>
    /// Represents analytics for a single payment status.
    /// يمثل التحليلات الخاصة بحالة دفع واحدة.
    /// </summary>
    public class StatusAnalyticsDto
    {
        /// <summary>
        /// Gets or sets the payment status.
        /// يحصل أو يعيّن حالة الدفع.
        /// </summary>
        public string Status { get; set; }

        /// <summary>
        /// Gets or sets the count for the status.
        /// يحصل أو يعيّن العدد الخاص بهذه الحالة.
        /// </summary>
        public int Count { get; set; }

        /// <summary>
        /// Gets or sets the total amount associated with the status.
        /// يحصل أو يعيّن إجمالي المبلغ المرتبط بهذه الحالة.
        /// </summary>
        public MoneyDto TotalAmount { get; set; }

        /// <summary>
        /// Gets or sets the relative percentage for the status.
        /// يحصل أو يعيّن النسبة المئوية لهذه الحالة.
        /// </summary>
        public double Percentage { get; set; }
    }

    /// <summary>
    /// Represents refund analytics for the selected period.
    /// يمثل تحليلات الاستردادات للفترة المحددة.
    /// </summary>
    public class RefundAnalyticsDto
    {
        /// <summary>
        /// Gets or sets the total number of refunds.
        /// يحصل أو يعيّن العدد الإجمالي للاستردادات.
        /// </summary>
        public int TotalRefunds { get; set; }

        /// <summary>
        /// Gets or sets the total refunded amount.
        /// يحصل أو يعيّن إجمالي المبلغ المسترد.
        /// </summary>
        public MoneyDto TotalRefundedAmount { get; set; }

        /// <summary>
        /// Gets or sets the refund rate.
        /// يحصل أو يعيّن معدل الاسترداد.
        /// </summary>
        public double RefundRate { get; set; }

        /// <summary>
        /// Gets or sets the average refund processing time.
        /// يحصل أو يعيّن متوسط زمن معالجة الاسترداد.
        /// </summary>
        public double AverageRefundTime { get; set; }

        /// <summary>
        /// Gets or sets the refund reasons grouped by label.
        /// يحصل أو يعيّن أسباب الاسترداد مجمعة حسب الوصف.
        /// </summary>
        public Dictionary<string, int> RefundReasons { get; set; }

        /// <summary>
        /// Gets or sets the refund trend entries.
        /// يحصل أو يعيّن عناصر اتجاهات الاسترداد.
        /// </summary>
        public List<RefundTrendDto> Trends { get; set; }
    }

    /// <summary>
    /// Represents a time-series refund trend entry.
    /// يمثل عنصرًا واحدًا من اتجاهات الاسترداد عبر الزمن.
    /// </summary>
    public class RefundTrendDto
    {
        /// <summary>
        /// Gets or sets the trend date.
        /// يحصل أو يعيّن تاريخ العنصر.
        /// </summary>
        public DateTime Date { get; set; }

        /// <summary>
        /// Gets or sets the number of refunds for the date.
        /// يحصل أو يعيّن عدد الاستردادات في ذلك التاريخ.
        /// </summary>
        public int RefundCount { get; set; }

        /// <summary>
        /// Gets or sets the refunded amount for the date.
        /// يحصل أو يعيّن المبلغ المسترد في ذلك التاريخ.
        /// </summary>
        public MoneyDto RefundedAmount { get; set; }
    }

}
