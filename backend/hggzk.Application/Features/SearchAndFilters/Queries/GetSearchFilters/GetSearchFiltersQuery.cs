using MediatR;
using System.Collections.Generic;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.SearchAndFilters;
using YemenBooking.Application.Features.SearchAndFilters.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.SearchAndFilters.Queries.GetSearchFilters;

/// <summary>
/// استعلام جلب البحث الفلاتر.
/// Get Search Filters query.
/// </summary>
public class GetSearchFiltersQuery : IRequest<ResultDto<SearchFiltersDto>>
{
    /// <summary>
    /// معرّف نوع العقار.
    /// Property type identifier.
    /// </summary>
    public Guid? PropertyTypeId { get; set; }
    
    /// <summary>
    /// الحد الأدنى للسعر.
    /// Minimum price.
    /// </summary>
    public decimal? MinPrice { get; set; }

    /// <summary>
    /// الحد الأقصى للسعر.
    /// Maximum price.
    /// </summary>
    public decimal? MaxPrice { get; set; }

    /// <summary>
    /// القيمة الخاصة بـ وسائل الراحة.
    /// Amenities value.
    /// </summary>
    public List<Guid> Amenities { get; set; } = new();

    /// <summary>
    /// معرّف نوع الوحدة.
    /// Unit type identifier.
    /// </summary>
    public Guid? UnitTypeId { get; set; }

    /// <summary>
    /// القيمة الخاصة بـ الديناميكي الحقل الفلاتر.
    /// Dynamic Field Filters value.
    /// </summary>
    public Dictionary<string, object> DynamicFieldFilters { get; set; } = new();

    /// <summary>
    /// معرّفات الخدمة.
    /// Service identifiers.
    /// </summary>
    public List<Guid> ServiceIds { get; set; } = new();
    
    /// <summary>
    /// القيمة الخاصة بـ المدينة.
    /// City value.
    /// </summary>
    public string? City { get; set; }
}


/// <summary>
/// استعلام جلب البحث الفلاتر.
/// Get Search Filters query.
/// </summary>
public class PropertyTypeFilterDto
{
    /// <summary>
    /// المعرف.
    /// Identifier.
    /// </summary>
    public Guid Id { get; set; }
    
    /// <summary>
    /// الاسم.
    /// Name.
    /// </summary>
    public string Name { get; set; } = string.Empty;
    
    /// <summary>
    /// القيمة الخاصة بـ العدد.
    /// Count value.
    /// </summary>
    public int Count { get; set; }
}

/// <summary>
/// استعلام جلب البحث الفلاتر.
/// Get Search Filters query.
/// </summary>
public class AmenityFilterDto
{
    /// <summary>
    /// المعرف.
    /// Identifier.
    /// </summary>
    public Guid Id { get; set; }
    
    /// <summary>
    /// الاسم.
    /// Name.
    /// </summary>
    public string Name { get; set; } = string.Empty;
    
    /// <summary>
    /// القيمة الخاصة بـ category.
    /// Category value.
    /// </summary>
    public string Category { get; set; } = string.Empty;
    
    /// <summary>
    /// القيمة الخاصة بـ العدد.
    /// Count value.
    /// </summary>
    public int Count { get; set; }
}