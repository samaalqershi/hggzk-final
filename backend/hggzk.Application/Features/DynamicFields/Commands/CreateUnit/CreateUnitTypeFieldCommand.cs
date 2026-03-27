namespace YemenBooking.Application.Features.DynamicFields.Commands.CreateUnit;

using MediatR;
using System.Collections.Generic;
using YemenBooking.Application.Common.Models;

/// <summary>
/// ينشئ حقلًا ديناميكيًا جديدًا لنوع الوحدة.
/// Creates a new dynamic field for a unit type.
/// </summary>
public class CreateUnitTypeFieldCommand : IRequest<ResultDto<string>>
{
    /// <summary>
    /// معرف نوع الوحدة المستهدف.
    /// Target unit type identifier.
    /// </summary>
    public required string UnitTypeId { get; set; }

    /// <summary>
    /// معرف نوع الحقل.
    /// Field type identifier.
    /// </summary>
    public required string FieldTypeId { get; set; }

    /// <summary>
    /// اسم الحقل الداخلي.
    /// Internal field name.
    /// </summary>
    public required string FieldName { get; set; }

    /// <summary>
    /// الاسم المعروض للحقل.
    /// Display name for the field.
    /// </summary>
    public required string DisplayName { get; set; }

    /// <summary>
    /// وصف الحقل.
    /// Field description.
    /// </summary>
    public string? Description { get; set; }

    /// <summary>
    /// خيارات الحقل بصيغة JSON.
    /// Field options serialized as JSON.
    /// </summary>
    public Dictionary<string, object>? FieldOptions { get; set; }

    /// <summary>
    /// قواعد التحقق المخصصة بصيغة JSON.
    /// Custom validation rules serialized as JSON.
    /// </summary>
    public Dictionary<string, object>? ValidationRules { get; set; }

    /// <summary>
    /// يحدد ما إذا كان الحقل إلزاميًا.
    /// Indicates whether the field is required.
    /// </summary>
    public bool IsRequired { get; set; }

    /// <summary>
    /// يحدد ما إذا كان الحقل قابلًا للبحث.
    /// Indicates whether the field is searchable.
    /// </summary>
    public bool IsSearchable { get; set; }

    /// <summary>
    /// يحدد ما إذا كان الحقل مرئيًا للعملاء.
    /// Indicates whether the field is public.
    /// </summary>
    public bool IsPublic { get; set; }

    /// <summary>
    /// ترتيب الحقل.
    /// Field display order.
    /// </summary>
    public int SortOrder { get; set; }

    /// <summary>
    /// فئة الحقل.
    /// Field category.
    /// </summary>
    public string? Category { get; set; }

    /// <summary>
    /// يحدد ما إذا كان الحقل مخصصًا للوحدات.
    /// Indicates whether the field is for units.
    /// </summary>
    public bool IsForUnits { get; set; }

    /// <summary>
    /// معرف مجموعة الحقول المرتبطة عند توفرها.
    /// Related field group identifier, when provided.
    /// </summary>
    public string? GroupId { get; set; }
    /// <summary>
    /// يحدد ما إذا كان الحقل يظهر في البطاقات.
    /// Indicates whether the field appears in cards.
    /// </summary>
    public bool ShowInCards { get; set; }

    /// <summary>
    /// يحدد ما إذا كان الحقل مرشحًا أساسيًا.
    /// Indicates whether the field is a primary filter.
    /// </summary>
    public bool IsPrimaryFilter { get; set; }

    /// <summary>
    /// أولوية الترتيب.
    /// Ordering priority.
    /// </summary>
    public int Priority { get; set; }
} 
