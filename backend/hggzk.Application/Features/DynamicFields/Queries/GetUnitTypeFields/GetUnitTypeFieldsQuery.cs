using YemenBooking.Application.Features;
namespace YemenBooking.Application.Features.DynamicFields.Queries.GetUnitTypeFields;
using YemenBooking.Application.Features.Units.DTOs;

using MediatR;
using System.Collections.Generic;
using YemenBooking.Application.Common.Models;

/// <summary>
/// يجلب الحقول الديناميكية لنوع وحدة محدد.
/// Retrieves dynamic fields for a specific unit type.
/// </summary>
public class GetUnitTypeFieldsQuery : IRequest<List<UnitTypeFieldDto>>
{
    /// <summary>
    /// معرف نوع الوحدة المستهدف.
    /// Target unit type identifier.
    /// </summary>
    public string unitTypeId { get; set; }

    /// <summary>
    /// يحدد التصفية حسب حالة التفعيل.
    /// Optional activation-state filter.
    /// </summary>
    public bool? IsActive { get; set; }

    /// <summary>
    /// يحدد التصفية حسب قابلية البحث.
    /// Optional searchable-only filter.
    /// </summary>
    public bool? IsSearchable { get; set; }

    /// <summary>
    /// يحدد التصفية حسب الإتاحة العامة.
    /// Optional public-only filter.
    /// </summary>
    public bool? IsPublic { get; set; }

    /// <summary>
    /// يحدد التصفية للحقول الخاصة بالوحدات.
    /// Optional filter for unit-specific fields.
    /// </summary>
    public bool? IsForUnits { get; set; }

    /// <summary>
    /// فئة الحقل المراد تصفيتها.
    /// Optional field category filter.
    /// </summary>
    public string? Category { get; set; }
    /// <summary>
    /// نص البحث المراد تطبيقه.
    /// Optional search term for fields.
    /// </summary>
    public string? SearchTerm { get; set; }
} 
