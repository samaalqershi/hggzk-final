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
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.AuditLog.Services;

namespace YemenBooking.Application.Features.DynamicFields.Commands.ManageFieldGroups;

    /// <summary>
    /// ينشئ مجموعة حقول جديدة ويعيد معرفها عند النجاح.
    /// Creates a new field group and returns its identifier on success.
    /// </summary>
public class CreateFieldGroupCommandHandler : IRequestHandler<CreateFieldGroupCommand, ResultDto<string>>
{
    private readonly IFieldGroupRepository _fieldGroupRepository;
    private readonly IUnitTypeRepository _unitTypeRepository;
    private readonly ICurrentUserService _currentUserService;
    private readonly IValidationService _validationService;
    private readonly IAuditService _auditService;
    private readonly ILogger<CreateFieldGroupCommandHandler> _logger;

    /// <summary>
    /// يُهيِّئ المعالج بالاعتمادات المطلوبة.
    /// Initializes the handler with the required dependencies.
    /// </summary>
    public CreateFieldGroupCommandHandler(
        IFieldGroupRepository fieldGroupRepository,
        IUnitTypeRepository unitTypeRepository,
        ICurrentUserService currentUserService,
        IValidationService validationService,
        IAuditService auditService,
        ILogger<CreateFieldGroupCommandHandler> logger)
    {
        _fieldGroupRepository = fieldGroupRepository;
        _unitTypeRepository = unitTypeRepository;
        _currentUserService = currentUserService;
        _validationService = validationService;
        _auditService = auditService;
        _logger = logger;
    }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة.
    /// Processes the create field group command and returns the result.
    /// </summary>
    public async Task<ResultDto<string>> Handle(CreateFieldGroupCommand request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء معالجة أمر إنشاء مجموعة الحقول لنوع الوحدة: {UnitTypeId}", request.unitTypeId);

            // Step 1: Validate input / الخطوة 1: التحقق من صحة المدخلات
            var inputValidationResult = await ValidateInputAsync(request, cancellationToken);
            if (!inputValidationResult.Success)
            {
                return inputValidationResult;
            }

            // Step 2: Check unit type existence / الخطوة 2: التحقق من وجود نوع الوحدة
            var unitTypeId = Guid.Parse(request.unitTypeId);
            var unitType = await _unitTypeRepository.GetUnitTypeByIdAsync(unitTypeId, cancellationToken);
            if (unitType == null)
            {
                _logger.LogWarning("نوع الوحدة غير موجود: {UnitTypeId}", request.unitTypeId);
                return ResultDto<string>.Failure("نوع الوحدة غير موجود");
            }

            // Step 3: Check authorization / الخطوة 3: التحقق من الصلاحيات
            var authorizationValidation = await ValidateAuthorizationAsync(cancellationToken);
            if (!authorizationValidation.Success)
            {
                return authorizationValidation;
            }

            // Step 4: Check business rules / الخطوة 4: التحقق من قواعد العمل
            var businessRulesValidation = await ValidateBusinessRulesAsync(request, unitTypeId, cancellationToken);
            if (!businessRulesValidation.Success)
            {
                return businessRulesValidation;
            }

            // Step 5: Create the group / الخطوة 5: إنشاء المجموعة
            var fieldGroup = new FieldGroup
            {
                Id = Guid.NewGuid(),
                UnitTypeId = unitTypeId,
                GroupName = request.GroupName,
                DisplayName = request.DisplayName,
                Description = request.Description,
                SortOrder = request.SortOrder,
                IsCollapsible = request.IsCollapsible,
                IsExpandedByDefault = request.IsExpandedByDefault,
                CreatedAt = DateTime.UtcNow,
                CreatedBy = _currentUserService.UserId,
                IsDeleted = false
            };

            var createdFieldGroup = await _fieldGroupRepository.CreateFieldGroupAsync(fieldGroup, cancellationToken);

            // Step 6: Persist the initial group creation / الخطوة 6: حفظ إنشاء المجموعة الأولي
            await _fieldGroupRepository.SaveChangesAsync(cancellationToken);

            // Step 7: Reorder other groups when needed / الخطوة 7: إعادة ترتيب المجموعات الأخرى عند الحاجة
            await ReorderExistingGroupsIfNeededAsync(unitTypeId, request.SortOrder, cancellationToken);

            // Step 8: Write audit entry / الخطوة 8: تسجيل العملية في سجل التدقيق
            await _auditService.LogActivityAsync(
                "FieldGroup",
                createdFieldGroup.Id.ToString(),
                "Create",
                $"تم إنشاء مجموعة حقول جديدة: {createdFieldGroup.GroupName}",
                null,
                createdFieldGroup,
                cancellationToken);

            _logger.LogInformation("تم إنشاء مجموعة الحقول بنجاح: {FieldGroupId}", createdFieldGroup.Id);

            return ResultDto<string>.Ok(
                createdFieldGroup.Id.ToString(),
                "تم إنشاء مجموعة الحقول بنجاح"
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في إنشاء مجموعة الحقول: {GroupName}", request.GroupName);
            return ResultDto<string>.Failure("حدث خطأ أثناء إنشاء مجموعة الحقول");
        }
    }

    private async Task<ResultDto<string>> ValidateInputAsync(CreateFieldGroupCommand request, CancellationToken cancellationToken)
    {
        var validationResult = await _validationService.ValidateAsync(request, cancellationToken);
        if (!validationResult.IsValid)
        {
            var errors = string.Join(", ", validationResult.Errors.Select(e => e.Message));
            _logger.LogWarning("بيانات غير صحيحة لإنشاء مجموعة الحقول: {Errors}", errors);
            return ResultDto<string>.Failure($"بيانات غير صحيحة: {errors}");
        }

        // Validate unit type ID / التحقق من معرف نوع الوحدة
        if (!Guid.TryParse(request.unitTypeId, out _))
        {
            _logger.LogWarning("معرف نوع الكيان غير صحيح: {PropertyTypeId}", request.unitTypeId);
            return ResultDto<string>.Failure("معرف نوع الكيان غير صحيح");
        }

        // Validate group name / التحقق من اسم المجموعة
        if (string.IsNullOrWhiteSpace(request.GroupName))
        {
            return ResultDto<string>.Failure("اسم المجموعة مطلوب");
        }

        if (request.GroupName.Length > 100)
        {
            return ResultDto<string>.Failure("اسم المجموعة لا يجب أن يتجاوز 100 حرف");
        }

        // Validate display name / التحقق من الاسم المعروض
        if (!string.IsNullOrWhiteSpace(request.DisplayName) && request.DisplayName.Length > 100)
        {
            return ResultDto<string>.Failure("الاسم المعروض لا يجب أن يتجاوز 100 حرف");
        }

        // Validate description / التحقق من الوصف
        if (!string.IsNullOrWhiteSpace(request.Description) && request.Description.Length > 500)
        {
            return ResultDto<string>.Failure("الوصف لا يجب أن يتجاوز 500 حرف");
        }

        // Validate sort order / التحقق من ترتيب الفرز
        if (request.SortOrder < 0)
        {
            return ResultDto<string>.Failure("ترتيب الفرز يجب أن يكون صفر أو أكبر");
        }

        return ResultDto<string>.Ok(string.Empty);
    }

    private Task<ResultDto<string>> ValidateAuthorizationAsync(CancellationToken cancellationToken)
    {
        if (_currentUserService.Role != "Admin")
        {
            _logger.LogWarning("المستخدم {UserId} لا يملك صلاحية إنشاء مجموعات الحقول", _currentUserService.UserId);
            return Task.FromResult(ResultDto<string>.Failure("غير مصرح لك بإنشاء مجموعات الحقول"));
        }

        return Task.FromResult(ResultDto<string>.Ok(string.Empty));
    }

    private async Task<ResultDto<string>> ValidateBusinessRulesAsync(CreateFieldGroupCommand request, Guid propertyTypeId, CancellationToken cancellationToken)
    {
        // Check for duplicate group names within the same unit type / التحقق من تكرار اسم المجموعة ضمن نفس نوع الوحدة
        var existingGroups = await _fieldGroupRepository.GetGroupsByUnitTypeIdAsync(propertyTypeId, cancellationToken);
        if (existingGroups.Any(g => g.GroupName.Equals(request.GroupName, StringComparison.OrdinalIgnoreCase)))
        {
            _logger.LogWarning("يوجد مجموعة حقول بنفس الاسم في نوع الكيان: {GroupName}", request.GroupName);
            return ResultDto<string>.Failure($"يوجد مجموعة حقول بالاسم '{request.GroupName}' مسبقاً في هذا النوع من الكيانات");
        }

        // Validate sort order collisions / التحقق من تعارض ترتيب الفرز
        var groupsWithSameSortOrder = existingGroups.Where(g => g.SortOrder == request.SortOrder).ToList();
        if (groupsWithSameSortOrder.Any())
        {
            _logger.LogInformation("يوجد مجموعات أخرى بنفس ترتيب الفرز، سيتم إعادة ترتيبها: {SortOrder}", request.SortOrder);
        }

        return ResultDto<string>.Ok(string.Empty);
    }

    private async Task ReorderExistingGroupsIfNeededAsync(Guid propertyTypeId, int newGroupSortOrder, CancellationToken cancellationToken)
    {
        var existingGroups = await _fieldGroupRepository.GetGroupsByUnitTypeIdAsync(propertyTypeId, cancellationToken);
        var groupsToUpdate = existingGroups
            .Where(g => g.SortOrder >= newGroupSortOrder)
            .OrderBy(g => g.SortOrder)
            .ToList();

        foreach (var group in groupsToUpdate)
        {
            group.SortOrder++;
            group.UpdatedAt = DateTime.UtcNow;
            group.UpdatedBy = _currentUserService.UserId;
            await _fieldGroupRepository.UpdateFieldGroupAsync(group, cancellationToken);
            await _fieldGroupRepository.SaveChangesAsync(cancellationToken);
        }

        if (groupsToUpdate.Any())
        {
            _logger.LogInformation("تم إعادة ترتيب {Count} مجموعة حقول", groupsToUpdate.Count);
        }
    }
}
