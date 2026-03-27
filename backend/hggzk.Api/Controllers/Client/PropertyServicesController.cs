using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.PropertyServices.Queries.GetPropertyServices;

namespace YemenBooking.Api.Controllers.Client
{
    /// <summary>
    /// متحكم خدمات العقار المخصص للعميل.
    /// Client-facing property services controller.
    /// </summary>
    public class ServicesController : BaseClientController
    {
        /// <summary>
        /// يهيئ نسخة جديدة من [ServicesController].
        /// Initializes a new instance of [ServicesController].
        /// </summary>
        /// <param name="mediator">وسيط MediatR المستخدم لتنفيذ الاستعلامات. MediatR mediator used to send queries.</param>
        public ServicesController(IMediator mediator) : base(mediator) { }

        /// <summary>
        /// يعيد خدمات عقار محدد.
        /// Returns services for a specific property.
        /// </summary>
        [HttpGet("property/{propertyId}")]
        public async Task<IActionResult> GetPropertyServices(Guid propertyId)
        {
            var query = new GetPropertyServicesQuery { PropertyId = propertyId };
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        // Other owner-level operations for services are handled via admin controller (with Owner role access)
    }
}
