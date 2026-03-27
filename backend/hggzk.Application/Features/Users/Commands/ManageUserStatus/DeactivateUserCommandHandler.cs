using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using System.Text.Json;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.AuditLog.Services;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Features.Users.Commands.ManageUserStatus
{
    /// <summary>
    /// معالج تعطيل مستخدم.
    /// user deactivation handler.
    /// </summary>
    public class DeactivateUserCommandHandler : IRequestHandler<DeactivateUserCommand, ResultDto<bool>>
    {
        private readonly IUserRepository _userRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly IAuditService _auditService;
        private readonly ILogger<DeactivateUserCommandHandler> _logger;

        /// <summary>
        /// يهيئ هذا المكوّن بالاعتماديات المطلوبة.
        /// Initializes this component with the required dependencies.
        /// </summary>
        /// <param name="userRepository">مستودع المستخدمين. User repository.</param>
        /// <param name="currentUserService">خدمة المستخدم الحالي. Current-user service.</param>
        /// <param name="auditService">خدمة التدقيق. Audit service.</param>
        /// <param name="logger">مسجل الأحداث. Logger.</param>
        public DeactivateUserCommandHandler(
            IUserRepository userRepository,
            ICurrentUserService currentUserService,
            IAuditService auditService,
            ILogger<DeactivateUserCommandHandler> logger)
        {
            _userRepository = userRepository;
            _currentUserService = currentUserService;
            _auditService = auditService;
            _logger = logger;
        }

    /// <summary>
    /// ينفذ منطق المعالجة لهذا الطلب.
    /// executes the handling logic for this request.
    /// </summary>
        public async Task<ResultDto<bool>> Handle(DeactivateUserCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("بدء إلغاء تفعيل المستخدم: UserId={UserId}", request.UserId);

            // التحقق من المدخلات.
            // Validate the incoming request.
            if (request.UserId == Guid.Empty)
                return ResultDto<bool>.Failed("معرف المستخدم مطلوب");

            // التحقق من الصلاحيات لمسؤول النظام فقط.
            // Ensure that only administrators may perform this operation.
            if (_currentUserService.Role != "Admin")
                return ResultDto<bool>.Failed("غير مصرح لك بإلغاء تفعيل المستخدم");

            // التحقق من الوجود.
            // Ensure that the user exists.
            var user = await _userRepository.GetUserByIdAsync(request.UserId, cancellationToken);
            if (user == null)
                return ResultDto<bool>.Failed("المستخدم غير موجود");

            // التنفيذ.
            // Persist the deactivation change.
            var result = await _userRepository.DeactivateUserAsync(request.UserId, cancellationToken);
            if (!result)
                return ResultDto<bool>.Failed("فشل إلغاء تفعيل المستخدم");
            await _userRepository.SaveChangesAsync(cancellationToken);

            // تسجيل التدقيق اليدوي.
            // Write a manual audit record.
            var auditValues = new { UserId = request.UserId, Deactivated = true };
            await _auditService.LogAuditAsync(
                entityType: "User",
                entityId: request.UserId,
                action: AuditAction.DEACTIVATE,
                oldValues: null,
                newValues: JsonSerializer.Serialize(auditValues),
                performedBy: _currentUserService.UserId,
                notes: $"تم إلغاء تفعيل المستخدم {request.UserId}",
                cancellationToken: cancellationToken);

            _logger.LogInformation("اكتمل إلغاء تفعيل المستخدم بنجاح: UserId={UserId}", request.UserId);
            return ResultDto<bool>.Succeeded(true, "تم إلغاء تفعيل المستخدم بنجاح");
        }
    }
}
