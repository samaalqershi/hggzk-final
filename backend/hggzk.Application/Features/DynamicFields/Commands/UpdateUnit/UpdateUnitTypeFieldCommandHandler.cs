using MediatR;
using Microsoft.Extensions.Logging;
using System;
using System.Linq;
using System.Text.Json;
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
using YemenBooking.Application.Features.SearchAndFilters.Services;
using Unit = MediatR.Unit;

namespace YemenBooking.Application.Features.DynamicFields.Commands.UpdateUnit;

/// <summary>
/// يعالج تحديث حقل ديناميكي لنوع الوحدة.
/// Handles updating a dynamic field for a unit type.
/// </summary>
public class UpdateUnitTypeFieldCommandHandler : IRequestHandler<UpdateUnitTypeFieldCommand, ResultDto<Unit>>
{
    private readonly IUnitTypeFieldRepository _unitTypeFieldRepository;
    private readonly IUnitTypeRepository _unitTypeRepository;
    private readonly IFieldGroupRepository _fieldGroupRepository;
    private readonly IUnitFieldValueRepository _unitFieldValueRepository;
    private readonly IFieldGroupFieldRepository _fieldGroupFieldRepository;
    private readonly ICurrentUserService _currentUserService;
    private readonly IValidationService _validationService;
    private readonly IAuditService _auditService;
    private readonly ILogger<UpdateUnitTypeFieldCommandHandler> _logger;
    private readonly IUnitIndexingService _indexingService;
    private readonly IUnitOfWork _unitOfWork;

    /// <summary>
    /// يُهيِّئ المعالج بالاعتمادات المطلوبة.
    /// Initializes the handler with the required dependencies.
    /// </summary>
    public UpdateUnitTypeFieldCommandHandler(
        IUnitTypeFieldRepository unitTypeFieldRepository,
        IUnitTypeRepository unitTypeRepository,
        IFieldGroupRepository fieldGroupRepository,
        IUnitFieldValueRepository unitFieldValueRepository,
        IFieldGroupFieldRepository fieldGroupFieldRepository,
        ICurrentUserService currentUserService,
        IValidationService validationService,
        IAuditService auditService,
        ILogger<UpdateUnitTypeFieldCommandHandler> logger,
        IUnitIndexingService indexingService,
        IUnitOfWork unitOfWork)
    {
        _unitTypeFieldRepository = unitTypeFieldRepository;
        _unitTypeRepository = unitTypeRepository;
        _fieldGroupRepository = fieldGroupRepository;
        _unitFieldValueRepository = unitFieldValueRepository;
        _fieldGroupFieldRepository = fieldGroupFieldRepository;
        _currentUserService = currentUserService;
        _validationService = validationService;
        _auditService = auditService;
        _logger = logger;
        _indexingService = indexingService;
        _unitOfWork = unitOfWork;
    }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة.
    /// Processes the update unit type field command and returns the result.
    /// </summary>
    public async Task<ResultDto<Unit>> Handle(UpdateUnitTypeFieldCommand request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء معالجة أمر تحديث الحقل الديناميكي: {FieldId}", request.FieldId);

            // Step 1: Validate input / الخطوة 1: التحقق من صحة المدخلات
            var inputValidationResult = ValidateInputAsync(request, cancellationToken);
            if (!inputValidationResult.Success)
            {
                return inputValidationResult;
            }

            // Step 2: Check field existence / الخطوة 2: التحقق من وجود الحقل
            var fieldId = Guid.Parse(request.FieldId);
            var existingField = await _unitTypeFieldRepository.GetUnitTypeFieldByIdAsync(fieldId, cancellationToken);
            if (existingField == null || existingField.IsDeleted)
            {
                _logger.LogWarning("الحقل الديناميكي غير موجود: {FieldId}", request.FieldId);
                return ResultDto<Unit>.Failure("الحقل الديناميكي غير موجود");
            }

            // Step 3: Check authorization / الخطوة 3: التحقق من الصلاحيات
            var authorizationValidation = ValidateAuthorizationAsync(cancellationToken);
            if (!authorizationValidation.Success)
            {
                return authorizationValidation;
            }

            // Step 4: Check business rules / الخطوة 4: التحقق من قواعد العمل
            var businessRulesValidation = await ValidateBusinessRulesAsync(request, existingField, cancellationToken);
            if (!businessRulesValidation.Success)
            {
                return businessRulesValidation;
            }

            // Step 5: Check impact on existing values / الخطوة 5: التحقق من تأثير التغييرات على القيم الحالية
            var existingValuesValidation = await ValidateExistingValuesAsync(request, existingField, cancellationToken);
            if (!existingValuesValidation.Success)
            {
                return existingValuesValidation;
            }

            // Step 6: Capture original values for audit / الخطوة 6: حفظ القيم الأصلية للمراجعة
            var originalFieldName = existingField.FieldName;
            var originalFieldType = existingField.FieldTypeId;
            var originalValues = new
            {
                existingField.FieldName,
                existingField.DisplayName,
                existingField.Description,
                existingField.FieldOptions,
                existingField.ValidationRules,
                existingField.IsRequired,
                existingField.IsSearchable,
                existingField.IsPublic,
                existingField.SortOrder,
                existingField.Category
            };
            
            // Determine whether reindexing is needed / تحديد ما إذا كانت إعادة الفهرسة مطلوبة
            var needsReindexing = false;
            var fieldNameChanged = !string.Equals(existingField.FieldName, request.FieldName, StringComparison.Ordinal);
            var fieldTypeChanged = !string.IsNullOrWhiteSpace(request.FieldTypeId) && 
                                   !string.Equals(existingField.FieldTypeId, request.FieldTypeId, StringComparison.OrdinalIgnoreCase);
            
            if (fieldNameChanged || fieldTypeChanged)
            {
                needsReindexing = true;
            }

            UnitTypeField? updatedField = null;
            await _unitOfWork.ExecuteInTransactionAsync(async () =>
            {
                // Step 7: Update the field / الخطوة 7: تحديث الحقل الديناميكي
                existingField.FieldName = request.FieldName;
                existingField.DisplayName = request.DisplayName;
                existingField.Description = request.Description;
                existingField.FieldOptions = JsonHelper.SafeSerializeDictionary(request.FieldOptions);
                existingField.ValidationRules = JsonHelper.SafeSerializeDictionary(request.ValidationRules);
                existingField.IsRequired = request.IsRequired;
                existingField.IsSearchable = request.IsSearchable;
                existingField.IsPublic = request.IsPublic;
                existingField.SortOrder = request.SortOrder;
                existingField.Category = request.Category;
                existingField.IsForUnits = request.IsForUnits;
                existingField.ShowInCards = request.ShowInCards ?? existingField.ShowInCards;
                existingField.IsPrimaryFilter = request.IsPrimaryFilter ?? existingField.IsPrimaryFilter;
                existingField.Priority = request.Priority ?? existingField.Priority;
                if (!string.IsNullOrWhiteSpace(request.FieldTypeId) && !string.Equals(existingField.FieldTypeId, request.FieldTypeId, StringComparison.OrdinalIgnoreCase))
                {
                    existingField.FieldTypeId = request.FieldTypeId!;
                }
                existingField.UpdatedAt = DateTime.UtcNow;

                updatedField = await _unitTypeFieldRepository.UpdateUnitTypeFieldAsync(existingField, cancellationToken);

                // Update group assignment if provided / تحديث ربط المجموعة إذا تم تمريره
                if (!string.IsNullOrWhiteSpace(request.GroupId))
                {
                    var updatedFieldId = updatedField.Id;
                    var existingLinks = await _fieldGroupFieldRepository.GetGroupsByFieldIdAsync(updatedFieldId, cancellationToken);
                    foreach (var link in existingLinks)
                    {
                        await _fieldGroupFieldRepository.RemoveFieldFromGroupAsync(updatedFieldId, link.GroupId, cancellationToken);
                    }

                    var newLink = new FieldGroupField
                    {
                        FieldId = updatedFieldId,
                        GroupId = Guid.Parse(request.GroupId),
                        SortOrder = updatedField.SortOrder
                    };
                    await _fieldGroupFieldRepository.AssignFieldToGroupAsync(newLink, cancellationToken);
                }

                await _unitTypeFieldRepository.SaveChangesAsync(cancellationToken);
            }, cancellationToken);

            // Step 8: Revalidate existing values if needed / الخطوة 8: إعادة التحقق من القيم الحالية عند الحاجة
            await RevalidateExistingValuesAsync(updatedField!, cancellationToken);

            // Rebuild Redis indexes if the name or type changed / إعادة بناء فهارس Redis إذا تغير الاسم أو النوع
            if (needsReindexing)
            {
                var indexingSuccess = false;
                var indexingAttempts = 0;
                const int maxIndexingAttempts = 3;
                
                while (!indexingSuccess && indexingAttempts < maxIndexingAttempts)
                {
                    try
                    {
                        indexingAttempts++;
                        await _indexingService.OnUnitTypeFieldUpdatedAsync(
                            originalFieldName,
                            updatedField.FieldName,
                            updatedField.FieldTypeId,
                            updatedField.IsPrimaryFilter,
                            updatedField.UnitTypeId,
                            cancellationToken);
                        
                        indexingSuccess = true;
                        _logger.LogInformation(
                            "✅ تمت إعادة فهرسة الحقل {OldName} → {NewName} (نوع: {NewType}) بنجاح (محاولة {Attempt}/{Max})",
                            originalFieldName,
                            updatedField.FieldName,
                            updatedField.FieldTypeId,
                            indexingAttempts,
                            maxIndexingAttempts);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "⚠️ فشلت محاولة {Attempt}/{Max} لإعادة فهرسة الحقل {FieldName}", 
                            indexingAttempts, maxIndexingAttempts, updatedField.FieldName);
                        
                        if (indexingAttempts < maxIndexingAttempts)
                        {
                            await Task.Delay(TimeSpan.FromSeconds(Math.Pow(2, indexingAttempts - 1)), cancellationToken);
                        }
                        else
                        {
                            _logger.LogCritical("❌ CRITICAL: فشل إعادة فهرسة الحقل بعد {Attempts} محاولات للحقل {FieldName}. " +
                                "التغييرات محفوظة في DB لكن الفهرس غير محدث! يجب تشغيل re-index يدوي.", 
                                maxIndexingAttempts, updatedField.FieldName);
                        }
                    }
                }
            }

            // Step 9: Write audit entry / الخطوة 9: تسجيل العملية في سجل التدقيق
            await _auditService.LogAuditAsync(
                entityType: "UnitTypeField",
                entityId: updatedField.Id,
                action: AuditAction.UPDATE,
                oldValues: JsonSerializer.Serialize(originalValues),
                newValues: JsonSerializer.Serialize(new {
                    updatedField.FieldName,
                    updatedField.DisplayName,
                    updatedField.Description,
                    updatedField.FieldOptions,
                    updatedField.ValidationRules,
                    updatedField.IsRequired,
                    updatedField.IsSearchable,
                    updatedField.IsPublic,
                    updatedField.SortOrder,
                    updatedField.Category
                }),
                performedBy: _currentUserService.UserId,
                notes: $"تم تحديث الحقل الديناميكي: {updatedField.FieldName} لنوع الوحدة: {updatedField.UnitTypeId} بواسطة {_currentUserService.Username} (ID={_currentUserService.UserId})",
                cancellationToken: cancellationToken);

            _logger.LogInformation("تم تحديث الحقل الديناميكي بنجاح: {FieldId}", updatedField.Id);

            return ResultDto<Unit>.Ok(
                Unit.Value,
                "تم تحديث الحقل الديناميكي بنجاح"
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في تحديث الحقل الديناميكي: {FieldId}", request.FieldId);
            return ResultDto<Unit>.Failure("حدث خطأ أثناء تحديث الحقل الديناميكي");
        }
    }

    private ResultDto<Unit> ValidateInputAsync(UpdateUnitTypeFieldCommand request, CancellationToken cancellationToken)
    {
        var validationErrors = new List<string>();

        // Validate field ID / التحقق من معرف الحقل
        if (string.IsNullOrWhiteSpace(request.FieldId))
        {
            validationErrors.Add("معرف الحقل مطلوب");
        }
        else if (!Guid.TryParse(request.FieldId, out _))
        {
            validationErrors.Add("معرف الحقل غير صحيح");
        }

        // Validate field name / التحقق من اسم الحقل
        if (string.IsNullOrWhiteSpace(request.FieldName))
        {
            validationErrors.Add("اسم الحقل مطلوب");
        }
        else if (request.FieldName.Length > 100)
        {
            validationErrors.Add("اسم الحقل يجب أن يكون أقل من 100 حرف");
        }

        // Validate display name / التحقق من الاسم المعروض
        if (string.IsNullOrWhiteSpace(request.DisplayName))
        {
            validationErrors.Add("الاسم المعروض مطلوب");
        }
        else if (request.DisplayName.Length > 100)
        {
            validationErrors.Add("الاسم المعروض يجب أن يكون أقل من 100 حرف");
        }

        // Validate description when provided / التحقق من الوصف عند توفره
        if (!string.IsNullOrWhiteSpace(request.Description) && request.Description.Length > 500)
        {
            validationErrors.Add("الوصف يجب أن يكون أقل من 500 حرف");
        }

        // Validate category when provided / التحقق من الفئة عند توفرها
        if (!string.IsNullOrWhiteSpace(request.Category) && request.Category.Length > 50)
        {
            validationErrors.Add("الفئة يجب أن تكون أقل من 50 حرف");
        }

        // Validate sort order / التحقق من ترتيب العرض
        if (request.SortOrder < 0)
        {
            validationErrors.Add("ترتيب العرض يجب أن يكون رقم موجب");
        }

        if (validationErrors.Any())
        {
            var errorMessage = string.Join(", ", validationErrors);
            _logger.LogWarning("فشل التحقق من البيانات المدخلة: {Errors}", errorMessage);
            return ResultDto<Unit>.Failure($"خطأ في البيانات المدخلة: {errorMessage}");
        }

        return ResultDto<Unit>.Ok(Unit.Value);
    }

    private ResultDto<Unit> ValidateAuthorizationAsync(CancellationToken cancellationToken)
    {
        if (_currentUserService.Role != "Admin")
        {
            _logger.LogWarning("محاولة تحديث حقل ديناميكي من مستخدم غير مسؤول: {UserId}", _currentUserService.UserId);
            return ResultDto<Unit>.Failure("ليس لديك صلاحية لتحديث الحقول الديناميكية");
        }

        return ResultDto<Unit>.Ok(Unit.Value);
    }

    private async Task<ResultDto<Unit>> ValidateBusinessRulesAsync(UpdateUnitTypeFieldCommand request, UnitTypeField existingField, CancellationToken cancellationToken)
    {
        // Check for duplicates if the field name changed / التحقق من التكرار إذا تغير اسم الحقل
        if (!existingField.FieldName.Equals(request.FieldName, StringComparison.OrdinalIgnoreCase))
        {
            var allFields = await _unitTypeFieldRepository.GetFieldsByUnitTypeIdAsync(existingField.UnitTypeId, cancellationToken);
            if (allFields.Any(f => f.Id != existingField.Id && 
                                  f.FieldName.Equals(request.FieldName, StringComparison.OrdinalIgnoreCase) && 
                                  !f.IsDeleted))
            {
                _logger.LogWarning("يوجد حقل آخر بنفس الاسم في نوع الوحدة: {FieldName}", request.FieldName);
                return ResultDto<Unit>.Failure($"يوجد حقل آخر بالاسم '{request.FieldName}' في نفس نوع الوحدة");
            }
        }

        // Validate field options for select-like fields / التحقق من خيارات الحقل لحقول select

        // Validate category value / التحقق من قيمة الفئة
        if (!string.IsNullOrWhiteSpace(request.Category))
        {
            var validCategories = new[] { "basic", "details", "features", "location", "contact", "custom" };
            if (!validCategories.Contains(request.Category.ToLower()))
            {
                _logger.LogWarning("فئة غير صحيحة: {Category}", request.Category);
                return ResultDto<Unit>.Failure($"الفئة '{request.Category}' غير مدعومة");
            }
        }

        return ResultDto<Unit>.Ok(Unit.Value);
    }

    private async Task<ResultDto<Unit>> ValidateExistingValuesAsync(UpdateUnitTypeFieldCommand request, UnitTypeField existingField, CancellationToken cancellationToken)
    {
        // If the field becomes required, ensure there are no empty values / إذا تغير الحقل من اختياري إلى إلزامي، التحقق من عدم وجود قيم فارغة
        if (!existingField.IsRequired && request.IsRequired)
        {
            var unitValues = await _unitFieldValueRepository.GetByFieldIdAsync(existingField.Id, cancellationToken);

            var emptyUnitValues = unitValues.Where(pv => string.IsNullOrWhiteSpace(pv.FieldValue)).Count();

            if (emptyUnitValues > 0 || emptyUnitValues > 0)
            {
                _logger.LogWarning("لا يمكن جعل الحقل إلزامي لوجود قيم فارغة - وحدةات: {UnitCount}, وحدات: {UnitCount}", 
                    emptyUnitValues, emptyUnitValues);
                return ResultDto<Unit>.Failure($"لا يمكن جعل الحقل إلزامي لوجود {emptyUnitValues + emptyUnitValues} قيمة فارغة");
            }
        }

        // Validate new options against existing values for select fields / التحقق من توافق الخيارات الجديدة مع القيم الحالية لحقول select

        return ResultDto<Unit>.Ok(Unit.Value);
    }

    private Task RevalidateExistingValuesAsync(UnitTypeField updatedField, CancellationToken cancellationToken)
    {
        try
        {
            // Revalidation hooks can be added here / يمكن إضافة منطق إعادة التحقق هنا
            // For example, refreshing search indexes or reprocessing values / مثل تحديث الفهارس أو إعادة معالجة القيم
            
            _logger.LogInformation("تم إعادة تقييم القيم الموجودة للحقل: {FieldId}", updatedField.Id);
            return Task.CompletedTask;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ في إعادة تقييم القيم الموجودة للحقل: {FieldId}", updatedField.Id);
            // Do not throw here because the main update already succeeded / لا نرمي استثناءً هنا لأن العملية الأساسية نجحت
            return Task.CompletedTask;
        }
    }
}
