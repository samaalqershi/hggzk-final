using System;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.PropertyTypes.Commands.CreateProperty;
using YemenBooking.Application.Features.PropertyTypes.Commands.UpdateProperty;
using YemenBooking.Application.Features.PropertyTypes.Commands.DeleteProperty;
using YemenBooking.Application.Features.PropertyTypes.Queries.GetPropertyTypes;
using YemenBooking.Application.Features.PropertyTypes.Queries.GetAllPropertyTypes;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// يدير أنواع العقارات المستخدمة في التصنيف والسلوك الافتراضي.
    /// Manages property types used for classification and default behavior.
    /// </summary>
    public class PropertyTypesController : BaseAdminController
    {
        /// <summary>
        /// ينشئ المتحكم مع حقن الوسيط.
        /// Creates the controller with the mediator dependency.
        /// </summary>
        public PropertyTypesController(IMediator mediator) : base(mediator) { }

        /// <summary>
        /// ينشئ نوع عقار جديدًا.
        /// Creates a new property type.
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> CreatePropertyType([FromBody] CreatePropertyTypeCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحدث نوع عقار موجود.
        /// Updates an existing property type.
        /// </summary>
        [HttpPut("{propertyTypeId}")]
        public async Task<IActionResult> UpdatePropertyType(Guid propertyTypeId, [FromBody] UpdatePropertyTypeCommand command)
        {
            command.PropertyTypeId = propertyTypeId;
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحذف نوع عقار من النظام.
        /// Deletes a property type from the system.
        /// </summary>
        [HttpDelete("{propertyTypeId}")]
        public async Task<IActionResult> DeletePropertyType(Guid propertyTypeId)
        {
            var command = new DeletePropertyTypeCommand { PropertyTypeId = propertyTypeId };
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يعرض جميع أنواع العقارات مع دعم الصفحات.
        /// Returns all property types with pagination support.
        /// </summary>
        [HttpGet]
        [AllowAnonymous]
        public async Task<IActionResult> GetAllPropertyTypes([FromQuery] GetAllPropertyTypesQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }
    }
} 
