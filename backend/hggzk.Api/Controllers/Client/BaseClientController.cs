using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace YemenBooking.Api.Controllers.Client
{
    /// <summary>
    /// الأساس المشترك لمتحكمات العميل.
    /// Shared base class for client-facing controllers.
    /// </summary>
    [ApiController]
    [Route("api/client/[controller]")]
    [Authorize(Roles = "Admin,Client,Owner,Staff")]
    public abstract class BaseClientController : ControllerBase
    {
        /// <summary>
        /// وسيط الطلبات المشترك.
        /// Shared mediator instance.
        /// </summary>
        protected readonly IMediator _mediator;

        /// <summary>
        /// يهيئ نسخة جديدة من [BaseClientController] باستخدام الوسيط المحدد.
        /// Initializes a new instance of [BaseClientController] with the provided mediator.
        /// </summary>
        /// <param name="mediator">وسيط MediatR المستخدم لتنفيذ الطلبات. MediatR mediator used to dispatch requests.</param>
        public BaseClientController(IMediator mediator)
        {
            _mediator = mediator;
        }
    }
} 
