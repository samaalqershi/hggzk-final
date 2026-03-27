using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Contracts.Services.Authentication;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Features.AuditLog.Services;
using YemenBooking.Application.Common.Interfaces;
using System.Text.Json;

namespace YemenBooking.Application.Features.Authentication.Commands.Login;

/// <summary>
/// طلب تسجيل الدخول الاجتماعي.
/// social login request.
/// </summary>
public class SocialLoginCommand : IRequest<ResultDto<ClientLoginUserResponse>>
{
    /// <summary>
    /// المزوّد
    /// provider
    /// </summary>
    public string Provider { get; set; } = string.Empty; // google | facebook
    /// <summary>
    /// الرمز
    /// token
    /// </summary>
    public string Token { get; set; } = string.Empty; // id_token (google) | access_token (facebook)
    /// <summary>
    /// قيمة `nonce` المرتبطة بعملية الدخول للتحقق من الطلب ومنع إعادة الإرسال.
    /// nonce value associated with the sign-in flow to validate the request and prevent replay.
    /// </summary>
    public string? Nonce { get; set; }
    /// <summary>
    /// الاسم
    /// name
    /// </summary>
    public string? Name { get; set; }
}

/// <summary>
/// معالج تسجيل الدخول الاجتماعي.
/// social login handler.
/// </summary>
public class SocialLoginCommandHandler : IRequestHandler<SocialLoginCommand, ResultDto<ClientLoginUserResponse>>
{
    private readonly ISocialAuthService _socialAuthService;
    private readonly IUserRepository _userRepository;
    private readonly IRoleRepository _roleRepository;
    private readonly IPasswordHashingService _passwordHashingService;
    private readonly IAuthenticationService _authService;
    private readonly ILogger<SocialLoginCommandHandler> _logger;
    private readonly IAuditService _auditService;
    private readonly ICurrentUserService _currentUserService;

    /// <summary>
    /// يهيئ هذا المكوّن بالاعتماديات المطلوبة.
    /// Initializes this component with the required dependencies.
    /// </summary>
    public SocialLoginCommandHandler(
        ISocialAuthService socialAuthService,
        IUserRepository userRepository,
        IRoleRepository roleRepository,
        IPasswordHashingService passwordHashingService,
        IAuthenticationService authService,
        ILogger<SocialLoginCommandHandler> logger,
        IAuditService auditService,
        ICurrentUserService currentUserService)
    {
        _socialAuthService = socialAuthService;
        _userRepository = userRepository;
        _roleRepository = roleRepository;
        _passwordHashingService = passwordHashingService;
        _authService = authService;
        _logger = logger;
        _auditService = auditService;
        _currentUserService = currentUserService;
    }

    /// <summary>
    /// ينفذ منطق المعالجة لهذا الطلب.
    /// executes the handling logic for this request.
    /// </summary>
    public async Task<ResultDto<ClientLoginUserResponse>> Handle(SocialLoginCommand request, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.Provider) || string.IsNullOrWhiteSpace(request.Token))
        {
            return ResultDto<ClientLoginUserResponse>.Failed("المزوّد أو التوكن مفقود", "PROVIDER_OR_TOKEN_MISSING");
        }

        try
        {
            static string NormalizeProvider(string raw)
            {
                // Be resilient to client differences between debug/release builds or different SDK/provider naming.
                // Examples we've seen in the wild: "Apple", "apple.com", "signInWithApple", "ios_apple".
                var p = (raw ?? string.Empty).Trim().ToLowerInvariant();
                p = p.Replace("-", string.Empty)
                     .Replace("_", string.Empty)
                     .Replace(" ", string.Empty);
                return p;
            }

            var provider = NormalizeProvider(request.Provider);
            SocialUserInfo info;
            switch (provider)
            {
                case "google":
                case "googleoauth":
                case "googleoauth2":
                case "googlesignin":
                    info = await _socialAuthService.VerifyGoogleIdTokenAsync(request.Token, cancellationToken);
                    break;
                case "facebook":
                case "fb":
                case "facebooksignin":
                    info = await _socialAuthService.VerifyFacebookAccessTokenAsync(request.Token, cancellationToken);
                    break;
                case "apple":
                case "applecom":
                case "signinwithapple":
                case "iosapple":
                case "appleid":
                    info = await _socialAuthService.VerifyAppleIdTokenAsync(request.Token, request.Nonce, cancellationToken);
                    break;
                default:
                    _logger.LogWarning("Unsupported social provider received: '{ProviderRaw}' normalized='{ProviderNormalized}'", request.Provider, provider);
                    return ResultDto<ClientLoginUserResponse>.Failed("مزود غير مدعوم", "UNSUPPORTED_PROVIDER");
            }

            if (info == null || string.IsNullOrWhiteSpace(info.ProviderUserId))
            {
                return ResultDto<ClientLoginUserResponse>.Failed("تعذر التحقق من هوية المستخدم", "VERIFICATION_FAILED");
            }

            var requestedName = string.IsNullOrWhiteSpace(request.Name) ? null : request.Name.Trim();
            var effectiveName = !string.IsNullOrWhiteSpace(info.Name) ? info.Name : requestedName;

            // Try find user by provider id first for Apple (email can be missing or not stable)
            User? user = null;
            var isNewUser = false;
            // For Apple, use provider-userId lookup first (email might be missing/unstable).
            if (provider.StartsWith("apple", StringComparison.OrdinalIgnoreCase) || provider == "signinwithapple" || provider == "appleid")
            {
                user = await _userRepository.GetUserBySocialProviderIdAsync("apple", info.ProviderUserId, cancellationToken);
            }

            // Then try by email
            if (user == null && !string.IsNullOrWhiteSpace(info.Email))
            {
                user = await _userRepository.GetUserByEmailAsync(info.Email!, cancellationToken);
            }

            // If not found, create a new user
            if (user == null)
            {
                isNewUser = true;
                var pseudoEmail = info.Email ?? $"{info.ProviderUserId}@{provider}.local";
                var hashedPassword = await _passwordHashingService.HashPasswordAsync(Guid.NewGuid().ToString("N"), cancellationToken);
                user = new User
                {
                    Id = Guid.NewGuid(),
                    Name = string.IsNullOrWhiteSpace(effectiveName)
                        ? provider.StartsWith("google", StringComparison.OrdinalIgnoreCase) ? "Google User" : provider.StartsWith("facebook", StringComparison.OrdinalIgnoreCase) ? "Facebook User" : "Apple User"
                        : effectiveName!,
                    Email = pseudoEmail,
                    Phone = string.Empty,
                    Password = hashedPassword,
                    ProfileImage = info.PictureUrl,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow,
                    IsActive = true,
                    EmailConfirmed = true,
                    IsEmailVerified = true,
                    EmailVerifiedAt = DateTime.UtcNow,
                    SettingsJson = "{}",
                    FavoritesJson = "[]",
                };
                await _userRepository.CreateUserAsync(user, cancellationToken);
                
                // تعيين دور Client للمستخدم الجديد
                try
                {
                    var allRoles = await _roleRepository.GetAllRolesAsync(cancellationToken);
                    var clientRole = allRoles.FirstOrDefault(r => r.Name.Equals("Client", StringComparison.OrdinalIgnoreCase));
                    if (clientRole != null)
                    {
                        await _roleRepository.AssignRoleToUserAsync(user.Id, clientRole.Id, cancellationToken);
                        _logger.LogInformation("Assigned Client role to new social login user {UserId} via {Provider}", user.Id, provider);
                    }
                    else
                    {
                        _logger.LogWarning("Client role not found when creating social login user {UserId}", user.Id);
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Failed to assign Client role to social login user {UserId}", user.Id);
                }
            }
            else
            {
                // Update basic profile info
                var changed = false;
                if (!string.IsNullOrWhiteSpace(effectiveName) && !string.Equals(effectiveName, user.Name, StringComparison.Ordinal))
                {
                    if (!string.Equals(provider, "apple", StringComparison.OrdinalIgnoreCase) ||
                        string.IsNullOrWhiteSpace(user.Name) ||
                        string.Equals(user.Name, "Apple User", StringComparison.OrdinalIgnoreCase))
                    {
                        user.Name = effectiveName!;
                        changed = true;
                    }
                }
                if (!string.IsNullOrWhiteSpace(info.PictureUrl) && info.PictureUrl != user.ProfileImage) { user.ProfileImage = info.PictureUrl; changed = true; }
                if (!user.IsEmailVerified || !user.EmailConfirmed || user.EmailVerifiedAt == null)
                {
                    user.IsEmailVerified = true;
                    user.EmailConfirmed = true;
                    user.EmailVerifiedAt ??= DateTime.UtcNow;
                    changed = true;
                }
                if (changed)
                {
                    user.UpdatedAt = DateTime.UtcNow;
                    await _userRepository.UpdateUserAsync(user, cancellationToken);
                }
            }

            // Persist provider mapping into SettingsJson
            try
            {
                var settings = string.IsNullOrWhiteSpace(user.SettingsJson) ? new Dictionary<string, object>() :
                    JsonSerializer.Deserialize<Dictionary<string, object>>(user.SettingsJson) ?? new Dictionary<string, object>();
                var social = settings.ContainsKey("social") && settings["social"] is JsonElement je && je.ValueKind == JsonValueKind.Object
                    ? JsonSerializer.Deserialize<Dictionary<string, object>>(je.GetRawText())!
                    : settings.ContainsKey("social") && settings["social"] is Dictionary<string, object> d ? d : new Dictionary<string, object>();

                // Store canonical provider keys (google/facebook/apple) to keep data consistent.
                var canonicalProvider = provider.StartsWith("google", StringComparison.OrdinalIgnoreCase)
                    ? "google"
                    : provider.StartsWith("facebook", StringComparison.OrdinalIgnoreCase)
                        ? "facebook"
                        : "apple";

                social[canonicalProvider] = new { id = info.ProviderUserId, email = info.Email };
                settings["social"] = social;
                user.SettingsJson = JsonSerializer.Serialize(settings);
                user.UpdatedAt = DateTime.UtcNow;
                if (!isNewUser)
                {
                    await _userRepository.UpdateUserAsync(user, cancellationToken);
                }
            }
            catch { }

            await _userRepository.SaveChangesAsync(cancellationToken);

            // Issue tokens
            var authResult = await _authService.IssueTokensForUserAsync(user.Id, cancellationToken);

            var response = new ClientLoginUserResponse
            {
                UserId = authResult.UserId,
                Name = authResult.UserName,
                Email = authResult.Email,
                Phone = "",
                AccessToken = authResult.AccessToken,
                RefreshToken = authResult.RefreshToken,
                Roles = new List<string> { string.IsNullOrWhiteSpace(authResult.AccountRole) ? authResult.Role : authResult.AccountRole },
            };

            // Optional audit
            try
            {
                var performerName = _currentUserService.Username;
                var performerId = _currentUserService.UserId;
                var notes = $"تم تسجيل دخول اجتماعي للمستخدم {authResult.UserId} عبر {provider} بواسطة {performerName} (ID={performerId})";
                await _auditService.LogAuditAsync(
                    entityType: "User",
                    entityId: authResult.UserId,
                    action: YemenBooking.Core.Entities.AuditAction.LOGIN,
                    oldValues: null,
                    newValues: JsonSerializer.Serialize(new { Success = true, Provider = provider }),
                    performedBy: performerId,
                    notes: notes,
                    cancellationToken: cancellationToken);
            }
            catch { }

            return ResultDto<ClientLoginUserResponse>.Ok(response, "تم تسجيل الدخول بنجاح");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Social login failed for provider {Provider}", request.Provider);
            return ResultDto<ClientLoginUserResponse>.Failed("فشل تسجيل الدخول الاجتماعي", "SOCIAL_LOGIN_FAILED");
        }
    }
}
