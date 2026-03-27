namespace YemenBooking.Application.Features.Units.DTOs;
using YemenBooking.Application.Features.DynamicFields.DTOs;

using System;
using System.Collections.Generic;

/// <summary>
/// بيانات نقل بيانات الوحدة للتحرير
/// DTO for unit edit form including dynamic values
/// </summary>
public class UnitEditDto
{
    /// <summary>
    /// خاصية UnitId.
    /// UnitId property.
    /// </summary>
    public Guid UnitId { get; set; }
    /// <summary>
    /// خاصية Name.
    /// Name property.
    /// </summary>
    public string Name { get; set; }
    /// <summary>
    /// خاصية CustomFeatures.
    /// CustomFeatures property.
    /// </summary>
    public Dictionary<string, object> CustomFeatures { get; set; }
    /// <summary>
    /// خاصية DynamicFields.
    /// DynamicFields property.
    /// </summary>
    public List<FieldGroupWithValuesDto> DynamicFields { get; set; }
} 