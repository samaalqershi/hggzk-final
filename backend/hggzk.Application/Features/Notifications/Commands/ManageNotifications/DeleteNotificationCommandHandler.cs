using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Notifications;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.Notifications.Commands.ManageNotifications
{
    /// <summary>
    /// يعالج الطلب ويطبق منطق التنفيذ.
    /// Processes the request and applies the execution logic.
    /// </summary>
    public class DeleteNotificationCommandHandler : IRequestHandler<DeleteNotificationCommand, ResultDto<bool>>
    {
        private readonly ILogger<DeleteNotificationCommandHandler> _logger;
        private readonly INotificationRepository _notificationRepository;

        /// <summary>
        /// يهيئ مثيلاً جديدًا من المعالج.
        /// Initializes a new handler instance.
        /// </summary>
        public DeleteNotificationCommandHandler(
            INotificationRepository notificationRepository,
            ILogger<DeleteNotificationCommandHandler> logger)
        {
            _notificationRepository = notificationRepository;
            _logger = logger;
        }

    /// <summary>
    /// يعالج هذا المكوّن المرتبط بـ النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles the corresponding current feature area command or query and returns the requested result.
    /// </summary>
        public async Task<ResultDto<bool>> Handle(DeleteNotificationCommand request, CancellationToken cancellationToken)
        {
            if (request.NotificationId == Guid.Empty)
                return ResultDto<bool>.Failed("معرف الإشعار مطلوب");

            var entity = await _notificationRepository.GetByIdAsync(request.NotificationId, cancellationToken);
            if (entity == null) return ResultDto<bool>.Failed("الإشعار غير موجود");

            await _notificationRepository.DeleteNotificationAsync(request.NotificationId, cancellationToken);
            await _notificationRepository.SaveChangesAsync(cancellationToken);
            _logger.LogInformation("تم حذف الإشعار {NotificationId}", request.NotificationId);
            return ResultDto<bool>.Succeeded(true, "تم حذف الإشعار");
        }
    }
}
