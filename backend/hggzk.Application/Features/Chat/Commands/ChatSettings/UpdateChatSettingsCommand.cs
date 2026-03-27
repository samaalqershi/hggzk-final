using YemenBooking.Application.Features.Chat.DTOs;

namespace YemenBooking.Application.Features.Chat.Commands.ChatSettings
{
    using MediatR;
    using YemenBooking.Application.Common.Models;

    /// <summary>
    /// يمثل أمرًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area command.
    /// </summary>
    public class UpdateChatSettingsCommand : IRequest<ResultDto<ChatSettingsDto>>
    {
        /// <summary>
        /// يحدد ما إذا كانت التنبيهات مفعلة.
        /// Indicates whether notifications are enabled.
        /// </summary>
        public bool? NotificationsEnabled { get; set; }

        /// <summary>
        /// يحدد ما إذا كان صوت التنبيهات مفعّلًا.
        /// Indicates whether notification sounds are enabled.
        /// </summary>
        public bool? SoundEnabled { get; set; }

        /// <summary>
        /// يحدد ما إذا كانت مؤشرات قراءة الرسائل مفعلة.
        /// Indicates whether read receipts are enabled.
        /// </summary>
        public bool? ShowReadReceipts { get; set; }

        /// <summary>
        /// يحدد ما إذا كانت مؤشرات الكتابة مفعلة.
        /// Indicates whether typing indicators are enabled.
        /// </summary>
        public bool? ShowTypingIndicator { get; set; }

        /// <summary>
        /// السمة المرئية لواجهة الدردشة.
        /// Visual theme for the chat interface.
        /// </summary>
        public string? Theme { get; set; }

        /// <summary>
        /// حجم الخط المفضل لواجهة الدردشة.
        /// Preferred font size for the chat interface.
        /// </summary>
        public string? FontSize { get; set; }

        /// <summary>
        /// يحدد ما إذا كان تنزيل الوسائط تلقائيًا مفعّلًا.
        /// Indicates whether media auto-download is enabled.
        /// </summary>
        public bool? AutoDownloadMedia { get; set; }

        /// <summary>
        /// يحدد ما إذا كانت نسخ الرسائل الاحتياطية مفعلة.
        /// Indicates whether message backups are enabled.
        /// </summary>
        public bool? BackupMessages { get; set; }
    }
} 
