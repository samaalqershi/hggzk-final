namespace YemenBooking.Application.Contracts.Services.Scheduling;

/// <summary>
/// نتيجة التحقق من توفر الوحدة خلال فترة محددة.
/// Result of checking unit availability for a date range.
/// </summary>
public class AvailabilityCheckResult
{
    /// <summary>
    /// يحدد ما إذا كانت الوحدة متاحة بالكامل للفترة المطلوبة.
    /// Indicates whether the unit is fully available for the requested period.
    /// </summary>
    public bool IsAvailable { get; set; }

    /// <summary>
    /// إجمالي عدد الأيام التي تم فحصها.
    /// Total number of days evaluated.
    /// </summary>
    public int TotalDays { get; set; }

    /// <summary>
    /// عدد الأيام المتاحة ضمن الفترة.
    /// Number of available days within the range.
    /// </summary>
    public int AvailableDays { get; set; }

    /// <summary>
    /// عدد الأيام غير المتاحة ضمن الفترة.
    /// Number of unavailable days within the range.
    /// </summary>
    public int UnavailableDays { get; set; }

    /// <summary>
    /// التواريخ غير المتاحة داخل الفترة المطلوبة.
    /// Unavailable dates inside the requested range.
    /// </summary>
    public List<DateTime> UnavailableDates { get; set; } = new();

    /// <summary>
    /// رسالة توضيحية إضافية عن نتيجة الفحص.
    /// Optional explanatory message about the check result.
    /// </summary>
    public string? Message { get; set; }
}
