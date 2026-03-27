using System.ComponentModel.DataAnnotations;

namespace YemenBooking.Core.Entities;

/// <summary>
/// يمثل تفضيلات المستخدم وخياراته الشخصية.
/// Represents the user's personal preferences and options.
/// </summary>
[Display(Name = "إعدادات المستخدم")]
public class UserSettings : BaseEntity<Guid>
{
    /// <summary>
    /// معرّف المستخدم المرتبط بهذه الإعدادات.
    /// Identifies the user associated with these settings.
    /// </summary>
    [Display(Name = "معرف المستخدم")]
    public Guid UserId { get; set; }

    /// <summary>
    /// اللغة المفضلة لواجهة المستخدم.
    /// The preferred language for the user interface.
    /// </summary>
    [Display(Name = "اللغة المفضلة")]
    [MaxLength(10)]
    public string? PreferredLanguage { get; set; } = "ar";

    /// <summary>
    /// العملة المفضلة في عرض الأسعار والقيم.
    /// The preferred currency used when displaying prices and values.
    /// </summary>
    [Display(Name = "العملة المفضلة")]
    [MaxLength(3)]
    public string? PreferredCurrency { get; set; } = "YER";

    /// <summary>
    /// المنطقة الزمنية المفضلة للمستخدم.
    /// The user's preferred time zone.
    /// </summary>
    [Display(Name = "المنطقة الزمنية")]
    [MaxLength(50)]
    public string? TimeZone { get; set; } = "Asia/Aden";

    /// <summary>
    /// يشير إلى تفعيل الوضع الليلي.
    /// Indicates whether dark mode is enabled.
    /// </summary>
    [Display(Name = "الوضع الليلي")]
    public bool DarkMode { get; set; } = false;

    /// <summary>
    /// يشير إلى استقبال إشعارات الحجوزات.
    /// Indicates whether booking notifications are enabled.
    /// </summary>
    [Display(Name = "إشعارات الحجوزات")]
    public bool BookingNotifications { get; set; } = true;

    /// <summary>
    /// يشير إلى استقبال إشعارات العروض.
    /// Indicates whether promotional notifications are enabled.
    /// </summary>
    [Display(Name = "إشعارات العروض")]
    public bool PromotionalNotifications { get; set; } = true;

    /// <summary>
    /// يشير إلى استقبال إشعارات البريد الإلكتروني.
    /// Indicates whether email notifications are enabled.
    /// </summary>
    [Display(Name = "إشعارات البريد الإلكتروني")]
    public bool EmailNotifications { get; set; } = true;

    /// <summary>
    /// يشير إلى استقبال إشعارات الرسائل النصية.
    /// Indicates whether SMS notifications are enabled.
    /// </summary>
    [Display(Name = "إشعارات الرسائل النصية")]
    public bool SmsNotifications { get; set; } = false;

    /// <summary>
    /// يشير إلى استقبال الإشعارات الفورية.
    /// Indicates whether push notifications are enabled.
    /// </summary>
    [Display(Name = "إشعارات الدفع")]
    public bool PushNotifications { get; set; } = true;

    /// <summary>
    /// إعدادات مرنة إضافية تُخزّن بصيغة JSON.
    /// Additional flexible settings stored as JSON.
    /// </summary>
    [Display(Name = "إعدادات إضافية")]
    public Dictionary<string, object>? AdditionalSettings { get; set; }

    /// <summary>
    /// مرجع التنقّل إلى المستخدم المرتبط.
    /// Navigation reference to the related user.
    /// </summary>
    public virtual User? User { get; set; }
}
