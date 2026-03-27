namespace YemenBooking.Application.Features.Chat.DTOs {
    using System;

    /// <summary>
    /// DTO لإعدادات الشات الخاصة بالمستخدم
    /// DTO for ChatSettings entity
    /// </summary>
    public class ChatSettingsDto
    {
        /// <summary>
        /// خاصية Id.
        /// Id property.
        /// </summary>
        public Guid Id { get; set; }
        /// <summary>
        /// خاصية UserId.
        /// UserId property.
        /// </summary>
        public Guid UserId { get; set; }
        /// <summary>
        /// خاصية NotificationsEnabled.
        /// NotificationsEnabled property.
        /// </summary>
        public bool NotificationsEnabled { get; set; }
        /// <summary>
        /// خاصية SoundEnabled.
        /// SoundEnabled property.
        /// </summary>
        public bool SoundEnabled { get; set; }
        /// <summary>
        /// خاصية ShowReadReceipts.
        /// ShowReadReceipts property.
        /// </summary>
        public bool ShowReadReceipts { get; set; }
        /// <summary>
        /// خاصية ShowTypingIndicator.
        /// ShowTypingIndicator property.
        /// </summary>
        public bool ShowTypingIndicator { get; set; }
        /// <summary>
        /// خاصية Theme.
        /// Theme property.
        /// </summary>
        public string Theme { get; set; } = string.Empty;
        /// <summary>
        /// خاصية FontSize.
        /// FontSize property.
        /// </summary>
        public string FontSize { get; set; } = string.Empty;
        /// <summary>
        /// خاصية AutoDownloadMedia.
        /// AutoDownloadMedia property.
        /// </summary>
        public bool AutoDownloadMedia { get; set; }
        /// <summary>
        /// خاصية BackupMessages.
        /// BackupMessages property.
        /// </summary>
        public bool BackupMessages { get; set; }
    }
} 