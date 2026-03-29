using System;
using System.Collections.Generic;
using YemenBooking.Application.Features.Units.DTOs;

namespace YemenBooking.Application.Features.PropertyTypes.DTOs
{
    /// <summary>
    /// نوع العقار مع أنواع الوحدات التابعة له
    /// Property type with its unit types
    /// </summary>
    public class PropertyTypeWithUnitsDto
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
        public string Name { get; set; } = string.Empty;
        /// <summary>
        /// خاصية Description.
        /// Description property.
        /// </summary>
        public string Description { get; set; } = string.Empty;
        /// <summary>
        /// خاصية NameEn.
        /// English name property.
        /// </summary>
        public string? NameEn { get; set; }
        /// <summary>
        /// خاصية DescriptionEn.
        /// English description property.
        /// </summary>
        public string? DescriptionEn { get; set; }
        /// <summary>
        /// خاصية PropertiesCount.
        /// PropertiesCount property.
        /// </summary>
        public int PropertiesCount { get; set; }
        /// <summary>
        /// خاصية Icon.
        /// Icon property.
        /// </summary>
        public string Icon { get; set; } = string.Empty;
        /// <summary>
        /// خاصية DefaultAmenities.
        /// DefaultAmenities property.
        /// </summary>
        public List<string> DefaultAmenities { get; set; } = new();
        /// <summary>
        /// خاصية UnitTypes.
        /// UnitTypes property.
        /// </summary>
        public List<UnitTypeDto> UnitTypes { get; set; } = new();
    }
}
