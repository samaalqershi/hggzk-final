using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.PropertyTypes.Queries.GetUnitTypes;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Units.DTOs;
using System.Collections.Generic;

namespace YemenBooking.Api.Controllers.Client
{
    /// <summary>
    /// يوفر أنواع الوحدات المتاحة للعميل.
    /// Exposes available unit types to clients.
    /// </summary>
    public class UnitTypesController : BaseClientController
    {
        /// <summary>
        /// ينشئ مثيلاً جديداً من <see cref="UnitTypesController"/>.
        /// Creates a new <see cref="UnitTypesController"/> instance.
        /// </summary>
        public UnitTypesController(IMediator mediator) : base(mediator)
        {
        }

        /// <summary>
        /// يجلب جميع أنواع الوحدات.
        /// Retrieves all unit types.
        /// </summary>
        /// <returns>قائمة أنواع الوحدات.</returns>
        [HttpGet]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<List<UnitTypeDto>>>> GetUnitTypes([FromQuery] GetUnitTypesQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }
    }
}
