namespace YemenBooking.Core.Entities
{
    using System;
    using System.ComponentModel.DataAnnotations;

    /// <summary>
    /// إعدادات المحادثات الخاصة بالمستخدم.
    /// User chat preferences.
    /// </summary>
    [Display(Name = "إعدادات الشات")]
    public class ChatSettings : BaseEntity<Guid>
    {
        /// <summary>
        /// معرف المستخدم.
        /// User identifier.
        /// </summary>
        [Display(Name = "معرف المستخدم")]
        public Guid UserId { get; set; }

        /// <summary>
        /// تفعيل التنبيهات.
        /// Enables notifications.
        /// </summary>
        [Display(Name = "تنبيهات مفعلة")]
        public bool NotificationsEnabled { get; set; } = true;

        /// <summary>
        /// تفعيل الصوت.
        /// Enables sound.
        /// </summary>
        [Display(Name = "صوت مفعّل")]
        public bool SoundEnabled { get; set; } = true;

        /// <summary>
        /// عرض إيصالات القراءة.
        /// Shows read receipts.
        /// </summary>
        [Display(Name = "عرض إيصالات القراءة")]
        public bool ShowReadReceipts { get; set; } = true;

        /// <summary>
        /// عرض مؤشر الكتابة.
        /// Shows typing indicator.
        /// </summary>
        [Display(Name = "عرض مؤشر الكتابة")]
        public bool ShowTypingIndicator { get; set; } = true;

        /// <summary>
        /// المظهر المفضل.
        /// Preferred theme.
        /// </summary>
        [Display(Name = "المظهر")]
        public string Theme { get; set; } = "light";

        /// <summary>
        /// حجم الخط المفضل.
        /// Preferred font size.
        /// </summary>
        [Display(Name = "حجم الخط")]
        public string FontSize { get; set; } = "medium";

        /// <summary>
        /// التحميل التلقائي للوسائط.
        /// Auto-download media.
        /// </summary>
        [Display(Name = "التحميل التلقائي للوسائط")]
        public bool AutoDownloadMedia { get; set; } = false;

        /// <summary>
        /// النسخ الاحتياطي للرسائل.
        /// Back up messages.
        /// </summary>
        [Display(Name = "نسخ احتياطي للرسائل")]
        public bool BackupMessages { get; set; } = false;
    }
} 
