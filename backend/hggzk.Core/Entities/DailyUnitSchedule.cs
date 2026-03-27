namespace YemenBooking.Core.Entities;

using System;
using System.ComponentModel.DataAnnotations;

/// <summary>
/// كيان الجدول اليومي الموحد للوحدة (يجمع التسعير والإتاحة)
/// Represents the daily schedule for a unit, including availability and pricing.
/// </summary>
[Display(Name = "كيان الجدول اليومي الموحد للوحدة")]
public class DailyUnitSchedule : BaseEntity<Guid>
{
    /// <summary>
    /// معرف الوحدة.
    /// Identifier of the unit.
    /// </summary>
    [Display(Name = "معرف الوحدة")]
    public Guid UnitId { get; set; }
    
    /// <summary>
    /// الكيان المرتبط بالوحدة.
    /// Navigation to the related unit entity.
    /// </summary>
    public virtual Unit Unit { get; set; } = null!;

    /// <summary>
    /// تاريخ اليوم بدون وقت.
    /// Calendar date without a time component.
    /// </summary>
    [Display(Name = "تاريخ اليوم")]
    public DateTime Date { get; set; }

    // ====== خصائص الإتاحة (Availability Properties) ======
    
    /// <summary>
    /// حالة الإتاحة.
    /// Availability status such as Available, Booked, Blocked, Maintenance, or OwnerUse.
    /// </summary>
    [Display(Name = "حالة الإتاحة")]
    public string Status { get; set; } = "Available";

    /// <summary>
    /// سبب عدم الإتاحة أو الحظر.
    /// Reason for unavailability or blocking.
    /// </summary>
    [Display(Name = "سبب عدم الإتاحة")]
    public string? Reason { get; set; }

    /// <summary>
    /// ملاحظات إضافية.
    /// Additional notes.
    /// </summary>
    [Display(Name = "ملاحظات")]
    public string? Notes { get; set; }

    /// <summary>
    /// معرف الحجز المرتبط.
    /// Identifier of the associated booking, if any.
    /// </summary>
    [Display(Name = "معرف الحجز المرتبط")]
    public Guid? BookingId { get; set; }

    /// <summary>
    /// الكيان المرتبط بالحجز.
    /// Navigation to the related booking entity.
    /// </summary>
    public virtual Booking? Booking { get; set; }

    // ====== خصائص التسعير (Pricing Properties) ======

    /// <summary>
    /// مبلغ السعر لهذا اليوم.
    /// Price amount for this day.
    /// </summary>
    [Display(Name = "مبلغ السعر")]
    public decimal? PriceAmount { get; set; }

    /// <summary>
    /// عملة السعر.
    /// Currency used for the price.
    /// </summary>
    [Display(Name = "عملة السعر")]
    public string? Currency { get; set; }

    /// <summary>
    /// الكيان المرتبط بالعملة.
    /// Navigation to the related currency entity.
    /// </summary>
    public virtual Currency? CurrencyRef { get; set; }

    /// <summary>
    /// نوع السعر.
    /// Price type such as Base, Weekend, Seasonal, Holiday, SpecialEvent, or Custom.
    /// </summary>
    [Display(Name = "نوع السعر")]
    public string? PriceType { get; set; }

    /// <summary>
    /// فئة التسعير.
    /// Pricing tier such as Normal, High, Peak, Discount, or Custom.
    /// </summary>
    [Display(Name = "فئة التسعير")]
    public string? PricingTier { get; set; }

    /// <summary>
    /// نسبة التغيير عن السعر الأساسي.
    /// Percentage change from the base price, positive or negative.
    /// </summary>
    [Display(Name = "نسبة التغيير")]
    public decimal? PercentageChange { get; set; }

    /// <summary>
    /// الحد الأدنى للسعر.
    /// Minimum price when a percentage rule applies.
    /// </summary>
    [Display(Name = "الحد الأدنى للسعر")]
    public decimal? MinPrice { get; set; }

    /// <summary>
    /// الحد الأقصى للسعر.
    /// Maximum price when a percentage rule applies.
    /// </summary>
    [Display(Name = "الحد الأقصى للسعر")]
    public decimal? MaxPrice { get; set; }

    // ====== خصائص إضافية (Additional Properties) ======

    /// <summary>
    /// وقت البداية.
    /// Optional start time for hourly units.
    /// </summary>
    [Display(Name = "وقت البداية")]
    public TimeSpan? StartTime { get; set; }

    /// <summary>
    /// وقت النهاية.
    /// Optional end time for hourly units.
    /// </summary>
    [Display(Name = "وقت النهاية")]
    public TimeSpan? EndTime { get; set; }

    /// <summary>
    /// اسم المستخدم الذي أنشأ السجل.
    /// Name of the user who created the record.
    /// </summary>
    [Display(Name = "أنشئ بواسطة")]
    public string? CreatedBy { get; set; }

    /// <summary>
    /// اسم المستخدم الذي عدّل السجل.
    /// Name of the user who last modified the record.
    /// </summary>
    [Display(Name = "عُدّل بواسطة")]
    public string? ModifiedBy { get; set; }
}
