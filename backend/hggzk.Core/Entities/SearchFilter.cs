using System;
using System.ComponentModel.DataAnnotations;

namespace YemenBooking.Core.Entities;

/// <summary>
/// يمثل فلتر بحث لحقل ديناميكي.
/// Represents a search filter for a dynamic field.
/// </summary>
[Display(Name = "كيان فلاتر البحث")]
public class SearchFilter : BaseEntity<Guid>
{
    /// <summary>
    /// معرف الحقل المرتبط.
    /// Linked field identifier.
    /// </summary>
    [Display(Name = "معرف الحقل المرتبط")]
    public Guid FieldId { get; set; }

    /// <summary>
    /// نوع الفلتر مثل range أو exact.
    /// Filter type such as range or exact.
    /// </summary>
    [Display(Name = "نوع الفلتر")]
    public string FilterType { get; set; }

    /// <summary>
    /// الاسم المعروض للمستخدم.
    /// Label shown to users.
    /// </summary>
    [Display(Name = "الاسم المعروض للفلتر")]
    public string DisplayName { get; set; }

    /// <summary>
    /// خيارات الفلتر بصيغة JSON.
    /// Filter options in JSON.
    /// </summary>
    [Display(Name = "خيارات إضافية للفلتر")]
    public string FilterOptions { get; set; }

    /// <summary>
    /// يحدد ما إذا كان الفلتر مفعلاً.
    /// Whether the filter is enabled.
    /// </summary>
    [Display(Name = "حالة تفعيل الفلتر")]
    public bool IsActive { get; set; }

    /// <summary>
    /// ترتيب ظهور الفلتر.
    /// Display order of the filter.
    /// </summary>
    [Display(Name = "ترتيب عرض الفلتر")]
    public int SortOrder { get; set; }

    /// <summary>
    /// الحقل المرتبط بهذا الفلتر.
    /// Field linked to this filter.
    /// </summary>
    [Display(Name = "علاقة الحقل المرتبط")]
    public virtual UnitTypeField UnitTypeField { get; set; }
} 
