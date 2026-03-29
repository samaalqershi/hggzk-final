namespace YemenBooking.Core.Entities;

using System;
using YemenBooking.Core.ValueObjects;
using System.Collections.Generic;
using YemenBooking.Core.Enums;
using System.ComponentModel.DataAnnotations;

/// <summary>
/// كيان الوحدة
/// Represents a rentable unit within a property.
/// </summary>
[Display(Name = "كيان الوحدة")]
public class Unit : BaseEntity<Guid>
{
    /// <summary>
    /// معرف العقار المرتبط.
    /// Identifier of the associated property.
    /// </summary>
    [Display(Name = "معرف الكيان")]
    public Guid PropertyId { get; set; }
    
    /// <summary>
    /// معرف نوع الوحدة.
    /// Identifier of the unit type.
    /// </summary>
    [Display(Name = "معرف نوع الوحدة")]
    public Guid UnitTypeId { get; set; }
    
    /// <summary>
    /// اسم الوحدة.
    /// Unit name, such as "Unit A" or "Royal Suite".
    /// </summary>
    [Display(Name = "اسم الوحدة")]
    public string Name { get; set; }

    /// <summary>
    /// اسم الوحدة باللغة الإنجليزية.
    /// English unit name.
    /// </summary>
    [Display(Name = "اسم الوحدة بالإنجليزية")]
    public string? NameEn { get; set; }
    
    /// <summary>
    /// السعة القصوى للوحدة.
    /// Maximum guest capacity for the unit.
    /// </summary>
    [Display(Name = "السعة القصوى للوحدة")]
    public int MaxCapacity { get; set; }
    
    /// <summary>
    /// نسبة الخصم الافتراضية للوحدة.
    /// Default discount percentage for the unit, from 0 to 100.
    /// </summary>
    public decimal DiscountPercentage { get; set; } = 0;
    
    /// <summary>
    /// الميزات المخصصة للوحدة بصيغة JSON.
    /// Custom unit features stored as JSON.
    /// </summary>
    [Display(Name = "الميزات المخصصة للوحدة")]
    public string CustomFeatures { get; set; } = "{}";

    /// <summary>
    /// الميزات المخصصة للوحدة باللغة الإنجليزية بصيغة JSON.
    /// English custom features stored as JSON.
    /// </summary>
    [Display(Name = "الميزات المخصصة للوحدة بالإنجليزية")]
    public string? CustomFeaturesEn { get; set; }

    /// <summary>
    /// عدد مرات المشاهدة.
    /// Number of views.
    /// </summary>
    [Display(Name = "عدد مرات المشاهدة")]
    public int ViewCount { get; set; } = 0;

    /// <summary>
    /// عدد الحجوزات.
    /// Number of bookings.
    /// </summary>
    [Display(Name = "عدد الحجوزات")]
    public int BookingCount { get; set; } = 0;
    
    /// <summary>
    /// يحدد ما إذا كانت الوحدة تسمح بإلغاء الحجز.
    /// Indicates whether the unit allows booking cancellation.
    /// </summary>
    [Display(Name = "تقبل إلغاء الحجز")]
    public bool AllowsCancellation { get; set; } = true;

    /// <summary>
    /// عدد أيام السماح بالإلغاء قبل الوصول.
    /// Number of days before check-in during which cancellation is allowed.
    /// </summary>
    [Display(Name = "أيام نافذة الإلغاء قبل الوصول")]
    public int? CancellationWindowDays { get; set; }

    /// <summary>
    /// سعة البالغين.
    /// Maximum number of adults.
    /// </summary>
    [Display(Name = "سعة البالغين")]
    public int? AdultsCapacity { get; set; }

    /// <summary>
    /// سعة الأطفال.
    /// Maximum number of children.
    /// </summary>
    [Display(Name = "سعة الأطفال")]
    public int? ChildrenCapacity { get; set; }

    /// <summary>
    /// العقار المرتبط بالوحدة.
    /// Property associated with the unit.
    /// </summary>
    [Display(Name = "الكيان المرتبط بالوحدة")]
    public virtual Property Property { get; set; }
    
    /// <summary>
    /// نوع الوحدة المرتبط.
    /// Associated unit type.
    /// </summary>
    [Display(Name = "نوع الوحدة المرتبط")]
    public virtual UnitType UnitType { get; set; }
    
    /// <summary>
    /// الحجوزات المرتبطة بالوحدة.
    /// Bookings associated with the unit.
    /// </summary>
    [Display(Name = "الحجوزات المرتبطة بالوحدة")]
    public virtual ICollection<Booking> Bookings { get; set; } = new List<Booking>();
    
    /// <summary>
    /// الصور المرتبطة بالوحدة.
    /// Images associated with the unit.
    /// </summary>
    [Display(Name = "الصور المرتبطة بالوحدة")]
    public virtual ICollection<PropertyImage> Images { get; set; } = new List<PropertyImage>();

    /// <summary>
    /// الجدول اليومي الموحد للوحدة.
    /// Daily schedule for the unit, combining pricing and availability.
    /// </summary>
    [Display(Name = "الجدول اليومي الموحد للوحدة")]
    public virtual ICollection<DailyUnitSchedule> DailySchedules { get; set; } = new List<DailyUnitSchedule>();

    /// <summary>
    /// قيم الحقول الخاصة بالوحدة.
    /// Custom field values associated with this unit.
    /// </summary>
    [Display(Name = "قيم الحقول الخاصة بالوحدة")]
    public virtual ICollection<UnitFieldValue> FieldValues { get; set; } = new List<UnitFieldValue>();

    /// <summary>
    /// طريقة احتساب السعر.
    /// Pricing calculation method such as hourly, daily, weekly, or monthly.
    /// </summary>
    [Display(Name = "طريقة حساب السعر")]
    public PricingMethod PricingMethod { get; set; }

    // Legacy SectionItems removed in favor of rich entities UnitInSection

    /// <summary>
    /// سجلات الربط الغنية بين الوحدة والأقسام.
    /// Rich linkage records between the unit and sections.
    /// </summary>
    public virtual ICollection<UnitInSection> UnitInSections { get; set; } = new List<UnitInSection>();

} 
