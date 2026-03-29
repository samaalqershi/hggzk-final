using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Enums;
using YemenBooking.Application.Features.DynamicFields.DTOs;

namespace YemenBooking.Application.Features.Units.Commands.UpdateUnit;

/// <summary>
/// أمر تحديث الوحدة.
/// Update Unit command.
/// </summary>
public class UpdateUnitCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف الوحدة.
    /// Unit identifier.
    /// </summary>
    public Guid UnitId { get; set; }

    /// <summary>
    /// الاسم.
    /// Name.
    /// </summary>
    public string? Name { get; set; }
    /// <summary>
    /// الاسم بالإنجليزية.
    /// Name in English.
    /// </summary>
    public string? NameEn { get; set; }

    /// <summary>
    /// الميزات المخصصة.
    /// Custom features.
    /// </summary>
    public string? CustomFeatures { get; set; }
    /// <summary>
    /// الميزات المخصصة بالإنجليزية.
    /// Custom features in English.
    /// </summary>
    public string? CustomFeaturesEn { get; set; }

    /// <summary>
    /// طريقة التسعير.
    /// Pricing strategy.
    /// </summary>
    public PricingMethod? PricingMethod { get; set; }

    /// <summary>
    /// سعة البالغين.
    /// Adult capacity.
    /// </summary>
    public int? AdultCapacity { get; set; }

    /// <summary>
    /// سعة الأطفال.
    /// Children capacity.
    /// </summary>
    public int? ChildrenCapacity { get; set; }
    
    /// <summary>
    /// قيم الحقول.
    /// Field values.
    /// </summary>
    public List<FieldValueDto> FieldValues { get; set; } = new List<FieldValueDto>();

    /// <summary>
    /// الصور المرتبطة.
    /// Related images.
    /// </summary>
    public List<string> Images { get; set; } = new List<string>();

    /// <summary>
    /// يشير إلى ما إذا كان يسمح بالإلغاء.
    /// Indicates whether cancellation is allowed.
    /// </summary>
    public bool? AllowsCancellation { get; set; }

    /// <summary>
    /// مدة نافذة الإلغاء بالأيام.
    /// Cancellation window in days.
    /// </summary>
    public int? CancellationWindowDays { get; set; }
} 
