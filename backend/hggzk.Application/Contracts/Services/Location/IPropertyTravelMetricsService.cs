using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Contracts.Services.Location;

/// <summary>
/// Calculates route-aware travel metrics between a property and a nearby place.
/// يحسب قياسات التنقل المعتمدة على المسار بين العقار والمكان القريب.
/// </summary>
public interface IPropertyTravelMetricsService
{
    /// <summary>
    /// Calculates distance and durations using the configured routing provider.
    /// يحسب المسافة والمدد باستخدام مزود المسارات المهيأ.
    /// </summary>
    Task<ResultDto<PropertyTravelMetrics>> CalculateAsync(
        decimal originLatitude,
        decimal originLongitude,
        decimal destinationLatitude,
        decimal destinationLongitude,
        CancellationToken cancellationToken = default);
}
