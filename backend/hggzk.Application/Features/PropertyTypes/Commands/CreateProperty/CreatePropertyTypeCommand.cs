using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.PropertyTypes.Commands.CreateProperty;

/// <summary>
/// يمثل طلب إنشاء نوع عقار جديد.
/// Creates a new property type.
/// </summary>
public class CreatePropertyTypeCommand : IRequest<ResultDto<Guid>>
{
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
