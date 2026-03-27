namespace YemenBooking.Core.Entities;

using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using YemenBooking.Core.Enums;

/// <summary>
/// يمثل قسماً يعرض محتوى مميزاً داخل الواجهة.
/// Represents a curated section displayed in the UI.
/// </summary>
[Display(Name = "كيان القسم")]
public class Section : BaseEntity<Guid>
{
	/// <summary>
	/// الاسم الداخلي للقسم.
	/// Internal section name.
	/// </summary>
	[Display(Name = "اسم القسم")]
	public string? Name { get; set; }

	/// <summary>
	/// عنوان القسم الظاهر للمستخدم.
	/// Displayed section title.
	/// </summary>
	[Display(Name = "عنوان القسم")]
	public string? Title { get; set; }

	/// <summary>
	/// النص الفرعي المساند للعنوان.
	/// Supporting subtitle text.
	/// </summary>
	[Display(Name = "العنوان الفرعي")]
	public string? Subtitle { get; set; }

	/// <summary>
	/// الوصف الكامل للقسم.
	/// Full section description.
	/// </summary>
	[Display(Name = "الوصف")]
	public string? Description { get; set; }

	/// <summary>
	/// وصف مختصر للقسم.
	/// Short section description.
	/// </summary>
	[Display(Name = "الوصف المختصر")]
	public string? ShortDescription { get; set; }

	/// <summary>
	/// نوع القسم.
	/// Section type.
	/// </summary>
	[Display(Name = "نوع القسم")]
	public SectionType Type { get; set; }

	/// <summary>
	/// نوع المحتوى الذي يعرضه القسم.
	/// Content type displayed by the section.
	/// </summary>
	[Display(Name = "نوع المحتوى")]
	public ContentType ContentType { get; set; } = ContentType.Properties;

	/// <summary>
	/// نمط العرض المستخدم داخل القسم.
	/// Layout used to render the section.
	/// </summary>
	[Display(Name = "نمط العرض")]
	public DisplayStyle DisplayStyle { get; set; } = DisplayStyle.Grid;

	/// <summary>
	/// عدد الأعمدة في العرض الشبكي.
	/// Number of columns in grid layout.
	/// </summary>
	[Display(Name = "عدد الأعمدة")]
	public int ColumnsCount { get; set; } = 2;

	/// <summary>
	/// الحد الافتراضي لعدد العناصر المعروضة.
	/// Default number of visible items.
	/// </summary>
	[Display(Name = "عدد العناصر للعرض")]
	public int ItemsToShow { get; set; } = 10;

	/// <summary>
	/// ترتيب ظهور القسم.
	/// Section display order.
	/// </summary>
	[Display(Name = "ترتيب القسم")]
	public int DisplayOrder { get; set; }

	/// <summary>
	/// الجهة المستهدفة بالقسم.
	/// Target of the section: properties or units.
	/// </summary>
	[Display(Name = "هدف القسم")] 
	public SectionTarget Target { get; set; }

	/// <summary>
	/// أيقونة القسم.
	/// Section icon.
	/// </summary>
	[Display(Name = "أيقونة القسم")]
	public string? Icon { get; set; }

	/// <summary>
	/// لون الهوية البصرية للقسم.
	/// Section color theme.
	/// </summary>
	[Display(Name = "لون القسم")]
	public string? ColorTheme { get; set; }

	/// <summary>
	/// صورة الخلفية.
	/// Background image.
	/// </summary>
	[Display(Name = "صورة الخلفية")]
	public string? BackgroundImage { get; set; }

	/// <summary>
	/// معرف صورة الخلفية في جدول الصور الموحد.
	/// Background image ID in the shared image table.
	/// </summary>
	[Display(Name = "معرف صورة الخلفية")]
	public Guid? BackgroundImageId { get; set; }

	/// <summary>
	/// معايير الفلترة بصيغة JSON.
	/// Filtering criteria in JSON.
	/// </summary>
	[Display(Name = "معايير الفلترة (JSON)")]
	public string? FilterCriteria { get; set; }

	/// <summary>
	/// معايير الترتيب بصيغة JSON.
	/// Sorting criteria in JSON.
	/// </summary>
	[Display(Name = "معايير الترتيب (JSON)")]
	public string? SortCriteria { get; set; }

	/// <summary>
	/// اسم المدينة المرتبطة بالقسم.
	/// City name linked to the section.
	/// </summary>
	[Display(Name = "اسم المدينة")]
	public string? CityName { get; set; }

	/// <summary>
	/// معرف نوع العقار.
	/// Property type ID.
	/// </summary>
	[Display(Name = "معرف نوع العقار")]
	public Guid? PropertyTypeId { get; set; }

	/// <summary>
	/// معرف نوع الوحدة.
	/// Unit type ID.
	/// </summary>
	[Display(Name = "معرف نوع الوحدة")]
	public Guid? UnitTypeId { get; set; }

	/// <summary>
	/// الحد الأدنى للسعر.
	/// Minimum price.
	/// </summary>
	[Display(Name = "نطاق السعر الأدنى")]
	public decimal? MinPrice { get; set; }

	/// <summary>
	/// الحد الأعلى للسعر.
	/// Maximum price.
	/// </summary>
	[Display(Name = "نطاق السعر الأعلى")]
	public decimal? MaxPrice { get; set; }

	/// <summary>
	/// الحد الأدنى للتقييم.
	/// Minimum rating.
	/// </summary>
	[Display(Name = "التقييم الأدنى")]
	public decimal? MinRating { get; set; }

	/// <summary>
	/// يحدد ما إذا كان القسم يظهر للزوار.
	/// Whether the section is visible to guests.
	/// </summary>
	[Display(Name = "مرئي للضيوف")]
	public bool IsVisibleToGuests { get; set; } = true;

	/// <summary>
	/// يحدد ما إذا كان القسم يظهر للمستخدمين المسجلين.
	/// Whether the section is visible to signed-in users.
	/// </summary>
	[Display(Name = "مرئي للمستخدمين المسجلين")]
	public bool IsVisibleToRegistered { get; set; } = true;

	/// <summary>
	/// اسم الصلاحية المطلوبة لعرض القسم.
	/// Permission required to view the section.
	/// </summary>
	[Display(Name = "يتطلب صلاحيات خاصة")]
	public string? RequiresPermission { get; set; }

	/// <summary>
	/// تاريخ بدء إظهار القسم.
	/// Start date for showing the section.
	/// </summary>
	[Display(Name = "تاريخ البداية")]
	public DateTime? StartDate { get; set; }

	/// <summary>
	/// تاريخ انتهاء إظهار القسم.
	/// End date for showing the section.
	/// </summary>
	[Display(Name = "تاريخ النهاية")]
	public DateTime? EndDate { get; set; }

	/// <summary>
	/// بيانات إضافية بصيغة JSON.
	/// Additional metadata in JSON.
	/// </summary>
	[Display(Name = "الميتاداتا (JSON)")]
	public string? Metadata { get; set; }

    /// <summary>
    /// تصنيف القسم مثل A أو B أو C أو D.
    /// Section class such as A, B, C, or D.
    /// </summary>
    [Display(Name = "فئة القسم")]
    public SectionClass? CategoryClass { get; set; }

    /// <summary>
    /// عدد العناصر المخصصة للصفحة الرئيسية.
    /// Number of items reserved for the home page.
    /// </summary>
    [Display(Name = "عدد عناصر الصفحة الرئيسية")]
    public int? HomeItemsCount { get; set; }

    /// <summary>
    /// العقارات المرتبطة بهذا القسم.
    /// Properties linked to this section.
    /// </summary>
    [Display(Name = "قائمة العقارات في القسم")]
    public virtual ICollection<PropertyInSection> PropertyItems { get; set; } = new List<PropertyInSection>();

	/// <summary>
	/// الوحدات المرتبطة بهذا القسم.
	/// Units linked to this section.
	/// </summary>
    [Display(Name = "قائمة الوحدات في القسم")]
	public virtual ICollection<UnitInSection> UnitItems { get; set; } = new List<UnitInSection>();

	/// <summary>
    /// الصور المرتبطة بهذا القسم.
    /// Images linked to this section.
	/// </summary>
	[Display(Name = "صور القسم")]
    public virtual ICollection<SectionImage> Images { get; set; } = new List<SectionImage>();
}
