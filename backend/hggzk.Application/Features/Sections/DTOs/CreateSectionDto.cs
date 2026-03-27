using System;
using YemenBooking.Core.Enums;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Sections.DTOs {
    /// <summary>
    /// فئة CreateSectionDto.
    /// CreateSectionDto class.
    /// </summary>
    public class CreateSectionDto
    {
        /// <summary>
        /// خاصية Type.
        /// Type property.
        /// </summary>
        public SectionType Type { get; set; }
        /// <summary>
        /// خاصية ContentType.
        /// ContentType property.
        /// </summary>
        public ContentType ContentType { get; set; }
        /// <summary>
        /// خاصية DisplayStyle.
        /// DisplayStyle property.
        /// </summary>
        public DisplayStyle DisplayStyle { get; set; }
        /// <summary>
        /// خاصية Name.
        /// Name property.
        /// </summary>
        public string? Name { get; set; }
        /// <summary>
        /// خاصية Title.
        /// Title property.
        /// </summary>
        public string? Title { get; set; }
        /// <summary>
        /// خاصية Subtitle.
        /// Subtitle property.
        /// </summary>
        public string? Subtitle { get; set; }
        /// <summary>
        /// خاصية Description.
        /// Description property.
        /// </summary>
        public string? Description { get; set; }
        /// <summary>
        /// خاصية ShortDescription.
        /// ShortDescription property.
        /// </summary>
        public string? ShortDescription { get; set; }
        /// <summary>
        /// خاصية DisplayOrder.
        /// DisplayOrder property.
        /// </summary>
        public int DisplayOrder { get; set; }
        /// <summary>
        /// خاصية Target.
        /// Target property.
        /// </summary>
        public SectionTarget Target { get; set; }
        /// <summary>
        /// خاصية IsActive.
        /// IsActive property.
        /// </summary>
        public bool IsActive { get; set; } = true;
        /// <summary>
        /// خاصية ColumnsCount.
        /// ColumnsCount property.
        /// </summary>
        public int ColumnsCount { get; set; } = 2;
        /// <summary>
        /// خاصية ItemsToShow.
        /// ItemsToShow property.
        /// </summary>
        public int ItemsToShow { get; set; } = 10;
        /// <summary>
        /// خاصية Icon.
        /// Icon property.
        /// </summary>
        public string? Icon { get; set; }
        /// <summary>
        /// خاصية ColorTheme.
        /// ColorTheme property.
        /// </summary>
        public string? ColorTheme { get; set; }
        /// <summary>
        /// خاصية BackgroundImage.
        /// BackgroundImage property.
        /// </summary>
        public string? BackgroundImage { get; set; }
        /// <summary>
        /// خاصية FilterCriteria.
        /// FilterCriteria property.
        /// </summary>
        public string? FilterCriteria { get; set; }
        /// <summary>
        /// خاصية SortCriteria.
        /// SortCriteria property.
        /// </summary>
        public string? SortCriteria { get; set; }
        /// <summary>
        /// خاصية CityName.
        /// CityName property.
        /// </summary>
        public string? CityName { get; set; }
        /// <summary>
        /// خاصية PropertyTypeId.
        /// PropertyTypeId property.
        /// </summary>
        public Guid? PropertyTypeId { get; set; }
        /// <summary>
        /// خاصية UnitTypeId.
        /// UnitTypeId property.
        /// </summary>
        public Guid? UnitTypeId { get; set; }
        /// <summary>
        /// خاصية MinPrice.
        /// MinPrice property.
        /// </summary>
        public decimal? MinPrice { get; set; }
        /// <summary>
        /// خاصية MaxPrice.
        /// MaxPrice property.
        /// </summary>
        public decimal? MaxPrice { get; set; }
        /// <summary>
        /// خاصية MinRating.
        /// MinRating property.
        /// </summary>
        public decimal? MinRating { get; set; }
        /// <summary>
        /// خاصية IsVisibleToGuests.
        /// IsVisibleToGuests property.
        /// </summary>
        public bool IsVisibleToGuests { get; set; } = true;
        /// <summary>
        /// خاصية IsVisibleToRegistered.
        /// IsVisibleToRegistered property.
        /// </summary>
        public bool IsVisibleToRegistered { get; set; } = true;
        /// <summary>
        /// خاصية RequiresPermission.
        /// RequiresPermission property.
        /// </summary>
        public string? RequiresPermission { get; set; }
        /// <summary>
        /// خاصية StartDate.
        /// StartDate property.
        /// </summary>
        public DateTime? StartDate { get; set; }
        /// <summary>
        /// خاصية EndDate.
        /// EndDate property.
        /// </summary>
        public DateTime? EndDate { get; set; }
        /// <summary>
        /// خاصية Metadata.
        /// Metadata property.
        /// </summary>
        public string? Metadata { get; set; }
    }
}

