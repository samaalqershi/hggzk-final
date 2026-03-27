using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Analytics.Commands.Reports;
using YemenBooking.Application.Features.Analytics.Queries.Dashboard;
using YemenBooking.Application.Features.Analytics.Queries.UserAnalytics;
using YemenBooking.Application.Features.Analytics.Queries.FinancialAnalytics;
using YemenBooking.Application.Features.Payments.Queries.GetPaymentAnalytics;
using YemenBooking.Application.Features.Analytics.Queries.PropertyAnalytics;
using YemenBooking.Application.Features.Analytics.Queries.BookingAnalytics;
using YemenBooking.Application.Features.Analytics.Queries;
using System;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// يوفّر تقارير وملخصات لوحة الإدارة.
    /// Provides admin dashboard reports and summaries.
    /// </summary>
    public class DashboardController : BaseAdminController
    {
    /// <summary>
    /// يهيئ المتحكم بالاعتماد على Mediator.
    /// Initializes the controller with Mediator.
    /// </summary>
        public DashboardController(IMediator mediator) : base(mediator) { }

        /// <summary>
        /// يجلب بيانات لوحة الإدارة ضمن نطاق زمني.
        /// Retrieves dashboard data for a date range.
        /// </summary>
        [HttpPost("dashboard")]
        public async Task<IActionResult> GetAdminDashboard([FromBody] GetAdminDashboardQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يصدر تقرير لوحة الإدارة.
        /// Exports the dashboard report.
        /// </summary>
        [HttpPost("dashboard/export")]
        public async Task<IActionResult> ExportDashboardReport([FromBody] ExportDashboardReportCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يجلب تقرير العملاء.
        /// Retrieves customer reporting data.
        /// </summary>
        [HttpGet("dashboard/customer-report")]
        public async Task<IActionResult> GetCustomerReport([FromQuery] GetCustomerReportQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب الملخص المالي.
        /// Retrieves the financial summary.
        /// </summary>
        [HttpGet("dashboard/financial-summary")]
        public async Task<IActionResult> GetFinancialSummary([FromQuery] GetFinancialSummaryQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب مؤشرات أداء العقار.
        /// Retrieves property performance metrics.
        /// </summary>
        [HttpPost("dashboard/performance")]
        public async Task<IActionResult> GetPropertyPerformance([FromBody] GetPropertyPerformanceQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب مقارنة أداء العقارات.
        /// Retrieves a property performance comparison.
        /// </summary>
        [HttpPost("dashboard/performance-comparison")]
        public async Task<IActionResult> GetPropertyPerformanceComparison([FromBody] GetPropertyPerformanceComparisonQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب نسبة الإشغال.
        /// Retrieves the occupancy rate.
        /// </summary>
        [HttpPost("dashboard/occupancy-rate")]
        public async Task<IActionResult> GetOccupancyRate([FromBody] GetOccupancyRateQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب تقرير الإشغال.
        /// Retrieves the occupancy report.
        /// </summary>
        [HttpPost("dashboard/occupancy-report")]
        public async Task<IActionResult> GetOccupancyReport([FromBody] GetOccupancyReportQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب تقرير الإيرادات.
        /// Retrieves the revenue report.
        /// </summary>
        [HttpPost("dashboard/revenue-report")]
        public async Task<IActionResult> GetRevenueReport([FromBody] GetRevenueReportQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب تحليل إلغاءات الحجوزات على مستوى المنصة.
        /// Retrieves platform-level cancellation analysis.
        /// </summary>
        [HttpPost("dashboard/cancellation-analysis")]
        public async Task<IActionResult> GetPlatformCancellationAnalysis([FromBody] GetPlatformCancellationAnalysisQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب تفصيل الإيرادات على مستوى المنصة.
        /// Retrieves the platform revenue breakdown.
        /// </summary>
        [HttpPost("dashboard/revenue-breakdown")]
        public async Task<IActionResult> GetPlatformRevenueBreakdown([FromBody] GetPlatformRevenueBreakdownQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب قمع اكتساب المستخدمين.
        /// Retrieves the user acquisition funnel.
        /// </summary>
        [HttpPost("dashboard/user-acquisition-funnel")]
        public async Task<IActionResult> GetUserAcquisitionFunnel([FromBody] GetUserAcquisitionFunnelQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب تحليل أفواج العملاء ضمن نطاق زمني.
        /// Retrieves customer cohort analysis for a date range.
        /// </summary>
        [HttpPost("dashboard/customer-cohort-analysis")]
        public async Task<IActionResult> GetCustomerCohortAnalysis([FromBody] GetCustomerCohortAnalysisQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب تحليل مشاعر التقييمات لعقار محدد.
        /// Retrieves review sentiment analysis for a specific property.
        /// </summary>
        [HttpGet("dashboard/review-sentiment-analysis/{propertyId}")]
        public async Task<IActionResult> GetReviewSentimentAnalysis(Guid propertyId)
        {
            var query = new GetReviewSentimentAnalysisQuery(propertyId);
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يجلب أعلى العقارات أداءً.
        /// Retrieves the top-performing properties.
        /// </summary>
        [HttpGet("dashboard/top-properties/{count}")]
        public async Task<IActionResult> GetTopPerformingProperties(int count)
        {
            var query = new GetTopPerformingPropertiesQuery(count);
            var result = await _mediator.Send(query);
            return Ok(result);
        }
    }
} 
