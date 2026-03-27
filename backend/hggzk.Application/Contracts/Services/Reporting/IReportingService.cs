namespace YemenBooking.Application.Contracts.Services.Reporting;

/// <summary>
/// واجهة خدمة التقارير
/// Reporting service interface
/// </summary>
public interface IReportingService
{
    /// <summary>
    /// الحصول على تقرير الحجوزات
    /// Get booking report
    /// </summary>
    Task<object> GetBookingReportAsync(
        DateTime fromDate,
        DateTime toDate,
        Guid? propertyId = null,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// حساب معدل الإشغال
    /// Calculate occupancy rate
    /// </summary>
    Task<decimal> CalculateOccupancyRateAsync(
        Guid propertyId,
        DateTime fromDate,
        DateTime toDate,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// حساب الإيرادات
    /// Calculate revenue
    /// </summary>
    Task<decimal> CalculateRevenueAsync(
        DateTime fromDate,
        DateTime toDate,
        Guid? propertyId = null,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// الحصول على تقرير الإيرادات
    /// Get revenue report
    /// </summary>
    Task<object> GetRevenueReportAsync(
        DateTime fromDate,
        DateTime toDate,
        Guid? propertyId = null,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// الحصول على تقرير الإشغال
    /// Get occupancy report
    /// </summary>
    Task<object> GetOccupancyReportAsync(
        DateTime fromDate,
        DateTime toDate,
        Guid propertyId,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// الحصول على تقرير العملاء
    /// Get customer report
    /// </summary>
    Task<object> GetCustomerReportAsync(
        DateTime fromDate,
        DateTime toDate,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// الحصول على أداء الكيان
    /// Get property performance
    /// </summary>
    Task<object> GetPropertyPerformanceAsync(
        Guid propertyId,
        DateTime fromDate,
        DateTime toDate,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// الحصول على الملخص المالي
    /// Get financial summary
    /// </summary>
    Task<object> GetFinancialSummaryAsync(
        DateTime fromDate,
        DateTime toDate,
        Guid? propertyId = null,
        CancellationToken cancellationToken = default);

}
