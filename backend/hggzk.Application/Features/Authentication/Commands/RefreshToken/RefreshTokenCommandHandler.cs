using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Authentication;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Entities;
using System.Text.Json;
using YemenBooking.Core.Interfaces.Repositories;
using System;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.AuditLog.Services;
using YemenBooking.Application.Features.Authentication.DTOs;
using YemenBooking.Application.Contracts.Services.Authentication;

namespace YemenBooking.Application.Features.Authentication.Commands.RefreshToken;

/// <summary>
/// معالج تحديث رمز الوصول.
/// token refresh handler.
/// </summary>
public class RefreshTokenCommandHandler : IRequestHandler<RefreshTokenCommand, ResultDto<RefreshTokenResponse>>
{
    private readonly IAuthenticationService _authService;
    private readonly IUserRepository _userRepository;
    private readonly ILogger<RefreshTokenCommandHandler> _logger;
    private readonly IAuditService _auditService;
    private readonly ICurrentUserService _currentUserService;

    /// <summary>
    /// يهيئ هذا المكوّن بالاعتماديات المطلوبة.
    /// Initializes this component with the required dependencies.
    /// </summary>
    /// <param name="authService">Authentication service. خدمة المصادقة.</param>
    /// <param name="userRepository">User repository. مستودع المستخدمين.</param>
    /// <param name="logger">Logger. مسجل الأحداث.</param>
    /// <param name="auditService">Audit service. خدمة التدقيق.</param>
    /// <param name="currentUserService">Current user context service. خدمة سياق المستخدم الحالي.</param>
    public RefreshTokenCommandHandler(
        IAuthenticationService authService,
        IUserRepository userRepository,
        ILogger<RefreshTokenCommandHandler> logger,
        IAuditService auditService,
        ICurrentUserService currentUserService)
    {
        _authService = authService;
        _userRepository = userRepository;
        _logger = logger;
        _auditService = auditService;
        _currentUserService = currentUserService;
    }

    /// <summary>
    /// ينفذ منطق المعالجة لهذا الطلب.
    /// executes the handling logic for this request.
    /// </summary>
    public async Task<ResultDto<RefreshTokenResponse>> Handle(RefreshTokenCommand request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء عملية تحديث رمز الوصول");

            // التحقق من صحة البيانات المدخلة
            if (string.IsNullOrWhiteSpace(request.RefreshToken))
            {
                _logger.LogWarning("محاولة تحديث رمز الوصول برمز تحديث فارغ");
                return ResultDto<RefreshTokenResponse>.Failed("رمز التحديث مطلوب", "REFRESH_TOKEN_REQUIRED");
            }

            // لم نعد نطلب رمز الوصول في مسار التحديث؛ يكفي رمز التحديث فقط
            if (string.IsNullOrWhiteSpace(request.AccessToken))
            {
                _logger.LogInformation("[RefreshToken] AccessToken فارغ - سيتم استخدام RefreshToken فقط للتحديث");
            }

            _logger.LogInformation("بدء عملية تحديث رمز الوصول");
            
            try
            {
                var newTokens = await _authService.RefreshTokenAsync(request.RefreshToken, cancellationToken);

                var response = new RefreshTokenResponse
                {
                    NewAccessToken = newTokens.AccessToken,
                    NewRefreshToken = newTokens.RefreshToken,
                    AccessTokenExpiry = newTokens.ExpiresAt,
                    RefreshTokenExpiry = newTokens.ExpiresAt.AddDays(0) // لا نملك قيمة منفصلة حالياً
                };

                _logger.LogInformation("تم تحديث رمز الوصول بنجاح للمستخدم: {UserId}", newTokens.UserId);

                // تدقيق يدوي: تحديث رمز الوصول
                var isMasterAdminIdentity = _authService.IsMasterAdminIdentity(newTokens.UserId, newTokens.Email);
                if (!isMasterAdminIdentity)
                {
                    var performerName = _currentUserService.Username;
                    var performerId = _currentUserService.UserId;
                    var notes = $"تم تحديث رمز الوصول للمستخدم {newTokens.UserId} بواسطة {performerName} (ID={performerId})";
                    await _auditService.LogAuditAsync(
                        entityType: "Auth",
                        entityId: newTokens.UserId,
                        action: AuditAction.UPDATE,
                        oldValues: null,
                        newValues: JsonSerializer.Serialize(new { Refreshed = true }),
                        performedBy: performerId,
                        notes: notes,
                        cancellationToken: cancellationToken);
                }

                return ResultDto<RefreshTokenResponse>.Ok(response, "تم تحديث رمز الوصول بنجاح");
            }
            catch (Exception refreshEx)
            {
                _logger.LogWarning(refreshEx, "فشل في تحديث رمز الوصول");
                return ResultDto<RefreshTokenResponse>.Failed("فشل تحديث رمز الوصول", "REFRESH_TOKEN_ERROR");
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء تحديث رمز الوصول");
            return ResultDto<RefreshTokenResponse>.Failed($"حدث خطأ أثناء تحديث رمز الوصول: {ex.Message}", "REFRESH_TOKEN_ERROR");
        }
    }
}
