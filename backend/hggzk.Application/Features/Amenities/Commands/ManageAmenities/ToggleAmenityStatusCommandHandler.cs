using System.Threading;
using System.Threading.Tasks;
using System.Linq;
using MediatR;
using YemenBooking.Application.Features.Amenities;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Common.Interfaces;

namespace YemenBooking.Application.Features.Amenities.Commands.ManageAmenities
{
    /// <summary>
    /// فئة ToggleAmenityStatusCommandHandler.
    /// ToggleAmenityStatusCommandHandler class.
    /// </summary>
    public class ToggleAmenityStatusCommandHandler : IRequestHandler<ToggleAmenityStatusCommand, ResultDto<bool>>
    {
        private readonly IAmenityRepository _amenityRepository;
        private readonly ICurrentUserService _currentUserService;

        /// <summary>
        /// يُهيِّئ المعالج بالاعتمادات المطلوبة.
        /// Initializes the handler with the required dependencies.
        /// </summary>
        public ToggleAmenityStatusCommandHandler(
            IAmenityRepository amenityRepository,
            ICurrentUserService currentUserService)
        {
            _amenityRepository = amenityRepository;
            _currentUserService = currentUserService;
        }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة.
    /// Processes the amenity status toggle command and returns the result.
    /// </summary>
        public async Task<ResultDto<bool>> Handle(ToggleAmenityStatusCommand request, CancellationToken cancellationToken)
        {
            var isAdmin = string.Equals(_currentUserService.Role, "Admin", System.StringComparison.OrdinalIgnoreCase)
                || string.Equals(_currentUserService.AccountRole, "Admin", System.StringComparison.OrdinalIgnoreCase)
                || (_currentUserService.UserRoles?.Any(r => string.Equals(r, "Admin", System.StringComparison.OrdinalIgnoreCase)) ?? false);
            if (!isAdmin)
                return ResultDto<bool>.Failed("غير مصرح لك بتغيير حالة المرفق");

            var amenity = await _amenityRepository.GetAmenityByIdAsync(request.AmenityId, cancellationToken);
            if (amenity == null)
                return ResultDto<bool>.Failed("المرفق غير موجود");

            amenity.IsActive = !amenity.IsActive;
            await _amenityRepository.UpdateAmenityAsync(amenity, cancellationToken);
            await _amenityRepository.SaveChangesAsync(cancellationToken);

            return ResultDto<bool>.Succeeded(true, amenity.IsActive ? "تم تفعيل المرفق" : "تم تعطيل المرفق");
        }
    }
}
