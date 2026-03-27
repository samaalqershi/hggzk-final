using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Amenities.Commands.ManageAmenities
{
    /// <summary>
    /// يبدّل حالة تفعيل المرفق بين نشط وغير نشط.
    /// Toggles the amenity status between active and inactive.
    /// </summary>
    public class ToggleAmenityStatusCommand : IRequest<ResultDto<bool>>
    {
        /// <summary>
        /// معرف المرفق المراد تبديل حالته.
        /// Amenity identifier whose status will be toggled.
        /// </summary>
        public Guid AmenityId { get; set; }
    }
}
