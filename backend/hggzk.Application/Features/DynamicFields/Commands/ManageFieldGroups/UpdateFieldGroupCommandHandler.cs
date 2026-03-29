using MediatR;
using Microsoft.Extensions.Logging;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Application.Features.DynamicFields;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using Unit = MediatR.Unit;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.AuditLog.Services;

namespace YemenBooking.Application.Features.DynamicFields.Commands.ManageFieldGroups;

    /// <summary>
    /// يحدّث مجموعة حقول موجودة مع التحقق من القواعد والصلاحيات.
    /// Updates an existing field group while validating rules and permissions.
    /// </summary>
public class UpdateFieldGroupCommandHandler : IRequestHandler<UpdateFieldGroupCommand, ResultDto<Unit>>
{
    private readonly IFieldGroupRepository _fieldGroupRepository;
    private readonly ICurrentUserService _currentUserService;
    private readonly IValidationService _validationService;
    private readonly IAuditService _auditService;
    private readonly ILogger<UpdateFieldGroupCommandHandler> _logger;

    /// <summary>
    /// يُهيِّئ المعالج بالاعتمادات المطلوبة.
    /// Initializes the handler with the required dependencies.
    /// </summary>
    public UpdateFieldGroupCommandHandler(
        IFieldGroupRepository fieldGroupRepository,
        ICurrentUserService currentUserService,
        IValidationService validationService,
        IAuditService auditService,
        ILogger<UpdateFieldGroupCommandHandler> logger)
    {
        _fieldGroupRepository = fieldGroupRepository;
        _currentUserService = currentUserService;
        _validationService = validationService;
        _auditService = auditService;
        _logger = logger;
    }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة.
    /// Processes the update field group command and returns the result.
    /// </summary>
    public async Task<ResultDto<Unit>> Handle(UpdateFieldGroupCommand request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء معالجة أمر تحديث مجموعة الحقول: {GroupId}", request.GroupId);

            // Step 1: Validate input / الخطوة 1: التحقق من صحة المدخلات
            var inputValidationResult = await ValidateInputAsync(request, cancellationToken);
            if (!inputValidationResult.Success)
            {
                return inputValidationResult;
            }

            // Step 2: Check group existence / الخطوة 2: التحقق من وجود المجموعة
            var groupId = Guid.Parse(request.GroupId);
            var existingFieldGroup = await _fieldGroupRepository.GetFieldGroupByIdAsync(groupId, cancellationToken);
            if (existingFieldGroup == null)
            {
                _logger.LogWarning("مجموعة الحقول غير موجودة: {GroupId}", request.GroupId);
                return ResultDto<Unit>.Failure("مجموعة الحقول غير موجودة");
            }

            // Step 3: Check authorization / الخطوة 3: التحقق من الصلاحيات
            var authorizationValidation = await ValidateAuthorizationAsync(cancellationToken);
            if (!authorizationValidation.Success)
            {
                return authorizationValidation;
            }

            // Step 4: Check business rules / الخطوة 4: التحقق من قواعد العمل
            var businessRulesValidation = await ValidateBusinessRulesAsync(request, existingFieldGroup, cancellationToken);
            if (!businessRulesValidation.Success)
            {
                return businessRulesValidation;
            }

            // Step 5: Capture original values for auditing / الخطوة 5: حفظ القيم الأصلية للمراجعة
            var originalValues = new
            {
                existingFieldGroup.GroupName,
                existingFieldGroup.GroupNameEn,
                existingFieldGroup.DisplayName,
                existingFieldGroup.DisplayNameEn,
                existingFieldGroup.Description,
                existingFieldGroup.DescriptionEn,
                existingFieldGroup.SortOrder,
                existingFieldGroup.IsCollapsible,
                existingFieldGroup.IsExpandedByDefault
            };

            // Step 6: Update the field group / الخطوة 6: تحديث مجموعة الحقول
            existingFieldGroup.GroupName = request.GroupName;
            existingFieldGroup.GroupNameEn = string.IsNullOrWhiteSpace(request.GroupNameEn) ? null : request.GroupNameEn.Trim();
            existingFieldGroup.DisplayName = request.DisplayName;
            existingFieldGroup.DisplayNameEn = string.IsNullOrWhiteSpace(request.DisplayNameEn) ? null : request.DisplayNameEn.Trim();
            existingFieldGroup.Description = request.Description;
            existingFieldGroup.DescriptionEn = string.IsNullOrWhiteSpace(request.DescriptionEn) ? null : request.DescriptionEn.Trim();
            existingFieldGroup.SortOrder = request.SortOrder;
            existingFieldGroup.IsCollapsible = request.IsCollapsible;
            existingFieldGroup.IsExpandedByDefault = request.IsExpandedByDefault;
            existingFieldGroup.UpdatedAt = DateTime.UtcNow;
            existingFieldGroup.UpdatedBy = _currentUserService.UserId;

            var updatedFieldGroup = await _fieldGroupRepository.UpdateFieldGroupAsync(existingFieldGroup, cancellationToken);

            // Step 7: Persist the group changes / الخطوة 7: حفظ تغييرات المجموعة
            await _fieldGroupRepository.SaveChangesAsync(cancellationToken);

            // Step 8: Write audit entry / الخطوة 8: تسجيل العملية في سجل التدقيق
            await _auditService.LogActivityAsync(
                "FieldGroup",
                updatedFieldGroup.Id.ToString(),
                "Update",
                $"تم تحديث مجموعة الحقول: {updatedFieldGroup.GroupName}",
                originalValues,
                updatedFieldGroup,
                cancellationToken);

            _logger.LogInformation("تم تحديث مجموعة الحقول بنجاح: {GroupId}", updatedFieldGroup.Id);

            return ResultDto<Unit>.Ok(
                Unit.Value,
                "تم تحديث مجموعة الحقول بنجاح"
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في تحديث مجموعة الحقول: {GroupId}", request.GroupId);
            return ResultDto<Unit>.Failure("حدث خطأ أثناء تحديث مجموعة الحقول");
        }
    }

    private async Task<ResultDto<Unit>> ValidateInputAsync(UpdateFieldGroupCommand request, CancellationToken cancellationToken)
    {
        var validationResult = await _validationService.ValidateAsync(request, cancellationToken);
        if (!validationResult.IsValid)
        {
            var errors = string.Join(", ", validationResult.Errors.Select(e => e.Message));
            _logger.LogWarning("بيانات غير صحيحة لتحديث مجموعة الحقول: {Errors}", errors);
            return ResultDto<Unit>.Failure($"بيانات غير صحيحة: {errors}");
        }

        // Validate group ID / التحقق من معرف المجموعة
        if (!Guid.TryParse(request.GroupId, out _))
        {
            _logger.LogWarning("معرف مجموعة الحقول غير صحيح: {GroupId}", request.GroupId);
            return ResultDto<Unit>.Failure("معرف مجموعة الحقول غير صحيح");
        }

        // Validate group name / التحقق من اسم المجموعة
        if (string.IsNullOrWhiteSpace(request.GroupName))
        {
            return ResultDto<Unit>.Failure("اسم المجموعة مطلوب");
        }

        if (request.GroupName.Length > 100)
        {
            return ResultDto<Unit>.Failure("اسم المجموعة لا يجب أن يتجاوز 100 حرف");
        }

        // Validate display name / التحقق من الاسم المعروض
        if (!string.IsNullOrWhiteSpace(request.DisplayName) && request.DisplayName.Length > 100)
        {
            return ResultDto<Unit>.Failure("الاسم المعروض لا يجب أن يتجاوز 100 حرف");
        }

        // Validate description / التحقق من الوصف
        if (!string.IsNullOrWhiteSpace(request.Description) && request.Description.Length > 500)
        {
            return ResultDto<Unit>.Failure("الوصف لا يجب أن يتجاوز 500 حرف");
        }

        // Validate sort order / التحقق من ترتيب الفرز
        if (request.SortOrder < 0)
        {
            return ResultDto<Unit>.Failure("ترتيب الفرز يجب أن يكون صفر أو أكبر");
        }

        return ResultDto<Unit>.Ok(Unit.Value);
    }

    private Task<ResultDto<Unit>> ValidateAuthorizationAsync(CancellationToken cancellationToken)
    {
        if ( _currentUserService.Role !="Admin")
        {
            _logger.LogWarning("المستخدم {UserId} لا يملك صلاحية تحديث مجموعات الحقول", _currentUserService.UserId);
            return Task.FromResult(ResultDto<Unit>.Failure("غير مصرح لك بتحديث مجموعات الحقول"));
        }

        return Task.FromResult(ResultDto<Unit>.Ok(Unit.Value));
    }

    private async Task<ResultDto<Unit>> ValidateBusinessRulesAsync(UpdateFieldGroupCommand request, FieldGroup existingFieldGroup, CancellationToken cancellationToken)
    {
        // Check for duplicates if the name changed / التحقق من التكرار إذا تغير الاسم
        if (!existingFieldGroup.GroupName.Equals(request.GroupName, StringComparison.OrdinalIgnoreCase))
        {
            var allGroups = await _fieldGroupRepository.GetGroupsByUnitTypeIdAsync(existingFieldGroup.UnitTypeId, cancellationToken);
            if (allGroups.Any(g => g.Id != existingFieldGroup.Id && 
                                  g.GroupName.Equals(request.GroupName, StringComparison.OrdinalIgnoreCase)))
            {
                _logger.LogWarning("يوجد مجموعة حقول أخرى بنفس الاسم: {GroupName}", request.GroupName);
                return ResultDto<Unit>.Failure($"يوجد مجموعة حقول أخرى بالاسم '{request.GroupName}' مسبقاً");
            }
        }

        // Validate settings / التحقق من الإعدادات
        if (request.IsCollapsible && request.IsExpandedByDefault)
        {
            // This combination is valid / هذا التوليف صحيح
        }

        if (!request.IsCollapsible && !request.IsExpandedByDefault)
        {
            // This combination is also valid / هذا التوليف صحيح أيضًا
        }

        return ResultDto<Unit>.Ok(Unit.Value);
    }
}
