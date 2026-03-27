using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Entities;
using System.Text.Json;
using YemenBooking.Application.Features.AuditLog.Services;
using System.Collections.Generic;
using YemenBooking.Application.Common.Interfaces;

namespace YemenBooking.Application.Features.Users.Commands.UpdateUser;

/// <summary>
/// معالج تحديث إعدادات المستخدم.
/// user settings update handler.
/// </summary>
public class UpdateUserSettingsCommandHandler : IRequestHandler<UpdateUserSettingsCommand, ResultDto<bool>>
{
    private readonly IUserRepository _userRepository;
    private readonly IUserSettingsRepository _userSettingsRepository;
    private readonly ILogger<UpdateUserSettingsCommandHandler> _logger;
    private readonly IAuditService _auditService;
    private readonly ICurrentUserService _currentUserService;
    /// <summary>
    /// يهيئ هذا المكوّن بالاعتماديات المطلوبة.
    /// Initializes this component with the required dependencies.
    /// </summary>
    /// <param name="userRepository">User repository. مستودع المستخدمين.</param>
    /// <param name="userSettingsRepository">User settings repository. مستودع إعدادات المستخدمين.</param>
    /// <param name="logger">Logger. مسجل الأحداث.</param>
    /// <param name="auditService">Audit service. خدمة التدقيق.</param>
    /// <param name="currentUserService">Current user context service. خدمة سياق المستخدم الحالي.</param>
    public UpdateUserSettingsCommandHandler(
        IUserRepository userRepository,
        IUserSettingsRepository userSettingsRepository,
        ILogger<UpdateUserSettingsCommandHandler> logger,
        IAuditService auditService,
        ICurrentUserService currentUserService)
    {
        _userRepository = userRepository;
        _userSettingsRepository = userSettingsRepository;
        _logger = logger;
        _auditService = auditService;
        _currentUserService = currentUserService;
    }

    /// <summary>
    /// ينفذ منطق المعالجة لهذا الطلب.
    /// executes the handling logic for this request.
    /// </summary>
    public async Task<ResultDto<bool>> Handle(UpdateUserSettingsCommand request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء عملية تحديث إعدادات المستخدم: {UserId}", request.UserId);

            // التحقق من صحة البيانات المدخلة
            var validationResult = ValidateRequest(request);
            if (!validationResult.IsSuccess)
            {
                return validationResult;
            }

            // التحقق من وجود المستخدم
            var user = await _userRepository.GetByIdAsync(request.UserId, cancellationToken);
            if (user == null)
            {
                _logger.LogWarning("لم يتم العثور على المستخدم: {UserId}", request.UserId);
                return ResultDto<bool>.Failed("المستخدم غير موجود", "USER_NOT_FOUND");
            }

            // البحث عن إعدادات المستخدم الحالية أو إنشاؤها
            var existingSettings = await _userSettingsRepository.GetByUserIdAsync(request.UserId, cancellationToken);
            
            if (existingSettings != null)
            {
                // تحديث الإعدادات الموجودة
                await UpdateExistingSettings(existingSettings, request, cancellationToken);
            }
            else
            {
                // إنشاء إعدادات جديدة
                await CreateNewSettings(request, cancellationToken);
            }

            await _userSettingsRepository.SaveChangesAsync(cancellationToken);

            _logger.LogInformation("تم تحديث إعدادات المستخدم بنجاح: {UserId}", request.UserId);

            // تدقيق يدوي: تحديث الإعدادات
            var performerName = _currentUserService.Username;
            var performerId = _currentUserService.UserId;
            var notes = $"تم تحديث إعدادات المستخدم {request.UserId} بواسطة {performerName} (ID={performerId})";
            await _auditService.LogAuditAsync(
                entityType: "UserSettings",
                entityId: request.UserId,
                action: AuditAction.UPDATE,
                oldValues: null,
                newValues: JsonSerializer.Serialize(new { request.PreferredLanguage, request.PreferredCurrency, request.TimeZone, request.DarkMode, request.NotificationSettings }),
                performedBy: performerId,
                notes: notes,
                cancellationToken: cancellationToken);

            return ResultDto<bool>.Ok( true, "تم تحديث الإعدادات بنجاح");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء تحديث إعدادات المستخدم: {UserId}", request.UserId);
            return ResultDto<bool>.Failed($"حدث خطأ أثناء تحديث الإعدادات: {ex.Message}", "UPDATE_SETTINGS_ERROR");
        }
    }

    private ResultDto<bool> ValidateRequest(UpdateUserSettingsCommand request)
    {
        if (request.UserId == Guid.Empty)
        {
            return ResultDto<bool>.Failed("معرف المستخدم غير صالح", "INVALID_USER_ID");
        }

        // التحقق من اللغة المفضلة
        var supportedLanguages = new[] { "ar", "en", "arabic", "english" };
        if (!supportedLanguages.Contains(request.PreferredLanguage.ToLower()))
        {
            return ResultDto<bool>.Failed("اللغة المفضلة غير مدعومة", "UNSUPPORTED_LANGUAGE");
        }

        // التحقق من العملة المفضلة
        var supportedCurrencies = new[] { "YER", "USD", "SAR", "AED", "EUR", "GBP" };
        if (!supportedCurrencies.Contains(request.PreferredCurrency.ToUpper()))
        {
            return ResultDto<bool>.Failed("العملة المفضلة غير مدعومة", "UNSUPPORTED_CURRENCY");
        }

        // التحقق من المنطقة الزمنية
        try
        {
            TimeZoneInfo.FindSystemTimeZoneById(request.TimeZone);
        }
        catch (TimeZoneNotFoundException)
        {
            return ResultDto<bool>.Failed("المنطقة الزمنية غير صالحة", "INVALID_TIMEZONE");
        }

        return ResultDto<bool>.Ok(true, "البيانات صحيحة");
    }

    private async Task UpdateExistingSettings(UserSettings existingSettings, UpdateUserSettingsCommand request, CancellationToken cancellationToken)
    {
        // تحديث الإعدادات
        existingSettings.PreferredLanguage = NormalizeLanguage(request.PreferredLanguage);
        existingSettings.PreferredCurrency = request.PreferredCurrency.ToUpper();
        existingSettings.TimeZone = request.TimeZone;
        existingSettings.DarkMode = request.DarkMode;
        // تحديث إعدادات الإشعارات من الطلب
        existingSettings.BookingNotifications = request.NotificationSettings.BookingNotifications;
        existingSettings.PromotionalNotifications = request.NotificationSettings.PromotionalNotifications;
        existingSettings.EmailNotifications = request.NotificationSettings.EmailNotifications;
        existingSettings.SmsNotifications = request.NotificationSettings.SmsNotifications;
        existingSettings.PushNotifications = request.NotificationSettings.PushNotifications;
        
        // تحديث الإعدادات الإضافية
        if (existingSettings.AdditionalSettings == null)
        {
            existingSettings.AdditionalSettings = new Dictionary<string, object>();
        }
        if (request.AdditionalSettings != null && request.AdditionalSettings.Count > 0)
        {
            foreach (var kv in request.AdditionalSettings)
            {
                existingSettings.AdditionalSettings[kv.Key] = kv.Value;
            }
        }
        if (request.BiometricEnabled.HasValue)
        {
            existingSettings.AdditionalSettings["biometricEnabled"] = request.BiometricEnabled.Value;
        }
        
        existingSettings.UpdatedAt = DateTime.UtcNow;

        var updated = await _userSettingsRepository.UpdateAsync(existingSettings, cancellationToken);
        if (updated == null)
        {
            _logger.LogError("فشل في تحديث إعدادات المستخدم: {UserId}", request.UserId);
            throw new InvalidOperationException("فشل في تحديث الإعدادات");
        }

        _logger.LogInformation("تم تحديث الإعدادات الموجودة للمستخدم: {UserId}", request.UserId);
    }

    private async Task CreateNewSettings(UpdateUserSettingsCommand request, CancellationToken cancellationToken)
    {
        var newSettings = new UserSettings
        {
            Id = Guid.NewGuid(),
            UserId = request.UserId,
            PreferredLanguage = NormalizeLanguage(request.PreferredLanguage),
            PreferredCurrency = request.PreferredCurrency.ToUpper(),
            TimeZone = request.TimeZone,
            DarkMode = request.DarkMode,
            BookingNotifications = request.NotificationSettings.BookingNotifications,
            PromotionalNotifications = request.NotificationSettings.PromotionalNotifications,
            EmailNotifications = request.NotificationSettings.EmailNotifications,
            SmsNotifications = request.NotificationSettings.SmsNotifications,
            PushNotifications = request.NotificationSettings.PushNotifications,
            AdditionalSettings = BuildAdditional(request),
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        var createResult = await _userSettingsRepository.CreateAsync(newSettings, cancellationToken);
        if (createResult == null)
        {
            _logger.LogError("فشل في إنشاء إعدادات جديدة للمستخدم: {UserId}", request.UserId);
            throw new InvalidOperationException("فشل في إنشاء الإعدادات");
        }

        _logger.LogInformation("تم إنشاء إعدادات جديدة للمستخدم: {UserId}", request.UserId);
    }

    private static Dictionary<string, object> BuildAdditional(UpdateUserSettingsCommand request)
    {
        var dict = request.AdditionalSettings != null
            ? new Dictionary<string, object>(request.AdditionalSettings)
            : new Dictionary<string, object>();
        if (request.BiometricEnabled.HasValue)
        {
            dict["biometricEnabled"] = request.BiometricEnabled.Value;
        }
        if (!dict.ContainsKey("biometricEnabled"))
        {
            dict["biometricEnabled"] = false;
        }
        return dict;
    }

    private string NormalizeLanguage(string language)
    {
        return language.ToLower() switch
        {
            "ar" or "arabic" or "عربي" => "ar",
            "en" or "english" or "إنجليزي" => "en",
            _ => "ar" // افتراضي
        };
    }
}
