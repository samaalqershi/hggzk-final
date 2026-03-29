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
using YemenBooking.Core.Interfaces.Repositories;
using System.Linq;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Core.Interfaces;

namespace YemenBooking.Application.Features.Amenities.Commands.ManageAmenities
{
    /// <summary>
    /// معالج أمر إنشاء المرفق
    /// </summary>
    public class CreateAmenityCommandHandler : IRequestHandler<CreateAmenityCommand, ResultDto<Guid>>
    {
        private readonly IAmenityRepository _amenityRepository;
        private readonly IPropertyTypeRepository _propertyTypeRepository;
        private readonly IPropertyTypeAmenityRepository _propertyTypeAmenityRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly IAuditService _auditService;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ILogger<CreateAmenityCommandHandler> _logger;

        /// <summary>
        /// يُهيِّئ المعالج بالاعتمادات المطلوبة.
        /// Initializes the handler with the required dependencies.
        /// </summary>
        public CreateAmenityCommandHandler(
            IAmenityRepository amenityRepository,
            IPropertyTypeRepository propertyTypeRepository,
            IPropertyTypeAmenityRepository propertyTypeAmenityRepository,
            ICurrentUserService currentUserService,
            IAuditService auditService,
            IUnitOfWork unitOfWork,
            ILogger<CreateAmenityCommandHandler> logger)
        {
            _amenityRepository = amenityRepository;
            _propertyTypeRepository = propertyTypeRepository;
            _propertyTypeAmenityRepository = propertyTypeAmenityRepository;
            _currentUserService = currentUserService;
            _auditService = auditService;
            _unitOfWork = unitOfWork;
            _logger = logger;
        }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة.
    /// Processes the create amenity command and returns the result.
    /// </summary>
        public async Task<ResultDto<Guid>> Handle(CreateAmenityCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("بدء معالجة أمر إنشاء المرفق: {Name}", request.Name);

            try
            {
                // التحقق من صحة المدخلات
                var inputValidation = await ValidateInputAsync(request);
                if (!inputValidation.IsSuccess)
                    return inputValidation;

                // التحقق من الصلاحيات
                var authorizationValidation = await ValidateAuthorizationAsync();
                if (!authorizationValidation.IsSuccess)
                    return authorizationValidation;

                // التحقق من قواعد العمل
                var businessValidation = await ValidateBusinessRulesAsync(request, cancellationToken);
                if (!businessValidation.IsSuccess)
                    return businessValidation;

                if (request.PropertyTypeId.HasValue && request.PropertyTypeId.Value != Guid.Empty)
                {
                    var propertyType = await _propertyTypeRepository.GetByIdAsync(request.PropertyTypeId.Value, cancellationToken);
                    if (propertyType == null)
                    {
                        return ResultDto<Guid>.Failed("نوع الكيان المحدد غير موجود");
                    }
                }

                // التنفيذ: إنشاء المرفق
                var amenity = new Amenity
                {
                    Id = Guid.NewGuid(),
                    Name = request.Name.Trim(),
                    NameEn = string.IsNullOrWhiteSpace(request.NameEn) ? null : request.NameEn.Trim(),
                    Description = request.Description.Trim(),
                    DescriptionEn = string.IsNullOrWhiteSpace(request.DescriptionEn) ? null : request.DescriptionEn.Trim(),
                    Icon = (request.Icon ?? string.Empty).Trim(),
                    IsActive = true, // تفعيل المرفق تلقائياً عند الإنشاء
                    CreatedAt = DateTime.UtcNow
                };
                PropertyTypeAmenity? createdLink = null;

                await _unitOfWork.ExecuteInTransactionAsync(async () =>
                {
                    await _amenityRepository.CreateAmenityAsync(amenity, cancellationToken);

                    // If a PropertyTypeId was provided, create the link immediately
                    if (request.PropertyTypeId.HasValue && request.PropertyTypeId.Value != Guid.Empty)
                    {
                        var linkExists = await _propertyTypeAmenityRepository
                            .ExistsAsync(x => x.PropertyTypeId == request.PropertyTypeId.Value && x.AmenityId == amenity.Id, cancellationToken);
                        if (!linkExists)
                        {
                            createdLink = new PropertyTypeAmenity
                            {
                                PropertyTypeId = request.PropertyTypeId.Value,
                                AmenityId = amenity.Id,
                                IsDefault = request.IsDefaultForType
                            };
                            await _propertyTypeAmenityRepository.CreatePropertyTypeAmenityAsync(createdLink, cancellationToken);
                        }
                    }

                    await _amenityRepository.SaveChangesAsync(cancellationToken);
                }, cancellationToken);

                if (createdLink != null)
                {
                    var notesLink = $"تم ربط المرفق بنوع الكيان مباشرة بعد الإنشاء بواسطة {_currentUserService.Username} (ID={_currentUserService.UserId})";
                    await _auditService.LogAuditAsync(
                        entityType: nameof(PropertyTypeAmenity),
                        entityId: createdLink.Id,
                        action: AuditAction.CREATE,
                        oldValues: null,
                        newValues: System.Text.Json.JsonSerializer.Serialize(new { createdLink.PropertyTypeId, createdLink.AmenityId, createdLink.IsDefault }),
                        performedBy: _currentUserService.UserId,
                        notes: notesLink,
                        cancellationToken: cancellationToken);
                }

                // الآثار الجانبية: تسجيل العملية في السجل (يدوي)
                var notes = $"تم إنشاء المرفق بنجاح بواسطة {_currentUserService.Username} (ID={_currentUserService.UserId})";
                await _auditService.LogAuditAsync(
                    entityType: nameof(Amenity),
                    entityId: amenity.Id,
                    action: AuditAction.CREATE,
                    oldValues: null,
                    newValues: System.Text.Json.JsonSerializer.Serialize(new { amenity.Id, amenity.Name, amenity.NameEn, amenity.Description, amenity.DescriptionEn, amenity.Icon }),
                    performedBy: _currentUserService.UserId,
                    notes: notes,
                    cancellationToken: cancellationToken);

                _logger.LogInformation("تم إنشاء المرفق بالمعرف {AmenityId}", amenity.Id);

                return ResultDto<Guid>.Succeeded(amenity.Id, "تم إنشاء المرفق بنجاح");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ في معالجة أمر إنشاء المرفق: {Name}", request.Name);
                return ResultDto<Guid>.Failed("حدث خطأ أثناء إنشاء المرفق");
            }
        }

        private Task<ResultDto<Guid>> ValidateInputAsync(CreateAmenityCommand request)
        {
            var errors = new List<string>();

            if (string.IsNullOrWhiteSpace(request.Name))
                errors.Add("اسم المرفق مطلوب");
            else if (request.Name.Length > 50)
                errors.Add("اسم المرفق لا يجب أن يتجاوز 50 حرفًا");

            if (!string.IsNullOrWhiteSpace(request.NameEn) && request.NameEn.Length > 50)
                errors.Add("اسم المرفق بالإنجليزية لا يجب أن يتجاوز 50 حرفًا");

            if (!string.IsNullOrWhiteSpace(request.Description) && request.Description.Length > 200)
                errors.Add("وصف المرفق لا يجب أن يتجاوز 200 حرفًا");

            if (!string.IsNullOrWhiteSpace(request.DescriptionEn) && request.DescriptionEn.Length > 200)
                errors.Add("وصف المرفق بالإنجليزية لا يجب أن يتجاوز 200 حرفًا");

            if (errors.Count > 0)
                return Task.FromResult(ResultDto<Guid>.Failed(errors, "بيانات المدخلات غير صحيحة"));

            return Task.FromResult(ResultDto<Guid>.Succeeded(Guid.Empty));
        }

        private Task<ResultDto<Guid>> ValidateAuthorizationAsync()
        {
            var isAdmin = string.Equals(_currentUserService.Role, "Admin", StringComparison.OrdinalIgnoreCase)
                || string.Equals(_currentUserService.AccountRole, "Admin", StringComparison.OrdinalIgnoreCase)
                || (_currentUserService.UserRoles?.Any(r => string.Equals(r, "Admin", StringComparison.OrdinalIgnoreCase)) ?? false);
            if (!isAdmin)
                return Task.FromResult(ResultDto<Guid>.Failed("غير مصرح لك بإنشاء مرافق"));

            return Task.FromResult(ResultDto<Guid>.Succeeded(Guid.Empty));
        }

        private async Task<ResultDto<Guid>> ValidateBusinessRulesAsync(CreateAmenityCommand request, CancellationToken cancellationToken)
        {
            var exists = await _amenityRepository
                .ExistsAsync(a => a.Name.ToLower() == request.Name.Trim().ToLower(), cancellationToken);

            if (exists)
                return ResultDto<Guid>.Failed("مرفق بنفس الاسم موجود مسبقًا");

            return ResultDto<Guid>.Succeeded(Guid.Empty);
        }
    }
} 
