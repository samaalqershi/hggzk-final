using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.PropertyTypes.Commands.UpdateProperty;

/// <summary>
/// يمثل طلب تحديث نوع عقار.
/// Updates an existing property type.
/// </summary>
public class UpdatePropertyTypeCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف نوع العقار.
    /// property type identifier.
    /// </summary>
    public Guid PropertyTypeId { get; set; }

    /// <summary>
    /// الاسم.
    /// name.
    /// </summary>
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// الوصف.
    /// description.
    /// </summary>
    public string Description { get; set; } = string.Empty;

    /// <summary>
    /// المزايا الافتراضية.
    /// default amenities.
    /// </summary>
    public string DefaultAmenities { get; set; } = string.Empty;

    /// <summary>
    /// الأيقونة.
    /// icon.
    /// </summary>
    public string Icon { get; set; } = string.Empty;

} 
