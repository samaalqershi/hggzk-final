using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Properties.Commands.UploadImages;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// يوفّر نقطة إداريّة لرفع الصور المرتبطة بالكيانات.
    /// Provides an admin endpoint for uploading entity-related images.
    /// </summary>
    public class UploadImageController : BaseAdminController
    {
        /// <summary>
        /// ينشئ المتحكم مع حقن الوسيط.
        /// Creates the controller with the mediator dependency.
        /// </summary>
        public UploadImageController(IMediator mediator) : base(mediator) { }

        /// <summary>
        /// يرفع صورة واحدة مع البيانات الوصفية المصاحبة لها.
        /// Uploads a single image together with its metadata.
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> UploadImage([FromBody] UploadImageCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }
    }
} 
