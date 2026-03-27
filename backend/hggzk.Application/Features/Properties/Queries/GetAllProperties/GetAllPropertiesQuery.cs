using MediatR;
using YemenBooking.Application.Common.Models;
using System;
using System.Collections.Generic;
using YemenBooking.Application.Features.Properties.DTOs;

namespace YemenBooking.Application.Features.Properties.Queries.GetAllProperties;

/// <summary>
/// استعلام للحصول على جميع العقارات مع التصفية والصفحات.
/// Query for retrieving all properties with filtering and pagination.
/// </summary>
public class GetAllPropertiesQuery : IRequest<PaginatedResult<YemenBooking.Application.Features.Properties.DTOs.PropertyDto>>
{
    /// <summary>
    /// رقم الصفحة.
    /// page number.
    /// </summary>
    public int PageNumber { get; set; } = 1;
    /// <summary>
    /// حجم الصفحة.
    /// page size.
    /// </summary>
    public int PageSize { get; set; } = 10;
    /// <summary>
    /// مصطلح البحث.
    /// search term.
    /// </summary>
    public string? SearchTerm { get; set; }
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
    /// الفرز حسب.
    /// sort by.
    /// </summary>
    public string? SortBy { get; set; }
    /// <summary>
    /// تصاعدي.
    /// sorted in ascending order.
    /// </summary>
    public bool IsAscending { get; set; } = true;
    /// <summary>
    /// معرّفات المزايا.
    /// amenity identifiers.
    /// </summary>
    public IEnumerable<Guid>? AmenityIds { get; set; }
    /// <summary>
    /// تقييمات النجوم.
    /// star ratings.
    /// </summary>
    public int[]? StarRatings { get; set; }
    /// <summary>
    /// أدنى متوسط تقييم.
    /// minimum average rating.
    /// </summary>
    public double? MinAverageRating { get; set; }
    /// <summary>
    /// معتمد.
    /// approved.
    /// </summary>
    public bool? IsApproved { get; set; }
    /// <summary>
    /// وجود حجوزات نشطة.
    /// active bookings exist.
    /// </summary>
    public bool? HasActiveBookings { get; set; }
} 
