using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Notifications;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Interfaces;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.AuditLog.Services;

namespace YemenBooking.Application.Features.Notifications.Commands.ManageNotifications
{
    /// <summary>
    /// يعالج الطلب ويطبق منطق التنفيذ.
    /// Processes the request and applies the execution logic.
    /// </summary>
    public class MarkAllNotificationsReadCommandHandler : IRequestHandler<MarkAllNotificationsReadCommand, ResultDto<bool>>
    {
        private readonly INotificationRepository _notificationRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly IAuditService _auditService;
        private readonly ILogger<MarkAllNotificationsReadCommandHandler> _logger;

        /// <summary>
        /// يهيئ مثيلاً جديدًا من المعالج.
        /// Initializes a new handler instance.
        /// </summary>
        public MarkAllNotificationsReadCommandHandler(
            INotificationRepository notificationRepository,
            ICurrentUserService currentUserService,
            IAuditService auditService,
            ILogger<MarkAllNotificationsReadCommandHandler> logger)
        {
            _notificationRepository = notificationRepository;
            _currentUserService = currentUserService;
            _auditService = auditService;
            _logger = logger;
        }

    /// <summary>
    /// يعالج هذا المكوّن المرتبط بـ النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles the corresponding current feature area command or query and returns the requested result.
    /// </summary>
        public async Task<ResultDto<bool>> Handle(MarkAllNotificationsReadCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("بدء وضع علامة قراءة على جميع الإشعارات: RecipientId={RecipientId}", request.RecipientId);

            // التحقق من صحة المدخلات
            if (request.RecipientId == Guid.Empty)
                return ResultDto<bool>.Failed("معرف المستلم مطلوب");

            // التحقق من الصلاحيات (المالك أو المسؤول)
            if (_currentUserService.Role != "Admin" && request.RecipientId != _currentUserService.UserId)
                return ResultDto<bool>.Failed("غير مصرح لك بوضع علامة القراءة على إشعارات هذا المستخدم");

            // التنفيذ: وضع علامة القراءة على جميع الإشعارات
            var success = await _notificationRepository.MarkAllUserNotificationsAsReadAsync(request.RecipientId, cancellationToken);
            await _notificationRepository.SaveChangesAsync(cancellationToken);

            // تسجيل العملية في سجل التدقيق (يدوي) مع ذكر اسم المستخدم والمعرف
            var notes = $"تم وضع علامة قراءة على جميع الإشعارات للمستخدم {request.RecipientId} بواسطة {_currentUserService.Username} (ID={_currentUserService.UserId})";
            await _auditService.LogAuditAsync(
                entityType: "Notification",
                entityId: request.RecipientId,
                action: YemenBooking.Core.Entities.AuditAction.UPDATE,
                oldValues: null,
                newValues: System.Text.Json.JsonSerializer.Serialize(new { AllMarkedRead = true }),
                performedBy: _currentUserService.UserId,
                notes: notes,
                cancellationToken: cancellationToken);

            _logger.LogInformation("اكتمل وضع علامة القراءة على جميع الإشعارات للمستخدم: RecipientId={RecipientId}", request.RecipientId);
            return ResultDto<bool>.Succeeded(success, success ? "تم وضع علامة قراءة على جميع الإشعارات بنجاح" : "لم يكن هناك إشعارات غير مقروءة");
        }
    }
} 
