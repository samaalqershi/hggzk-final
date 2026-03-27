using System.Text.Json.Serialization;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Chat.Commands.Presence
{
    /// <summary>
    /// يمثل أمرًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area command.
    /// </summary>
    public class UpdateUserStatusCommand : IRequest<ResultDto>
    {
        /// <summary>
        /// حالة المستخدم الجديدة.
        /// New user presence status.
        /// </summary>
        [JsonPropertyName("status")]
        public string Status { get; set; } = string.Empty;
    }
} 
