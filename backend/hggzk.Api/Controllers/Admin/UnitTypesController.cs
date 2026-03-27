using System;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.PropertyTypes.Commands.CreateUnit;
using YemenBooking.Application.Features.PropertyTypes.Commands.UpdateUnit;
using YemenBooking.Application.Features.PropertyTypes.Commands.DeleteUnit;
using YemenBooking.Application.Features.PropertyTypes.Queries.GetAllUnitTypes;
using YemenBooking.Application.Features.PropertyTypes.Queries.GetUnitTypes;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// يدير أنواع الوحدات المستخدمة داخل العقارات.
    /// Manages unit types used within properties.
    /// </summary>
    public class UnitTypesController : BaseAdminController
    {
        /// <summary>
        /// ينشئ المتحكم مع حقن الوسيط.
        /// Creates the controller with the mediator dependency.
        /// </summary>
        public UnitTypesController(IMediator mediator) : base(mediator) { }

        /// <summary>
        /// ينشئ نوع وحدة جديدًا.
        /// Creates a new unit type.
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> CreateUnitType([FromBody] CreateUnitTypeCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحدث نوع وحدة موجود.
        /// Updates an existing unit type.
        /// </summary>
        [HttpPut("{unitTypeId}")]
        public async Task<IActionResult> UpdateUnitType(Guid unitTypeId, [FromBody] UpdateUnitTypeCommand command)
        {
            command.UnitTypeId = unitTypeId;
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحذف نوع وحدة من النظام.
        /// Deletes a unit type from the system.
        /// </summary>
        [HttpDelete("{unitTypeId}")]
        public async Task<IActionResult> DeleteUnitType(Guid unitTypeId)
        {
            var command = new DeleteUnitTypeCommand { UnitTypeId = unitTypeId };
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يعرض أنواع الوحدات المرتبطة بنوع عقار محدد.
        /// Returns unit types linked to a specific property type.
        /// </summary>
        [HttpGet("property-type/{propertyTypeId}")]
        public async Task<IActionResult> GetUnitTypesByPropertyType(Guid propertyTypeId)
        {
            var query = new GetUnitTypesByPropertyTypeQuery { PropertyTypeId = propertyTypeId };
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعرض جميع أنواع الوحدات مع دعم الصفحات.
        /// Returns all unit types with pagination support.
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAllUnitTypes([FromQuery] GetAllUnitTypesQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }
    }
} 
