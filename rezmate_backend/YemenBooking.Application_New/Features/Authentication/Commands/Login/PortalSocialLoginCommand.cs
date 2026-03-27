using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Authentication.DTOs;
using YemenBooking.Application.Features.Authentication.Services;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.Authentication.Commands.Login;

public class PortalSocialLoginCommand : IRequest<ResultDto<AuthResultDto>>
{
    public string Provider { get; set; } = string.Empty;
    public string Token { get; set; } = string.Empty;
    public string? Nonce { get; set; }
    public string? Name { get; set; }
}

public class PortalSocialLoginCommandHandler : IRequestHandler<PortalSocialLoginCommand, ResultDto<AuthResultDto>>
{
    private readonly ISocialAuthService _socialAuthService;
    private readonly IUserRepository _userRepository;
    private readonly IRoleRepository _roleRepository;
    private readonly IPasswordHashingService _passwordHashingService;
    private readonly IAuthenticationService _authService;
    private readonly ILogger<PortalSocialLoginCommandHandler> _logger;

    public PortalSocialLoginCommandHandler(
        ISocialAuthService socialAuthService,
        IUserRepository userRepository,
        IRoleRepository roleRepository,
        IPasswordHashingService passwordHashingService,
        IAuthenticationService authService,
        ILogger<PortalSocialLoginCommandHandler> logger)
    {
        _socialAuthService = socialAuthService;
        _userRepository = userRepository;
        _roleRepository = roleRepository;
        _passwordHashingService = passwordHashingService;
        _authService = authService;
        _logger = logger;
    }

    public async Task<ResultDto<AuthResultDto>> Handle(PortalSocialLoginCommand request, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.Provider) || string.IsNullOrWhiteSpace(request.Token))
        {
            return ResultDto<AuthResultDto>.Failed("المزوّد أو التوكن مفقود", "PROVIDER_OR_TOKEN_MISSING");
        }

        try
        {
            var provider = request.Provider.Trim().ToLowerInvariant();
            SocialUserInfo info;
            switch (provider)
            {
                case "google":
                    info = await _socialAuthService.VerifyGoogleIdTokenAsync(request.Token, cancellationToken);
                    break;
                case "facebook":
                    info = await _socialAuthService.VerifyFacebookAccessTokenAsync(request.Token, cancellationToken);
                    break;
                case "apple":
                    info = await _socialAuthService.VerifyAppleIdTokenAsync(request.Token, request.Nonce, cancellationToken);
                    break;
                default:
                    return ResultDto<AuthResultDto>.Failed("مزود غير مدعوم", "UNSUPPORTED_PROVIDER");
            }

            if (info == null || string.IsNullOrWhiteSpace(info.ProviderUserId))
            {
                return ResultDto<AuthResultDto>.Failed("تعذر التحقق من هوية المستخدم", "VERIFICATION_FAILED");
            }

            var requestedName = string.IsNullOrWhiteSpace(request.Name) ? null : request.Name.Trim();
            var effectiveName = !string.IsNullOrWhiteSpace(info.Name) ? info.Name : requestedName;

            User? user = null;
            if (string.Equals(provider, "apple", StringComparison.OrdinalIgnoreCase))
            {
                user = await _userRepository.GetUserBySocialProviderIdAsync(provider, info.ProviderUserId, cancellationToken);
            }

            if (user == null && !string.IsNullOrWhiteSpace(info.Email))
            {
                user = await _userRepository.GetUserByEmailAsync(info.Email!, cancellationToken);
            }

            var isNewUser = false;
            if (user == null)
            {
                isNewUser = true;
                var pseudoEmail = info.Email ?? $"{info.ProviderUserId}@{provider}.local";
                var hashedPassword = await _passwordHashingService.HashPasswordAsync(Guid.NewGuid().ToString("N"), cancellationToken);

                user = new User
                {
                    Id = Guid.NewGuid(),
                    Name = string.IsNullOrWhiteSpace(effectiveName)
                        ? provider == "google" ? "Google User" : provider == "facebook" ? "Facebook User" : "Apple User"
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

                try
                {
                    var allRoles = await _roleRepository.GetAllRolesAsync(cancellationToken);
                    var ownerRole = allRoles.FirstOrDefault(r => r.Name.Equals("Owner", StringComparison.OrdinalIgnoreCase));
                    if (ownerRole != null)
                    {
                        await _roleRepository.AssignRoleToUserAsync(user.Id, ownerRole.Id, cancellationToken);
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Failed to assign Owner role to portal social login user {UserId}", user.Id);
                }
            }
            else
            {
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

                if (!string.IsNullOrWhiteSpace(info.PictureUrl) && info.PictureUrl != user.ProfileImage)
                {
                    user.ProfileImage = info.PictureUrl;
                    changed = true;
                }

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

            try
            {
                var settings = string.IsNullOrWhiteSpace(user.SettingsJson)
                    ? new Dictionary<string, object>()
                    : JsonSerializer.Deserialize<Dictionary<string, object>>(user.SettingsJson) ?? new Dictionary<string, object>();

                var social = settings.ContainsKey("social") && settings["social"] is JsonElement je && je.ValueKind == JsonValueKind.Object
                    ? JsonSerializer.Deserialize<Dictionary<string, object>>(je.GetRawText())!
                    : settings.ContainsKey("social") && settings["social"] is Dictionary<string, object> d
                        ? d
                        : new Dictionary<string, object>();

                social[provider] = new { id = info.ProviderUserId, email = info.Email };
                settings["social"] = social;
                user.SettingsJson = JsonSerializer.Serialize(settings);
                user.UpdatedAt = DateTime.UtcNow;
                await _userRepository.UpdateUserAsync(user, cancellationToken);
            }
            catch { }

            var authResult = await _authService.IssueTokensForUserAsync(user.Id, cancellationToken);

            var roles = (await _userRepository.GetUserRolesAsync(user.Id, cancellationToken))?.ToList() ?? new List<UserRole>();
            var roleNames = roles.Select(r => r.Role?.Name ?? string.Empty)
                .Where(n => !string.IsNullOrWhiteSpace(n))
                .ToList();

            var normalizedAccountRole = (authResult.AccountRole ?? string.Empty).Trim().ToLowerInvariant();
            if (normalizedAccountRole == "client")
            {
                return ResultDto<AuthResultDto>.Failed("لا يُسمح لحساب العملاء بتسجيل الدخول إلى لوحة التحكم", "PORTAL_CLIENT_NOT_ALLOWED");
            }

            var requiresProfileCompletion = false;
            if (normalizedAccountRole == "owner")
            {
                requiresProfileCompletion = string.IsNullOrWhiteSpace(authResult.PropertyId);
            }
            else
            {
                requiresProfileCompletion = false;
            }

            var response = new AuthResultDto
            {
                AccessToken = authResult.AccessToken,
                RefreshToken = authResult.RefreshToken,
                ExpiresAt = authResult.ExpiresAt,
                UserId = authResult.UserId,
                UserName = authResult.UserName,
                Email = authResult.Email,
                Role = authResult.Role,
                AccountRole = authResult.AccountRole,
                ProfileImage = authResult.ProfileImage,
                PropertyId = authResult.PropertyId,
                PropertyName = authResult.PropertyName,
                StaffId = authResult.StaffId,
                PropertyCurrency = authResult.PropertyCurrency,
                SettingsJson = user.SettingsJson ?? "{}",
                FavoritesJson = user.FavoritesJson ?? "[]",
                RequiresProfileCompletion = requiresProfileCompletion || isNewUser
            };

            return ResultDto<AuthResultDto>.Ok(response, "تم تسجيل الدخول بنجاح");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Portal social login failed for provider {Provider}", request.Provider);
            return ResultDto<AuthResultDto>.Failed("فشل تسجيل الدخول الاجتماعي", "SOCIAL_LOGIN_FAILED");
        }
    }
}
