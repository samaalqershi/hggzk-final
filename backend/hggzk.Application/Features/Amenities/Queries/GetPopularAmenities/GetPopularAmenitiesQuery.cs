using MediatR;
using YemenBooking.Application.Features.Amenities;
using YemenBooking.Application.Features.Amenities.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Amenities.Queries.GetPopularAmenities
{
    /// <summary>
    /// يجلب المرافق الأكثر استخدامًا أو طلبًا.
    /// Retrieves the most popular amenities.
    /// </summary>
    public class GetPopularAmenitiesQuery : IRequest<List<AmenityDto>>
    {
        /// <summary>
        /// عدد النتائج المطلوب إرجاعها.
        /// Maximum number of results to return.
        /// </summary>
        public int Limit { get; set; } = 10;
    }
}
