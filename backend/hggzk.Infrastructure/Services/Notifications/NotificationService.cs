using System;
using System.Collections.Generic;
using System.Globalization;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Notifications.Services;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Notifications;

namespace YemenBooking.Infrastructure.Services.Notifications;

/// <summary>
/// يمثل خدمة توزيع الإشعارات عبر القنوات المتاحة.
/// Represents the notification distribution service across available channels.
/// </summary>
public class NotificationService : INotificationService
{
    private readonly IEmailService _emailService;

    private readonly ISmsService _smsService;

    private readonly IFirebaseService _firebaseService;

    private readonly IUserRepository _userRepository;

    private readonly IUserSettingsRepository _userSettingsRepository;

    private readonly ILogger<NotificationService> _logger;

    /// <summary>
    /// ينشئ مثيلًا جديدًا من خدمة الإشعارات.
    /// Creates a new instance of the notification service.
    /// </summary>
    public NotificationService(
        IEmailService emailService,
        ISmsService smsService,
        IFirebaseService firebaseService,
        IUserRepository userRepository,
        IUserSettingsRepository userSettingsRepository,
        ILogger<NotificationService> logger)
    {
        _emailService = emailService;
        _smsService = smsService;
        _firebaseService = firebaseService;
        _userRepository = userRepository;
        _userSettingsRepository = userSettingsRepository;
        _logger = logger;
    }

    /// <summary>
    /// يرسل الإشعار إلى المستخدم المستهدف عبر القنوات المهيأة.
    /// Sends the notification to the target user through the configured channels.
    /// </summary>
    public async Task SendAsync(NotificationRequest request, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("إرسال إشعار عام: {@Request}", request);
        await NotifyByIdsAsync(request, cancellationToken);
    }

    /// <summary>
    /// يوزع الإشعار على قنوات البريد والرسائل والنشر الفوري للمستخدم المحدد.
    /// Delivers the notification through email, SMS, and push channels for the specified user.
    /// </summary>
    private async Task NotifyByIdsAsync(NotificationRequest request, CancellationToken cancellationToken)
    {
        if (request.UserId == Guid.Empty)
        {
            return;
        }

        var user = await _userRepository.GetUserByIdAsync(request.UserId, cancellationToken);
        if (user == null)
        {
            return;
        }

        var language = await ResolvePreferredLanguageAsync(request.UserId, cancellationToken);
        var title = ResolveLocalizedContent(request.Title, request.TitleAr, request.TitleEn, language);
        var content = ResolveLocalizedContent(request.Message, request.MessageAr, request.MessageEn, language);

        await _emailService.SendEmailAsync(user.Email, title, content, false, cancellationToken);

        if (!string.IsNullOrEmpty(user.Phone))
        {
            await _smsService.SendSmsAsync(user.Phone, $"{title}: {content}", cancellationToken);
        }

        var priority = "info";
        if (ContainsAny(title, content, "إلغاء", "خطأ", "فشل", "cancel", "void", "failed", "error"))
        {
            priority = "high";
        }
        else if (ContainsAny(title, content, "تأكيد", "نجاح", "تم", "confirmed", "success", "processed", "completed"))
        {
            priority = "success";
        }
        else if (ContainsAny(title, content, "تذكير", "تغير", "reminder", "updated", "changed"))
        {
            priority = "medium";
        }

        var data = new Dictionary<string, string>
        {
            { "type", "notification" },
            { "priority", priority }
        };

        await _firebaseService.SendNotificationAsync($"user_{request.UserId}", title, content, data, cancellationToken);
    }

    private async Task<string> ResolvePreferredLanguageAsync(Guid userId, CancellationToken cancellationToken)
    {
        var settings = await _userSettingsRepository.GetByUserIdAsync(userId, cancellationToken);
        var preferredLanguage = settings?.PreferredLanguage;

        if (!string.IsNullOrWhiteSpace(preferredLanguage)
            && preferredLanguage.StartsWith("en", StringComparison.OrdinalIgnoreCase))
        {
            return "en";
        }

        return string.Equals(CultureInfo.CurrentUICulture.TwoLetterISOLanguageName, "en", StringComparison.OrdinalIgnoreCase)
            ? "en"
            : "ar";
    }

    private static string ResolveLocalizedContent(
        string fallback,
        string? arabic,
        string? english,
        string language)
    {
        if (!string.IsNullOrWhiteSpace(arabic) || !string.IsNullOrWhiteSpace(english))
        {
            if (language.StartsWith("en", StringComparison.OrdinalIgnoreCase))
            {
                return !string.IsNullOrWhiteSpace(english) ? english! : fallback;
            }

            return !string.IsNullOrWhiteSpace(arabic) ? arabic! : fallback;
        }

        if (string.IsNullOrWhiteSpace(fallback))
        {
            return fallback;
        }

        const string separator = " / ";
        var separatorIndex = fallback.IndexOf(separator, StringComparison.Ordinal);
        if (separatorIndex < 0)
        {
            return fallback;
        }

        var left = fallback[..separatorIndex].Trim();
        var right = fallback[(separatorIndex + separator.Length)..].Trim();
        var leftIsArabic = ContainsArabic(left);

        if (language.StartsWith("en", StringComparison.OrdinalIgnoreCase))
        {
            return leftIsArabic ? right : left;
        }

        return leftIsArabic ? left : right;
    }

    private static bool ContainsAny(string title, string content, params string[] tokens)
    {
        foreach (var token in tokens)
        {
            if (title.Contains(token, StringComparison.OrdinalIgnoreCase)
                || content.Contains(token, StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }
        }

        return false;
    }

    private static bool ContainsArabic(string value)
    {
        foreach (var ch in value)
        {
            if ((ch >= '\u0600' && ch <= '\u06FF')
                || (ch >= '\u0750' && ch <= '\u077F')
                || (ch >= '\u08A0' && ch <= '\u08FF'))
            {
                return true;
            }
        }

        return false;
    }
}
