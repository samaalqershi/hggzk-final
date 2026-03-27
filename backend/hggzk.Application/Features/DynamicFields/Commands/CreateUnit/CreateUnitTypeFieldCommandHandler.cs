using MediatR;
using Microsoft.Extensions.Logging;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using YemenBooking.Application.Features.DynamicFields;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Entities;
using YemenBooking.Application.Features.AuditLog.Services;
using YemenBooking.Core.Helpers;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Interfaces;
using YemenBooking.Application.Common.Interfaces;

namespace YemenBooking.Application.Features.DynamicFields.Commands.CreateUnit;

/// <summary>
/// ينشئ حقلًا ديناميكيًا جديدًا لنوع الوحدة.
/// Creates a new dynamic field for a unit type.
/// </summary>
public class CreateUnitTypeFieldCommandHandler : IRequestHandler<CreateUnitTypeFieldCommand, ResultDto<string>>
{
    private readonly IUnitTypeFieldRepository _unitTypeFieldRepository;
    private readonly IUnitTypeRepository _unitTypeRepository;
    private readonly IFieldGroupRepository _fieldGroupRepository;
    private readonly IFieldGroupFieldRepository _fieldGroupFieldRepository;
    private readonly ICurrentUserService _currentUserService;
    private readonly IValidationService _validationService;
    private readonly IAuditService _auditService;
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<CreateUnitTypeFieldCommandHandler> _logger;

    /// <summary>
    /// يُهيِّئ المعالج بالاعتمادات المطلوبة.
    /// Initializes the handler with the required dependencies.
    /// </summary>
    public CreateUnitTypeFieldCommandHandler(
        IUnitTypeFieldRepository unitTypeFieldRepository,
        IUnitTypeRepository unitTypeRepository,
        IFieldGroupRepository fieldGroupRepository,
        IFieldGroupFieldRepository fieldGroupFieldRepository,
        ICurrentUserService currentUserService,
        IValidationService validationService,
        IAuditService auditService,
        IUnitOfWork unitOfWork,
        ILogger<CreateUnitTypeFieldCommandHandler> logger)
    {
        _unitTypeFieldRepository = unitTypeFieldRepository;
        _unitTypeRepository = unitTypeRepository;
        _fieldGroupRepository = fieldGroupRepository;
        _fieldGroupFieldRepository = fieldGroupFieldRepository;
        _currentUserService = currentUserService;
        _validationService = validationService;
        _auditService = auditService;
        _unitOfWork = unitOfWork;
        _logger = logger;
    }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة.
    /// Processes the create unit type field command and returns the result.
    /// </summary>
    public async Task<ResultDto<string>> Handle(CreateUnitTypeFieldCommand request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء معالجة أمر إنشاء حقل نوع الوحدة: {FieldName} لنوع الوحدة: {UnitTypeId}", 
                request.FieldName, request.UnitTypeId);

            // Step 1: Validate input / الخطوة 1: التحقق من صحة المدخلات
            var inputValidationResult = await ValidateInputAsync(request, cancellationToken);
            if (!inputValidationResult.Success)
            {
                return inputValidationResult;
            }

            // Step 2: Check required entities / الخطوة 2: التحقق من الكيانات المطلوبة
            var entityValidationResult = await ValidateEntitiesExistenceAsync(request, cancellationToken);
            if (!entityValidationResult.Success)
            {
                return entityValidationResult;
            }

            // Step 3: Check authorization / الخطوة 3: التحقق من الصلاحيات
            var authorizationValidation = await ValidateAuthorizationAsync(cancellationToken);
            if (!authorizationValidation.Success)
            {
                return authorizationValidation;
            }

            // Step 4: Check business rules / الخطوة 4: التحقق من قواعد العمل
            var businessRulesValidation = await ValidateBusinessRulesAsync(request, cancellationToken);
            if (!businessRulesValidation.Success)
            {
                return businessRulesValidation;
            }

            UnitTypeField? createdField = null;
            await _unitOfWork.ExecuteInTransactionAsync(async () =>
            {
                // Step 5: Create the field / الخطوة 5: إنشاء الحقل
                var unitTypeField = new UnitTypeField
                {
                    Id = Guid.NewGuid(),
                    UnitTypeId = Guid.Parse(request.UnitTypeId),
                    FieldTypeId = request.FieldTypeId,
                    FieldName = request.FieldName,
                    DisplayName = request.DisplayName,
                    Description = request.Description ?? string.Empty,
                    FieldOptions = JsonHelper.SafeSerializeDictionary(request.FieldOptions),
                    ValidationRules = JsonHelper.SafeSerializeDictionary(request.ValidationRules),
                    IsRequired = request.IsRequired,
                    IsSearchable = request.IsSearchable,
                    IsPublic = request.IsPublic,
                    SortOrder = request.SortOrder,
                    Category = request.Category ?? string.Empty,
                    IsForUnits = request.IsForUnits,
                    ShowInCards = request.ShowInCards,
                    IsPrimaryFilter = request.IsPrimaryFilter,
                    Priority = request.Priority,
                    CreatedAt = DateTime.UtcNow,
                    CreatedBy = _currentUserService.UserId,
                    IsDeleted = false
                };

                createdField = await _unitTypeFieldRepository.CreateUnitTypeFieldAsync(unitTypeField, cancellationToken);

                // Step 6: Assign the field to a group when provided / الخطوة 6: ربط الحقل بمجموعة عند توفرها
                if (!string.IsNullOrWhiteSpace(request.GroupId))
                {
                    await AssignFieldToGroupAsync(createdField.Id, Guid.Parse(request.GroupId), cancellationToken);
                }

                // Step 7: Persist all pending data changes / الخطوة 7: حفظ جميع التغييرات المعلقة
                await _unitTypeFieldRepository.SaveChangesAsync(cancellationToken);
            }, cancellationToken);

            // Step 8: Write audit entry / الخطوة 8: تسجيل العملية في سجل التدقيق
            await _auditService.LogAuditAsync(
                entityType: "UnitTypeField",
                entityId: createdField!.Id,
                action: AuditAction.CREATE,
                oldValues: null,
                newValues: System.Text.Json.JsonSerializer.Serialize(new {
                    createdField!.Id,
                    createdField!.UnitTypeId,
                    createdField!.FieldTypeId,
                    createdField!.FieldName,
                    createdField!.DisplayName,
                    createdField!.IsRequired,
                    createdField!.IsSearchable,
                    createdField!.IsPublic,
                    createdField!.SortOrder,
                    createdField!.Category
                }),
                performedBy: _currentUserService.UserId,
                notes: $"تم إنشاء حقل جديد: {createdField!.FieldName} لنوع الوحدة: {createdField!.UnitTypeId} بواسطة {_currentUserService.Username} (ID={_currentUserService.UserId})",
                cancellationToken: cancellationToken);

            _logger.LogInformation("تم إنشاء حقل نوع الوحدة بنجاح: {FieldId}", createdField!.Id);

            return ResultDto<string>.Ok(
                createdField!.Id.ToString(),
                "تم إنشاء الحقل بنجاح"
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في إنشاء حقل نوع الوحدة: {FieldName}", request.FieldName);
            return ResultDto<string>.Failure("حدث خطأ أثناء إنشاء الحقل");
        }
    }

    private async Task<ResultDto<string>> ValidateInputAsync(CreateUnitTypeFieldCommand request, CancellationToken cancellationToken)
    {
        var validationResult = await _validationService.ValidateAsync(request, cancellationToken);
        if (!validationResult.IsValid)
        {
            var errors = string.Join(", ", validationResult.Errors.Select(e => e.Message));
            _logger.LogWarning("بيانات غير صحيحة لإنشاء حقل نوع الوحدة: {Errors}", errors);
            return ResultDto<string>.Failure($"بيانات غير صحيحة: {errors}");
        }

        // Validate identifiers / التحقق من المعرفات
        if (!Guid.TryParse(request.UnitTypeId, out _))
        {
            return ResultDto<string>.Failure("معرف نوع الوحدة غير صحيح");
        }

        if (string.IsNullOrWhiteSpace(request.FieldTypeId))
        {
            return ResultDto<string>.Failure("معرف نوع الحقل غير صحيح");
        }

        if (!string.IsNullOrWhiteSpace(request.GroupId) && !Guid.TryParse(request.GroupId, out _))
        {
            return ResultDto<string>.Failure("معرف المجموعة غير صحيح");
        }

        // Validate field name / التحقق من اسم الحقل
        if (string.IsNullOrWhiteSpace(request.FieldName))
        {
            return ResultDto<string>.Failure("اسم الحقل مطلوب");
        }

        if (request.FieldName.Length > 100)
        {
            return ResultDto<string>.Failure("اسم الحقل لا يجب أن يتجاوز 100 حرف");
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

    private async Task<ResultDto<string>> ValidateEntitiesExistenceAsync(CreateUnitTypeFieldCommand request, CancellationToken cancellationToken)
    {
        // Check unit type existence / التحقق من وجود نوع الوحدة
        var unitTypeId = Guid.Parse(request.UnitTypeId);
        var unitType = await _unitTypeRepository.GetByIdAsync(unitTypeId, cancellationToken);
        if (unitType == null)
        {
            _logger.LogWarning("نوع الوحدة غير موجود: {UnitTypeId}", request.UnitTypeId);
            return ResultDto<string>.Failure("نوع الوحدة غير موجود");
        }

        // Check the group when specified / التحقق من المجموعة إذا تم تحديدها
        if (!string.IsNullOrWhiteSpace(request.GroupId))
        {
            var groupId = Guid.Parse(request.GroupId);
            var fieldGroup = await _fieldGroupRepository.GetFieldGroupByIdAsync(groupId, cancellationToken);
            if (fieldGroup == null)
            {
                _logger.LogWarning("مجموعة الحقول غير موجودة: {GroupId}", request.GroupId);
                return ResultDto<string>.Failure("مجموعة الحقول غير موجودة");
            }

            // Ensure the group belongs to the same unit type / التأكد من أن المجموعة تتبع نفس نوع الوحدة
            if (fieldGroup.UnitTypeId != unitTypeId)
            {
                _logger.LogWarning("مجموعة الحقول لا تنتمي لنفس نوع الوحدة: {GroupId}", request.GroupId);
                return ResultDto<string>.Failure("مجموعة الحقول لا تنتمي لنفس نوع الوحدة");
            }
        }

        return ResultDto<string>.Ok(string.Empty);
    }

    private Task<ResultDto<string>> ValidateAuthorizationAsync(CancellationToken cancellationToken)
    {
        if (_currentUserService.Role != "Admin" )
        {
            _logger.LogWarning("المستخدم {UserId} لا يملك صلاحية إنشاء حقول نوع الوحدة", _currentUserService.UserId);
            return Task.FromResult(ResultDto<string>.Failure("غير مصرح لك بإنشاء حقول نوع الوحدة"));
        }

        return Task.FromResult(ResultDto<string>.Ok(string.Empty));
    }

    private async Task<ResultDto<string>> ValidateBusinessRulesAsync(CreateUnitTypeFieldCommand request, CancellationToken cancellationToken)
    {
        var unitTypeId = Guid.Parse(request.UnitTypeId);

        // Check for duplicate field names within the same unit type / التحقق من تكرار اسم الحقل ضمن نفس نوع الوحدة
        var existingFields = await _unitTypeFieldRepository.GetFieldsByUnitTypeIdAsync(unitTypeId, cancellationToken);
        if (existingFields.Any(f => f.FieldName.Equals(request.FieldName, StringComparison.OrdinalIgnoreCase)))
        {
            _logger.LogWarning("يوجد حقل بنفس الاسم في نوع الوحدة: {FieldName}", request.FieldName);
            return ResultDto<string>.Failure($"يوجد حقل بالاسم '{request.FieldName}' مسبقاً في هذا النوع من الوحدةات");
        }

        // Validate category / التحقق من الفئة
        if (!string.IsNullOrWhiteSpace(request.Category))
        {
            // Category validation is intentionally relaxed here. / التحقق من الفئة هنا متساهل عمدًا.
        }

        return ResultDto<string>.Ok(string.Empty);
    }

    private async Task AssignFieldToGroupAsync(Guid fieldId, Guid groupId, CancellationToken cancellationToken)
    {
        try
        {
            var fieldGroupField = new FieldGroupField
            {
                FieldId = fieldId,
                GroupId = groupId,
                SortOrder = 0, // Will be adjusted later if needed / سيتم ضبطه لاحقًا عند الحاجة
                CreatedAt = DateTime.UtcNow,
                CreatedBy = _currentUserService.UserId,
                IsDeleted = false
            };

            await _fieldGroupFieldRepository.AssignFieldToGroupAsync(fieldGroupField, cancellationToken);
            _logger.LogInformation("تم إضافة الحقل {FieldId} للمجموعة {GroupId}", fieldId, groupId);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في إضافة الحقل للمجموعة: {FieldId} -> {GroupId}", fieldId, groupId);
            // Keep creation flow intact / لا نوقف عملية الإنشاء
        }
    }
}
