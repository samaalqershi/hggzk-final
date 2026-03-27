// LEGACY: To be removed after full migration to Features structure.
using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Sections;
using YemenBooking.Core.Enums;
using YemenBooking.Application.Features.Sections.DTOs;

namespace YemenBooking.Application.Features.Sections.Commands.ManageSections
{
	/// <summary>
	/// أمر إنشاء القسم.
	/// Create Section command.
	/// </summary>
	public class CreateSectionCommand : IRequest<ResultDto<SectionDto>>
	{
		/// <summary>
		/// النوع.
		/// Type.
		/// </summary>
		public SectionType Type { get; set; }
    /// <summary>
    /// نوع المحتوى.
    /// Content type.
    /// </summary>
    public ContentType ContentType { get; set; }
    /// <summary>
    /// نمط العرض.
    /// Display style.
    /// </summary>
    public DisplayStyle DisplayStyle { get; set; }
    /// <summary>
    /// الاسم.
    /// Name.
    /// </summary>
    public string? Name { get; set; }
    /// <summary>
    /// العنوان.
    /// Title.
    /// </summary>
    public string? Title { get; set; }
    /// <summary>
    /// العنوان الفرعي.
    /// Subtitle.
    /// </summary>
    public string? Subtitle { get; set; }
    /// <summary>
    /// الوصف.
    /// Description.
    /// </summary>
    public string? Description { get; set; }
    /// <summary>
    /// الوصف المختصر.
    /// Short description.
    /// </summary>
    public string? ShortDescription { get; set; }
		/// <summary>
		/// ترتيب العرض.
		/// Display order.
		/// </summary>
		public int DisplayOrder { get; set; }
		/// <summary>
		/// القيمة الخاصة بـ target.
		/// Target value.
		/// </summary>
		public SectionTarget Target { get; set; }
		/// <summary>
		/// يشير إلى ما إذا كان العنصر نشطًا.
		/// Indicates whether the item is active.
		/// </summary>
		public bool IsActive { get; set; } = true;
    /// <summary>
    /// عدد الأعمدة.
    /// Number of columns.
    /// </summary>
    public int ColumnsCount { get; set; } = 2;
    /// <summary>
    /// عدد العناصر المعروضة.
    /// Number of items to show.
    /// </summary>
    public int ItemsToShow { get; set; } = 10;
    /// <summary>
    /// الأيقونة.
    /// Icon.
    /// </summary>
    public string? Icon { get; set; }
    /// <summary>
    /// سمة اللون.
    /// Color theme.
    /// </summary>
    public string? ColorTheme { get; set; }
    /// <summary>
    /// صورة الخلفية.
    /// Background image.
    /// </summary>
    public string? BackgroundImage { get; set; }
    /// <summary>
    /// معايير التصفية.
    /// Filter criteria.
    /// </summary>
    public string? FilterCriteria { get; set; }
    /// <summary>
    /// معايير الفرز.
    /// Sort criteria.
    /// </summary>
    public string? SortCriteria { get; set; }
    /// <summary>
    /// اسم المدينة.
    /// City name.
    /// </summary>
    public string? CityName { get; set; }
    /// <summary>
    /// معرّف نوع العقار.
    /// Property type identifier.
    /// </summary>
    public Guid? PropertyTypeId { get; set; }
    /// <summary>
    /// معرّف نوع الوحدة.
    /// Unit type identifier.
    /// </summary>
    public Guid? UnitTypeId { get; set; }
    /// <summary>
    /// الحد الأدنى للسعر.
    /// Minimum price.
    /// </summary>
    public decimal? MinPrice { get; set; }
    /// <summary>
    /// الحد الأقصى للسعر.
    /// Maximum price.
    /// </summary>
    public decimal? MaxPrice { get; set; }
    /// <summary>
    /// الحد الأدنى للتقييم.
    /// Minimum rating.
    /// </summary>
    public decimal? MinRating { get; set; }
    /// <summary>
    /// يشير إلى ما إذا كان ظاهرًا للضيوف.
    /// Indicates whether it is visible to guests.
    /// </summary>
    public bool IsVisibleToGuests { get; set; } = true;
    /// <summary>
    /// يشير إلى ما إذا كان ظاهرًا للمستخدمين المسجلين.
    /// Indicates whether it is visible to registered users.
    /// </summary>
    public bool IsVisibleToRegistered { get; set; } = true;
    /// <summary>
    /// الصلاحية المطلوبة.
    /// Required permission.
    /// </summary>
    public string? RequiresPermission { get; set; }
    /// <summary>
    /// تاريخ البداية.
    /// Start date.
    /// </summary>
    public DateTime? StartDate { get; set; }
    /// <summary>
    /// تاريخ النهاية.
    /// End date.
    /// </summary>
    public DateTime? EndDate { get; set; }
    /// <summary>
    /// البيانات الوصفية.
    /// Metadata.
    /// </summary>
    public string? Metadata { get; set; }
		/// <summary>
		/// المفتاح المؤقت.
		/// Temporary key.
		/// </summary>
		public string? TempKey { get; set; }
        /// <summary>
        /// تصنيف الفئة.
        /// Classification.
        /// </summary>
        public SectionClass? CategoryClass { get; set; }
        /// <summary>
        /// عدد عناصر الصفحة الرئيسية.
        /// Home items count.
        /// </summary>
        public int? HomeItemsCount { get; set; }
	}
}
