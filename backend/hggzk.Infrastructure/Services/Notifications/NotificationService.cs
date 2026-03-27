using System;
using System.Collections.Generic;
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
        ILogger<NotificationService> logger)
    {
        _emailService = emailService;
        _smsService = smsService;
        _firebaseService = firebaseService;
        _userRepository = userRepository;
        _logger = logger;
    }

    /// <summary>
    /// يرسل الإشعار إلى المستخدم المستهدف عبر القنوات المهيأة.
    /// Sends the notification to the target user through the configured channels.
    /// </summary>
    public async Task SendAsync(NotificationRequest request, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("إرسال إشعار عام: {@Request}", request);
        await NotifyByIdsAsync(request.UserId, request.Title, request.Message, cancellationToken);
    }

    /// <summary>
    /// يوزع الإشعار على قنوات البريد والرسائل والنشر الفوري للمستخدم المحدد.
    /// Delivers the notification through email, SMS, and push channels for the specified user.
    /// </summary>
    private async Task NotifyByIdsAsync(Guid userId, string title, string content, CancellationToken cancellationToken)
    {
        if (userId == Guid.Empty)
        {
            return;
        }

        var user = await _userRepository.GetUserByIdAsync(userId, cancellationToken);
        if (user == null)
        {
            return;
        }

        await _emailService.SendEmailAsync(user.Email, title, content, false, cancellationToken);

        if (!string.IsNullOrEmpty(user.Phone))
        {
            await _smsService.SendSmsAsync(user.Phone, $"{title}: {content}", cancellationToken);
        }

        var priority = "info";
        if (title.Contains("إلغاء") || title.Contains("خطأ") || content.Contains("فشل"))
        {
            priority = "high";
        }
        else if (title.Contains("تأكيد") || title.Contains("نجاح") || content.Contains("تم"))
        {
            priority = "success";
        }
        else if (title.Contains("تذكير") || title.Contains("تغير"))
        {
            priority = "medium";
        }

        var data = new Dictionary<string, string>
        {
            { "type", "notification" },
            { "priority", priority }
        };

        await _firebaseService.SendNotificationAsync($"user_{userId}", title, content, data, cancellationToken);
    }
}
