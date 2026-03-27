using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Amenities.Commands.AssignAmenities;

/// <summary>
/// يخصّص مرفقًا لعقار محدد.
/// Assigns an amenity to a specific property.
/// </summary>
public class AssignAmenityToPropertyCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرف العقار المستهدف.
    /// Target property identifier.
    /// </summary>
    public Guid PropertyId { get; set; }

    /// <summary>
    /// معرف المرفق المطلوب تخصيصه.
    /// Amenity identifier to assign.
    /// </summary>
    public Guid AmenityId { get; set; }

    /// <summary>
    /// يحدد ما إذا كان المرفق متاحًا لهذا العقار.
    /// Indicates whether the amenity is available for the property.
    /// </summary>
    public bool IsAvailable { get; set; } = true;

    /// <summary>
    /// تكلفة إضافية اختيارية للمرفق.
    /// Optional extra cost for the amenity.
    /// </summary>
    public decimal? ExtraCost { get; set; }

    /// <summary>
    /// وصف اختياري لارتباط المرفق بالعقار.
    /// Optional description for the property-amenity relation.
    /// </summary>
    public string? Description { get; set; }
} 
