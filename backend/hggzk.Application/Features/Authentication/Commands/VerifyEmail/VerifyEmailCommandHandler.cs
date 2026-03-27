using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Authentication;
using YemenBooking.Application.Common.Models;
using System.Text.Json;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.AuditLog.Services;
using YemenBooking.Application.Features.Authentication.DTOs;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Features.Authentication.Commands.VerifyEmail;

/// <summary>
/// معالج التحقق من البريد الإلكتروني.
/// email verification handler.
/// </summary>
public class VerifyEmailCommandHandler : IRequestHandler<VerifyEmailCommand, ResultDto<VerifyEmailResponse>>
{
    private readonly IUserRepository _userRepository;
    private readonly IEmailVerificationService _emailVerificationService;
    private readonly ILogger<VerifyEmailCommandHandler> _logger;
    private readonly IAuditService _auditService;
    private readonly ICurrentUserService _currentUserService;

    /// <summary>
    /// يهيئ هذا المكوّن بالاعتماديات المطلوبة.
    /// Initializes this component with the required dependencies.
    /// </summary>
    /// <param name="userRepository">مستودع المستخدمين / User repository.</param>
    /// <param name="emailVerificationService">خدمة تأكيد البريد الإلكتروني / Email verification service.</param>
    /// <param name="logger">مسجل الأحداث / Logger instance.</param>
    /// <param name="auditService">خدمة التدقيق / Audit service.</param>
    /// <param name="currentUserService">خدمة المستخدم الحالي / Current user service.</param>
    public VerifyEmailCommandHandler(
        IUserRepository userRepository,
        IEmailVerificationService emailVerificationService,
        ILogger<VerifyEmailCommandHandler> logger,
        IAuditService auditService,
        ICurrentUserService currentUserService)
    {
        _userRepository = userRepository;
        _emailVerificationService = emailVerificationService;
        _logger = logger;
        _auditService = auditService;
        _currentUserService = currentUserService;
    }

    /// <summary>
    /// ينفذ منطق المعالجة لهذا الطلب.
    /// executes the handling logic for this request.
    /// </summary>
    public async Task<ResultDto<VerifyEmailResponse>> Handle(VerifyEmailCommand request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء عملية تأكيد البريد الإلكتروني للمستخدم: {UserId}", request.UserId);

            // التحقق من صحة البيانات المدخلة / Validate input data.
            if (request.UserId == Guid.Empty)
            {
                _logger.LogWarning("محاولة تأكيد بريد إلكتروني بمعرف مستخدم غير صالح");
                return ResultDto<VerifyEmailResponse>.Failed("معرف المستخدم غير صالح", "INVALID_USER_ID");
            }

            if (string.IsNullOrWhiteSpace(request.VerificationToken))
            {
                return ResultDto<VerifyEmailResponse>.Failed("رمز التأكيد مطلوب", "VERIFICATION_TOKEN_REQUIRED");
            }

            // البحث عن المستخدم / Look up the user.
            var user = await _userRepository.GetByIdAsync(request.UserId, cancellationToken);
            if (user == null)
            {
                _logger.LogWarning("لم يتم العثور على المستخدم: {UserId}", request.UserId);
                return ResultDto<VerifyEmailResponse>.Failed("المستخدم غير موجود", "USER_NOT_FOUND");
            }

            // التحقق من حالة تأكيد البريد الإلكتروني / Check whether the email is already verified.
            if (user.IsEmailVerified)
            {
                _logger.LogInformation("البريد الإلكتروني مؤكد مسبقاً للمستخدم: {UserId}", request.UserId);
                
                var alreadyVerifiedResponse = new VerifyEmailResponse
                {
                    Success = true,
                    Message = "البريد الإلكتروني مؤكد مسبقاً"
                };

                return ResultDto<VerifyEmailResponse>.Ok(alreadyVerifiedResponse, "البريد الإلكتروني مؤكد مسبقاً");
            }

            // التحقق من صلاحية الرمز من خدمة التحقق / Validate token expiry with the verification service.
            var isExpired = await _emailVerificationService.IsCodeExpiredAsync(user.Email, request.VerificationToken);
            if (isExpired)
            {
                _logger.LogWarning("رمز التأكيد منتهي الصلاحية للمستخدم: {UserId}", request.UserId);
                return ResultDto<VerifyEmailResponse>.Failed("رمز التأكيد منتهي الصلاحية", "VERIFICATION_TOKEN_EXPIRED");
            }

            var isValidToken = await _emailVerificationService.VerifyCodeAsync(user.Email, request.VerificationToken);
            if (!isValidToken)
            {
                _logger.LogWarning("رمز التأكيد غير صحيح للمستخدم: {UserId}", request.UserId);
                return ResultDto<VerifyEmailResponse>.Failed("رمز التأكيد غير صحيح", "INVALID_VERIFICATION_TOKEN");
            }

            // تأكيد البريد الإلكتروني / Mark the email as verified.
            user.IsEmailVerified = true;
            user.EmailVerifiedAt = DateTime.UtcNow;
            user.UpdatedAt = DateTime.UtcNow;

            await _userRepository.UpdateUserAsync(user, cancellationToken);
            await _userRepository.SaveChangesAsync(cancellationToken);
            
            // تم حذف الرمز داخل خدمة التحقق عند نجاح التحقق / The token is removed by the verification service after success.

            _logger.LogInformation("تم تأكيد البريد الإلكتروني بنجاح للمستخدم: {UserId}", request.UserId);

            var response = new VerifyEmailResponse
            {
                Success = true,
                Message = "تم تأكيد البريد الإلكتروني بنجاح. يمكنك الآن الاستفادة من جميع ميزات التطبيق"
            };

            // تدقيق يدوي: تأكيد البريد الإلكتروني / Manual audit: email verification.
            var performerName = _currentUserService.Username;
            var performerId = _currentUserService.UserId;
            var notes = $"تم تأكيد البريد الإلكتروني للمستخدم {request.UserId} بواسطة {performerName} (ID={performerId})";
            await _auditService.LogAuditAsync(
                entityType: "User",
                entityId: request.UserId,
                action: AuditAction.UPDATE,
                oldValues: null,
                newValues: JsonSerializer.Serialize(new { EmailVerified = true }),
                performedBy: performerId,
                notes: notes,
                cancellationToken: cancellationToken);

            return ResultDto<VerifyEmailResponse>.Ok(response, "تم تأكيد البريد الإلكتروني بنجاح");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء تأكيد البريد الإلكتروني للمستخدم: {UserId}", request.UserId);
            return ResultDto<VerifyEmailResponse>.Failed($"حدث خطأ أثناء تأكيد البريد الإلكتروني: {ex.Message}", "VERIFY_EMAIL_ERROR");
        }
    }
}
