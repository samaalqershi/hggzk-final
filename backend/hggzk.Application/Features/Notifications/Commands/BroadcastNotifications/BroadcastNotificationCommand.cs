using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Notifications.Commands.BroadcastNotifications
{
    /// <summary>
    /// يمثل أمرًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area command.
    /// </summary>
    public class BroadcastNotificationCommand : IRequest<ResultDto<int>>
    {
        /// <summary>
        /// نوع الإشعار.
        /// Notification type.
        /// </summary>
        public string Type { get; set; } = string.Empty;
        /// <summary>
        /// عنوان الإشعار.
        /// Notification title.
        /// </summary>
        public string Title { get; set; } = string.Empty;
        /// <summary>
        /// نص الإشعار.
        /// Notification message.
        /// </summary>
        public string Message { get; set; } = string.Empty;

        // Targeting
        /// <summary>
        /// يحدد ما إذا كان الإرسال موجّهًا إلى جميع المستخدمين.
        /// Indicates whether the broadcast targets all users.
        /// </summary>
        public bool TargetAllUsers { get; set; } = false;
        /// <summary>
        /// معرّفات المستخدمين المستهدفين.
        /// Target user identifiers.
        /// </summary>
        public Guid[]? TargetUserIds { get; set; }
        /// <summary>
        /// الأدوار المستهدفة.
        /// Target roles.
        /// </summary>
        public string[]? TargetRoles { get; set; }
        /// <summary>
        /// معرّف القناة المستهدفة.
        /// Target channel identifier.
        /// </summary>
        public Guid? TargetChannelId { get; set; } // New: Target specific channel

        // Optional scheduling
        /// <summary>
        /// وقت الإرسال المجدول.
        /// Scheduled send time.
        /// </summary>
        public DateTime? ScheduledFor { get; set; }
        /// <summary>
        /// أولوية الإشعار.
        /// Notification priority.
        /// </summary>
        public string Priority { get; set; } = "MEDIUM";
        
        // Additional data
        /// <summary>
        /// البيانات الإضافية.
        /// Additional data.
        /// </summary>
        public Dictionary<string, string>? Data { get; set; }
    }
}

