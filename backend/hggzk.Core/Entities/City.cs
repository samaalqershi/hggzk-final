namespace YemenBooking.Core.Entities;

using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

/// <summary>
/// مدينة يمكن ربطها بالعقارات والصور.
/// City linked to properties and images.
/// </summary>
[Display(Name = "كيان المدينة")]
public class City
{
    /// <summary>
    /// اسم المدينة، وهو المفتاح الأساسي.
    /// City name, used as the primary key.
    /// </summary>
    [Key]
    public string Name { get; set; }

    /// <summary>
    /// الاسم الإنجليزي للمدينة.
    /// English city name.
    /// </summary>
    public string? NameEn { get; set; }

    /// <summary>
    /// الدولة.
    /// Country name.
    /// </summary>
    public string Country { get; set; }

    /// <summary>
    /// اسم الدولة باللغة الإنجليزية.
    /// English country name.
    /// </summary>
    public string? CountryEn { get; set; }

    /// <summary>
    /// روابط الصور المخزنة بصيغة JSON.
    /// Stored image URLs as JSON.
    /// </summary>
    public string ImagesJson { get; set; } = "[]";

    /// <summary>
    /// العقارات الموجودة في هذه المدينة.
    /// Properties located in this city.
    /// </summary>
    public virtual ICollection<Property> Properties { get; set; } = new List<Property>();

    /// <summary>
    /// الصور المرتبطة بالمدينة عبر جدول الصور المشترك.
    /// Images associated with this city through the shared images table.
    /// </summary>
    public virtual ICollection<PropertyImage> Images { get; set; } = new List<PropertyImage>();
}
