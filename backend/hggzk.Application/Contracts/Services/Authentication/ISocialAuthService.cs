using System.Threading;
using System.Threading.Tasks;

namespace YemenBooking.Application.Contracts.Services.Authentication;

/// <summary>
/// واجهة التحقق من مزودي المصادقة الاجتماعية.
/// Contract for verifying third-party social authentication providers.
/// </summary>
public interface ISocialAuthService
{
    /// <summary>
    /// يتحقق من رمز تعريف Google.
    /// Verifies a Google ID token.
    /// </summary>
    Task<SocialUserInfo> VerifyGoogleIdTokenAsync(string idToken, CancellationToken cancellationToken = default);

    /// <summary>
    /// يتحقق من رمز وصول Facebook.
    /// Verifies a Facebook access token.
    /// </summary>
    Task<SocialUserInfo> VerifyFacebookAccessTokenAsync(string accessToken, CancellationToken cancellationToken = default);

    /// <summary>
    /// يتحقق من رمز تعريف Apple.
    /// Verifies an Apple ID token.
    /// </summary>
    Task<SocialUserInfo> VerifyAppleIdTokenAsync(string idToken, string? nonce = null, CancellationToken cancellationToken = default);
}

/// <summary>
/// يمثل معلومات المستخدم المستخرجة من مزود المصادقة الاجتماعية.
/// Represents normalized user information returned from a social provider.
/// </summary>
public class SocialUserInfo
{
    /// <summary>
    /// اسم مزود المصادقة.
    /// Social provider name.
    /// </summary>
    public string Provider { get; set; } = string.Empty;

    /// <summary>
    /// المعرف الخارجي للمستخدم لدى المزود.
    /// External user identifier at the provider.
    /// </summary>
    public string ProviderUserId { get; set; } = string.Empty;

    /// <summary>
    /// البريد الإلكتروني للمستخدم إن توفر.
    /// User email when available.
    /// </summary>
    public string? Email { get; set; }

    /// <summary>
    /// الاسم المعروض للمستخدم إن توفر.
    /// User display name when available.
    /// </summary>
    public string? Name { get; set; }

    /// <summary>
    /// رابط صورة المستخدم إن توفر.
    /// User profile picture URL when available.
    /// </summary>
    public string? PictureUrl { get; set; }
}
