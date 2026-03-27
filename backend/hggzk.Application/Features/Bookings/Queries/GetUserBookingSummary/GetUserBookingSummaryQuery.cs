using MediatR;
using System.Collections.Generic;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Bookings.Queries.GetUserBookingSummary;

/// <summary>
/// يمثل استعلامًا ضمن نطاق الحجوزات.
/// Represents a booking-related query.
/// </summary>
public class GetUserBookingSummaryQuery : IRequest<ResultDto<UserBookingSummaryDto>>
{
    /// <summary>
    /// معرّف المستخدم المطلوب تلخيص حجوزاته.
    /// Identifier of the user whose bookings should be summarized.
    /// </summary>
    public Guid UserId { get; set; }
    
    /// <summary>
    /// السنة المطلوبة للملخص إن كانت محددة.
    /// Requested year for the summary, when specified.
    /// </summary>
    public int? Year { get; set; }
}

/// <summary>
/// يمثل نموذج بيانات مرتبطًا بنطاق الحجوزات.
/// Represents a data model for the booking-related feature area.
/// </summary>
public class UserBookingSummaryDto
{
    /// <summary>
    /// ملخصات الحجوزات الشهرية.
    /// Monthly booking summaries.
    /// </summary>
    public List<MonthlyBookingSummaryDto> MonthlyBookings { get; set; } = new();
    
    /// <summary>
    /// أكثر العقارات حجزًا.
    /// Top booked properties.
    /// </summary>
    public List<PropertyBookingFrequencyDto> TopBookedProperties { get; set; } = new();
    
    /// <summary>
    /// أكثر المدن زيارةً.
    /// Top visited cities.
    /// </summary>
    public List<CityVisitFrequencyDto> TopVisitedCities { get; set; } = new();
}

/// <summary>
/// يمثل ملخص الحجوزات لشهر محدد.
/// Represents booking summary for a specific month.
/// </summary>
public class MonthlyBookingSummaryDto
{
    /// <summary>
    /// رقم الشهر.
    /// Month number.
    /// </summary>
    public int Month { get; set; }
    
    /// <summary>
    /// السنة.
    /// Year.
    /// </summary>
    public int Year { get; set; }
    
    /// <summary>
    /// عدد الحجوزات.
    /// Number of bookings.
    /// </summary>
    public int BookingsCount { get; set; }
    
    /// <summary>
    /// إجمالي المبلغ المصروف.
    /// Total amount spent.
    /// </summary>
    public decimal AmountSpent { get; set; }
}

/// <summary>
/// يمثل تكرار الحجوزات لكل عقار.
/// Represents booking frequency per property.
/// </summary>
public class PropertyBookingFrequencyDto
{
    /// <summary>
    /// اسم العقار.
    /// Property name.
    /// </summary>
    public string PropertyName { get; set; } = string.Empty;
    
    /// <summary>
    /// المدينة.
    /// City.
    /// </summary>
    public string City { get; set; } = string.Empty;
    
    /// <summary>
    /// عدد الحجوزات.
    /// Number of bookings.
    /// </summary>
    public int BookingsCount { get; set; }
}

/// <summary>
/// يمثل تكرار الزيارات لكل مدينة.
/// Represents visit frequency per city.
/// </summary>
public class CityVisitFrequencyDto
{
    /// <summary>
    /// اسم المدينة.
    /// City name.
    /// </summary>
    public string CityName { get; set; } = string.Empty;
    
    /// <summary>
    /// عدد الزيارات.
    /// Number of visits.
    /// </summary>
    public int VisitsCount { get; set; }
}
