using System;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Amenities;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.AuditLog.Services;
using YemenBooking.Core.Entities;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Core.Interfaces.Repositories;
using System.Linq;

namespace YemenBooking.Application.Features.Amenities.Commands.ManageAmenities
{
    /// <summary>
    /// معالج أمر تحديث بيانات المرفق
    /// </summary>
    public class UpdateAmenityCommandHandler : IRequestHandler<UpdateAmenityCommand, ResultDto<bool>>
    {
        private readonly ICurrentUserService _currentUserService;
        private readonly IAmenityRepository _amenityRepository;
        private readonly IAuditService _auditService;
        private readonly ILogger<UpdateAmenityCommandHandler> _logger;

        /// <summary>
        /// يُهيِّئ المعالج بالاعتمادات المطلوبة.
        /// Initializes the handler with the required dependencies.
        /// </summary>
        public UpdateAmenityCommandHandler(
            IAmenityRepository amenityRepository,
            ICurrentUserService currentUserService,
            IAuditService auditService,
            ILogger<UpdateAmenityCommandHandler> logger)
        {
            _amenityRepository = amenityRepository;
            _currentUserService = currentUserService;
            _auditService = auditService;
            _logger = logger;
        }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة.
    /// Processes the update amenity command and returns the result.
    /// </summary>
        public async Task<ResultDto<bool>> Handle(UpdateAmenityCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("بدء معالجة أمر تحديث المرفق: {AmenityId}", request.AmenityId);

            try
            {
                // التحقق من صحة المدخلات
                var inputValidation = await ValidateInputAsync(request);
                if (!inputValidation.IsSuccess)
                    return inputValidation;

                // التحقق من وجود المرفق
                var existing = await _amenityRepository.GetByIdAsync(request.AmenityId, cancellationToken);
                if (existing == null)
                    return ResultDto<bool>.Failed("المرفق غير موجود");

                // التحقق من الصلاحيات
                var authorizationValidation = await ValidateAuthorizationAsync();
                if (!authorizationValidation.IsSuccess)
                    return authorizationValidation;

                // التحقق من قواعد العمل
                var businessValidation = await ValidateBusinessRulesAsync(request, existing, cancellationToken);
                if (!businessValidation.IsSuccess)
                    return businessValidation;

                // حفظ القيم القديمة للتدقيق
                var oldValues = new Amenity
                {
                    Id = existing.Id,
                    Name = existing.Name,
                    NameEn = existing.NameEn,
                    Description = existing.Description,
                    DescriptionEn = existing.DescriptionEn,
                    CreatedAt = existing.CreatedAt,
                    UpdatedAt = existing.UpdatedAt,
                    IsDeleted = existing.IsDeleted,
                    DeletedAt = existing.DeletedAt
                };

                // التنفيذ: تحديث بيانات المرفق
                if (!string.IsNullOrWhiteSpace(request.Name))
                    existing.Name = request.Name.Trim();
                if (request.NameEn != null)
                    existing.NameEn = string.IsNullOrWhiteSpace(request.NameEn) ? null : request.NameEn.Trim();
                if (!string.IsNullOrWhiteSpace(request.Description))
                    existing.Description = request.Description.Trim();
                if (request.DescriptionEn != null)
                    existing.DescriptionEn = string.IsNullOrWhiteSpace(request.DescriptionEn) ? null : request.DescriptionEn.Trim();
                if (!string.IsNullOrWhiteSpace(request.Icon))
                    existing.Icon = request.Icon.Trim();
                existing.UpdatedAt = DateTime.UtcNow;

                await _amenityRepository.UpdateAmenityAsync(existing, cancellationToken);
                await _amenityRepository.SaveChangesAsync(cancellationToken);

                // الآثار الجانبية: تسجيل العملية في السجل مع القيم القديمة والجديدة (يدوي)
                var notes = $"تم تحديث بيانات المرفق عن طريق {_currentUserService.Username} (ID={_currentUserService.UserId})";
                await _auditService.LogAuditAsync(
                    entityType: nameof(Amenity),
                    entityId: existing.Id,
                    action: AuditAction.UPDATE,
                    oldValues: System.Text.Json.JsonSerializer.Serialize(new { oldValues.Id, oldValues.Name, oldValues.NameEn, oldValues.Description, oldValues.DescriptionEn }),
                    newValues: System.Text.Json.JsonSerializer.Serialize(new { existing.Id, existing.Name, existing.NameEn, existing.Description, existing.DescriptionEn }),
                    performedBy: _currentUserService.UserId,
                    notes: notes,
                    cancellationToken: cancellationToken);

                _logger.LogInformation("تم تحديث المرفق بالمعرف {AmenityId}", existing.Id);
                return ResultDto<bool>.Succeeded(true, "تم تحديث بيانات المرفق بنجاح");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ في معالجة أمر تحديث المرفق: {AmenityId}", request.AmenityId);
                return ResultDto<bool>.Failed("حدث خطأ أثناء تحديث المرفق");
            }
        }

        private Task<ResultDto<bool>> ValidateInputAsync(UpdateAmenityCommand request)
        {
            var errors = new List<string>();

            if (request.AmenityId == Guid.Empty)
                errors.Add("معرف المرفق مطلوب");

            if (string.IsNullOrWhiteSpace(request.Name))
                errors.Add("اسم المرفق مطلوب");
            else if (request.Name.Length > 50)
                errors.Add("اسم المرفق لا يجب أن يتجاوز 50 حرفًا");

            if (!string.IsNullOrWhiteSpace(request.NameEn) && request.NameEn.Length > 50)
                errors.Add("اسم المرفق بالإنجليزية لا يجب أن يتجاوز 50 حرفًا");

            if (request.Description == null)
                errors.Add("وصف المرفق مطلوب");
            else if (request.Description.Length > 200)
                errors.Add("وصف المرفق لا يجب أن يتجاوز 200 حرفًا");

            if (!string.IsNullOrWhiteSpace(request.DescriptionEn) && request.DescriptionEn.Length > 200)
                errors.Add("وصف المرفق بالإنجليزية لا يجب أن يتجاوز 200 حرفًا");

            if (errors.Count > 0)
                return Task.FromResult(ResultDto<bool>.Failed(errors, "بيانات المدخلات غير صحيحة"));

            return Task.FromResult(ResultDto<bool>.Succeeded(true));
        }

        private Task<ResultDto<bool>> ValidateAuthorizationAsync()
        {
            var isAdmin = string.Equals(_currentUserService.Role, "Admin", StringComparison.OrdinalIgnoreCase)
                || string.Equals(_currentUserService.AccountRole, "Admin", StringComparison.OrdinalIgnoreCase)
                || (_currentUserService.UserRoles?.Any(r => string.Equals(r, "Admin", StringComparison.OrdinalIgnoreCase)) ?? false);
            if (!isAdmin)
                return Task.FromResult(ResultDto<bool>.Failed("غير مصرح لك بتحديث بيانات المرفق"));

            return Task.FromResult(ResultDto<bool>.Succeeded(true));
        }

        private async Task<ResultDto<bool>> ValidateBusinessRulesAsync(
            UpdateAmenityCommand request,
            Amenity existing,
            CancellationToken cancellationToken)
        {
            // التحقق من عدم وجود مرفق آخر بنفس الاسم عند تغييره
            if (!string.Equals(existing.Name.Trim(), request.Name.Trim(), StringComparison.OrdinalIgnoreCase))
            {
                var duplicate = await _amenityRepository
                    .ExistsAsync(a => a.Name.ToLower() == request.Name.Trim().ToLower(), cancellationToken);
                if (duplicate)
                    return ResultDto<bool>.Failed("مرفق آخر بنفس الاسم موجود مسبقًا");
            }

            return ResultDto<bool>.Succeeded(true);
        }
    }
} 
