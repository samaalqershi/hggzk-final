using System;
using System.Collections.Generic;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Sections.DTOs {
    /// <summary>
    /// فئة HomeScreenTemplateDto.
    /// HomeScreenTemplateDto class.
    /// </summary>
    public class HomeScreenTemplateDto
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
        /// خاصية Description.
        /// Description property.
        /// </summary>
        public string Description { get; set; }
        /// <summary>
        /// خاصية Version.
        /// Version property.
        /// </summary>
        public string Version { get; set; }
        /// <summary>
        /// خاصية IsActive.
        /// IsActive property.
        /// </summary>
        public bool IsActive { get; set; }
        /// <summary>
        /// خاصية IsDefault.
        /// IsDefault property.
        /// </summary>
        public bool IsDefault { get; set; }
        /// <summary>
        /// خاصية PublishedAt.
        /// PublishedAt property.
        /// </summary>
        public DateTime? PublishedAt { get; set; }
        /// <summary>
        /// خاصية PublishedBy.
        /// PublishedBy property.
        /// </summary>
        public Guid? PublishedBy { get; set; }
        /// <summary>
        /// خاصية PublishedByName.
        /// PublishedByName property.
        /// </summary>
        public string PublishedByName { get; set; }
        /// <summary>
        /// خاصية Platform.
        /// Platform property.
        /// </summary>
        public string Platform { get; set; }
        /// <summary>
        /// خاصية TargetAudience.
        /// TargetAudience property.
        /// </summary>
        public string TargetAudience { get; set; }
        /// <summary>
        /// خاصية MetaData.
        /// MetaData property.
        /// </summary>
        public string MetaData { get; set; }
        /// <summary>
        /// خاصية CustomizationData.
        /// CustomizationData property.
        /// </summary>
        public string CustomizationData { get; set; }
        /// <summary>
        /// خاصية UserPreferences.
        /// UserPreferences property.
        /// </summary>
        public string UserPreferences { get; set; }
        /// <summary>
        /// خاصية CreatedAt.
        /// CreatedAt property.
        /// </summary>
        public DateTime CreatedAt { get; set; }
        /// <summary>
        /// خاصية UpdatedAt.
        /// UpdatedAt property.
        /// </summary>
        public DateTime? UpdatedAt { get; set; }
        /// <summary>
        /// خاصية Sections.
        /// Sections property.
        /// </summary>
        public List<HomeScreenSectionDto> Sections { get; set; }
    }
}