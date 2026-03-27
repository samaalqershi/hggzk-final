using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Staffs;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Features.AuditLog.Services;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Features.Staffs.Commands.ManageStaff
{
    /// <summary>
    /// يعالج إزالة الموظف ويعيد النتيجة المطلوبة.
    /// Processes the Remove Staff request and returns the requested result.
    /// </summary>
    public class RemoveStaffCommandHandler : IRequestHandler<RemoveStaffCommand, ResultDto<bool>>
    {
        private readonly IStaffRepository _staffRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly IAuditService _auditService;
        private readonly ILogger<RemoveStaffCommandHandler> _logger;

        /// <summary>
        /// ينشئ مثيلاً جديداً من RemoveStaffCommandHandler.
        /// Initializes a new instance of RemoveStaffCommandHandler.
        /// </summary>
        /// <param name="staffRepository">مستودع الموظف / staff repository.</param>
        /// <param name="currentUserService">خدمة المستخدم الحالي / Current user service.</param>
        /// <param name="auditService">خدمة التدقيق / Audit service.</param>
        /// <param name="logger">مسجل الأحداث / Logger.</param>
        public RemoveStaffCommandHandler(
            IStaffRepository staffRepository,
            ICurrentUserService currentUserService,
            IAuditService auditService,
            ILogger<RemoveStaffCommandHandler> logger)
        {
            _staffRepository = staffRepository;
            _currentUserService = currentUserService;
            _auditService = auditService;
            _logger = logger;
        }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
        public async Task<ResultDto<bool>> Handle(RemoveStaffCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("بدء إزالة موظف: StaffId={StaffId}", request.StaffId);

            // التحقق من المدخلات
            if (request.StaffId == Guid.Empty)
                return ResultDto<bool>.Failed("معرف الموظف مطلوب");

            // التحقق من الوجود
            var staff = await _staffRepository.GetStaffByIdAsync(request.StaffId, cancellationToken);
            if (staff == null)
                return ResultDto<bool>.Failed("الموظف غير موجود");

            // التحقق من الصلاحيات (مالك الكيان أو مسؤول)
            var property = await _staffRepository.GetPropertyByIdAsync(staff.PropertyId, cancellationToken);
            if (property == null)
                return ResultDto<bool>.Failed("الكيان المرتبط بالموظف غير موجود");
            if (_currentUserService.Role != "Admin" && property.OwnerId != _currentUserService.UserId)
                return ResultDto<bool>.Failed("غير مصرح لك بحذف هذا الموظف");

            // تنفيذ الإزالة
            bool removed = await _staffRepository.RemoveStaffAsync(request.StaffId, cancellationToken);
            if (!removed)
                return ResultDto<bool>.Failed("فشل إزالة الموظف");
            await _staffRepository.SaveChangesAsync(cancellationToken);

            // تسجيل التدقيق (يدوي) يتضمن اسم ومعرّف المنفذ
            var notes = $"تم إزالة الموظف {request.StaffId} بواسطة {_currentUserService.Username} (ID={_currentUserService.UserId})";
            await _auditService.LogAuditAsync(
                entityType: "Staff",
                entityId: request.StaffId,
                action: AuditAction.DELETE,
                oldValues: System.Text.Json.JsonSerializer.Serialize(new { request.StaffId }),
                newValues: null,
                performedBy: _currentUserService.UserId,
                notes: notes,
                cancellationToken: cancellationToken);

            _logger.LogInformation("اكتملت عملية إزالة الموظف بنجاح: StaffId={StaffId}", request.StaffId);
            return ResultDto<bool>.Succeeded(true, "تم إزالة الموظف بنجاح");
        }
    }
} 
