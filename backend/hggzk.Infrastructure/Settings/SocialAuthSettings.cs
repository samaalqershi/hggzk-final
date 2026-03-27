namespace YemenBooking.Infrastructure.Settings
{
    /// <summary>
    /// يمثل إعدادات مزودي تسجيل الدخول الاجتماعي المدعومين.
    /// Represents settings for the supported social sign-in providers.
    /// </summary>
    public class SocialAuthSettings
    {
        /// <summary>
        /// يحدد معرفات عملاء Google المسموح بها للتحقق من تسجيل الدخول.
        /// Gets or sets the allowed Google client identifiers used for sign-in validation.
        /// </summary>
        public string[] GoogleClientIds { get; set; } = new string[0];

        /// <summary>
        /// يحدد معرف تطبيق Facebook المستخدم في التكامل.
        /// Gets or sets the Facebook application identifier used by the integration.
        /// </summary>
        public string FacebookAppId { get; set; } = string.Empty;

        /// <summary>
        /// يحدد السر الخاص بتطبيق Facebook.
        /// Gets or sets the Facebook application secret.
        /// </summary>
        public string FacebookAppSecret { get; set; } = string.Empty;

        /// <summary>
        /// يحدد معرفات عملاء Apple المسموح بها للتحقق من تسجيل الدخول.
        /// Gets or sets the allowed Apple client identifiers used for sign-in validation.
        /// </summary>
        public string[] AppleClientIds { get; set; } = new string[0];
    }
}
