using System;
using System.Collections.Generic;

namespace YemenBooking.Application.Features.Reviews.DTOs {
    /// <summary>
    /// فئة HomeScreenPreviewDto.
    /// HomeScreenPreviewDto class.
    /// </summary>
    public class HomeScreenPreviewDto
    {
        /// <summary>
        /// خاصية TemplateId.
        /// TemplateId property.
        /// </summary>
        public Guid TemplateId { get; set; }
        /// <summary>
        /// خاصية TemplateName.
        /// TemplateName property.
        /// </summary>
        public string TemplateName { get; set; }
        /// <summary>
        /// خاصية Platform.
        /// Platform property.
        /// </summary>
        public string Platform { get; set; }
        /// <summary>
        /// خاصية DeviceType.
        /// DeviceType property.
        /// </summary>
        public string DeviceType { get; set; }
        /// <summary>
        /// خاصية Sections.
        /// Sections property.
        /// </summary>
        public List<HomeScreenSectionPreviewDto> Sections { get; set; }
        /// <summary>
        /// خاصية Metadata.
        /// Metadata property.
        /// </summary>
        public PreviewMetadata Metadata { get; set; }
    }

    /// <summary>
    /// فئة HomeScreenSectionPreviewDto.
    /// HomeScreenSectionPreviewDto class.
    /// </summary>
    public class HomeScreenSectionPreviewDto
    {
        /// <summary>
        /// خاصية Id.
        /// Id property.
        /// </summary>
        public Guid Id { get; set; }
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
        /// خاصية Styles.
        /// Styles property.
        /// </summary>
        public Dictionary<string, string> Styles { get; set; }
        /// <summary>
        /// خاصية Components.
        /// Components property.
        /// </summary>
        public List<HomeScreenComponentPreviewDto> Components { get; set; }
    }

    /// <summary>
    /// فئة HomeScreenComponentPreviewDto.
    /// HomeScreenComponentPreviewDto class.
    /// </summary>
    public class HomeScreenComponentPreviewDto
    {
        /// <summary>
        /// خاصية Id.
        /// Id property.
        /// </summary>
        public Guid Id { get; set; }
        /// <summary>
        /// خاصية Type.
        /// Type property.
        /// </summary>
        public string Type { get; set; }
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
        /// خاصية PropertyDto.
        /// PropertyDto property.
        /// </summary>
        public Dictionary<string, object> PropertyDto { get; set; }
        /// <summary>
        /// خاصية Styles.
        /// Styles property.
        /// </summary>
        public Dictionary<string, string> Styles { get; set; }
        /// <summary>
        /// خاصية Data.
        /// Data property.
        /// </summary>
        public object Data { get; set; }
        /// <summary>
        /// خاصية Animation.
        /// Animation property.
        /// </summary>
        public AnimationConfig Animation { get; set; }
    }

    /// <summary>
    /// فئة AnimationConfig.
    /// AnimationConfig class.
    /// </summary>
    public class AnimationConfig
    {
        /// <summary>
        /// خاصية Type.
        /// Type property.
        /// </summary>
        public string Type { get; set; }
        /// <summary>
        /// خاصية Duration.
        /// Duration property.
        /// </summary>
        public int Duration { get; set; }
        /// <summary>
        /// خاصية Delay.
        /// Delay property.
        /// </summary>
        public int Delay { get; set; }
        /// <summary>
        /// خاصية Easing.
        /// Easing property.
        /// </summary>
        public string Easing { get; set; }
    }

    /// <summary>
    /// فئة PreviewMetadata.
    /// PreviewMetadata class.
    /// </summary>
    public class PreviewMetadata
    {
        /// <summary>
        /// خاصية GeneratedAt.
        /// GeneratedAt property.
        /// </summary>
        public DateTime GeneratedAt { get; set; }
        /// <summary>
        /// خاصية TotalSections.
        /// TotalSections property.
        /// </summary>
        public int TotalSections { get; set; }
        /// <summary>
        /// خاصية TotalComponents.
        /// TotalComponents property.
        /// </summary>
        public int TotalComponents { get; set; }
        /// <summary>
        /// خاصية EstimatedLoadTime.
        /// EstimatedLoadTime property.
        /// </summary>
        public int EstimatedLoadTime { get; set; }
        /// <summary>
        /// خاصية UsedMockData.
        /// UsedMockData property.
        /// </summary>
        public bool UsedMockData { get; set; }
    }
}