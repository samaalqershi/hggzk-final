using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.PropertyTypes.Queries.GetPropertyTypes;
using YemenBooking.Application.Common.Models;
using System.Collections.Generic;
using YemenBooking.Application.Features.Properties.DTOs;
using YemenBooking.Application.Features.PropertyTypes.DTOs;
using YemenBooking.Application.Features.PropertyTypes.Queries.GetPropertyTypesWithUnits;

namespace YemenBooking.Api.Controllers.Client
{
    /// <summary>
    /// متحكم أنواع العقارات الموجه للعميل.
    /// Client-facing property types controller.
    /// </summary>
    public class PropertyTypesController : BaseClientController
    {
        /// <summary>
        /// يهيئ نسخة جديدة من [PropertyTypesController].
        /// Initializes a new instance of [PropertyTypesController].
        /// </summary>
        /// <param name="mediator">وسيط MediatR المستخدم لتنفيذ الاستعلامات. MediatR mediator used to send queries.</param>
        public PropertyTypesController(IMediator mediator) : base(mediator)
        {
        }

        /// <summary>
        /// يعيد جميع أنواع العقارات.
        /// Returns all property types.
        /// </summary>
        /// <returns>قائمة أنواع العقارات. Property types list.</returns>
        [HttpGet]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<List<PropertyTypeDto>>>> GetPropertyTypes()
        {
            var query = new GetPropertyTypesQuery();
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعيد أنواع العقارات مع أنواع الوحدات التابعة لها في طلب واحد.
        /// Returns property types together with their unit types in a single request.
        /// </summary>
        [HttpGet("with-units")]
        [AllowAnonymous]
        public async Task<ActionResult<ResultDto<List<PropertyTypeWithUnitsDto>>>> GetPropertyTypesWithUnits()
        {
            var result = await _mediator.Send(new GetPropertyTypesWithUnitsQuery());
            return Ok(result);
        }
    }
}
