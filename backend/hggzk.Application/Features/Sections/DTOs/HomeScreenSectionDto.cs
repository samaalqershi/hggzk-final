using System;
using System.Collections.Generic;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Sections.DTOs {
    /// <summary>
    /// فئة HomeScreenSectionDto.
    /// HomeScreenSectionDto class.
    /// </summary>
    public class HomeScreenSectionDto
    {
        /// <summary>
        /// خاصية Id.
        /// Id property.
        /// </summary>
        public Guid Id { get; set; }
        /// <summary>
        /// خاصية TemplateId.
        /// TemplateId property.
        /// </summary>
        public Guid TemplateId { get; set; }
        /// <summary>
        /// خاصية Name.
        /// Name property.
        /// </summary>
        public string Name { get; set; }
        /// <summary>
        /// خاصية Title.
        /// Title property.
        /// </summary>
        public string Title { get; set; }
        /// <summary>
        /// خاصية Subtitle.
        /// Subtitle property.
        /// </summary>
        public string Subtitle { get; set; }
        /// <summary>
        /// خاصية Order.
        /// Order property.
        /// </summary>
        public int Order { get; set; }
        /// <summary>
        /// خاصية IsVisible.
        /// IsVisible property.
        /// </summary>
        public bool IsVisible { get; set; }
        /// <summary>
        /// خاصية BackgroundColor.
        /// BackgroundColor property.
        /// </summary>
        public string BackgroundColor { get; set; }
        /// <summary>
        /// خاصية BackgroundImage.
        /// BackgroundImage property.
        /// </summary>
        public string BackgroundImage { get; set; }
        /// <summary>
        /// خاصية Padding.
        /// Padding property.
        /// </summary>
        public string Padding { get; set; }
        /// <summary>
        /// خاصية Margin.
        /// Margin property.
        /// </summary>
        public string Margin { get; set; }
        /// <summary>
        /// خاصية MinHeight.
        /// MinHeight property.
        /// </summary>
        public int MinHeight { get; set; }
        /// <summary>
        /// خاصية MaxHeight.
        /// MaxHeight property.
        /// </summary>
        public int MaxHeight { get; set; }
        /// <summary>
        /// خاصية CustomStyles.
        /// CustomStyles property.
        /// </summary>
        public string CustomStyles { get; set; }
        /// <summary>
        /// خاصية Conditions.
        /// Conditions property.
        /// </summary>
        public string Conditions { get; set; }
        /// <summary>
        /// خاصية Components.
        /// Components property.
        /// </summary>
        public List<HomeScreenComponentDto> Components { get; set; }
    }
}