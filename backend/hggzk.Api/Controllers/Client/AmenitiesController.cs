using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Amenities.Queries.GetAllAmenities;
using YemenBooking.Application.Common.Models;
using System.Collections.Generic;
using YemenBooking.Application.Features.Amenities.DTOs;

namespace YemenBooking.Api.Controllers.Client
{
    /// <summary>
    /// متحكم عرض المرافق المتاحة للعملاء.
    /// Client-facing amenities controller.
    /// </summary>
    public class AmenitiesController : BaseClientController
    {
        /// <summary>
        /// يهيئ نسخة جديدة من [AmenitiesController].
        /// Initializes a new instance of [AmenitiesController].
        /// </summary>
        /// <param name="mediator">وسيط MediatR المستخدم لتنفيذ الاستعلامات. MediatR mediator used to send queries.</param>
        public AmenitiesController(IMediator mediator) : base(mediator)
        {
        }

        /// <summary>
        /// يعيد قائمة المرافق المتاحة.
        /// Returns the list of available amenities.
        /// </summary>
        /// <returns>قائمة المرافق. The available amenities list.</returns>
        [HttpGet]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<List<AmenityDto>>>> GetAllAmenities([FromQuery] GetAllAmenitiesQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }
    }
}
