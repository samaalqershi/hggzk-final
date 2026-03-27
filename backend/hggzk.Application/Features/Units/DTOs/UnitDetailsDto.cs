using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.DynamicFields.DTOs;
using YemenBooking.Application.Features.Scheduling.DTOs;

namespace YemenBooking.Application.Features.Units.DTOs;

/// <summary>
/// Represents the detailed view of a unit, including schedules and dynamic fields.
/// يمثل العرض التفصيلي للوحدة بما في ذلك الجداول والحقول الديناميكية.
/// </summary>
public class UnitDetailsDto
{
    /// <summary>
    /// Gets or sets the unit identifier.
    /// يحصل أو يعيّن معرف الوحدة.
    /// </summary>
    public Guid Id { get; set; }
    
    /// <summary>
    /// Gets or sets the property identifier.
    /// يحصل أو يعيّن معرف العقار.
    /// </summary>
    public Guid PropertyId { get; set; }
    
    /// <summary>
    /// Gets or sets the property name.
    /// يحصل أو يعيّن اسم العقار.
    /// </summary>
    public string PropertyName { get; set; } = string.Empty;
    
    /// <summary>
    /// Gets or sets the unit name.
    /// يحصل أو يعيّن اسم الوحدة.
    /// </summary>
    public string Name { get; set; } = string.Empty;
    
    /// <summary>
    /// Gets or sets the unit type.
    /// يحصل أو يعيّن نوع الوحدة.
    /// </summary>
    public UnitTypeDto UnitType { get; set; } = null!;
    
    /// <summary>
    /// Gets or sets the unit-type identifier.
    /// يحصل أو يعيّن معرف نوع الوحدة.
    /// </summary>
    public Guid UnitTypeId { get; set; }
    
    /// <summary>
    /// Gets or sets the unit-type name.
    /// يحصل أو يعيّن اسم نوع الوحدة.
    /// </summary>
    public string UnitTypeName { get; set; } = string.Empty;
    
    /// <summary>
    /// Gets or sets the currency code when needed by the client.
    /// يحصل أو يعيّن رمز العملة عند الحاجة من قبل العميل.
    /// </summary>
    public string? Currency { get; set; }
    
    /// <summary>
    /// Gets or sets the maximum capacity.
    /// يحصل أو يعيّن السعة القصوى.
    /// </summary>
    public int MaxCapacity { get; set; }
    
    /// <summary>
    /// Gets or sets the view count.
    /// يحصل أو يعيّن عدد المشاهدات.
    /// </summary>
    public int ViewCount { get; set; }
    
    /// <summary>
    /// Gets or sets the booking count.
    /// يحصل أو يعيّن عدد الحجوزات.
    /// </summary>
    public int BookingCount { get; set; }
    
    /// <summary>
    /// Gets or sets the pricing method.
    /// يحصل أو يعيّن طريقة حساب السعر.
    /// </summary>
    public string PricingMethod { get; set; } = string.Empty;
    
    /// <summary>
    /// Gets or sets the unit images.
    /// يحصل أو يعيّن صور الوحدة.
    /// </summary>
    public List<UnitImageDto> Images { get; set; } = new();
    
    /// <summary>
    /// Gets or sets the custom features JSON payload.
    /// يحصل أو يعيّن حمولة JSON للميزات المخصصة.
    /// </summary>
    public string CustomFeatures { get; set; } = string.Empty;
    
    /// <summary>
    /// Gets or sets the dynamic field values.
    /// يحصل أو يعيّن قيم الحقول الديناميكية.
    /// </summary>
    public List<UnitFieldValueDto> FieldValues { get; set; } = new();

    /// <summary>
    /// Gets or sets the dynamic field groups with values.
    /// يحصل أو يعيّن مجموعات الحقول الديناميكية مع القيم.
    /// </summary>
    public List<FieldGroupWithValuesDto> DynamicFields { get; set; } = new();
    
    /// <summary>
    /// Gets or sets the daily schedules for pricing and availability.
    /// يحصل أو يعيّن الجداول اليومية للتسعير والإتاحة.
    /// </summary>
    public List<DailyScheduleDto> DailySchedules { get; set; } = new();
    
    /// <summary>
    /// Gets or sets the calculated price for the selected period.
    /// يحصل أو يعيّن السعر المحسوب للفترة المحددة.
    /// </summary>
    public CalculatedPriceDto? CalculatedPrice { get; set; }

    /// <summary>
    /// Gets or sets whether the unit allows cancellation.
    /// يحصل أو يعيّن ما إذا كانت الوحدة تقبل الإلغاء.
    /// </summary>
    public bool AllowsCancellation { get; set; }

    /// <summary>
    /// Gets or sets the cancellation window in days.
    /// يحصل أو يعيّن نافذة الإلغاء بالأيام.
    /// </summary>
    public int? CancellationWindowDays { get; set; }
}

/// <summary>
/// Represents a deprecated pricing rule contract kept for compatibility.
/// يمثل عقد قاعدة تسعير مُهملًا ومحتفظًا به للتوافق.
/// </summary>
[Obsolete("Use DailyScheduleDto instead. استخدم DailyScheduleDto بدلاً من ذلك.")]
public class PricingRuleDto
{
    /// <summary>
    /// Gets or sets the price type.
    /// يحصل أو يعيّن نوع السعر.
    /// </summary>
    public string PriceType { get; set; } = string.Empty;
    
    /// <summary>
    /// Gets or sets the start date.
    /// يحصل أو يعيّن تاريخ البداية.
    /// </summary>
    public DateTime StartDate { get; set; }
    
    /// <summary>
    /// Gets or sets the end date.
    /// يحصل أو يعيّن تاريخ النهاية.
    /// </summary>
    public DateTime EndDate { get; set; }
    
    /// <summary>
    /// Gets or sets the price amount.
    /// يحصل أو يعيّن مبلغ السعر.
    /// </summary>
    public decimal PriceAmount { get; set; }
    
    /// <summary>
    /// Gets or sets the optional description.
    /// يحصل أو يعيّن الوصف الاختياري.
    /// </summary>
    public string? Description { get; set; }
}

/// <summary>
/// Represents the calculated price for a unit.
/// يمثل السعر المحسوب لوحدة.
/// </summary>
public class CalculatedPriceDto
{
    /// <summary>
    /// Gets or sets the base amount.
    /// يحصل أو يعيّن المبلغ الأساسي.
    /// </summary>
    public decimal BaseAmount { get; set; }
    
    /// <summary>
    /// Gets or sets the discounts amount.
    /// يحصل أو يعيّن قيمة الخصومات.
    /// </summary>
    public decimal Discounts { get; set; }
    
    /// <summary>
    /// Gets or sets the additional fees.
    /// يحصل أو يعيّن الرسوم الإضافية.
    /// </summary>
    public decimal Fees { get; set; }
    
    /// <summary>
    /// Gets or sets the taxes amount.
    /// يحصل أو يعيّن قيمة الضرائب.
    /// </summary>
    public decimal Taxes { get; set; }
    
    /// <summary>
    /// Gets or sets the total amount.
    /// يحصل أو يعيّن المبلغ الإجمالي.
    /// </summary>
    public decimal TotalAmount { get; set; }
    
    /// <summary>
    /// Gets or sets the number of nights.
    /// يحصل أو يعيّن عدد الليالي.
    /// </summary>
    public int NumberOfNights { get; set; }
    
    /// <summary>
    /// Gets or sets the price breakdown.
    /// يحصل أو يعيّن تفصيل حساب السعر.
    /// </summary>
    public List<PriceBreakdownDto> Breakdown { get; set; } = new();
}

/// <summary>
/// Represents a single price breakdown entry.
/// يمثل عنصرًا واحدًا من تفصيل السعر.
/// </summary>
public class PriceBreakdownDto
{
    /// <summary>
    /// Gets or sets the breakdown date.
    /// يحصل أو يعيّن تاريخ التفصيل.
    /// </summary>
    public DateTime Date { get; set; }
    
    /// <summary>
    /// Gets or sets the amount for the date.
    /// يحصل أو يعيّن المبلغ لهذا التاريخ.
    /// </summary>
    public decimal Amount { get; set; }
    
    /// <summary>
    /// Gets or sets the pricing reason label.
    /// يحصل أو يعيّن وسم سبب التسعير.
    /// </summary>
    public string Reason { get; set; } = string.Empty;
}
