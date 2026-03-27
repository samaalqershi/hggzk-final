using YemenBooking.Application.Features.Chat.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Chat.Queries.GetChatSettings
{
    using MediatR;
    using YemenBooking.Application.Common.Models;

    /// <summary>
    /// يمثل استعلامًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area query.
    /// </summary>
    public class GetChatSettingsQuery : IRequest<ResultDto<ChatSettingsDto>>
    {
    }
} 