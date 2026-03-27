using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace YemenBooking.Api.Controllers.Common
{
    /// <summary>
    /// الأساس المشترك لمتحكمات النطاق العام.
    /// Shared base for common controllers.
    /// </summary>
    [ApiController]
    [Route("api/common/[controller]")]
    public abstract class BaseCommonController : ControllerBase
    {
        /// <summary>
        /// المرسل الوسيط المستخدم في المتحكمات المشتقة.
        /// Mediator available to derived controllers.
        /// </summary>
        protected readonly IMediator _mediator;

        /// <summary>
        /// ينشئ الأساس المشترك مع المرسل الوسيط.
        /// Creates the shared base with the mediator.
        /// </summary>
        public BaseCommonController(IMediator mediator)
        {
            _mediator = mediator;
        }
    }
} 
