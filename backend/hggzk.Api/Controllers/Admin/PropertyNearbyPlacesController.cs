using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.NearbyPlaces.Commands.CreateProperty;
using YemenBooking.Application.Features.NearbyPlaces.Commands.DeleteProperty;
using YemenBooking.Application.Features.NearbyPlaces.Commands.ManageNearbyPlaces;
using YemenBooking.Application.Features.NearbyPlaces.Commands.UpdateProperty;
using YemenBooking.Application.Features.NearbyPlaces.DTOs;
using YemenBooking.Application.Features.NearbyPlaces.Queries.GetNearbyPlaceById;
using YemenBooking.Application.Features.NearbyPlaces.Queries.GetNearbyPlaces;

namespace YemenBooking.Api.Controllers.Admin;

/// <summary>
/// Manages real nearby places assigned to properties.
/// يدير الأماكن القريبة الحقيقية المرتبطة بالعقارات.
/// </summary>
[ApiController]
[Route("api/admin/property-nearby-places")]
[Route("api/admin/propertynearbyplaces")]
[Authorize(Roles = "Admin,Owner")]
public class PropertyNearbyPlacesController : ControllerBase
{
    private readonly IMediator _mediator;

    public PropertyNearbyPlacesController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpPost]
    public async Task<ActionResult<ResultDto<Guid>>> Create([FromBody] CreatePropertyNearbyPlaceCommand command)
    {
        return Ok(await _mediator.Send(command));
    }

    [HttpPut("{nearbyPlaceId}")]
    public async Task<ActionResult<ResultDto<bool>>> Update(Guid nearbyPlaceId, [FromBody] UpdatePropertyNearbyPlaceCommand command)
    {
        command.NearbyPlaceId = nearbyPlaceId;
        return Ok(await _mediator.Send(command));
    }

    [HttpDelete("{nearbyPlaceId}")]
    public async Task<ActionResult<ResultDto<bool>>> Delete(Guid nearbyPlaceId)
    {
        return Ok(await _mediator.Send(new DeletePropertyNearbyPlaceCommand
        {
            NearbyPlaceId = nearbyPlaceId
        }));
    }

    [HttpPatch("{nearbyPlaceId}/toggle-status")]
    public async Task<ActionResult<ResultDto<bool>>> ToggleStatus(Guid nearbyPlaceId)
    {
        return Ok(await _mediator.Send(new TogglePropertyNearbyPlaceStatusCommand
        {
            NearbyPlaceId = nearbyPlaceId
        }));
    }

    [HttpGet]
    public async Task<ActionResult<ResultDto<List<PropertyNearbyPlaceDto>>>> GetAll([FromQuery] GetNearbyPlacesQuery query)
    {
        return Ok(await _mediator.Send(query));
    }

    [HttpGet("{nearbyPlaceId}")]
    public async Task<ActionResult<ResultDto<PropertyNearbyPlaceDto>>> GetById(Guid nearbyPlaceId)
    {
        return Ok(await _mediator.Send(new GetNearbyPlaceByIdQuery
        {
            NearbyPlaceId = nearbyPlaceId
        }));
    }
}
