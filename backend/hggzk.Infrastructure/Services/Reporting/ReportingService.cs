using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using YemenBooking.Core.Interfaces.Repositories;
using System.Linq;

namespace YemenBooking.Infrastructure.Services.Reporting
{
    /// <summary>
    /// Provides report generation services for bookings, revenue, occupancy, and customer activity.
    /// يوفر خدمات إعداد التقارير للحجوزات والإيرادات والإشغال ونشاط العملاء.
    /// </summary>
    public class ReportingService : IReportingService
    {
        private readonly ILogger<ReportingService> _logger;
        private readonly IBookingRepository _bookingRepository;
        private readonly IPropertyRepository _propertyRepository;

        /// <summary>
        /// Initializes the reporting service with booking and property repositories.
        /// يهيئ خدمة التقارير مع مستودعات الحجوزات والعقارات.
        /// </summary>
        public ReportingService(
            ILogger<ReportingService> logger,
            IBookingRepository bookingRepository,
            IPropertyRepository propertyRepository)
        {
            _logger = logger;
            _bookingRepository = bookingRepository;
            _propertyRepository = propertyRepository;
        }

        /// <summary>
        /// Builds a booking summary grouped by day.
        /// يبني ملخص الحجوزات مجمّعًا حسب اليوم.
        /// </summary>
        public async Task<object> GetBookingReportAsync(DateTime fromDate, DateTime toDate, Guid? propertyId = null, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("الحصول على تقرير الحجوزات من {FromDate} إلى {ToDate}", fromDate, toDate);
            var bookings = propertyId.HasValue
                ? await _bookingRepository.GetBookingsByPropertyAsync(propertyId.Value, fromDate, toDate, cancellationToken)
                : await _bookingRepository.GetBookingsByDateRangeAsync(fromDate, toDate, cancellationToken);
            var report = bookings
                .GroupBy(b => b.BookedAt.Date)
                .Select(g => new { Date = g.Key, Count = g.Count() })
                .OrderBy(r => r.Date)
                .ToList();
            return report;
        }

        /// <summary>
        /// Calculates occupancy for a property over the requested date range.
        /// يحسب الإشغال لعقار خلال نطاق التاريخ المطلوب.
        /// </summary>
        public async Task<decimal> CalculateOccupancyRateAsync(Guid propertyId, DateTime fromDate, DateTime toDate, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("حساب معدل الإشغال للكيان: {PropertyId}", propertyId);
            var prop = await _propertyRepository.GetPropertyWithUnitsAsync(propertyId, cancellationToken);
            var unitsCount = prop?.Units.Count ?? 0;
            if (unitsCount == 0) return 0m;
            var bookings = await _bookingRepository.GetBookingsByPropertyAsync(propertyId, fromDate, toDate, cancellationToken);
            double bookedNights = bookings.Sum(b =>
            {
                var start = b.CheckIn < fromDate ? fromDate : b.CheckIn;
                var end = b.CheckOut > toDate ? toDate : b.CheckOut;
                return (end.Date - start.Date).TotalDays;
            });
            var totalNights = (toDate.Date - fromDate.Date).TotalDays * unitsCount;
            return totalNights > 0 ? (decimal)bookedNights / (decimal)totalNights : 0m;
        }

        /// <summary>
        /// Calculates total revenue for the requested date range.
        /// يحسب إجمالي الإيرادات لنطاق التاريخ المطلوب.
        /// </summary>
        public async Task<decimal> CalculateRevenueAsync(DateTime fromDate, DateTime toDate, Guid? propertyId = null, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("حساب الإيرادات من {FromDate} إلى {ToDate}", fromDate, toDate);
            return await _bookingRepository.GetTotalRevenueAsync(propertyId, fromDate, toDate, cancellationToken);
        }

        /// <summary>
        /// Builds a daily revenue summary for the requested period.
        /// يبني ملخص الإيرادات اليومي للفترة المطلوبة.
        /// </summary>
        public async Task<object> GetRevenueReportAsync(DateTime fromDate, DateTime toDate, Guid? propertyId = null, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("الحصول على تقرير الإيرادات من {FromDate} إلى {ToDate}", fromDate, toDate);
            var bookings = propertyId.HasValue
                ? await _bookingRepository.GetBookingsByPropertyAsync(propertyId.Value, fromDate, toDate, cancellationToken)
                : await _bookingRepository.GetBookingsByDateRangeAsync(fromDate, toDate, cancellationToken);
            var report = bookings
                .GroupBy(b => b.BookedAt.Date)
                .Select(g => new { Date = g.Key, Revenue = g.Sum(b => b.TotalPrice.Amount) })
                .OrderBy(r => r.Date)
                .ToList();
            return report;
        }

        /// <summary>
        /// Builds a day-by-day occupancy breakdown for a property.
        /// يبني تفصيلاً يوميًا للإشغال لعقار محدد.
        /// </summary>
        public async Task<object> GetOccupancyReportAsync(DateTime fromDate, DateTime toDate, Guid propertyId, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("الحصول على تقرير الإشغال للكيان: {PropertyId}", propertyId);
            var prop = await _propertyRepository.GetPropertyWithUnitsAsync(propertyId, cancellationToken);
            var unitsCount = prop?.Units.Count ?? 0;
            var dates = Enumerable.Range(0, (toDate.Date - fromDate.Date).Days + 1)
                .Select(i => fromDate.Date.AddDays(i));
            var bookings = await _bookingRepository.GetBookingsByPropertyAsync(propertyId, fromDate, toDate, cancellationToken);
            var report = dates.Select(date =>
            {
                var occupied = bookings.Count(b => b.CheckIn.Date <= date && b.CheckOut.Date > date);
                return new
                {
                    Date = date,
                    OccupiedUnits = occupied,
                    TotalUnits = unitsCount,
                    OccupancyRate = unitsCount > 0 ? (decimal)occupied / unitsCount : 0m
                };
            }).ToList();
            return report;
        }

        /// <summary>
        /// Builds a customer activity summary for the requested period.
        /// يبني ملخص نشاط العملاء للفترة المطلوبة.
        /// </summary>
        public async Task<object> GetCustomerReportAsync(DateTime fromDate, DateTime toDate, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("الحصول على تقرير العملاء من {FromDate} إلى {ToDate}", fromDate, toDate);
            var bookings = await _bookingRepository.GetBookingsByDateRangeAsync(fromDate, toDate, cancellationToken);
            var report = bookings
                .GroupBy(b => b.UserId)
                .Select(g => new
                {
                    UserId = g.Key,
                    CustomerName = g.First().User.Name,
                    BookingsCount = g.Count(),
                    TotalSpent = g.Sum(b => b.TotalPrice.Amount)
                })
                .OrderByDescending(r => r.TotalSpent)
                .ToList();
            return report;
        }

        /// <summary>
        /// Returns performance metrics for a specific property.
        /// يعيد مؤشرات أداء لعقار محدد.
        /// </summary>
        public Task<object> GetPropertyPerformanceAsync(Guid propertyId, DateTime fromDate, DateTime toDate, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("الحصول على أداء الكيان: {PropertyId}", propertyId);
            return _propertyRepository.CalculatePerformanceMetricsAsync(propertyId, fromDate, toDate, cancellationToken);
        }

        /// <summary>
        /// Builds a financial summary covering revenue, bookings, and average booking value.
        /// يبني ملخصًا ماليًا يشمل الإيرادات والحجوزات ومتوسط قيمة الحجز.
        /// </summary>
        public async Task<object> GetFinancialSummaryAsync(DateTime fromDate, DateTime toDate, Guid? propertyId = null, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("الحصول على الملخص المالي من {FromDate} إلى {ToDate}", fromDate, toDate);
            var revenue = await CalculateRevenueAsync(fromDate, toDate, propertyId, cancellationToken);
            var bookingsCount = await _bookingRepository.GetTotalBookingsCountAsync(propertyId, fromDate, toDate, cancellationToken);
            var average = bookingsCount > 0 ? revenue / bookingsCount : 0m;
            return new { TotalRevenue = revenue, TotalBookings = bookingsCount, AverageBookingValue = average };
        }
    }
}
