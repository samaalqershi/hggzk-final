using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using System.Text.Json;
using YemenBooking.Core.Interfaces.Repositories;
using System;
using System.Threading;
using YemenBooking.Application.Features.AuditLog.Services;
using System.Threading.Tasks;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.Authentication.DTOs;
using YemenBooking.Application.Contracts.Services.Authentication;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Enums;
using Microsoft.EntityFrameworkCore;

namespace YemenBooking.Application.Features.Authentication.Commands.Account
{
    /// <summary>
    /// معالج حذف الحساب.
    /// account deletion handler.
    /// </summary>
    public class DeleteAccountCommandHandler : IRequestHandler<DeleteAccountCommand, ResultDto<DeleteAccountResponse>>
    {
        private readonly IPasswordHashingService _passwordHashingService;
        private readonly ISocialAuthService _socialAuthService;
        private readonly IUserRepository _userRepository;
        private readonly IBookingRepository _bookingRepository;
        private readonly ILogger<DeleteAccountCommandHandler> _logger;
        private readonly IAuditService _auditService;
        private readonly ICurrentUserService _currentUserService;

    /// <summary>
    /// يهيئ هذا المكوّن بالاعتماديات المطلوبة.
    /// Initializes this component with the required dependencies.
    /// </summary>
    /// <param name="passwordHashingService">Password hashing service. خدمة تجزئة كلمات المرور.</param>
    /// <param name="socialAuthService">Social authentication service. خدمة التحقق الاجتماعي.</param>
    /// <param name="userRepository">User repository. مستودع المستخدمين.</param>
    /// <param name="bookingRepository">Booking repository. مستودع الحجوزات.</param>
    /// <param name="logger">Logger. مسجل الأحداث.</param>
    /// <param name="auditService">Audit service. خدمة التدقيق.</param>
    /// <param name="currentUserService">Current user context service. خدمة سياق المستخدم الحالي.</param>
        public DeleteAccountCommandHandler(
            IPasswordHashingService passwordHashingService,
            ISocialAuthService socialAuthService,
            IUserRepository userRepository,
            IBookingRepository bookingRepository,
            ILogger<DeleteAccountCommandHandler> logger,
            IAuditService auditService,
            ICurrentUserService currentUserService)
        {
            _passwordHashingService = passwordHashingService;
            _socialAuthService = socialAuthService;
            _userRepository = userRepository;
            _bookingRepository = bookingRepository;
            _logger = logger;
            _auditService = auditService;
            _currentUserService = currentUserService;
        }

    /// <summary>
    /// ينفذ منطق المعالجة لهذا الطلب.
    /// executes the handling logic for this request.
    /// </summary>
        public async Task<ResultDto<DeleteAccountResponse>> Handle(DeleteAccountCommand request, CancellationToken cancellationToken)
        {
            try
            {
                // Prefer authenticated user id (do not trust userId from request body)
                var userId = _currentUserService.UserId != Guid.Empty
                    ? _currentUserService.UserId
                    : request.UserId;

                _logger.LogInformation("بدء عملية حذف حساب المستخدم: {UserId}", userId);

                // التحقق من صحة البيانات المدخلة
                if (userId == Guid.Empty)
                {
                    _logger.LogWarning("محاولة حذف حساب بدون معرف مستخدم صالح");
                    return ResultDto<DeleteAccountResponse>.Failed("معرف المستخدم غير صالح", "INVALID_USER_ID");
                }

                // البحث عن المستخدم
                var user = await _userRepository.GetUserByIdAsync(userId, cancellationToken);
                if (user == null)
                {
                    _logger.LogWarning("لم يتم العثور على المستخدم: {UserId}", userId);
                    return ResultDto<DeleteAccountResponse>.Failed("المستخدم غير موجود", "USER_NOT_FOUND");
                }

                var identityVerification = await VerifyIdentityAsync(request, user, cancellationToken);
                if (!identityVerification.IsValid)
                {
                    return ResultDto<DeleteAccountResponse>.Failed(
                        identityVerification.Message,
                        identityVerification.Code);
                }

                _logger.LogInformation("تم التحقق من هوية المستخدم لحذف الحساب: {UserId}", userId);

                // التحقق من وجود حجوزات نشطة لم ينتهِ وقتها بعد
                // الحجوزات التي انتهى تاريخ مغادرتها (CheckOut) لا تعتبر نشطة
                // نستخدم Date فقط للمقارنة لأن CheckOut عادة يكون تاريخ بدون وقت (00:00:00)
                // الحجز يعتبر نشطاً فقط إذا كان تاريخ المغادرة > اليوم (أي لم يحن موعد المغادرة بعد)
                var now = DateTime.UtcNow;
                var today = now.Date;
                var hasActiveBookings = await _bookingRepository
                    .GetQueryable()
                    .AnyAsync(b => b.UserId == userId &&
                                 (b.Status == BookingStatus.Pending || b.Status == BookingStatus.Confirmed || b.Status == BookingStatus.CheckedIn) &&
                                 b.CheckOut.Date > today,
                        cancellationToken);

                if (hasActiveBookings)
                {
                    _logger.LogWarning("محاولة حذف حساب مع وجود حجوزات نشطة لم تنتهِ بعد: {UserId}", userId);
                    return ResultDto<DeleteAccountResponse>.Failed("لا يمكن حذف الحساب لوجود حجوزات نشطة لم ينتهِ وقتها. يرجى الانتظار حتى انتهاء الحجوزات أو إلغائها", "ACTIVE_BOOKINGS_EXIST");
                }

                // تسجيل سبب الحذف إذا تم توفيره
                if (!string.IsNullOrWhiteSpace(request.Reason))
                {
                    _logger.LogInformation("سبب حذف الحساب {UserId}: {Reason}", userId, request.Reason);
                }

                // Soft delete + anonymize personal data (PII)
                user.IsDeleted = true;
                user.DeletedAt = DateTime.UtcNow;
                user.IsActive = false;
                user.UpdatedAt = DateTime.UtcNow;

                // Ensure unique email/phone to avoid blocking future registrations
                // Phone column is varchar(20), so we use a short unique identifier
                var shortId = user.Id.ToString("N").Substring(0, 8); // First 8 chars of GUID without dashes
                user.Email = $"deleted+{user.Id}@example.invalid";
                user.Name = "حساب محذوف";
                user.Phone = $"DEL{shortId}";  // Max 11 chars: "DEL" + 8 chars = 11 chars (fits in varchar(20))
                user.ProfileImage = null;
                user.ProfileImageUrl = null;

                // Clear verification/reset tokens
                user.EmailConfirmationToken = null;
                user.EmailConfirmationTokenExpires = null;
                user.PasswordResetToken = null;
                user.PasswordResetTokenExpires = null;
                user.PhoneNumberConfirmationCode = null;
                user.PhoneNumberConfirmationCodeExpires = null;

                await _userRepository.UpdateUserAsync(user, cancellationToken);
                await _userRepository.SaveChangesAsync(cancellationToken);
                _logger.LogInformation("تم حذف الحساب (Soft Delete) بنجاح: {UserId}", userId);

                // تدقيق يدوي: حذف الحساب
                var performerName = _currentUserService.Username;
                var performerId = _currentUserService.UserId;
                var notes = $"تم حذف حساب المستخدم {userId} بواسطة {performerName} (ID={performerId})";
                await _auditService.LogAuditAsync(
                    entityType: "User",
                    entityId: userId,
                    action: YemenBooking.Core.Entities.AuditAction.DELETE,
                    oldValues: null,
                    newValues: JsonSerializer.Serialize(new { Success = true, Reason = request.Reason }),
                    performedBy: performerId,
                    notes: notes,
                    cancellationToken: cancellationToken);

                var response = new DeleteAccountResponse
                {
                    Success = true,
                    Message = "تم حذف الحساب بنجاح. نأسف لرؤيتك تغادر"
                };

                return ResultDto<DeleteAccountResponse>.Ok(response, "تم حذف الحساب بنجاح");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ أثناء حذف حساب المستخدم: {UserId}", request.UserId);
                return ResultDto<DeleteAccountResponse>.Failed($"حدث خطأ أثناء حذف الحساب: {ex.Message}", "DELETE_ACCOUNT_ERROR");
            }
        }

        private async Task<(bool IsValid, string Message, string Code)> VerifyIdentityAsync(
            DeleteAccountCommand request,
            User user,
            CancellationToken cancellationToken)
        {
            var hasPassword = !string.IsNullOrWhiteSpace(request.Password);
            var hasSocialProof = !string.IsNullOrWhiteSpace(request.SocialProvider)
                                 && !string.IsNullOrWhiteSpace(request.SocialToken);
            var hasSocialProviderOnly = !string.IsNullOrWhiteSpace(request.SocialProvider)
                                        && string.IsNullOrWhiteSpace(request.SocialToken);

            if (!hasPassword && !hasSocialProof)
            {
                if (hasSocialProviderOnly)
                {
                    return (false, "تعذر استلام رمز التحقق من مزود تسجيل الدخول الاجتماعي. أعد المحاولة", "SOCIAL_TOKEN_MISSING");
                }
                return (false, "يجب تأكيد الهوية بكلمة المرور أو عبر Google/Apple", "IDENTITY_CONFIRMATION_REQUIRED");
            }

            if (hasPassword)
            {
                var passwordValid = await _passwordHashingService.VerifyPasswordAsync(
                    request.Password!,
                    user.Password,
                    cancellationToken);
                if (passwordValid)
                {
                    return (true, string.Empty, string.Empty);
                }

                if (!hasSocialProof)
                {
                    return (false, "كلمة المرور غير صحيحة", "INVALID_PASSWORD");
                }
            }

            if (!hasSocialProof)
            {
                return (false, "تعذر تأكيد الهوية", "IDENTITY_CONFIRMATION_FAILED");
            }

            var provider = CanonicalizeProvider(request.SocialProvider);
            if (provider == null)
            {
                return (false, "مزود تسجيل الدخول الاجتماعي غير مدعوم", "UNSUPPORTED_SOCIAL_PROVIDER");
            }

            try
            {
                SocialUserInfo socialInfo = provider switch
                {
                    "google" => await _socialAuthService.VerifyGoogleIdTokenAsync(request.SocialToken!, cancellationToken),
                    "facebook" => await _socialAuthService.VerifyFacebookAccessTokenAsync(request.SocialToken!, cancellationToken),
                    "apple" => await _socialAuthService.VerifyAppleIdTokenAsync(request.SocialToken!, request.SocialNonce, cancellationToken),
                    _ => throw new InvalidOperationException("Unsupported social provider")
                };

                if (socialInfo == null || string.IsNullOrWhiteSpace(socialInfo.ProviderUserId))
                {
                    return (false, "تعذر التحقق من حساب التواصل الاجتماعي", "SOCIAL_VERIFICATION_FAILED");
                }

                var mappedUser = await _userRepository.GetUserBySocialProviderIdAsync(
                    provider,
                    socialInfo.ProviderUserId,
                    cancellationToken);

                if (mappedUser?.Id == user.Id)
                {
                    _logger.LogInformation(
                        "تم تأكيد هوية المستخدم لحذف الحساب عبر {Provider}. UserId={UserId}",
                        provider,
                        user.Id);
                    return (true, string.Empty, string.Empty);
                }

                if (!string.IsNullOrWhiteSpace(socialInfo.Email)
                    && string.Equals(socialInfo.Email.Trim(), user.Email.Trim(), StringComparison.OrdinalIgnoreCase))
                {
                    _logger.LogWarning(
                        "تم تأكيد حذف الحساب عبر تطابق البريد بدون Social Mapping صريح. UserId={UserId}, Provider={Provider}",
                        user.Id,
                        provider);
                    return (true, string.Empty, string.Empty);
                }

                return (false, "حساب التواصل الاجتماعي لا يطابق هذا المستخدم", "SOCIAL_ACCOUNT_MISMATCH");
            }
            catch (Exception ex)
            {
                _logger.LogWarning(
                    ex,
                    "فشل التحقق الاجتماعي أثناء حذف الحساب. UserId={UserId}, Provider={Provider}",
                    user.Id,
                    request.SocialProvider);
                return (false, "فشل التحقق عبر مزود تسجيل الدخول الاجتماعي", "SOCIAL_VERIFICATION_FAILED");
            }
        }

        private static string? CanonicalizeProvider(string? rawProvider)
        {
            if (string.IsNullOrWhiteSpace(rawProvider))
            {
                return null;
            }

            var provider = rawProvider.Trim().ToLowerInvariant()
                .Replace("-", string.Empty)
                .Replace("_", string.Empty)
                .Replace(" ", string.Empty);

            if (provider.StartsWith("google", StringComparison.OrdinalIgnoreCase))
            {
                return "google";
            }

            if (provider.StartsWith("facebook", StringComparison.OrdinalIgnoreCase) || provider == "fb")
            {
                return "facebook";
            }

            if (provider.StartsWith("apple", StringComparison.OrdinalIgnoreCase) || provider == "signinwithapple")
            {
                return "apple";
            }

            return null;
        }
    }
}
