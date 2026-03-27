namespace YemenBooking.Core.Entities;

using System;
using System.ComponentModel.DataAnnotations;
using YemenBooking.Core.ValueObjects;

/// <summary>
/// يمثل خدمة إضافية تم ربطها بحجز محدد مع الكمية والتكلفة الإجمالية الناتجة عنها.
/// Represents an add-on service attached to a specific booking together with its quantity and resulting total cost.
/// </summary>
[Display(Name = "كيان خدمة الحجز")]
public class BookingService : BaseEntity<Guid>
{
    /// <summary>
    /// يحدد الحجز الذي أضيفت هذه الخدمة ضمنه.
    /// Identifies the booking to which this service entry was added.
    /// </summary>
    [Display(Name = "معرف الحجز")]
    public Guid BookingId { get; set; }
    
    /// <summary>
    /// يحدد الخدمة الأصلية المقدمة ضمن هذا السجل.
    /// Identifies the source service being referenced by this record.
    /// </summary>
    [Display(Name = "معرف الخدمة")]
    public Guid ServiceId { get; set; }
    
    /// <summary>
    /// يوضح عدد الوحدات أو مرات تنفيذ الخدمة داخل هذا الحجز.
    /// Specifies how many units or occurrences of the service are included in the booking.
    /// </summary>
    [Display(Name = "الكمية")]
    public int Quantity { get; set; }
    
    /// <summary>
    /// يحتفظ بالتكلفة الإجمالية للخدمة بعد احتساب الكمية والتسعير المعتمد.
    /// Stores the total service cost after applying the selected quantity and pricing rules.
    /// </summary>
    [Display(Name = "السعر الإجمالي للخدمة")]
    public Money TotalPrice { get; set; }
    
    /// <summary>
    /// يوفر مرجع التنقل إلى الحجز الذي يملك هذا السجل الخدمي.
    /// Provides navigation to the booking that owns this service entry.
    /// </summary>
    [Display(Name = "الحجز المرتبط بخدمة الحجز")]
    public virtual Booking Booking { get; set; }
    
    /// <summary>
    /// يوفر مرجع التنقل إلى تعريف الخدمة الأصلي القابل لإعادة الاستخدام.
    /// Provides navigation to the reusable source service definition.
    /// </summary>
    [Display(Name = "الخدمة المرتبطة بخدمة الحجز")]
    public virtual PropertyService Service { get; set; }
} 
