using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Users.Commands.UpdateUser;
using YemenBooking.Application.Features.Users.Queries.GetCurrentUser;

namespace YemenBooking.Api.Controllers.Common
{
    /// <summary>
    /// عمليات المستخدم الحالية والصورة والإعدادات.
    /// Current user, profile picture, and settings operations.
    /// </summary>
    public class UsersController : BaseCommonController
    {
        /// <summary>
        /// ينشئ متحكم المستخدم مع المرسل الوسيط.
        /// Creates the user controller with the mediator.
        /// </summary>
        public UsersController(IMediator mediator) : base(mediator) { }

        /// <summary>
        /// يعيد بيانات المستخدم الحالي.
        /// Returns the current user details.
        /// </summary>
        [HttpGet("current")]
        [Authorize]
        public async Task<IActionResult> GetCurrentUser()
        {
            var query = new GetCurrentUserQuery();
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يحدّث صورة الملف الشخصي.
        /// Updates the profile picture.
        /// </summary>
        [HttpPut("profile-picture")]
        public async Task<IActionResult> UpdateProfilePicture([FromBody] UpdateUserProfilePictureCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يحدّث إعدادات المستخدم بصيغة JSON.
        /// Updates the user's JSON settings.
        /// </summary>
        [HttpPut("settings")]
        public async Task<IActionResult> UpdateUserSettings([FromBody] UpdateUserSettingsCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }
    }
} 
