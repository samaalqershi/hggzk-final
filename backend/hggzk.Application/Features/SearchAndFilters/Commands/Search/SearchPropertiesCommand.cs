using System;
using System.Collections.Generic;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.SearchAndFilters.DTOs;

namespace YemenBooking.Application.Features.SearchAndFilters.Commands.Search;

/// <summary>
/// أمر البحث عن العقارات.
/// Search Properties command.
/// </summary>
public class SearchPropertiesCommand : IRequest<ResultDto<SearchPropertiesResponse>>
{
    /// <summary>
    /// القيمة الخاصة بـ المدينة.
    /// City value.
    /// </summary>
    public string? City { get; set; }

    /// <summary>
    /// تاريخ الوصول.
    /// Check-in date.
    /// </summary>
    public DateTime? CheckIn { get; set; }

    /// <summary>
    /// تاريخ المغادرة.
    /// Check-out date.
    /// </summary>
    public DateTime? CheckOut { get; set; }

    /// <summary>
    /// عدد الضيوف.
    /// Guest count.
    /// </summary>
    public int? GuestCount { get; set; }

    /// <summary>
    /// معرّف نوع العقار.
    /// Property type identifier.
    /// </summary>
    public Guid? PropertyTypeId { get; set; }

    /// <summary>
    /// رقم الصفحة.
    /// Page number.
    /// </summary>
    public int PageNumber { get; set; } = 1;

    /// <summary>
    /// حجم الصفحة.
    /// Page size.
    /// </summary>
    public int PageSize { get; set; } = 10;

    /// <summary>
    /// معيار الفرز.
    /// Sort by value.
    /// </summary>
    public string? SortBy { get; set; }

    /// <summary>
    /// اتجاه الفرز.
    /// Sort direction.
    /// </summary>
    public string SortDirection { get; set; } = "asc";

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
    /// معرّفات وسائل الراحة.
    /// Amenity identifiers.
    /// </summary>
    public List<Guid>? AmenityIds { get; set; }

    /// <summary>
    /// تقييمات النجوم.
    /// Star ratings.
    /// </summary>
    public List<int>? StarRatings { get; set; }

    /// <summary>
    /// الحد الأدنى لمتوسط التقييم.
    /// Minimum average rating.
    /// </summary>
    public decimal? MinAverageRating { get; set; }

    /// <summary>
    /// عبارة البحث.
    /// Search term.
    /// </summary>
    public string? SearchTerm { get; set; }

    /// <summary>
    /// خط العرض.
    /// Latitude.
    /// </summary>
    public double? Latitude { get; set; }

    /// <summary>
    /// خط الطول.
    /// Longitude.
    /// </summary>
    public double? Longitude { get; set; }

    /// <summary>
    /// نصف القطر بالكيلومترات.
    /// Radius in kilometers.
    /// </summary>
    public double? RadiusKm { get; set; }
}






