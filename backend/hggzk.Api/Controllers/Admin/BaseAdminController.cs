using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// الأساس المشترك لمتحكمات الإدارة.
    /// Shared base for admin controllers.
    /// </summary>
    [ApiController]
    [Route("api/admin/[controller]")]
    [Authorize(Roles = "Admin,Owner")]
    public abstract class BaseAdminController : ControllerBase
    {
        /// <summary>
        /// حقل _mediator.
        /// _mediator field.
        /// </summary>
        protected readonly IMediator _mediator;

    /// <summary>
    /// يهيئ المتحكم الأساسي باستخدام خدمة MediatR.
    /// Initializes the base controller with MediatR.
    /// </summary>
        public BaseAdminController(IMediator mediator)
        {
            _mediator = mediator;
        }
    }
}
