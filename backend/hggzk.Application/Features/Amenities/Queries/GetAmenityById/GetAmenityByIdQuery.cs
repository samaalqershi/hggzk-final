using MediatR;
using YemenBooking.Application.Features.Amenities;
using YemenBooking.Application.Features.Amenities.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Amenities.Queries.GetAmenityById
{
    /// <summary>
    /// يجلب تفاصيل مرفق محدد بواسطة المعرف.
    /// Retrieves a specific amenity by its identifier.
    /// </summary>
    public class GetAmenityByIdQuery : IRequest<AmenityDto>
    {
        /// <summary>
        /// معرف المرفق المراد جلبه.
        /// Amenity identifier to retrieve.
        /// </summary>
        public Guid AmenityId { get; set; }
    }
}
