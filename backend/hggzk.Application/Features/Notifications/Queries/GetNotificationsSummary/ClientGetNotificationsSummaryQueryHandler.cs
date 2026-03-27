using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Notifications;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Entities;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.Notifications.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Notifications.Queries.GetNotificationsSummary;

/// <summary>
/// يعالج الاستعلام ويعيد النتائج المطلوبة.
/// Processes the query and returns the requested data.
/// </summary>
public class ClientGetNotificationsSummaryQueryHandler : IRequestHandler<ClientGetNotificationsSummaryQuery, ResultDto<ClientNotificationsSummaryDto>>
{
    private readonly INotificationRepository _notificationRepository;
    private readonly IUserRepository _userRepository;
    private readonly ILogger<ClientGetNotificationsSummaryQueryHandler> _logger;
    private readonly ICurrentUserService _currentUserService;

    /// <summary>
    /// يهيئ مثيلاً جديدًا من المعالج.
    /// Initializes a new handler instance.
    /// </summary>
    public ClientGetNotificationsSummaryQueryHandler(
        INotificationRepository notificationRepository,
        IUserRepository userRepository,
        ILogger<ClientGetNotificationsSummaryQueryHandler> logger,
        ICurrentUserService currentUserService)
    {
        _notificationRepository = notificationRepository;
        _userRepository = userRepository;
        _logger = logger;
        _currentUserService = currentUserService;
    }

    /// <summary>
    /// يعالج هذا المكوّن المرتبط بـ النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles the corresponding current feature area command or query and returns the requested result.
    /// </summary>
    public async Task<ResultDto<ClientNotificationsSummaryDto>> Handle(ClientGetNotificationsSummaryQuery request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء استعلام ملخص الإشعارات للعميل. معرف المستخدم: {UserId}", request.UserId);

            // التحقق من صحة البيانات المدخلة / Validate input data.
            var validationResult = ValidateRequest(request);
            if (!validationResult.IsSuccess)
            {
                return validationResult;
            }

            // التحقق من وجود المستخدم / Validate that the user exists.
            var user = await _userRepository.GetByIdAsync(request.UserId, cancellationToken);
            if (user == null)
            {
                _logger.LogWarning("لم يتم العثور على المستخدم: {UserId}", request.UserId);
                return ResultDto<ClientNotificationsSummaryDto>.Failed("المستخدم غير موجود", "USER_NOT_FOUND");
            }

            // الحصول على إحصائيات الإشعارات / Build notification statistics.
            // الحصول على عدد الإشعارات غير المقروءة / Get unread notification count.
            var unreadCount = await _notificationRepository.GetUnreadNotificationsCountAsync(request.UserId, cancellationToken);
            
            // الحصول على جميع الإشعارات للمستخدم (مع تحديد عدد أكبر للحصول على الإحصائيات) / Load all user notifications with a larger page size for summary statistics.
            var allNotifications = (await _notificationRepository.GetUserNotificationsAsync(request.UserId, null, 1, 1000, cancellationToken))
                ?.ToList() ?? new List<Notification>();
            
            var totalCount = allNotifications.Count;
            var readCount = totalCount - unreadCount;

            // إحصائيات حسب النوع / Group statistics by type.
            var countByType = allNotifications
                .GroupBy(n => n.Type ?? "Unknown")
                .ToDictionary(g => g.Key, g => g.Count());

            // إحصائيات حسب الأولوية / Group statistics by priority.
            var countByPriority = allNotifications
                .GroupBy(n => n.Priority ?? "MEDIUM")
                .ToDictionary(g => g.Key, g => g.Count());

            // آخر إشعار / Most recent notification.
            var lastNotification = allNotifications
                .OrderByDescending(n => n.CreatedAt)
                .FirstOrDefault();
            
            ClientNotificationDto? lastNotificationDto = null;
            if (lastNotification != null)
            {
                lastNotificationDto = MapToClientNotificationDto(lastNotification);
                // Localize times for the last notification.
                lastNotificationDto.CreatedAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(lastNotificationDto.CreatedAt);
                if (lastNotificationDto.ReadAt.HasValue)
                    lastNotificationDto.ReadAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(lastNotificationDto.ReadAt.Value);
            }

            // الحصول على الإشعارات عالية الأولوية غير المقروءة / Get unread high-priority notifications.
            var highPriorityNotifications = allNotifications
                .Where(n => !n.IsRead && (n.Priority == "HIGH" || n.Priority == "URGENT"))
                .OrderByDescending(n => n.CreatedAt)
                .Take(5)
                .ToList();

            var highPriorityUnreadDtos = highPriorityNotifications
                .Select(MapToClientNotificationDto)
                .ToList();
            for (int i = 0; i < highPriorityUnreadDtos.Count; i++)
            {
                highPriorityUnreadDtos[i].CreatedAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(highPriorityUnreadDtos[i].CreatedAt);
                if (highPriorityUnreadDtos[i].ReadAt.HasValue)
                    highPriorityUnreadDtos[i].ReadAt = await _currentUserService.ConvertFromUtcToUserLocalAsync(highPriorityUnreadDtos[i].ReadAt.Value);
            }

            // إنشاء DTO للاستجابة / Build the response DTO.
            var summaryDto = new ClientNotificationsSummaryDto
            {
                TotalCount = totalCount,
                UnreadCount = unreadCount,
                ReadCount = readCount,
                CountByType = countByType,
                CountByPriority = countByPriority,
                LastNotification = lastNotificationDto,
                HighPriorityUnread = highPriorityUnreadDtos
            };

            _logger.LogInformation("تم الحصول على ملخص الإشعارات بنجاح. المستخدم: {UserId}, إجمالي: {Total}, غير مقروء: {Unread}", 
                request.UserId, totalCount, unreadCount);

            return ResultDto<ClientNotificationsSummaryDto>.Ok(
                summaryDto, 
                "تم الحصول على ملخص الإشعارات بنجاح"
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء الحصول على ملخص الإشعارات. معرف المستخدم: {UserId}", request.UserId);
            return ResultDto<ClientNotificationsSummaryDto>.Failed(
                $"حدث خطأ أثناء الحصول على ملخص الإشعارات: {ex.Message}", 
                "GET_NOTIFICATIONS_SUMMARY_ERROR"
            );
        }
    }

    private ResultDto<ClientNotificationsSummaryDto> ValidateRequest(ClientGetNotificationsSummaryQuery request)
    {
        if (request.UserId == Guid.Empty)
        {
            _logger.LogWarning("معرف المستخدم مطلوب");
            return ResultDto<ClientNotificationsSummaryDto>.Failed("معرف المستخدم مطلوب", "USER_ID_REQUIRED");
        }

        return ResultDto<ClientNotificationsSummaryDto>.Ok(null, "البيانات صحيحة");
    }

    private ClientNotificationDto MapToClientNotificationDto(Notification notification)
    {
        return new ClientNotificationDto
        {
            Id = notification.Id,
            Title = notification.Title ?? string.Empty,
            Content = notification.Message ?? string.Empty,
            Type = notification.Type ?? string.Empty,
            Priority = notification.Priority ?? "MEDIUM",
            IsRead = notification.IsRead,
            CreatedAt = notification.CreatedAt,
            ReadAt = notification.ReadAt,
            IconUrl = null, // يمكن إضافة هذه الخاصية لاحقاً إذا لزم الأمر / This can be added later if needed.
            ImageUrl = null, // يمكن إضافة هذه الخاصية لاحقاً إذا لزم الأمر / This can be added later if needed.
            AdditionalData = notification.Data,
            ActionUrl = null, // يمكن إضافة هذه الخاصية لاحقاً إذا لزم الأمر / This can be added later if needed.
            CanDismiss = notification.CanDismiss
        };
    }
}
