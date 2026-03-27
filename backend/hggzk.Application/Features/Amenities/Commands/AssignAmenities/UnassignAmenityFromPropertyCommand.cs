using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Amenities.Commands.AssignAmenities;

/// <summary>
/// يلغي تخصيص مرفق من عقار محدد.
/// Unassigns an amenity from a specific property.
/// </summary>
public class UnassignAmenityFromPropertyCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرف العقار المستهدف.
    /// Target property identifier.
    /// </summary>
    public Guid PropertyId { get; set; }

    /// <summary>
    /// معرف المرفق المطلوب إلغاؤه.
    /// Amenity identifier to unassign.
    /// </summary>
    public Guid AmenityId { get; set; }
}
