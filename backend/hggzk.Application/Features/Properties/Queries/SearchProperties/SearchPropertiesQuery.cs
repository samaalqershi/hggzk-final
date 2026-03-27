using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Enums;
using System;
using System.Collections.Generic;
using YemenBooking.Application.Features.SearchAndFilters.DTOs;

namespace YemenBooking.Application.Features.Properties.Queries.SearchProperties;

/// <summary>
/// يمثل استعلام بحث عقارات.
/// Represents the search query for properties.
/// </summary>
public class SearchPropertiesQuery : IRequest<ResultDto<SearchPropertiesResponse>>
{
    /// <summary>
    /// مصطلح البحث.
    /// search term.
    /// </summary>
    public string? SearchTerm { get; set; }
    /// <summary>
    /// المدينة.
    /// city.
    /// </summary>
    public string? City { get; set; }
    /// <summary>
    /// تاريخ الوصول.
    /// check-in date.
    /// </summary>
    public DateTime? CheckIn { get; set; }
    /// <summary>
    /// تاريخ المغادرة.
    /// check-out date.
    /// </summary>
    public DateTime? CheckOut { get; set; }
    /// <summary>
    /// عدد البالغين.
    /// adults.
    /// </summary>
    public int? Adults { get; set; }
    /// <summary>
    /// عدد الأطفال المشمولين في البحث.
    /// Number of children included in the search.
    /// </summary>
    public int? Children { get; set; }
    /// <summary>
    /// عدد الضيوف.
    /// guest count.
    /// </summary>
    public int? GuestsCount { get; set; }
    /// <summary>
    /// معرّف نوع العقار.
    /// property type identifier.
    /// </summary>
    public Guid? PropertyTypeId { get; set; }
    /// <summary>
    /// الحد الأدنى للسعر.
    /// minimum price.
    /// </summary>
    public decimal? MinPrice { get; set; }
    /// <summary>
    /// الحد الأقصى للسعر.
    /// maximum price.
    /// </summary>
    public decimal? MaxPrice { get; set; }
    /// <summary>
    /// الحد الأدنى للتقييم بالنجوم.
    /// Minimum star rating.
    /// </summary>
    public int? MinStarRating { get; set; }
    
    /// <summary>
    /// المزايا الإلزامية التي يجب أن تتوفر في العقار.
    /// Required amenities that must be available in the property.
    /// </summary>
    public List<Guid> RequiredAmenities { get; set; } = new();
    /// <summary>
    /// معرّف نوع الوحدة.
    /// unit type identifier.
    /// </summary>
    public Guid? UnitTypeId { get; set; }

    /// <summary>
    /// معرّفات الخدمات المطلوبة.
    /// Required service identifiers.
    /// </summary>
    public List<Guid> ServiceIds { get; set; } = new();
   
    /// <summary>
    /// مرشحات الحقول الديناميكية.
    /// Dynamic field filters.
    /// </summary>
    public Dictionary<string, string> DynamicFieldFilters { get; set; } = new();
    /// <summary>
    /// خط العرض.
    /// latitude.
    /// </summary>
    public decimal? Latitude { get; set; }
    /// <summary>
    /// خط الطول.
    /// longitude.
    /// </summary>
    public decimal? Longitude { get; set; }
    /// <summary>
    /// نصف القطر بالكيلومترات.
    /// radius in kilometers.
    /// </summary>
    public double? RadiusKm { get; set; }
    /// <summary>
    /// الفرز حسب.
    /// sort by.
    /// </summary>
    public string? SortBy { get; set; } // price_asc, price_desc, rating, distance
    /// <summary>
    /// رقم الصفحة.
    /// page number.
    /// </summary>
    public int PageNumber { get; set; } = 1;
    /// <summary>
    /// حجم الصفحة.
    /// page size.
    /// </summary>
    public int PageSize { get; set; } = 20;
    /// <summary>
    /// العملة المفضلة.
    /// preferred currency.
    /// </summary>
    public string? PreferredCurrency { get; set; }

    /// <summary>
    /// يحدد ما إذا كان الطلب يهدف إلى معاينة العدادات والفلاتر فقط.
    /// Indicates whether the request is for live facet preview only.
    /// </summary>
    public bool PreviewOnly { get; set; }
}
