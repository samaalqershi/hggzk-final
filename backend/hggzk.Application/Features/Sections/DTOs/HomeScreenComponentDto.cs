using System;
using System.Collections.Generic;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Properties.DTOs;

namespace YemenBooking.Application.Features.Sections.DTOs {
    /// <summary>
    /// فئة HomeScreenComponentDto.
    /// HomeScreenComponentDto class.
    /// </summary>
    public class HomeScreenComponentDto
    {
        /// <summary>
        /// خاصية Id.
        /// Id property.
        /// </summary>
        public Guid Id { get; set; }
        /// <summary>
        /// خاصية SectionId.
        /// SectionId property.
        /// </summary>
        public Guid SectionId { get; set; }
        /// <summary>
        /// خاصية ComponentType.
        /// ComponentType property.
        /// </summary>
        public string ComponentType { get; set; }
        /// <summary>
        /// خاصية Name.
        /// Name property.
        /// </summary>
        public string Name { get; set; }
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
        /// خاصية ColSpan.
        /// ColSpan property.
        /// </summary>
        public int ColSpan { get; set; }
        /// <summary>
        /// خاصية RowSpan.
        /// RowSpan property.
        /// </summary>
        public int RowSpan { get; set; }
        /// <summary>
        /// خاصية Alignment.
        /// Alignment property.
        /// </summary>
        public string Alignment { get; set; }
        /// <summary>
        /// خاصية CustomClasses.
        /// CustomClasses property.
        /// </summary>
        public string CustomClasses { get; set; }
        /// <summary>
        /// خاصية AnimationType.
        /// AnimationType property.
        /// </summary>
        public string AnimationType { get; set; }
        /// <summary>
        /// خاصية AnimationDuration.
        /// AnimationDuration property.
        /// </summary>
        public int AnimationDuration { get; set; }
        /// <summary>
        /// خاصية Conditions.
        /// Conditions property.
        /// </summary>
        public string Conditions { get; set; }
        /// <summary>
        /// خاصية PropertyDto.
        /// PropertyDto property.
        /// </summary>
        public List<ComponentPropertyDto> PropertyDto { get; set; }
        /// <summary>
        /// خاصية Styles.
        /// Styles property.
        /// </summary>
        public List<ComponentStyleDto> Styles { get; set; }
        /// <summary>
        /// خاصية Actions.
        /// Actions property.
        /// </summary>
        public List<ComponentActionDto> Actions { get; set; }
        /// <summary>
        /// خاصية DataSource.
        /// DataSource property.
        /// </summary>
        public ComponentDataSourceDto DataSource { get; set; }
    }
}