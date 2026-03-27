using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Properties;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Properties.Queries.GetCheckPropertyAvailability;

/// <summary>
/// استعلام للتحقق من توفر العقار لفترة محددة.
/// Query for checking property availability over a specified date range.
/// </summary>
public class CheckPropertyAvailabilityQuery : IRequest<ResultDto<PropertyAvailabilityResponse>>
{
    /// <summary>
    /// معرّف العقار.
    /// property identifier.
    /// </summary>
    public Guid PropertyId { get; set; }
    /// <summary>
    /// تاريخ الوصول.
    /// check-in date.
    /// </summary>
    public DateTime CheckInDate { get; set; }
    /// <summary>
    /// تاريخ المغادرة.
    /// check-out date.
    /// </summary>
    public DateTime CheckOutDate { get; set; }
    /// <summary>
    /// عدد الضيوف.
    /// guest count.
    /// </summary>
    public int GuestsCount { get; set; }
}

/// <summary>
/// نتيجة التحقق من توفر العقار.
/// Result of a property availability check.
/// </summary>
public class PropertyAvailabilityResponse
{
    /// <summary>
    /// وجود وحدات متاحة.
    /// available units exist.
    /// </summary>
    public bool HasAvailableUnits { get; set; }
    /// <summary>
    /// عدد الوحدات المتاحة.
    /// available units count.
    /// </summary>
    public int AvailableUnitsCount { get; set; }
    /// <summary>
    /// أقل سعر متاح.
    /// minimum available price.
    /// </summary>
    public decimal? MinAvailablePrice { get; set; }
    /// <summary>
    /// العملة.
    /// currency.
    /// </summary>
    public string? Currency { get; set; }
    /// <summary>
    /// الرسالة.
    /// message.
    /// </summary>
    public string Message { get; set; } = string.Empty;
    
    /// <summary>
    /// أنواع الوحدات المتاحة ضمن نتيجة التحقق.
    /// Available unit types returned by the availability check.
    /// </summary>
    public List<string> AvailableUnitTypes { get; set; } = new();
}
