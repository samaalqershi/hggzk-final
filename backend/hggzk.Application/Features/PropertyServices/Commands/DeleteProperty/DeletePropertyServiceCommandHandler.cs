using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.PropertyServices;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.AuditLog.Services;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Features.PropertyServices.Commands.DeleteProperty
{
    /// <summary>
    /// يحذف خدمة مرتبطة بعقار.
    /// Deletes a service associated with a property.
    /// </summary>
    public class DeletePropertyServiceCommandHandler : IRequestHandler<DeletePropertyServiceCommand, ResultDto<bool>>
    {
        private readonly IPropertyServiceRepository _serviceRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly IAuditService _auditService;
        private readonly ILogger<DeletePropertyServiceCommandHandler> _logger;

        /// <summary>
        /// يهيئ معالج حذف خدمة العقار.
        /// Initializes the property service deletion handler.
        /// </summary>
        public DeletePropertyServiceCommandHandler(
            IPropertyServiceRepository serviceRepository,
            ICurrentUserService currentUserService,
            IAuditService auditService,
            ILogger<DeletePropertyServiceCommandHandler> logger)
        {
            _serviceRepository = serviceRepository;
            _currentUserService = currentUserService;
            _auditService = auditService;
            _logger = logger;
        }

        /// <summary>
        /// يعالج Delete Property Service الوارد.
        /// Processes the incoming delete property service request.
        /// </summary>
        public async Task<ResultDto<bool>> Handle(DeletePropertyServiceCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("بدء حذف خدمة الكيان: ServiceId={ServiceId}", request.ServiceId);

            if (request.ServiceId == Guid.Empty)
                return ResultDto<bool>.Failed("معرف الخدمة مطلوب");

            var service = await _serviceRepository.GetServiceByIdAsync(request.ServiceId, cancellationToken);
            if (service == null)
                return ResultDto<bool>.Failed("الخدمة غير موجودة");

            var property = await _serviceRepository.GetPropertyByIdAsync(service.PropertyId, cancellationToken);
            if (property == null)
                return ResultDto<bool>.Failed("الكيان المرتبط بالخدمة غير موجود");

            var isAdmin = string.Equals(_currentUserService.Role, "Admin", StringComparison.OrdinalIgnoreCase)
                || string.Equals(_currentUserService.AccountRole, "Admin", StringComparison.OrdinalIgnoreCase)
                || (_currentUserService.UserRoles?.Any(r => string.Equals(r, "Admin", StringComparison.OrdinalIgnoreCase)) ?? false);
            if (!isAdmin && property.OwnerId != _currentUserService.UserId)
                return ResultDto<bool>.Failed("غير مصرح لك بحذف هذه الخدمة");

            // التحقق من عدم وجود حجوزات أو مدفوعات تعتمد على هذه الخدمة
            var hasBookingRefs = await _serviceRepository.ServiceHasBookingReferencesAsync(request.ServiceId, cancellationToken);
            if (hasBookingRefs)
                return ResultDto<bool>.Failed("لا يمكن حذف الخدمة لارتباطها بحجوزات جارية أو سابقة");

            var success = await _serviceRepository.DeletePropertyServiceAsync(request.ServiceId, cancellationToken);
            if (!success)
                return ResultDto<bool>.Failed("فشل حذف الخدمة");
            await _serviceRepository.SaveChangesAsync(cancellationToken);

            // تسجيل التدقيق (يدوي) يتضمن اسم ومعرّف المنفذ
            var notes = $"تم حذف الخدمة {request.ServiceId} بواسطة {_currentUserService.Username} (ID={_currentUserService.UserId})";
            await _auditService.LogAuditAsync(
                entityType: "PropertyService",
                entityId: request.ServiceId,
                action: AuditAction.DELETE,
                oldValues: System.Text.Json.JsonSerializer.Serialize(new { request.ServiceId }),
                newValues: null,
                performedBy: _currentUserService.UserId,
                notes: notes,
                cancellationToken: cancellationToken);

            _logger.LogInformation("اكتمل حذف الخدمة: ServiceId={ServiceId}", request.ServiceId);
            return ResultDto<bool>.Succeeded(true, "تم حذف الخدمة بنجاح");
        }
    }
} 
