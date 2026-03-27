using MediatR;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Amenities.Commands.ManageAmenities;
using YemenBooking.Application.Features.Amenities.Commands.AssignAmenities;
using YemenBooking.Application.Features.Amenities.Queries.GetAllAmenities;
using YemenBooking.Application.Features.Amenities.Queries.GetAmenityById;
using YemenBooking.Application.Features.Amenities.Queries.GetAmenityStats;
using YemenBooking.Application.Features.Amenities.Queries.GetPopularAmenities;
using YemenBooking.Application.Features.Amenities.DTOs;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// يوفّر نقاط إدارة المرافق ضمن لوحة الإدارة.
    /// Provides admin endpoints for amenity management.
    /// </summary>
    public class AmenitiesController : BaseAdminController
    {
    /// <summary>
    /// يهيئ المتحكم بالاعتماد على Mediator.
    /// Initializes the controller with Mediator.
    /// </summary>
        public AmenitiesController(IMediator mediator) : base(mediator) { }

    /// <summary>
    /// ينشئ مرفقًا جديدًا في النظام.
    /// Creates a new amenity in the system.
    /// </summary>
        [HttpPost]
        public async Task<IActionResult> CreateAmenity([FromBody] CreateAmenityCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

    /// <summary>
    /// يحدّث بيانات مرفق موجود.
    /// Updates an existing amenity.
    /// </summary>
        [HttpPut("{amenityId}")]
        public async Task<IActionResult> UpdateAmenity(Guid amenityId, [FromBody] UpdateAmenityCommand command)
        {
            command.AmenityId = amenityId;
            var result = await _mediator.Send(command);
            return Ok(result);
        }

    /// <summary>
    /// يحذف مرفقًا من النظام مع مراعاة قيود الارتباط.
    /// Deletes an amenity while honoring relationship constraints.
    /// </summary>
        [HttpDelete("{amenityId}")]
        public async Task<IActionResult> DeleteAmenity(Guid amenityId)
        {
            var command = new DeleteAmenityCommand { AmenityId = amenityId };
            var result = await _mediator.Send(command);
            // If failed due to reference checks, return 409 with reason
            if (!result.IsSuccess && (result.Message?.Contains("لا يمكن حذف المرفق") == true))
            {
                return Conflict(ResultDto.Failure(result.Message, errorCode: "AMENITY_DELETE_CONFLICT"));
            }
            return Ok(result);
        }

    /// <summary>
    /// يجلب المرافق مع دعم التصفّح.
    /// Retrieves amenities with pagination support.
    /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAllAmenities([FromQuery] GetAllAmenitiesQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

    /// <summary>
    /// يجلب مرفقًا محددًا بحسب المعرّف.
    /// Retrieves a specific amenity by its identifier.
    /// </summary>
        [HttpGet("{amenityId}")]
        public async Task<IActionResult> GetAmenityById(Guid amenityId)
        {
            var result = await _mediator.Send(new GetAmenityByIdQuery { AmenityId = amenityId });
            return Ok(ResultDto<AmenityDto>.Ok(result));
        }

    /// <summary>
    /// يعرض إحصائيات المرافق.
    /// Returns amenity statistics.
    /// </summary>
        [HttpGet("stats")]
        public async Task<IActionResult> GetAmenityStats()
        {
            var result = await _mediator.Send(new GetAmenityStatsQuery());
            return Ok(ResultDto<AmenityStatsDto>.Ok(result));
        }

    /// <summary>
    /// يجلب المرافق الأكثر شيوعًا.
    /// Retrieves the most popular amenities.
    /// </summary>
        [HttpGet("popular")]
        public async Task<IActionResult> GetPopularAmenities([FromQuery] int limit = 10)
        {
            var result = await _mediator.Send(new GetPopularAmenitiesQuery { Limit = limit });
            return Ok(ResultDto<List<AmenityDto>>.Ok(result));
        }

    /// <summary>
    /// يبدّل حالة تفعيل المرفق.
    /// Toggles the amenity active state.
    /// </summary>
        [HttpPost("{amenityId}/toggle-status")]
        public async Task<IActionResult> ToggleAmenityStatus(Guid amenityId)
        {
            var cmd = new ToggleAmenityStatusCommand { AmenityId = amenityId };
            var result = await _mediator.Send(cmd);
            return Ok(result);
        }

    /// <summary>
    /// يربط مرفقًا بعقار محدد.
    /// Assigns an amenity to a specific property.
    /// </summary>
        [HttpPost("{amenityId}/assign/property/{propertyId}")]
        public async Task<IActionResult> AssignAmenityToProperty(Guid amenityId, Guid propertyId, [FromBody] AssignAmenityToPropertyCommand command)
        {
            command.AmenityId = amenityId;
            command.PropertyId = propertyId;
            var result = await _mediator.Send(command);
            return Ok(result);
        }

    /// <summary>
    /// يفك ارتباط المرفق من العقار.
    /// Unassigns the amenity from the property.
    /// </summary>
        [HttpDelete("{amenityId}/assign/property/{propertyId}")]
        public async Task<IActionResult> UnassignAmenityFromProperty(Guid amenityId, Guid propertyId)
        {
            var cmd = new UnassignAmenityFromPropertyCommand
            {
                AmenityId = amenityId,
                PropertyId = propertyId
            };
            var result = await _mediator.Send(cmd);
            if (!result.IsSuccess)
                return Conflict(ResultDto.Failure(result.Message ?? "تعذر إلغاء الإسناد"));
            return Ok(result);
        }

    /// <summary>
    /// يربط مرفقًا بنوع عقار محدد.
    /// Assigns an amenity to a specific property type.
    /// </summary>
        [HttpPost("{amenityId}/assign/property-type/{propertyTypeId}")]
        public async Task<IActionResult> AssignAmenityToPropertyType(Guid amenityId, Guid propertyTypeId, [FromBody] AssignAmenityToPropertyTypeCommand command)
        {
            command.AmenityId = amenityId;
            command.PropertyTypeId = propertyTypeId;
            var result = await _mediator.Send(command);
            return Ok(result);
        }
    }
} 
