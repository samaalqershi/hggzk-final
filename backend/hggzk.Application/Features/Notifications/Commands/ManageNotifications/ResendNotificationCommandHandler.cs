using System;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Notifications;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.Notifications.Services;

namespace YemenBooking.Application.Features.Notifications.Commands.ManageNotifications
{
    /// <summary>
    /// يعالج الطلب ويطبق منطق التنفيذ.
    /// Processes the request and applies the execution logic.
    /// </summary>
    public class ResendNotificationCommandHandler : IRequestHandler<ResendNotificationCommand, ResultDto<bool>>
    {
        private readonly INotificationService _notificationService;
        private readonly INotificationRepository _notificationRepository;
        private readonly ILogger<ResendNotificationCommandHandler> _logger;

        /// <summary>
        /// يهيئ مثيلاً جديدًا من المعالج.
        /// Initializes a new handler instance.
        /// </summary>
        public ResendNotificationCommandHandler(
            INotificationRepository notificationRepository,
            INotificationService notificationService,
            ILogger<ResendNotificationCommandHandler> logger)
        {
            _notificationRepository = notificationRepository;
            _notificationService = notificationService;
            _logger = logger;
        }

    /// <summary>
    /// يعالج هذا المكوّن المرتبط بـ النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles the corresponding current feature area command or query and returns the requested result.
    /// </summary>
        public async Task<ResultDto<bool>> Handle(ResendNotificationCommand request, CancellationToken cancellationToken)
        {
            if (request.NotificationId == Guid.Empty)
                return ResultDto<bool>.Failed("معرف الإشعار مطلوب");

            var entity = await _notificationRepository.GetByIdAsync(request.NotificationId, cancellationToken);
            if (entity == null)
                return ResultDto<bool>.Failed("الإشعار غير موجود");

            try
            {
                await _notificationService.SendAsync(new YemenBooking.Core.Notifications.NotificationRequest
                {
                    UserId = entity.RecipientId,
                    Title = entity.Title,
                    Message = entity.Message,
                    Type = Enum.TryParse<YemenBooking.Core.Notifications.NotificationType>(entity.Type, true, out var t)
                        ? t : YemenBooking.Core.Notifications.NotificationType.BookingUpdated,
                    Data = string.IsNullOrWhiteSpace(entity.Data) ? null : JsonSerializer.Deserialize<object>(entity.Data)
                }, cancellationToken);

                entity.MarkAsSent(request.Channel ?? "IN_APP");
                await _notificationRepository.UpdateNotificationAsync(entity, cancellationToken);
                await _notificationRepository.SaveChangesAsync(cancellationToken);
                return ResultDto<bool>.Succeeded(true, "تمت إعادة إرسال الإشعار");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "فشل إعادة إرسال الإشعار {NotificationId}", request.NotificationId);
                entity.MarkAsFailed(ex.Message);
                await _notificationRepository.UpdateNotificationAsync(entity, cancellationToken);
                await _notificationRepository.SaveChangesAsync(cancellationToken);
                return ResultDto<bool>.Failed("فشل إعادة إرسال الإشعار");
            }
        }
    }
}
