namespace YemenBooking.Core.Entities;

using System;
using YemenBooking.Core.ValueObjects;
using System.Collections.Generic;
using YemenBooking.Core.Enums;
using System.ComponentModel.DataAnnotations;

/// <summary>
/// يمثل خدمة إضافية يمكن تقديمها ضمن العقار مع نموذج تسعيرها ومعلوماتها التشغيلية.
/// Represents an add-on service offered by the property with pricing and operational details.
/// </summary>
[Display(Name = "كيان خدمة الكيان")]
public class PropertyService : BaseEntity<Guid>
{
    /// <summary>
    /// معرّف العقار الذي تقدم هذه الخدمة ضمنه.
    /// Identifier of the property that offers this service.
    /// </summary>
    [Display(Name = "معرف الكيان")]
    public Guid PropertyId { get; set; }
    
    /// <summary>
    /// اسم الخدمة كما يظهر للمستخدم.
    /// Display name of the service.
    /// </summary>
    [Display(Name = "اسم الخدمة")]
    public string Name { get; set; }
    
    /// <summary>
    /// سعر الخدمة وفق العملة المعتمدة.
    /// Service price in the configured currency.
    /// </summary>
    [Display(Name = "سعر الخدمة")]
    public Money Price { get; set; }
    
    /// <summary>
    /// وصف يوضح ما تتضمنه الخدمة.
    /// Description explaining what the service includes.
    /// </summary>
    public string? Description { get; set; }

    /// <summary>
    /// الأيقونة المستخدمة لتمثيل الخدمة.
    /// Icon used to represent the service.
    /// </summary>
    public string Icon { get; set; } = string.Empty;

    /// <summary>
    /// نموذج التسعير المعتمد للخدمة.
    /// Pricing model applied to the service.
    /// </summary>
    [Display(Name = "نموذج التسعير")]
    public PricingModel PricingModel { get; set; }
    
    /// <summary>
    /// المرجع الملاحي إلى العقار المرتبط بالخدمة.
    /// Navigation reference to the property associated with the service.
    /// </summary>
    [Display(Name = "الكيان المرتبط بالخدمة")]
    public virtual Property Property { get; set; }
    
    /// <summary>
    /// الحجوزات التي تضمنت هذه الخدمة.
    /// Bookings that included this service.
    /// </summary>
    [Display(Name = "الحجوزات المرتبطة بهذه الخدمة")]
    public virtual ICollection<BookingService> BookingServices { get; set; } = new List<BookingService>();
} 
