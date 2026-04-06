namespace YemenBooking.Application.Common.Models;

/// <summary>
/// Represents route-based travel metrics between a property and a nearby place.
/// يمثل قياسات التنقل المعتمدة على المسار بين العقار والمكان القريب.
/// </summary>
public sealed class PropertyTravelMetrics
{
    /// <summary>
    /// Distance in meters returned by the routing provider.
    /// المسافة بالمتر كما أعادها مزود المسارات.
    /// </summary>
    public int DistanceInMeters { get; init; }

    /// <summary>
    /// Estimated walking duration in minutes when available.
    /// مدة المشي المقدرة بالدقائق عند توفرها.
    /// </summary>
    public int? WalkingMinutes { get; init; }

    /// <summary>
    /// Estimated driving duration in minutes when available.
    /// مدة القيادة المقدرة بالدقائق عند توفرها.
    /// </summary>
    public int? DrivingMinutes { get; init; }
}
