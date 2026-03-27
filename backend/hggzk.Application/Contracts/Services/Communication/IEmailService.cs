namespace YemenBooking.Application.Contracts.Services.Communication;

/// <summary>
/// واجهة خدمة البريد الإلكتروني
/// Email service interface
/// </summary>
public interface IEmailService
{
    /// <summary>
    /// إرسال بريد ترحيبي
    /// Send welcome email
    /// </summary>
    Task<bool> SendWelcomeEmailAsync(
        string email, 
        string userName, 
        CancellationToken cancellationToken = default);

    /// <summary>
    /// إرسال بريد إلكتروني
    /// Send email
    /// </summary>
    Task<bool> SendEmailAsync(
        string to, 
        string subject, 
        string body, 
        bool isHtml = true, 
        CancellationToken cancellationToken = default);

    /// <summary>
    /// إرسال بريد إعادة تعيين كلمة المرور
    /// Send password reset email
    /// </summary>
    Task<bool> SendPasswordResetEmailAsync(
        string email,
        string userName,
        string resetToken,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// إرسال رسالة دعم للفريق المختص
    /// Send support message to support team
    /// </summary>
    Task<bool> SendSupportEmailAsync(
        string userName,
        string userEmail,
        string subject,
        string message,
        string? deviceInfo = null,
        CancellationToken cancellationToken = default);
}
