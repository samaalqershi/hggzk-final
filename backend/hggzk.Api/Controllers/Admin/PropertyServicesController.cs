using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.PropertyServices.Commands.CreateProperty;
using YemenBooking.Application.Features.PropertyServices.Commands.UpdateProperty;
using YemenBooking.Application.Features.PropertyServices.Commands.DeleteProperty;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.PropertyServices.Queries.GetPropertyServices;
using YemenBooking.Application.Features.PropertyServices.Queries.GetServicesByType;
using YemenBooking.Application.Features.PropertyServices.Queries.GetServiceById;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// يدير الخدمات الإضافية المتاحة للعقار والتسعير المرتبط بها.
    /// Manages add-on services offered by a property and their pricing.
    /// </summary>
    [ApiController]
    [Route("api/admin/[controller]")]
    [Authorize(Roles = "Admin,Owner")]
    public class PropertyServicesController : ControllerBase
    {
        /// <summary>
        /// وسيط تنفيذ الأوامر والاستعلامات.
        /// Mediator for commands and queries.
        /// </summary>
        private readonly IMediator _mediator;

        /// <summary>
        /// ينشئ المتحكم مع حقن الوسيط.
        /// Creates the controller with the mediator dependency.
        /// </summary>
        public PropertyServicesController(IMediator mediator)
        {
            _mediator = mediator;
        }

        /// <summary>
        /// ينشئ خدمة جديدة مرتبطة بعقار.
        /// Creates a new service associated with a property.
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> CreatePropertyService([FromBody] CreatePropertyServiceCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحدث خدمة عقار موجودة.
        /// Updates an existing property service.
        /// </summary>
        [HttpPut("{serviceId}")]
        public async Task<IActionResult> UpdatePropertyService(Guid serviceId, [FromBody] UpdatePropertyServiceCommand command)
        {
            command.ServiceId = serviceId;
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحذف خدمة عقار من النظام.
        /// Deletes a property service from the system.
        /// </summary>
        [HttpDelete("{serviceId}")]
        public async Task<IActionResult> DeletePropertyService(Guid serviceId)
        {
            var command = new DeletePropertyServiceCommand { ServiceId = serviceId };
            var result = await _mediator.Send(command);
            // If failed due to reference checks, return 409 with reason
            if (!result.IsSuccess && (result.Message?.Contains("لا يمكن حذف الخدمة") == true))
            {
                return Conflict(ResultDto.Failure(result.Message, errorCode: "SERVICE_DELETE_CONFLICT"));
            }
            return Ok(result);
        }

        /// <summary>
        /// يعرض الخدمات المرتبطة بعقار محدد.
        /// Returns services linked to a specific property.
        /// </summary>
        [HttpGet("property/{propertyId}")]
        public async Task<IActionResult> GetPropertyServices(Guid propertyId)
        {
            var query = new GetPropertyServicesQuery { PropertyId = propertyId };
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعرض خدمة عقار محددة بحسب المعرف.
        /// Returns a property service by identifier.
        /// </summary>
        [HttpGet("{serviceId}")]
        public async Task<IActionResult> GetServiceById(Guid serviceId)
        {
            var query = new GetServiceByIdQuery { ServiceId = serviceId };
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يعرض الخدمات بحسب النوع مع دعم الصفحات.
        /// Returns services by type with pagination support.
        /// </summary>
        [HttpGet("type/{serviceType}")]
        public async Task<IActionResult> GetServicesByType(
            [FromRoute] string serviceType,
            [FromQuery] int pageNumber = 1,
            [FromQuery] int pageSize = 10)
        {
            var query = new GetServicesByTypeQuery
            {
                ServiceType = serviceType,
                PageNumber = pageNumber,
                PageSize = pageSize,
            };
            var result = await _mediator.Send(query);
            return Ok(result);
        }
    }
} 
