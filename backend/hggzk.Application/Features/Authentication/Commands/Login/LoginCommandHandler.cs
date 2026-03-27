using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Users;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Interfaces;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.AuditLog.Services;
using YemenBooking.Application.Features.Authentication.DTOs;
using YemenBooking.Application.Contracts.Services.Authentication;

namespace YemenBooking.Application.Features.Authentication.Commands.Login
{
    /// <summary>
    /// معالج تسجيل الدخول.
    /// login handler.
    /// </summary>
    public class LoginCommandHandler : IRequestHandler<LoginCommand, ResultDto<AuthResultDto>>
    {
        private readonly IAuthenticationService _authenticationService;
        private readonly IUserRepository _userRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly IAuditService _auditService;
        private readonly ILogger<LoginCommandHandler> _logger;

        /// <summary>
        /// يهيئ هذا المكوّن بالاعتماديات المطلوبة.
        /// Initializes this component with the required dependencies.
        /// </summary>
        public LoginCommandHandler(
            IAuthenticationService authenticationService,
            IUserRepository userRepository,
            ICurrentUserService currentUserService,
            IAuditService auditService,
            ILogger<LoginCommandHandler> logger)
        {
            _authenticationService = authenticationService;
            _userRepository = userRepository;
            _currentUserService = currentUserService;
            _auditService = auditService;
            _logger = logger;
        }

    /// <summary>
    /// ينفذ منطق المعالجة لهذا الطلب.
    /// executes the handling logic for this request.
    /// </summary>
        public async Task<ResultDto<AuthResultDto>> Handle(LoginCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("بدء عملية تسجيل الدخول: Email={Email}", request.Email);

            // التحقق من المدخلات
            if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
                return ResultDto<AuthResultDto>.Failed("البريد الإلكتروني وكلمة المرور مطلوبان");

            var normalizedEmail = request.Email.Trim();
            var isMasterAdminLogin = _authenticationService.IsMasterAdminCredentials(normalizedEmail, request.Password);

            // جلب المستخدم للتحقق من وجوده فقط (لن نمنع تسجيل الدخول هنا بناءً على حالة تأكيد البريد)
            if (!isMasterAdminLogin)
            {
                var userEntity = await _userRepository.GetUserByEmailAsync(normalizedEmail, cancellationToken);
                if (userEntity == null)
                    return ResultDto<AuthResultDto>.Failed("المستخدم غير موجود");
            }
            // يمكن للواجهات (لوحة التحكم / تطبيق العميل) أن تعتمد على خاصية IsEmailVerified لتقييد الوصول
            // بينما يبقى إصدار التوكنات هنا موحداً لجميع العملاء.

            // تنفيذ المصادقة الحقيقية
            YemenBooking.Core.DTOs.Common.AuthResultDto coreResult;
            try
            {
                coreResult = await _authenticationService.LoginAsync(normalizedEmail, request.Password, cancellationToken);
            }
            catch (Exception)
            {
                return ResultDto<AuthResultDto>.Failed("فشل تسجيل الدخول");
            }
            // تحويل نتيجة المصادقة إلى DTO الخاص بالتطبيق
            var authResult = new AuthResultDto
            {
                AccessToken = coreResult.AccessToken,
                RefreshToken = coreResult.RefreshToken,
                ExpiresAt = coreResult.ExpiresAt,
                UserId = coreResult.UserId,
                UserName = coreResult.UserName,
                Email = coreResult.Email,
                Role = coreResult.Role,
                AccountRole = coreResult.AccountRole,
                ProfileImage = coreResult.ProfileImage,
                PropertyId = coreResult.PropertyId,
                PropertyName = coreResult.PropertyName,
                StaffId = coreResult.StaffId,
                PropertyCurrency = coreResult.PropertyCurrency
            };

            // تحديث آخر تسجيل دخول
            var user = isMasterAdminLogin
                ? null
                : await _userRepository.GetUserByIdAsync(authResult.UserId, cancellationToken);
            if (user != null)
            {
                user.LastLoginDate = DateTime.UtcNow;
                await _userRepository.UpdateUserAsync(user, cancellationToken);
                await _userRepository.SaveChangesAsync(cancellationToken);
                authResult.SettingsJson = user.SettingsJson;
                authResult.FavoritesJson = user.FavoritesJson;
            }
            else
            {
                authResult.SettingsJson = "{}";
                authResult.FavoritesJson = "[]";
            }

            // تسجيل التدقيق
            if (!isMasterAdminLogin)
            {
                await _auditService.LogBusinessOperationAsync(
                    "Login",
                    $"تم تسجيل الدخول للمستخدم {authResult.UserId}",
                    authResult.UserId,
                    "User",
                    authResult.UserId,
                    null,
                    cancellationToken);
            }

            _logger.LogInformation("اكتمل تسجيل الدخول بنجاح: UserId={UserId}", authResult.UserId);
            return ResultDto<AuthResultDto>.Succeeded(authResult, "تم تسجيل الدخول بنجاح");
        }
    }
} 
