using System.Threading;
using System.Threading.Tasks;
using MediatR;
using YemenBooking.Application.Features.Amenities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.Amenities.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Amenities.Queries.GetAmenityById
{
    /// <summary>
    /// فئة GetAmenityByIdQueryHandler.
    /// GetAmenityByIdQueryHandler class.
    /// </summary>
    public class GetAmenityByIdQueryHandler : IRequestHandler<GetAmenityByIdQuery, AmenityDto>
    {
        private readonly IAmenityRepository _amenityRepository;
        private readonly ICurrentUserService _currentUserService;

        /// <summary>
        /// يُهيِّئ المعالج بالاعتمادات المطلوبة.
        /// Initializes the handler with the required dependencies.
        /// </summary>
        public GetAmenityByIdQueryHandler(IAmenityRepository amenityRepository, ICurrentUserService currentUserService)
        {
            _amenityRepository = amenityRepository;
            _currentUserService = currentUserService;
        }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة.
    /// Processes the amenity lookup query and returns the result.
    /// </summary>
        public async Task<AmenityDto> Handle(GetAmenityByIdQuery request, CancellationToken cancellationToken)
        {
            var a = await _amenityRepository.GetAmenityByIdAsync(request.AmenityId, cancellationToken);
            if (a == null) return new AmenityDto();
            var dto = new AmenityDto
            {
                Id = a.Id,
                Name = a.Name,
                Description = a.Description,
                Icon = a.Icon,
                IsActive = a.IsActive,
                CreatedAt = a.CreatedAt,
                UpdatedAt = a.UpdatedAt
            };

            dto.CreatedAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(dto.CreatedAt);
            if (dto.UpdatedAt.HasValue)
            {
                dto.UpdatedAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(dto.UpdatedAt.Value);
            }

            return dto;
        }
    }
}
