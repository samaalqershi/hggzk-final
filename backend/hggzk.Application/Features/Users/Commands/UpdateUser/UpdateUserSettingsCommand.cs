using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Users;
using YemenBooking.Application.Features.Users.DTOs;

namespace YemenBooking.Application.Features.Users.Commands.UpdateUser
{
    /// <summary>
    /// طلب تحديث إعدادات المستخدم.
    /// user settings update request.
    /// </summary>
    public class UpdateUserSettingsCommand : IRequest<ResultDto<bool>>
    {
        /// <summary>
        /// معرّف المستخدم
        /// user ID
        /// </summary>
        public Guid UserId { get; set; }

        /// <summary>
        /// اللغة المفضلة
        /// preferred language
        /// </summary>
        public string PreferredLanguage { get; set; } = "ar";

        /// <summary>
        /// العملة المفضلة
        /// preferred currency
        /// </summary>
        public string PreferredCurrency { get; set; } = "YER";

        /// <summary>
        /// المنطقة الزمنية
        /// time zone
        /// </summary>
        public string TimeZone { get; set; } = "Asia/Aden";

        /// <summary>
        /// الوضع الليلي
        /// dark mode
        /// </summary>
        public bool DarkMode { get; set; } = false;

    
        /// <summary>
        /// إعدادات الإشعارات
        /// notification settings
        /// </summary>
        public NotificationSettingsDto NotificationSettings { get; set; } = new();
        
        /// <summary>
        /// Additional Settings
        /// additional settings
        /// </summary>
        public Dictionary<string, object> AdditionalSettings { get; set; } = new();

        /// <summary>
        /// تفعيل المصادقة البيومترية
        /// biometric authentication enabled
        /// </summary>
        public bool? BiometricEnabled { get; set; }
    }
}