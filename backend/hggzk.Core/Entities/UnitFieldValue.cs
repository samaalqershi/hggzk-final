using System;
using YemenBooking.Core.Interfaces;
using System.ComponentModel.DataAnnotations;

namespace YemenBooking.Core.Entities;

/// <summary>
/// كيان قيم الحقول للوحدات
/// Represents a custom field value assigned to a unit.
/// </summary>
[Display(Name = "كيان قيم الحقول للوحدات")]
public class UnitFieldValue : BaseEntity<Guid>, IFieldValue
{
    /// <summary>
    /// معرف الوحدة.
    /// Identifier of the unit.
    /// </summary>
    [Display(Name = "معرف الوحدة")]
    public Guid UnitId { get; set; }

    /// <summary>
    /// معرف حقل نوع الوحدة.
    /// Identifier of the related unit type field.
    /// </summary>
    [Display(Name = "معرف حقل نوع الوحدة")]
    public Guid UnitTypeFieldId { get; set; }

    /// <summary>
    /// قيمة الحقل.
    /// Field value.
    /// </summary>
    [Display(Name = "قيمة الحقل")]
    public string FieldValue { get; set; } = string.Empty;

    /// <summary>
    /// الوحدة المرتبطة.
    /// Associated unit.
    /// </summary>
    [Display(Name = "الوحدة المرتبطة")]
    public virtual Unit? Unit { get; set; }

    /// <summary>
    /// الحقل المرتبط.
    /// Associated unit type field.
    /// </summary>
    [Display(Name = "الحقل المرتبط")]
    public virtual UnitTypeField? UnitTypeField { get; set; }
} 
