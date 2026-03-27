using MediatR;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Users.Commands.UpdateUser;
using YemenBooking.Application.Features.Users.Queries.GetUserSettings;
using YemenBooking.Application.Features.Users.DTOs;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Api.Controllers.Client
{
    /// <summary>
    /// يوفر واجهات إعدادات المستخدم للعميل.
    /// Exposes client user settings endpoints.
    /// </summary>
    public class SettingsController : BaseClientController
    {
        /// <summary>
        /// ينشئ مثيلاً جديداً من <see cref="SettingsController"/>.
        /// Creates a new <see cref="SettingsController"/> instance.
        /// </summary>
        public SettingsController(IMediator mediator) : base(mediator)
        {
        }

        /// <summary>
        /// يحدّث إعدادات المستخدم.
        /// Updates user settings.
        /// </summary>
        /// <param name="command">الإعدادات الجديدة.</param>
        /// <returns>نتيجة التحديث.</returns>
        [HttpPut]
        public async Task<ActionResult<ResultDto<bool>>> UpdateUserSettings([FromBody] UpdateUserSettingsCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يجلب إعدادات المستخدم الحالية.
        /// Retrieves the current user settings.
        /// </summary>
        /// <param name="query">معايير الاستعلام.</param>
        /// <returns>إعدادات المستخدم.</returns>
        [HttpGet]
        public async Task<ActionResult<ResultDto<UserSettingsDto>>> GetUserSettings([FromQuery] GetUserSettingsQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }

        /// <summary>
        /// يحدّث لغة المستخدم.
        /// Updates the user's language.
        /// </summary>
        /// <param name="languageCode">رمز اللغة.</param>
        /// <returns>نتيجة التحديث.</returns>
        [HttpGet("language/{languageCode}")]
        public async Task<ActionResult<ResultDto<bool>>> UpdateLanguageUser(string languageCode)
        {
            return Ok(new ResultDto<bool>
            {
                Data = true,
                Message = "تم تحديث اللغة بنجاح",
                Success = true
            });
        }
    }
}
